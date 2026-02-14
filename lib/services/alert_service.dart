import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationMonitor {
  static void startListening(String childUid) async {
    print("📡 [Monitor] Trying to start listener...");

    bool status = await NotificationListenerService.isPermissionGranted();
    print("🔑 [Monitor] Permission Status: $status");

    if (!status) {
      print("🚨 [Monitor] Permission missing! Opening settings...");
      await NotificationListenerService.requestPermission();
      return;
    }

    NotificationListenerService.notificationsStream.listen((event) {
      print(
        "📥 [Monitor] New notification detected from: ${event.packageName}",
      );
      _uploadToFirebase(childUid, event);
    });
  }

  static void _uploadToFirebase(String childUid, dynamic event) {
    // الرفع لنود alerts الخاص بالطفل ليعرضه الأب بشكل ديناميكي
    final ref = FirebaseDatabase.instance.ref("alerts/$childUid").push();

    ref.set({
      "title": event.title,
      "description": event.content,
      "packageName": event.packageName,
      "timestamp": ServerValue.timestamp,
      "time_display": DateFormat('hh:mm a').format(DateTime.now()),
      "date_raw": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "type": "notification_read",
    });

    print("✅ [Monitor] Notification from ${event.packageName} uploaded!");
  }
}
