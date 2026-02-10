import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppUsageScreen extends StatelessWidget {
  const AppUsageScreen({super.key});

  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);

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
        title: Text("App Usage", style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.calendar_month_outlined, color: navyBlue), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTotalUsageChart(),
            
            const SizedBox(height: 30),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Most Used Apps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navyBlue)),
                TextButton(onPressed: () {}, child: const Text("See All")),
              ],
            ),
            
            const SizedBox(height: 10),
            
            _buildAppItem("TikTok", "2h 15m", "Social", Icons.tiktok, Colors.black),
            _buildAppItem("Roblox", "1h 45m", "Games", Icons.gamepad, Colors.blue),
            _buildAppItem("Duolingo", "52m", "Education", Icons.language, Colors.green),
            _buildAppItem("Instagram", "45m", "Social", Icons.camera_alt, Colors.pink),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalUsageChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 70,
                    sections: [
                      PieChartSectionData(color: skyBlue, value: 40, radius: 15, showTitle: false),
                      PieChartSectionData(color: Colors.blueAccent, value: 35, radius: 15, showTitle: false),
                      PieChartSectionData(color: navyBlue, value: 25, radius: 15, showTitle: false),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("6h 42m", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: navyBlue)),
                    const Text("TODAY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _chartLegend(skyBlue, "Games", "2h 15m"),
              _chartLegend(Colors.blueAccent, "Social", "3h 22m"),
              _chartLegend(navyBlue, "Edu", "1h 05m"),
            ],
          )
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label, String time) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(radius: 5, backgroundColor: color),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildAppItem(String name, String time, String cat, IconData icon, Color iconCol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconCol.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: iconCol),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("$time • $cat", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () {},
            child: const Text("Limit", style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }
}