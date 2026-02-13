package com.mansourappdevelopment.androidapp.kidsafe.broadcasts;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.telephony.TelephonyManager;
import android.util.Log;
import java.util.HashMap;
import io.flutter.plugin.common.MethodChannel;

// استيراد الـ MainActivity من مكانها الجديد اللي في صورتك
import com.example.gardians.MainActivity; 

public class PhoneStateReceiver extends BroadcastReceiver {
    private static final String TAG = "PhoneStateReceiver";
    private static long startCallTime;

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(TelephonyManager.ACTION_PHONE_STATE_CHANGED)) {
            String state = intent.getStringExtra(TelephonyManager.EXTRA_STATE);
            String phoneNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER);

            Log.i(TAG, "Phone State: " + state + " | Number: " + phoneNumber);

            if (TelephonyManager.EXTRA_STATE_RINGING.equals(state)) {
                // بداية الرن
                startCallTime = System.currentTimeMillis();
                sendToFlutter("Incoming Call", phoneNumber, "0");
            } 
            else if (TelephonyManager.EXTRA_STATE_OFFHOOK.equals(state)) {
                // المكالمة بدأت (رد أو بيتصل)
                startCallTime = System.currentTimeMillis();
                sendToFlutter("Started", phoneNumber, "0");
            } 
            else if (TelephonyManager.EXTRA_STATE_IDLE.equals(state)) {
                // المكالمة انتهت
                long endCallTime = System.currentTimeMillis();
                double duration = (endCallTime - startCallTime) / 1000.0;
                sendToFlutter("Ended", phoneNumber, String.valueOf(duration));
            }
        }
    }

    private void sendToFlutter(final String status, final String number, final String duration) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                // التأكد إن المحرك بتاع فلاتر شغال
                if (MainActivity.Companion.getFlutterEngineInstance() != null) {
                    HashMap<String, String> callData = new HashMap<>();
                    callData.put("status", status);
                    callData.put("phoneNumber", number != null ? number : "Private");
                    callData.put("duration", duration);

                    new MethodChannel(MainActivity.Companion.getFlutterEngineInstance().getDartExecutor().getBinaryMessenger(), "com.kidsafe/calls")
                            .invokeMethod("onCallEvent", callData);
                }
            }
        });
    }
}