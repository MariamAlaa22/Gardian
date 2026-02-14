import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class AppRulesScreen extends StatefulWidget {
  const AppRulesScreen({super.key});

  @override
  State<AppRulesScreen> createState() => _AppRulesScreenState();
}

class _AppRulesScreenState extends State<AppRulesScreen> {
  final Color navyBlue = const Color(0xFF042459);
  String _activeTab = "All";
  String _searchQuery = "";
  late String selectedChildUid;

  @override
  void initState() {
    super.initState();
    // جلب الـ UID المخزن عند اختيار الطفل من شاشة الـ Devices
    selectedChildUid = SharedPrefsUtils.getString(Constants.childId) ?? "";
  }

  void _toggleAppBlock(String packageKey, bool isBlocked) async {
    if (selectedChildUid.isEmpty) return;

    // تحديث مباشر لقيمة is_blocked في قاعدة البيانات
    await FirebaseDatabase.instance
        .ref("devices_data/$selectedChildUid/installed_apps/$packageKey")
        .update({"is_blocked": isBlocked});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        title: Text(
          "Control Apps",
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildTabHeader(),
          _buildSearchField(),
          Expanded(
            child: selectedChildUid.isEmpty
                ? const Center(child: Text("Please select a child first"))
                : _buildLiveAppsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAppsList() {
    return StreamBuilder(
      // مراقبة مسار التطبيقات الخاص بالطفل المحدد
      stream: FirebaseDatabase.instance
          .ref("devices_data/$selectedChildUid/installed_apps")
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text("No apps found on child's device"));
        }

        // تحويل البيانات القادمة من Firebase
        final dynamic rawData = snapshot.data!.snapshot.value;
        Map<dynamic, dynamic> appsData = Map<dynamic, dynamic>.from(
          rawData as Map,
        );

        List<Map<String, dynamic>> appsList = [];
        appsData.forEach((key, value) {
          appsList.add({
            "key": key, // هذا هو الباكيج نيم المعدل (مثال: com_whatsapp)
            "name": value['app_name'] ?? "Unknown",
            "package": value['package_name'] ?? "",
            "is_blocked": value['is_blocked'] ?? false,
          });
        });

        // ترتيب الأبجدية: التطبيقات المحظورة تظهر في الأعلى أولاً ثم البقية
        appsList.sort(
          (a, b) =>
              b['is_blocked'].toString().compareTo(a['is_blocked'].toString()),
        );

        // الفلترة
        var filteredList = appsList.where((app) {
          bool matchesSearch = app['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          bool matchesTab =
              _activeTab == "All" ||
              (_activeTab == "Blocked" && app['is_blocked']) ||
              (_activeTab == "Allowed" && !app['is_blocked']);
          return matchesSearch && matchesTab;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filteredList.length,
          itemBuilder: (context, index) => _buildAppItem(filteredList[index]),
        );
      },
    );
  }

  Widget _buildAppItem(Map<String, dynamic> app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: app['is_blocked']
              ? Colors.red.withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: app['is_blocked']
                ? Colors.red.withOpacity(0.1)
                : navyBlue.withOpacity(0.1),
            child: Icon(
              app['is_blocked'] ? Icons.block : Icons.android,
              color: app['is_blocked'] ? Colors.red : navyBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  app['package'],
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // زر القفل/الفتح
          Switch(
            value: app['is_blocked'],
            activeColor: Colors.red,
            onChanged: (val) => _toggleAppBlock(app['key'], val),
          ),
        ],
      ),
    );
  }

  // ... (نفس ميثودز الـ Header والـ Search اللي في كودك)
  Widget _buildTabHeader() {
    /* ... */
    return Container();
  } // تأكد من بقاء الكود الخاص بك هنا

  Widget _buildSearchField() {
    /* ... */
    return Container();
  } // تأكد من بقاء الكود الخاص بك هنا
}
