import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// استيراد الشاشات
import 'package:gardians/screens/commdetails.dart';
import 'package:gardians/screens/devices.dart';
import 'package:gardians/screens/alertsettings.dart';
import 'package:gardians/screens/alerts.dart';
import 'package:gardians/screens/location.dart';
import 'package:gardians/screens/profile.dart';
import 'package:gardians/screens/reports.dart';
import 'package:gardians/screens/rules.dart';
import 'package:gardians/screens/usage.dart';

// 1. حل مشكلة الـ Ambiguous Import باستخدام كلمة 'as'
import 'package:gardians/screens/parent.dart' as screen;
import '../models/parent.dart' as model;

// استيراد باقي الـ Utils والموديلات
import '../models/child.dart';
import '../utils/background_generator.dart';
import '../utils/account_utils.dart';

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

  // 2. تحديث تعريف الموديلات باستخدام الـ Prefix الجديد
  final model.Parent currentParent = model.Parent(
    name: "Abdelrahman Amr",
    email: "abdelrahmanamr.eltawab@gmail.com",
  );

  final Child selectedChild = Child(
    name: "Billy's iPhone",
    email: "billy@safeguard.com",
  );

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

  // ... (نفس كود الـ AppBar والـ Drawer اللي فات)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // 3. حل مشكلة الـ Method undefined: أضفت لك الميثودز اللي كانت ناقصة تحت

  Widget _dashboardBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildChildSelector(),
          const SizedBox(height: 20),
          _buildScreenTimeCard(), // دي اللي كانت عاملة Error
          const SizedBox(height: 20),
          _buildMonitorCard(), // ودي كمان
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
        ],
      ),
    );
  }

  // --- الميثودز اللي كانت ناقصة عشان الايرور يروح ---

  Widget _buildScreenTimeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text(
            "TOTAL SCREEN TIME",
            style: TextStyle(fontWeight: FontWeight.bold),
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
          LinearProgressIndicator(
            value: 0.8,
            color: navyBlue,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: skyBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: Text("AI Content Monitor - Safe")),
    );
  }

  // ... (باقي الـ Widgets الفرعية اللي في الكود الأصلي بتاعك زي _buildBlockedSection و _buildUsageSection)

  // تعديل الـ Drawer عشان يستخدم الموديل الصح
  Widget _buildDrawer() {
    return Drawer(
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
              ),
            ),
            accountName: Text(currentParent.name!),
            accountEmail: Text(currentParent.email!),
          ),
          // ... باقي الـ ListTile
        ],
      ),
    );
  }

  // الميثودز المساعدة
  String _getAppBarTitle() {
    /* ... */
    return "Guardian";
  }

  // تحديث الـ Child Selector عشان يظهر حروف اسم الطفل
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
            backgroundColor: BackgroundGenerator.getRandomColor(), // لون عشوائي
            child: Text(
              BackgroundGenerator.getFirstCharacters(
                selectedChild.name!,
              ), // حروف اسم الطفل
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            selectedChild.name!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Icon(Icons.unfold_more, color: navyBlue),
        ],
      ),
    );
  }

  Widget _buildBlockedSection() {
    return Container();
  }

  Widget _buildUsageSection() {
    return Container();
  }

  Widget _buildCommunicationSection() {
    return Container();
  }

  // تحديث الـ Bottom Nav عشان ميعملش Crash
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: const Color.fromARGB(255, 47, 152, 168),
      unselectedItemColor: navyBlue.withOpacity(0.3),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_pin),
          label: "Location",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: "Alerts",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    IconData i,
    String t,
    VoidCallback o, {
    bool isLogout = false,
  }) {
    return ListTile();
  }
}
