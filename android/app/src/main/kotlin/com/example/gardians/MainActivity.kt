package com.example.gardians

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // غيرنا الاسم هنا لـ sFlutterEngine عشان ميتخانقش مع الدالة
        sFlutterEngine = flutterEngine
    }

    companion object {
        // المتغير بقى اسمه sFlutterEngine
        private var sFlutterEngine: FlutterEngine? = null

        // دي الدالة اللي SmsReceiver.java بينادي عليها وممنوع نغير اسمها
        @JvmStatic
        fun getFlutterEngineInstance(): FlutterEngine? {
            return sFlutterEngine
        }
    }
}