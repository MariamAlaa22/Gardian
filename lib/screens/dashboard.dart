import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gardians/screens/commdetails.dart';
import 'package:gardians/screens/devices.dart';
import 'package:gardians/screens/alertsettings.dart';
import 'package:gardians/screens/alerts.dart';
import 'package:gardians/screens/location.dart';
import 'package:gardians/screens/parent.dart';
import 'package:gardians/screens/profile.dart';
import 'package:gardians/screens/reports.dart';
import 'package:gardians/screens/rules.dart';
import 'package:gardians/screens/usage.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);
  final Color backgroundGrey = const Color(0xFFF8F9FA);

  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _dashboardBody(),
      const ChildLocationScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Guardian";
      case 1:
        return "Location";
      case 2:
        return "Alerts";
      case 3:
        return "Profile";
      default:
        return "Guardian";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // (Header)
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: const Color.fromARGB(255, 125, 176, 188),
),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 45, color: navyBlue),
              ),
              accountName: Text(
                "Parent Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text("parent@safeguard.com"),
            ),

            // (Child Control)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 10, bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "CHILD MONITORING",
                  style: TextStyle(
                    color: navyBlue.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(Icons.apps_outage_rounded, "Control Apps", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppRulesScreen()),
              );
            }),
            _buildDrawerItem(Icons.devices_other, "Manage Devices", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DevicesScreen()),
              );
            }),

            _buildDrawerItem(Icons.report, "Weekly Reports", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeeklyReportScreen(),
                ),
              );
            }),

            Divider(color: navyBlue.withValues(alpha: 0.2)),

            // (Account & System)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 10, bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "SETTINGS",
                  style: TextStyle(
                    color: navyBlue.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(
              Icons.settings_outlined,
              "Account Settings",
              () {},
            ),
            _buildDrawerItem(Icons.help_outline, "Help & Support", () {}),

            const Spacer(),

            _buildDrawerItem(Icons.logout, "Logout", () {
              
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Parent(),
                  ), 
                  (route) => false, 
                );
            }, isLogout: true),
            const SizedBox(height: 20),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: navyBlue),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(backgroundColor: skyBlue.withAlpha(50)),
          ),

          if (_selectedIndex == 2)
            IconButton(
              padding: const EdgeInsets.only(right: 12),
              constraints: const BoxConstraints(),
              icon: Icon(Icons.settings, color: navyBlue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlertsSettingsScreen(),
                  ),
                );
              },
            ),
        ],
      ),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 28,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 47, 152, 168),
        unselectedItemColor: navyBlue.withValues(alpha: 0.3),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.location_pin), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
    );
  }

  // ================= DASHBOARD BODY =================

  Widget _dashboardBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildChildSelector(),
          const SizedBox(height: 20),
          _buildScreenTimeCard(),
          const SizedBox(height: 20),
          _buildMonitorCard(),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBlockedSection()),
              const SizedBox(width: 15),
              Expanded(child: _buildUsageSection()),
            ],
          ),
          const SizedBox(height: 20),
          _buildCommunicationSection(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : navyBlue),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : navyBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=child'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SELECTED CHILD",
                style: TextStyle(
                  fontSize: 10,
                  color: navyBlue.withValues(alpha: 0.5),
                ),
              ),
              Text(
                "Billy's iPhone",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.unfold_more, color: navyBlue),
        ],
      ),
    );
  }

  Widget _buildMonitorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AI Content Monitor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Safe",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50, //(Donut)
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: 60, // need Real Data
                        radius: 18,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: Colors.blue,
                        value: 34,
                        radius: 18,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: 3,
                        radius: 18,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: Colors.orange,
                        value: 3,
                        radius: 18,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "94%",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: navyBlue,
                      ),
                    ),
                    Text(
                      "SAFE",
                      style: TextStyle(
                        color: navyBlue.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildReportLegend(),
        ],
      ),
    );
  }

  Widget _buildReportLegend() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 3,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _legendItem("Text (Safe)", "60%", Colors.green),
        _legendItem("Video (Safe)", "34%", Colors.blue),
        _legendItem("Text (Harmful)", "3%", Colors.red),
        _legendItem("Video (Harmful)", "3%", Colors.orange),
      ],
    );
  }

  Widget _legendItem(String title, String val, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: navyBlue,
              ),
            ),
            Text(
              val,
              style: TextStyle(
                fontSize: 10,
                color: navyBlue.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlockedSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "BLOCKED",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                ),
              ),
              Icon(
                Icons.add,
                size: 18,
                color: Color.fromARGB(255, 47, 152, 168),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _appBlockedItem("WhatsApp"),
          _appBlockedItem("TikTok"),
          _appBlockedItem("X"),
          Center(
            child: Text(
              "Tap to see all",
              style: TextStyle(
                fontSize: 10,
                color: navyBlue.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBlockedItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            color: navyBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppUsageScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color(0x4D9ED7EB),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "USAGE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: navyBlue,
              ),
            ),
            const SizedBox(height: 15),
            _usageItem("YouTube", "2h 15m", 0.7, Colors.brown),
            _usageItem("Roblox", "1h 10m", 0.4, Colors.yellow),
            _usageItem("Insta", "45m", 0.2, Colors.purple),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "Tap to see more",
                style: TextStyle(
                  fontSize: 10,
                  color: navyBlue.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageItem(String name, String time, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: navyBlue.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[100],
            color: color,
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOTAL SCREEN TIME",
            style: TextStyle(
              fontSize: 12,
              color: navyBlue.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "4h 12m",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: navyBlue,
            ),
          ),
          Text(
            "of 5h limit",
            style: TextStyle(color: navyBlue.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: 0.84,
            minHeight: 8,
            color: navyBlue,
            backgroundColor: Colors.grey[100],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "84% of daily allowance used",
                style: TextStyle(
                  fontSize: 12,
                  color: navyBlue.withValues(alpha: 0.5),
                ),
              ),
              Text(
                "48m remaining",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildCommunicationSection() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0x4D9ED7EB), 
      borderRadius: BorderRadius.circular(25), 
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "CALLS & MESSAGES",
              style: TextStyle(
                fontSize: 12,
                color: navyBlue.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommunicationDetailsScreen()),
    );
  },
  child: Text(
    "Details >",
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: navyBlue,
    ),
  ),
),
          ],
        ),
        const SizedBox(height: 15),
        
        Row(
          children: [
            _buildStatCard(
              title: "Calls",
              count: "56",
              icon: Icons.call_rounded,
            ),
            const SizedBox(width: 15),
            _buildStatCard(
              title: "Messages",
              count: "109",
              icon: Icons.chat_bubble_rounded,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildStatCard({
  required String title,
  required String count,
  required IconData icon,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: navyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: navyBlue.withValues(alpha: 0.3), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: navyBlue.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ),
  );
}
}
