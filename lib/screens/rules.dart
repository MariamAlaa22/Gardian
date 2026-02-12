import 'package:flutter/material.dart';
import '../utils/shared_prefs_utils.dart';

// 1. تعريف موديل التطبيق
class AppModel {
  String name;
  IconData icon;
  String status;
  String category;

  AppModel({
    required this.name,
    required this.icon,
    required this.status,
    required this.category,
  });
}

class AppRulesScreen extends StatefulWidget {
  const AppRulesScreen({super.key});

  @override
  State<AppRulesScreen> createState() => _AppRulesScreenState();
}

class _AppRulesScreenState extends State<AppRulesScreen> {
  final Color navyBlue = const Color(0xFF042459);
  String _activeTab = "All";
  String _searchQuery = "";

  // 2. قائمة التطبيقات الأساسية (ستتحول لـ Dynamic عند التحميل)
  List<AppModel> _apps = [
    AppModel(
      name: "WhatsApp",
      icon: Icons.chat,
      status: "Allowed",
      category: "Communication",
    ),
    AppModel(
      name: "Instagram",
      icon: Icons.camera_alt,
      status: "Allowed",
      category: "Communication",
    ),
    AppModel(
      name: "Snapchat",
      icon: Icons.snapchat,
      status: "Blocked",
      category: "Communication",
    ),
    AppModel(
      name: "Roblox",
      icon: Icons.gamepad,
      status: "Limited",
      category: "Games",
    ),
    AppModel(
      name: "TikTok",
      icon: Icons.tiktok,
      status: "Blocked",
      category: "Entertainment",
    ),
    AppModel(
      name: "YouTube",
      icon: Icons.video_library,
      status: "Limited",
      category: "Entertainment",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAppStatuses(); // تحميل الحالات المحفوظة
  }

  // تحميل الحالات من الذاكرة
  void _loadAppStatuses() {
    setState(() {
      for (var app in _apps) {
        String? savedStatus = SharedPrefsUtils.getString(
          "app_status_${app.name}",
        );
        if (savedStatus != null) {
          app.status = savedStatus;
        }
      }
    });
  }

  // تغيير الحالة وحفظها
  void _updateAppStatus(int index, String newStatus) async {
    setState(() {
      _apps[index].status = newStatus;
    });
    await SharedPrefsUtils.setString(
      "app_status_${_apps[index].name}",
      newStatus,
    );
  }

  // إضافة تطبيق جديد
  void _addNewApp(String name, String category) {
    setState(() {
      _apps.add(
        AppModel(
          name: name,
          icon: Icons.apps,
          status: "Allowed",
          category: category,
        ),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Blocked":
        return Colors.red;
      case "Limited":
        return Colors.orange;
      case "Allowed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Control Apps",
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: navyBlue,
        onPressed: _showAddAppDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 151, 207, 220),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "All",
                "Blocked",
                "Limited",
                "Allowed",
              ].map((tab) => _buildTab(tab)).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search apps...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _buildFilteredList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- ميثودز بناء العناصر ---

  List<Widget> _buildFilteredList() {
    List<AppModel> filteredApps = _apps.where((app) {
      bool matchesTab = (_activeTab == "All") || (app.status == _activeTab);
      bool matchesSearch = app.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesTab && matchesSearch;
    }).toList();

    if (filteredApps.isEmpty)
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text("No apps found"),
          ),
        ),
      ];

    Map<String, List<AppModel>> groupedApps = {};
    for (var app in filteredApps) {
      groupedApps.putIfAbsent(app.category, () => []).add(app);
    }

    List<Widget> items = [];
    groupedApps.forEach((category, apps) {
      items.add(_buildCategoryHeader(category, apps.length.toString()));
      items.addAll(
        apps.map((app) {
          int originalIndex = _apps.indexOf(app);
          return _buildAppRuleItem(originalIndex, app);
        }),
      );
    });
    return items;
  }

  Widget _buildAppRuleItem(int index, AppModel app) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(index), // مسح بالضغط المطول
      onTap: () => _showStatusPicker(index), // تعديل بالضغط العادي
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(app.icon, color: navyBlue),
            const SizedBox(width: 15),
            Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            _statusBadge(app.status),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- ديالوجات التحكم ---

  void _showStatusPicker(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ["Allowed", "Limited", "Blocked"].map((status) {
          return ListTile(
            title: Text(
              status,
              style: TextStyle(color: _getStatusColor(status)),
            ),
            onTap: () {
              _updateAppStatus(index, status);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showAddAppDialog() {
    String newName = "";
    String newCat = "Other";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New App"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (v) => newName = v,
              decoration: const InputDecoration(hintText: "App Name"),
            ),
            TextField(
              onChanged: (v) => newCat = v,
              decoration: const InputDecoration(hintText: "Category"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (newName.isNotEmpty) _addNewApp(newName, newCat);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Rule?"),
        content: Text(
          "Do you want to remove ${_apps[index].name} from the list?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() => _apps.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    bool isSelected = (_activeTab == label);
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? navyBlue : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "$title ($count)",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
