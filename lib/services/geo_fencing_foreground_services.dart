import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GeoFencingMonitor {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users/childs");

  void startMonitoring(String childEmail, String childName) {
    // البحث عن الـ UID الخاص بالطفل
    _dbRef.orderByChild("email").equalTo(childEmail).onValue.listen((event) {
      if (event.snapshot.exists) {
        // الحصول على أول طفل مطابق للبحث
        final DataSnapshot childSnapshot = event.snapshot.children.first;
        final String childUID = childSnapshot.key!;

        // مراقبة حالة الـ outOfFence
        _dbRef.child(childUID).child("location/outOfFence").onValue.listen((fenceEvent) {
          if (fenceEvent.snapshot.exists) {
            // تحويل القيمة لـ bool بأمان
            final bool isOut = fenceEvent.snapshot.value as bool? ?? false;

            if (isOut) {
              _showOutNotification(childName);
            }
          }
        });
      }
    });
  }

  void _showOutNotification(String childName) {
    Fluttertoast.showToast(
      msg: "$childName is out of the fence!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP, // التنبيه يظهر فوق زي الجافا
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }
}