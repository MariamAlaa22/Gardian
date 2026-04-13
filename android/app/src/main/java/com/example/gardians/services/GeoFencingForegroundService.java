package com.example.gardians.services;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.example.gardians.MainActivity;
import com.example.gardians.R;
import com.example.gardians.utils.Constant;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

public class GeoFencingForegroundService extends Service {
	private static final String TAG = "GeoFencingTAG";
	private FirebaseDatabase firebaseDatabase;
	private DatabaseReference databaseReference;
	private String lastChildEmail = null;
	private static final String CHANNEL_ID = "com.example.gardians.utils.CHANNEL_ID";

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		firebaseDatabase = FirebaseDatabase.getInstance();
		databaseReference = firebaseDatabase.getReference("users");

		final String childEmail = intent.getStringExtra(Constant.CHILD_EMAIL_EXTRA);
		final String childName = intent.getStringExtra(Constant.CHILD_NAME_EXTRA);
		String notificationContent = "GeoFencing " + (childName == null ? "Child" : childName);
		if (childEmail != null) lastChildEmail = childEmail;

		if (intent.getAction() != null) {
			if (intent.getAction().equals(Constant.ACTION_STOP_GEO_FENCING_SERVICE)) {
				closeFencingService();
				Log.i(TAG, "onStartCommand: lastEmail: " + lastChildEmail);
			}
		}

		Intent notificationIntent = new Intent(this, MainActivity.class);
		int pendingFlag = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0;
		PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, pendingFlag);

		Intent stopIntent = new Intent(this, GeoFencingForegroundService.class);
		stopIntent.setAction(Constant.ACTION_STOP_GEO_FENCING_SERVICE);
		PendingIntent stopPendingIntent = PendingIntent.getService(
				this,
				Constant.GEO_FENCING_SERVICE_REQUEST_CODE,
				stopIntent,
				PendingIntent.FLAG_CANCEL_CURRENT | pendingFlag
		);

		Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
				.setContentTitle(notificationContent)
				.setSmallIcon(R.mipmap.ic_launcher)
				.addAction(android.R.drawable.ic_menu_close_clear_cancel, getString(R.string.stop), stopPendingIntent)
				.setContentIntent(pendingIntent)
				.build();

		startForeground(Constant.GEO_FENCING_NOTIFICATION_ID, notification);
		Log.i(TAG, "onStartCommand: service started");

		if (childEmail == null) return START_REDELIVER_INTENT;
		Query query = databaseReference.child("childs").orderByChild("email").equalTo(childEmail);
		query.addListenerForSingleValueEvent(new ValueEventListener() {
			@Override
			public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					final DataSnapshot nodeShot = dataSnapshot.getChildren().iterator().next();
					String childUID = nodeShot.getKey();
					Query geoFencingQuery = databaseReference.child("childs").child(childUID).child("location").child("outOfFence");
					geoFencingQuery.addValueEventListener(new ValueEventListener() {
						@Override
						public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
							Log.i(TAG, "onDataChange: value: " + dataSnapshot.getValue());
							if (dataSnapshot.exists()) showNotification(dataSnapshot, childName == null ? "Child" : childName);
						}

						@Override
						public void onCancelled(@NonNull DatabaseError databaseError) {
						}
					});
				}
			}

			@Override
			public void onCancelled(@NonNull DatabaseError databaseError) {
			}
		});

		return START_REDELIVER_INTENT;
	}

	@Nullable
	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}

	private void showNotification(DataSnapshot dataSnapshot, String childName) {
		if ((boolean) dataSnapshot.getValue()) {
			Toast.makeText(this, childName + getString(R.string.is_out_of_the_fence), Toast.LENGTH_SHORT).show();
			stopSelf();
		}
	}

	private void closeFencingService() {
		if (lastChildEmail != null) {
			Query query = databaseReference.child("childs").orderByChild("email").equalTo(lastChildEmail);
			query.addListenerForSingleValueEvent(new ValueEventListener() {
				@Override
				public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
					if (dataSnapshot.exists()) {
						final DataSnapshot nodeShot = dataSnapshot.getChildren().iterator().next();
						String childUID = nodeShot.getKey();
						databaseReference.child("childs").child(childUID).child("location").child("outOfFence").setValue(false);
						databaseReference.child("childs").child(childUID).child("location").child("geoFence").setValue(false);
						stopSelf();
					}
				}

				@Override
				public void onCancelled(@NonNull DatabaseError databaseError) {
				}
			});
		} else {
			stopSelf();
		}
	}
}
