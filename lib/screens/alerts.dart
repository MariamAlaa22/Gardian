import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  final Color navyBlue = const Color(0xFF042459);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("TODAY"),
          _buildAlertCard(
            "Geo-fence breached",
            "Liam has left the designated School zone.",
            "10:30 AM",
            Icons.location_off,
            Colors.red,
          ),
          _buildAlertCard(
            "Content blocked",
            "A restricted website was blocked on Maya's iPad.",
            "09:15 AM",
            Icons.block,
            Colors.orange,
          ),
          _buildAlertCard(
            "Limit reached",
            "Screen time limit for 'Social Media' was reached.",
            "08:00 AM",
            Icons.timer,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("YESTERDAY"),
          _buildAlertCard(
            "New App Installed",
            "Liam installed 'Roblox' on his Android device.",
            "06:45 PM",
            Icons.security,
            Colors.blue,
          ),
          _buildAlertCard(
            "Low Battery",
            "Maya's phone battery is below 10%.",
            "04:20 PM",
            Icons.battery_alert,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: TextStyle(color: navyBlue.withValues(alpha: 0.4), fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildAlertCard(String title, String sub, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: IntrinsicHeight( 
        child: Row(
          children: [
            
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
              ),
            ),
            const SizedBox(width: 15),
            CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Icon(icon, color: Color(0xFF042459), size: 20),
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
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Color(0xFF042459) )),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(time, style: const TextStyle(color: Color(0xFF042459), fontSize: 10, )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(sub, style: TextStyle(color: navyBlue.withValues(alpha: 0.5), fontSize: 12)),
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