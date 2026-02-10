import 'package:flutter/material.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تعريف الألوان جوه الـ build عشان نتجنب أي Errors مع withValues
    final Color navyBlue = const Color(0xFF042459);
    final Color skyBlue = const Color(0xFF9ED7EB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: skyBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Weekly Report", 
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. كارت ملخص الوقت الإجمالي
            _buildSummaryCard(navyBlue, skyBlue),
            
            const SizedBox(height: 30),

            Text("Daily Usage", 
              style: TextStyle(color: navyBlue, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 2. الرسم البياني للأعمدة
            _buildBarChart(navyBlue, skyBlue),

            const SizedBox(height: 30),

            // 3. كروت الإحصائيات الصغيرة (Safety Score & Pickups)
            Row(
              children: [
                _buildSmallStatCard("Safety Score", "8/10", Icons.shield_outlined, navyBlue, skyBlue),
                const SizedBox(width: 15),
                _buildSmallStatCard("Pickups/Day", "142", Icons.touch_app_outlined, navyBlue, skyBlue),
              ],
            ),

            const SizedBox(height: 30),

            // 4. أكتر تطبيقات استخدماً
            Text("Top Used Apps", 
              style: TextStyle(color: navyBlue, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildAppUsageTile("YouTube", "12h 30m", Icons.play_circle_fill, Colors.red, navyBlue, skyBlue),
            _buildAppUsageTile("Roblox", "8h 15m", Icons.games, Colors.blue, navyBlue, skyBlue),
            _buildAppUsageTile("TikTok", "5h 45m", Icons.music_note, Colors.black, navyBlue, skyBlue),
            
            const SizedBox(height: 40),

            // 5. زرار إرسال التقرير (إضافة احترافية)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Logic لإرسال التقرير للإيميل
                },
                icon: const Icon(Icons.email_outlined),
                label: const Text("Send Report to Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets مساعدة لتقليل زحمة الكود ---

  Widget _buildSummaryCard(Color navy, Color sky) {
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
          const Text("26h 45m", 
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("15% less than last week", 
            style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBarChart(Color navy, Color sky) {
    List<double> data = [0.4, 0.7, 0.5, 0.9, 0.6, 0.3, 0.8];
    List<String> days = ["S", "M", "T", "W", "T", "F", "S"];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: sky.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 12,
                height: 100 * data[index],
                decoration: BoxDecoration(
                  color: index == 3 ? navy : sky,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Text(days[index], style: TextStyle(color: navy, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color navy, Color sky) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sky.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: navy, size: 28),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppUsageTile(String name, String time, IconData icon, Color iconColor, Color navy, Color sky) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: sky.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text("Usage details", style: TextStyle(fontSize: 10)),
        trailing: Text(time, style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
      ),
    );
  }
}