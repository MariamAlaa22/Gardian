package com.example.gardians.services;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.IBinder;
import android.telephony.TelephonyManager;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.example.gardians.MainActivity;
import com.example.gardians.R;
import com.example.gardians.broadcasts.PhoneStateReceiver;
import com.example.gardians.broadcasts.SmsReceiver;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

public class CallSmsForegroundService extends Service {
	public static final int NOTIFICATION_ID = 2711;
	private static final String CHANNEL_ID = "com.example.gardians.utils.CHANNEL_ID";

	private PhoneStateReceiver phoneStateReceiver;
	private SmsReceiver smsReceiver;

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
		if (user == null) {
			stopSelf();
			return START_NOT_STICKY;
		}

		Intent notificationIntent = new Intent(this, MainActivity.class);
		int pendingFlag = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0;
		PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, pendingFlag);

		Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
				.setContentTitle("Guardian monitoring active")
				.setSmallIcon(R.mipmap.ic_launcher)
				.setContentIntent(pendingIntent)
				.build();
		startForeground(NOTIFICATION_ID, notification);

		if (phoneStateReceiver == null) {
			phoneStateReceiver = new PhoneStateReceiver(user);
			IntentFilter callIntentFilter = new IntentFilter(TelephonyManager.ACTION_PHONE_STATE_CHANGED);
			registerReceiver(phoneStateReceiver, callIntentFilter);
		}

		if (smsReceiver == null) {
			smsReceiver = new SmsReceiver(user);
			IntentFilter smsIntentFilter = new IntentFilter("android.provider.Telephony.SMS_RECEIVED");
			registerReceiver(smsReceiver, smsIntentFilter);
		}

		return START_STICKY;
	}

	@Override
	public void onDestroy() {
		if (phoneStateReceiver != null) {
			unregisterReceiver(phoneStateReceiver);
			phoneStateReceiver = null;
		}
		if (smsReceiver != null) {
			unregisterReceiver(smsReceiver);
			smsReceiver = null;
		}
		super.onDestroy();
	}

	@Nullable
	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}
}
