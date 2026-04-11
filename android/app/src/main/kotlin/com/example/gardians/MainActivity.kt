package com.example.gardians

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager

class MainActivity : FlutterActivity() {

    // This name must match EXACTLY what you write in Flutter later
    private val CHANNEL = "com.kidsafe/apps"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getInstalledApps") {
                    result.success(getInstalledApps())
                } else {
                    result.notImplemented()
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
}