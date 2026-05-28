package com.example.gardians

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.app.NotificationChannel
import android.app.NotificationManager
import android.provider.ContactsContract
import android.content.Intent
import android.os.Build
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.database.ValueEventListener
//mmmmmm
class MainActivity : FlutterActivity() {
    private val appsChannelName = "com.kidsafe/apps"
    private val callSmsChannelName = "guardian/calls_sms"
    private val geoChannelName = "guardian/geofence"

    private val mainForegroundService = "com.example.gardians.services.CallSmsForegroundService"
    private val geoFencingService = "com.example.gardians.services.GeoFencingForegroundService"
    private val channelId = "com.example.gardians.utils.CHANNEL_ID"
    private val usersRoot = "users"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ensureLegacyNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appsChannelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getInstalledApps") {
                    result.success(getInstalledApps())
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, callSmsChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startMonitoring" -> {
                        startMainForegroundService()
                        result.success(true)
                    }
                    "stopMonitoring" -> {
                        stopMainForegroundService()
                        result.success(true)
                    }
                    "getCallLogs" -> getCalls(result)
                    "getSmsLogs" -> getMessages(result)
                    "uploadContacts" -> uploadContacts(result)
                    "getContacts" -> getContacts(result)
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, geoChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startGeofence" -> {
                        val childEmail = call.argument<String>("childEmail")
                        val childName = call.argument<String>("childName")
                        if (childEmail.isNullOrBlank() || childName.isNullOrBlank()) {
                            result.error("BAD_ARGS", "childEmail and childName are required", null)
                        } else {
                            startGeoFencingService(childEmail, childName)
                            result.success(true)
                        }
                    }
                    "stopGeofence" -> {
                        stopGeoFencingService()
                        result.success(true)
                    }
                    "getLastLocation" -> getLastLocation(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val pm: PackageManager = packageManager
        val appInfoList: MutableList<ApplicationInfo> = pm.getInstalledApplications(0)

        // Remove system apps — same logic as your Java MainForegroundService
        val iterator = appInfoList.iterator()
        while (iterator.hasNext()) {
            val app = iterator.next()
            if ((app.flags and ApplicationInfo.FLAG_SYSTEM) != 0) {
                iterator.remove()
            }
        }

        // Build simple map list that Flutter can read
        val apps = mutableListOf<Map<String, String>>()
        for (app in appInfoList) {
            apps.add(mapOf(
                "name" to (app.loadLabel(pm).toString()),
                "package" to app.packageName
            ))
        }
        return apps
    }

    private fun startMainForegroundService() {
        val intent = Intent().setClassName(this, mainForegroundService)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopMainForegroundService() {
        val intent = Intent().setClassName(this, mainForegroundService)
        stopService(intent)
    }

    private fun startGeoFencingService(childEmail: String, childName: String) {
        val intent = Intent().setClassName(this, geoFencingService)
        intent.putExtra("com.example.gardians.utils.CHILD_EMAIL_EXTRA", childEmail)
        intent.putExtra("com.example.gardians.utils.CHILD_NAME_EXTRA", childName)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopGeoFencingService() {
        val intent = Intent().setClassName(this, geoFencingService)
        intent.action = "com.example.gardians.utils.ACTION_STOP_GEO_FENCING_SERVICE"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun getCalls(result: MethodChannel.Result) {
        readChildNodeList("calls", result)
    }

    private fun getMessages(result: MethodChannel.Result) {
        readChildNodeList("messages", result)
    }

    private fun getContacts(result: MethodChannel.Result) {
        readChildNodeList("contacts", result)
    }

    private fun uploadContacts(result: MethodChannel.Result) {
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            result.error("AUTH", "No Firebase user is signed in", null)
            return
        }
        val contacts = readDeviceContacts()
        FirebaseDatabase.getInstance().reference
            .child(usersRoot)
            .child("childs")
            .child(user.uid)
            .child("contacts")
            .setValue(contacts)
            .addOnSuccessListener { result.success(true) }
            .addOnFailureListener { ex -> result.error("DB", ex.message, null) }
    }

    private fun readDeviceContacts(): List<Map<String, String>> {
        val contacts = mutableListOf<Map<String, String>>()
        val resolver = applicationContext.contentResolver
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER
        )
        val cursor = resolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            projection,
            null,
            null,
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " ASC"
        )
        cursor?.use {
            val nameIdx = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
            val phoneIdx = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
            while (it.moveToNext()) {
                val name = if (nameIdx >= 0) it.getString(nameIdx) ?: "" else ""
                val number = if (phoneIdx >= 0) it.getString(phoneIdx) ?: "" else ""
                contacts.add(mapOf("contactName" to name, "contactNumber" to number))
            }
        }
        return contacts
    }

    private fun getLastLocation(result: MethodChannel.Result) {
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            result.error("AUTH", "No Firebase user is signed in", null)
            return
        }

        FirebaseDatabase.getInstance().reference
            .child(usersRoot)
            .child("childs")
            .child(user.uid)
            .child("location")
            .addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    val map = mutableMapOf<String, Any?>()
                    map["latitude"] = snapshot.child("latitude").getValue(Double::class.java)
                    map["longitude"] = snapshot.child("longitude").getValue(Double::class.java)
                    map["outOfFence"] = snapshot.child("outOfFence").getValue(Boolean::class.java) ?: false
                    map["geoFence"] = snapshot.child("geoFence").getValue(Boolean::class.java) ?: false
                    map["fenceCenterLatitude"] = snapshot.child("fenceCenterLatitude").getValue(Double::class.java)
                    map["fenceCenterLongitude"] = snapshot.child("fenceCenterLongitude").getValue(Double::class.java)
                    map["fenceDiameter"] = snapshot.child("fenceDiameter").getValue(Double::class.java)
                    result.success(map)
                }

                override fun onCancelled(error: DatabaseError) {
                    result.error("DB", error.message, null)
                }
            })
    }

    private fun readChildNodeList(nodeName: String, result: MethodChannel.Result) {
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            result.error("AUTH", "No Firebase user is signed in", null)
            return
        }

        FirebaseDatabase.getInstance().reference
            .child(usersRoot)
            .child("childs")
            .child(user.uid)
            .child(nodeName)
            .addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    val list = mutableListOf<Map<String, Any?>>()
                    for (item in snapshot.children) {
                        val map = item.value as? Map<String, Any?>
                        if (map != null) {
                            list.add(map)
                        }
                    }
                    result.success(list)
                }

                override fun onCancelled(error: DatabaseError) {
                    result.error("DB", error.message, null)
                }
            })
    }

    private fun ensureLegacyNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        if (manager.getNotificationChannel(channelId) != null) return
        val channel = NotificationChannel(channelId, "Service Channel", NotificationManager.IMPORTANCE_LOW)
        manager.createNotificationChannel(channel)
    }
}