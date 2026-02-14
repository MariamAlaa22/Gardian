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
  final Color accentBlue = const Color(0xFF5AB9D9);
  final Color backgroundGrey = const Color(0xFFF8F9FA);

  int _selectedIndex = 0;
  late model.Parent currentParent;
  String selectedChildUid = "";
  String selectedChildName = "Select Child";

  final String _parentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ميثود واحدة لتحميل كل البيانات وتجنب الـ Reload المتكرر
  void _loadData() {
    setState(() {
      // تحميل بيانات الأب
      String pName =
          SharedPrefsUtils.getString(Constants.name) ?? "Guardian Parent";
      String pEmail =
          SharedPrefsUtils.getString(Constants.email) ?? "parent@safeguard.com";
      currentParent = model.Parent(name: pName, email: pEmail);

      // تحميل بيانات الطفل المختار حالياً
      selectedChildUid = SharedPrefsUtils.getString(Constants.childId) ?? "";
      selectedChildName =
          SharedPrefsUtils.getString(Constants.childName) ?? "Select Child";
    });
  }

  void _refreshDashboard() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // قائمة الصفحات يتم تعريفها داخل الـ build للتفاعل مع الـ selectedIndex
    final List<Widget> pages = [
      _dashboardBody(),
      const ChildLocationScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: backgroundGrey,
      drawer: _buildDynamicDrawer(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        title: Text(
          _selectedIndex == 0 ? "Guardian" : _getAppBarTitle(),
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
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _dashboardBody() {
    // لو مفيش طفل مختار، اطلب منه يختار واحد
    if (selectedChildUid.isEmpty) {
      return _buildNoChildState();
    }

    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref("devices_data/$selectedChildUid")
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _buildWaitingForDataState();
        }

        final data = Map<dynamic, dynamic>.from(
          snapshot.data!.snapshot.value as Map,
        );

        int battery = data['battery_level'] ?? 0;
        bool isOnline = data['is_online'] ?? false;
        String currentApp = data['current_app'] ?? "Home Screen";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildLiveStatusCard(isOnline, battery),
              const SizedBox(height: 20),
              _buildChildSelectorCard(),
              const SizedBox(height: 20),
              _buildCurrentAppCard(currentApp),
              const SizedBox(height: 20),
              _buildScreenTimeCard(),
              const SizedBox(height: 20),
              _buildMonitorCard(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildBlockedSection()),
                  const SizedBox(width: 15),
                  Expanded(child: _buildUsageSection()),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- كروت البيانات الحية ---

  Widget _buildLiveStatusCard(bool isOnline, int battery) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                color: isOnline ? Colors.green : Colors.grey,
                size: 12,
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? "Online" : "Offline",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                battery > 20
                    ? Icons.battery_charging_full
                    : Icons.battery_alert,
                color: battery > 20 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                "$battery%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAppCard(String packageName) {
    String appName = packageName.contains('.')
        ? packageName.split('.').last
        : packageName;
    appName = appName[0].toUpperCase() + appName.substring(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [navyBlue, accentBlue]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CURRENTLY USING",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phonelink_setup, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelectorCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DevicesScreen()),
      ).then((_) => _refreshDashboard()),
      child: Container(
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
                BackgroundGenerator.getFirstCharacters(selectedChildName),
                style: const TextStyle(color: Colors.white),
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
                  selectedChildName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.unfold_more, color: navyBlue),
          ],
        ),
      ),
    );
  }

  // --- شاشات الخطأ والتحميل ---

  Widget _buildNoChildState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 80, color: navyBlue.withOpacity(0.2)),
          const SizedBox(height: 10),
          const Text("Please select a child to monitor"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DevicesScreen()),
            ).then((_) => _refreshDashboard()),
            child: const Text("Select Device"),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Waiting for connection...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Make sure 'Activate Protection' is enabled on $selectedChildName's phone.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- بقية الـ Widgets الخاصة بالتصميم (Screen Time, Charts, etc.) ---
  // (نفس الـ Widgets الجميلة اللي صممتها سابقاً)

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
          const Text(
            "4h 12m",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF042459),
            ),
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
              const Icon(Icons.security, color: Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: 90,
                    radius: 15,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: 10,
                    radius: 15,
                    showTitle: false,
                  ),
                ],
              ),
            ),
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
          Text(
            "BLOCKED",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: navyBlue,
            ),
          ),
          const SizedBox(height: 10),
          _appBlockedItem("TikTok"),
          _appBlockedItem("Snapchat"),
        ],
      ),
    );
  }

  Widget _appBlockedItem(String name) {
    return Row(
      children: [
        const Icon(Icons.block, size: 14, color: Colors.red),
        const SizedBox(width: 5),
        Text(name, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildUsageSection() {
    return Container(
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
          const SizedBox(height: 10),
          _usageItem("YouTube", 0.8),
          _usageItem("Games", 0.4),
        ],
      ),
    );
  }

  Widget _usageItem(String name, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontSize: 10)),
        LinearProgressIndicator(value: val, minHeight: 2, color: accentBlue),
      ],
    );
  }

  // --- التنقل والـ Navigation ---

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color.fromARGB(255, 47, 152, 168),
      unselectedItemColor: navyBlue.withOpacity(0.3),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.location_pin), label: ""),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: "",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
      ],
    );
  }

  Widget _buildDynamicDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 125, 176, 188),
            ),
            accountName: Text(currentParent.name!),
            accountEmail: Text(currentParent.email!),
            currentAccountPicture: CircleAvatar(
              child: Text(
                BackgroundGenerator.getFirstCharacters(currentParent.name!),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("App Rules"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppRulesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () => FirebaseAuth.instance.signOut().then(
              (_) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Parent()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
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
}
