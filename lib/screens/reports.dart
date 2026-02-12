import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // لفتح الإيميل

// 1. موديل بيانات التقرير
class WeeklyReportData {
  final String totalTime;
  final String improvement;
  final List<double> dailyUsage; // من 0.0 لـ 1.0
  final String safetyScore;
  final String pickups;
  final List<Map<String, dynamic>> topApps;

  WeeklyReportData({
    required this.totalTime,
    required this.improvement,
    required this.dailyUsage,
    required this.safetyScore,
    required this.pickups,
    required this.topApps,
  });
}

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  // ميثود لإرسال التقرير عبر الإيميل
  Future<void> _sendEmailReport(String reportContent) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'parent@example.com',
      query: 'subject=Weekly Child Safety Report&body=$reportContent',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color navyBlue = const Color(0xFF042459);
    final Color skyBlue = const Color(0xFF9ED7EB);

    // 2. بيانات تجريبية (Mock Data) جاية من الـ Model
    final report = WeeklyReportData(
      totalTime: "26h 45m",
      improvement: "15% less than last week",
      dailyUsage: [0.4, 0.7, 0.5, 0.9, 0.6, 0.3, 0.8],
      safetyScore: "8/10",
      pickups: "142",
      topApps: [
        {
          "name": "YouTube",
          "time": "12h 30m",
          "icon": Icons.play_circle_fill,
          "color": Colors.red,
        },
        {
          "name": "Roblox",
          "time": "8h 15m",
          "icon": Icons.games,
          "color": Colors.blue,
        },
        {
          "name": "TikTok",
          "time": "5h 45m",
          "icon": Icons.music_note,
          "color": Colors.black,
        },
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: skyBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Weekly Report",
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(report, navyBlue, skyBlue),
            const SizedBox(height: 30),
            Text(
              "Daily Usage",
              style: TextStyle(
                color: navyBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildBarChart(report.dailyUsage, navyBlue, skyBlue),
            const SizedBox(height: 30),
            Row(
              children: [
                _buildSmallStatCard(
                  "Safety Score",
                  report.safetyScore,
                  Icons.shield_outlined,
                  navyBlue,
                  skyBlue,
                ),
                const SizedBox(width: 15),
                _buildSmallStatCard(
                  "Pickups/Day",
                  report.pickups,
                  Icons.touch_app_outlined,
                  navyBlue,
                  skyBlue,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "Top Used Apps",
              style: TextStyle(
                color: navyBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            // تحويل قائمة التطبيقات لـ Dynamic
            ...report.topApps.map(
              (app) => _buildAppUsageTile(
                app["name"],
                app["time"],
                app["icon"],
                app["color"],
                navyBlue,
                skyBlue,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _sendEmailReport(
                  "Weekly Summary: ${report.totalTime} usage.",
                ),
                icon: const Icon(Icons.email_outlined),
                label: const Text(
                  "Send Report to Email",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(WeeklyReportData report, Color navy, Color sky) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text("Total Screen Time", style: TextStyle(color: sky, fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            report.totalTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            report.improvement,
            style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> dailyData, Color navy, Color sky) {
    List<String> days = ["S", "M", "T", "W", "T", "F", "S"];
    return Container(
      height: 180,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: sky.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(dailyData.length, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 12,
                height: 100 * dailyData[index],
                decoration: BoxDecoration(
                  color: dailyData[index] > 0.8
                      ? Colors.redAccent
                      : (index == 3 ? navy : sky),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ميثود _buildSmallStatCard و _buildAppUsageTile بتفضل بنفس الـ UI بتاعك بس بتربط الـ parameters
  Widget _buildSmallStatCard(
    String title,
    String value,
    IconData icon,
    Color navy,
    Color sky,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sky.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: navy, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: navy,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppUsageTile(
    String name,
    String time,
    IconData icon,
    Color iconColor,
    Color navy,
    Color sky,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: sky.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        trailing: Text(
          time,
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
