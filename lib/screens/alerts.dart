import 'package:flutter/material.dart';

// 1. تعريف موديل التنبيه (Alert Model)
class AlertItem {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;
  final String dateCategory; // TODAY, YESTERDAY, etc.

  AlertItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
    required this.dateCategory,
  });
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final Color navyBlue = const Color(0xFF042459);

  // 2. قائمة التنبيهات التجريبية (Mock Data)
  final List<AlertItem> _allAlerts = [
    AlertItem(
      title: "Geo-fence breached",
      description: "Liam has left the designated School zone.",
      time: "10:30 AM",
      icon: Icons.location_off,
      color: Colors.red,
      dateCategory: "TODAY",
    ),
    AlertItem(
      title: "Content blocked",
      description: "A restricted website was blocked on Maya's iPad.",
      time: "09:15 AM",
      icon: Icons.block,
      color: Colors.orange,
      dateCategory: "TODAY",
    ),
    AlertItem(
      title: "Limit reached",
      description: "Screen time limit for 'Social Media' was reached.",
      time: "08:00 AM",
      icon: Icons.timer,
      color: Colors.blue,
      dateCategory: "TODAY",
    ),
    AlertItem(
      title: "New App Installed",
      description: "Liam installed 'Roblox' on his Android device.",
      time: "06:45 PM",
      icon: Icons.security,
      color: Colors.blue,
      dateCategory: "YESTERDAY",
    ),
    AlertItem(
      title: "Low Battery",
      description: "Maya's phone battery is below 10%.",
      time: "04:20 PM",
      icon: Icons.battery_alert,
      color: Colors.orange,
      dateCategory: "YESTERDAY",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // تقسيم التنبيهات حسب التاريخ برمجياً
    final todayAlerts = _allAlerts
        .where((a) => a.dateCategory == "TODAY")
        .toList();
    final yesterdayAlerts = _allAlerts
        .where((a) => a.dateCategory == "YESTERDAY")
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (todayAlerts.isNotEmpty) ...[
            _buildSectionHeader("TODAY"),
            ...todayAlerts.map((a) => _buildAlertCard(a)),
          ],
          const SizedBox(height: 10),
          if (yesterdayAlerts.isNotEmpty) ...[
            _buildSectionHeader("YESTERDAY"),
            ...yesterdayAlerts.map((a) => _buildAlertCard(a)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: navyBlue.withOpacity(0.4),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  // تعديل الميثود لتقبل موديل AlertItem
  Widget _buildAlertCard(AlertItem alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: alert.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 15),
            CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Icon(alert.icon, color: navyBlue, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          alert.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: navyBlue,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            alert.time,
                            style: TextStyle(color: navyBlue, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      alert.description,
                      style: TextStyle(
                        color: navyBlue.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
