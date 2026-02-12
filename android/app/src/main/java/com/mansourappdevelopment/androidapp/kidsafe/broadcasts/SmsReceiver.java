package com.mansourappdevelopment.androidapp.kidsafe.broadcasts;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.telephony.SmsMessage;
import java.util.HashMap;
import io.flutter.plugin.common.MethodChannel;

// السطر ده لازم يكون هنا بالظبط بره الـ class فوق
import com.example.gardians.MainActivity; 

public class SmsReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle bundle = intent.getExtras();
        if (bundle != null) {
            Object[] pdusObjs = (Object[]) bundle.get("pdus");
            if (pdusObjs == null) return;

            StringBuilder messageBodyFull = new StringBuilder();
            String senderPhoneNumber = "";

            for (Object pdusObj : pdusObjs) {
                SmsMessage currentMessage = SmsMessage.createFromPdu((byte[]) pdusObj);
                senderPhoneNumber = currentMessage.getDisplayOriginatingAddress();
                messageBodyFull.append(currentMessage.getDisplayMessageBody().replace("\n", " "));
            }
            
            sendToFlutter(senderPhoneNumber, messageBodyFull.toString());
        }
    }

    private void sendToFlutter(final String sender, final String body) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                // بنادي على الـ Instance اللي في MainActivity
                if (MainActivity.Companion.getFlutterEngineInstance() != null) {
                    HashMap<String, String> smsData = new HashMap<>();
                    smsData.put("sender", sender);
                    smsData.put("body", body);

                    new MethodChannel(MainActivity.Companion.getFlutterEngineInstance().getDartExecutor().getBinaryMessenger(), "com.kidsafe/sms")
                            .invokeMethod("onMessageReceived", smsData);
                }
            }
        });
    }
}