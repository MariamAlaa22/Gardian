package com.mansourappdevelopment.androidapp.kidsafe.broadcasts;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.os.Handler;
import android.os.Looper;
import java.util.HashMap;
import io.flutter.plugin.common.MethodChannel;
import com.example.gardians.MainActivity;

public class BootCompleteReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Log.i("BootReceiver", "🚀 الجهاز فتح فعلاً!");

            // بنحاول نكلم فلاتر عشان ترفع الداتا للفيربيز
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    if (MainActivity.getFlutterEngineInstance() != null) {
                        new MethodChannel(MainActivity.getFlutterEngineInstance().getDartExecutor().getBinaryMessenger(), "com.kidsafe/boot")
                                .invokeMethod("onDeviceBooted", "الجهاز فتح في الوقت الحالي");
                    }
                }
            });
        }
    }
}