package com.mansourappdevelopment.androidapp.kidsafe.broadcasts;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.telephony.SmsMessage;
import android.util.Log;
import java.util.HashMap;
import io.flutter.plugin.common.MethodChannel;
import com.example.gardians.MainActivity; 

public class SmsReceiver extends BroadcastReceiver {
    private static final String TAG = "SmsReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        // أهم سطر عشان نعرف لو الأندرويد استلمها أصلاً
        Log.i(TAG, "📩 رسالة جديدة وصلت للأندرويد بره فلاتر!");

        if (intent.getAction() != null && intent.getAction().equals("android.provider.Telephony.SMS_RECEIVED")) {
            Bundle bundle = intent.getExtras();
            if (bundle != null) {
                Object[] pdus = (Object[]) bundle.get("pdus");
                if (pdus != null) {
                    for (Object pdu : pdus) {
                        SmsMessage smsMessage = SmsMessage.createFromPdu((byte[]) pdu);
                        String sender = smsMessage.getDisplayOriginatingAddress();
                        String body = smsMessage.getMessageBody();

                        Log.i(TAG, "📩 محتوى الرسالة: من " + sender + " النص: " + body);
                        sendToFlutter(sender, body);
                    }
                }
            }
        }
    }

    private void sendToFlutter(final String sender, final String body) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (MainActivity.Companion.getFlutterEngineInstance() != null) {
                    HashMap<String, String> smsData = new HashMap<>();
                    smsData.put("sender", sender);
                    smsData.put("body", body);

                    new MethodChannel(MainActivity.Companion.getFlutterEngineInstance().getDartExecutor().getBinaryMessenger(), "com.kidsafe/sms")
                            .invokeMethod("onMessageReceived", smsData);
                    Log.i(TAG, "✅ تم إرسال الرسالة بنجاح لمحرك فلاتر");
                } else {
                    Log.e(TAG, "❌ محرك فلاتر (Flutter Engine) لسه ميت، مش عارف أبعت الرسالة!");
                }
            }
        });
    }
}