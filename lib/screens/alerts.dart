import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
// تأكد من استيراد Constants و SharedPrefs لجلب ID الطفل
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final Color navyBlue = const Color(0xFF042459);
  late String selectedChildUid;

  @override
  void initState() {
    super.initState();
    selectedChildUid = SharedPrefsUtils.getString(Constants.childId) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Child Notifications"),
        backgroundColor: Colors.white,
        foregroundColor: navyBlue,
        elevation: 0,
      ),
      body: selectedChildUid.isEmpty
          ? const Center(child: Text("Please select a child first"))
          : StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref("alerts/$selectedChildUid")
                  .orderByChild("timestamp")
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null)
                  return _buildEmptyState();

                Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );
                List<Map<dynamic, dynamic>> sortedList = data.values
                    .map((e) => Map<dynamic, dynamic>.from(e))
                    .toList();
                sortedList.sort(
                  (a, b) => b['timestamp'].compareTo(a['timestamp']),
                );

                // فلترة لليوم والأمس
                String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                var todayAlerts = sortedList
                    .where((a) => a['date_raw'] == today)
                    .toList();
                var olderAlerts = sortedList
                    .where((a) => a['date_raw'] != today)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (todayAlerts.isNotEmpty) ...[
                      _buildSectionHeader("TODAY"),
                      ...todayAlerts.map((a) => _buildAlertCard(a)),
                    ],
                    if (olderAlerts.isNotEmpty) ...[
                      _buildSectionHeader("OLDER"),
                      ...olderAlerts.map((a) => _buildAlertCard(a)),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _buildAlertCard(Map<dynamic, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0x4D9ED7EB), // نفس اللون اللي انت اخترته
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            _getIcon(alert['packageName']),
            color: navyBlue,
            size: 20,
          ),
        ),
        title: Text(
          alert['title'] ?? "Notification",
          style: TextStyle(fontWeight: FontWeight.bold, color: navyBlue),
        ),
        subtitle: Text(
          alert['description'] ?? "",
          style: TextStyle(color: navyBlue.withOpacity(0.6)),
        ),
        trailing: Text(
          alert['time_display'] ?? "",
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  // دالة بسيطة لتغيير الأيقونة حسب التطبيق
  IconData _getIcon(String? pkg) {
    if (pkg == null) return Icons.notifications;
    if (pkg.contains("whatsapp")) return Icons.chat;
    if (pkg.contains("facebook")) return Icons.facebook;
    if (pkg.contains("youtube")) return Icons.play_arrow;
    return Icons.apps;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: navyBlue.withOpacity(0.4),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No notifications recorded yet."));
  }
}
