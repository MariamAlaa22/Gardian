import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// استيراد الشاشات
import 'package:gardians/screens/devices.dart';
import 'package:gardians/screens/usage.dart';
import 'package:gardians/screens/reports.dart';
import 'package:gardians/screens/rules.dart';
import 'package:gardians/screens/location.dart';
import 'package:gardians/screens/alerts.dart';
import 'package:gardians/screens/profile.dart';
import 'package:gardians/screens/parent.dart';
import 'package:gardians/screens/alertsettings.dart';

// استيراد الـ Utils والموديلات
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';
import '../utils/background_generator.dart';
import '../models/parent.dart' as model;
import '../models/child.dart';

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
  List<Widget> _pages = [];

  // بيانات الأب والطفل
  late model.Parent currentParent;
  late Child selectedChild;

  // المرجع لقاعدة البيانات
  final _dbRef = FirebaseDatabase.instance.ref("users/parents");
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _loadLocalData(); // تحميل البيانات المحلية كـ Backup
    _initializePages();
  }

  void _loadLocalData() {
    String savedName =
        SharedPrefsUtils.getString(Constants.name) ?? "Guardian Parent";
    String savedEmail =
        SharedPrefsUtils.getString(Constants.email) ?? "parent@safeguard.com";
    currentParent = model.Parent(name: savedName, email: savedEmail);

    String savedChildName =
        SharedPrefsUtils.getString(Constants.childName) ?? "Select Child";
    selectedChild = Child(name: savedChildName, email: "");
  }

  void _initializePages() {
    _pages = [
      _dashboardBody(),
      const ChildLocationScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];
  }

  void _refreshChildData() {
    setState(() {
      _loadLocalData();
      _initializePages();
    });
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
    // 1. استخدام StreamBuilder لمراقبة بيانات الأب في Firebase
    return StreamBuilder(
      stream: _dbRef.child(_uid).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          // تحديث بيانات الأب من السيرفر
          currentParent = model.Parent(
            name: data['name'] ?? currentParent.name,
            email: data['email'] ?? currentParent.email,
          );

          // حفظ الاسم الجديد محلياً للـ Cache
          SharedPrefsUtils.setString(Constants.name, currentParent.name!);
        }

        return Scaffold(
          backgroundColor: backgroundGrey,
          drawer: _buildDynamicDrawer(),
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
          ),
          body: _pages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: 28,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color.fromARGB(255, 47, 152, 168),
            unselectedItemColor: navyBlue.withOpacity(0.3),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_pin),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dashboardBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DevicesScreen()),
              );
              _refreshChildData();
            },
            child: _buildChildSelector(),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppUsageScreen()),
            ),
            child: _buildScreenTimeCard(),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WeeklyReportScreen(),
              ),
            ),
            child: _buildMonitorCard(),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppRulesScreen(),
                    ),
                  ),
                  child: _buildBlockedSection(),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(child: _buildUsageSection()),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDynamicDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 125, 176, 188),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                BackgroundGenerator.getFirstCharacters(currentParent.name!),
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              currentParent.name!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(currentParent.email!),
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
          const Divider(),
          _buildDrawerItem(Icons.logout, "Logout", () {
            FirebaseAuth.instance.signOut(); // تسجيل الخروج من Firebase
            SharedPrefsUtils.clear();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Parent()),
              (route) => false,
            );
          }, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ميثودز الـ UI فضلت زي ما هي بالظبط
  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: skyBlue,
            child: Text(
              BackgroundGenerator.getFirstCharacters(selectedChild.name!),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SELECTED CHILD",
                style: TextStyle(
                  fontSize: 10,
                  color: navyBlue.withOpacity(0.5),
                ),
              ),
              Text(
                selectedChild.name!,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
        color: const Color(0x4D9ED7EB),
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
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: 60,
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
                        color: navyBlue.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Tap for detailed weekly analysis",
            style: TextStyle(fontSize: 10, color: navyBlue.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedSection() {
    return Container(
      padding: const EdgeInsets.all(15),
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
                "BLOCKED",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                ),
              ),
              const Icon(
                Icons.settings,
                size: 16,
                color: Color.fromARGB(255, 47, 152, 168),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _appBlockedItem("WhatsApp"),
          _appBlockedItem("TikTok"),
          Center(
            child: Text(
              "Manage Rules",
              style: TextStyle(fontSize: 10, color: navyBlue.withOpacity(0.5)),
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
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color: navyBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppUsageScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0x4D9ED7EB),
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
            _usageItem("YouTube", 0.7, Colors.brown),
            _usageItem("Roblox", 0.4, Colors.yellow),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "Full Stats",
                style: TextStyle(
                  fontSize: 10,
                  color: navyBlue.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageItem(String name, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[100],
            color: color,
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOTAL SCREEN TIME",
            style: TextStyle(
              fontSize: 12,
              color: navyBlue.withOpacity(0.5),
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
            style: TextStyle(color: navyBlue.withOpacity(0.5)),
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: 0.84,
            minHeight: 8,
            color: navyBlue,
            backgroundColor: Colors.grey[100],
          ),
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
}
