import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'rules.dart'; // عشان نربط زرار الـ Limit

class AppUsageScreen extends StatefulWidget {
  const AppUsageScreen({super.key});

  @override
  State<AppUsageScreen> createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends State<AppUsageScreen> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);

  // 1. قائمة التطبيقات (Dynamic List)
  // ملاحظة: الـ value هنا هي النسبة المئوية للرسم البياني
  final List<Map<String, dynamic>> mostUsedApps = [
    {
      "name": "TikTok",
      "time": "2h 15m",
      "cat": "Social",
      "icon": Icons.tiktok,
      "color": Colors.black,
      "perc": 40.0,
    },
    {
      "name": "Roblox",
      "time": "1h 45m",
      "cat": "Games",
      "icon": Icons.gamepad,
      "color": Colors.blueAccent,
      "perc": 30.0,
    },
    {
      "name": "Duolingo",
      "time": "52m",
      "cat": "Education",
      "icon": Icons.language,
      "color": Colors.green,
      "perc": 15.0,
    },
    {
      "name": "Instagram",
      "time": "45m",
      "cat": "Social",
      "icon": Icons.camera_alt,
      "color": Colors.pink,
      "perc": 15.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "App Usage",
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // الرسم البياني اللي بيقرأ من الـ List أوتوماتيكياً
            _buildDynamicUsageChart(),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Most Used Apps",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: navyBlue,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text("View Details")),
              ],
            ),

            const SizedBox(height: 10),

            // عرض التطبيقات بشكل ديناميكي
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mostUsedApps.length,
              itemBuilder: (context, index) {
                final app = mostUsedApps[index];
                return _buildAppItem(app, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ميثود ذكية لبناء الـ Chart بناءً على الداتا
  Widget _buildDynamicUsageChart() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: skyBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 75,
                    // تحويل الـ List لـ Chart Sections برمجياً
                    sections: mostUsedApps.map((app) {
                      return PieChartSectionData(
                        color: app["color"],
                        value: app["perc"],
                        radius: 18,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "5h 37m",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: navyBlue,
                      ),
                    ),
                    const Text(
                      "SCREEN TIME",
                      style: TextStyle(
                        color: Colors.grey,
                        letterSpacing: 1.2,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          // الـ Legend اللي بيطلع تحت الشارت أوتوماتيكياً
          Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: mostUsedApps
                .map((app) => _chartLegend(app["color"], app["cat"]))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAppItem(Map<String, dynamic> app, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: app["color"].withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(app["icon"], color: app["color"]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${app["time"]} • ${app["cat"]}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              elevation: 0,
            ),
            onPressed: () {
              // ربط زرار الـ Limit بصفحة القواعد
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppRulesScreen()),
              );
            },
            child: const Text("Set Limit", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
