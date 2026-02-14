import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gardians/screens/addchild.dart';
import '../utils/background_generator.dart';
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final Color navyBlue = const Color(0xFF042459);
  final String _parentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

  // دالة موحدة لحفظ بيانات الطفل المختار في الـ Shared Preferences
  Future<void> _saveChildData(String id, String name) async {
    await SharedPrefsUtils.setString(Constants.childId, id);
    await SharedPrefsUtils.setString(Constants.childName, name);
    // تأكيد إضافي لضمان مطابقة الـ Key المستخدم في شاشة الخريطة
    await SharedPrefsUtils.setString("selected_child_name", name);

    debugPrint("✅ [Devices] Child Saved Globally: ID=$id, Name=$name");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        title: Text(
          "Paired Devices",
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref("users/parents/$_parentUid/children")
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null ||
              snapshot.data!.snapshot.value is! Map) {
            return _buildEmptyState();
          }

          final Map<dynamic, dynamic> childrenData = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: childrenData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              String childId = childrenData.keys.elementAt(index);
              return _buildDeviceCard(childId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 47, 152, 168),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddChildScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDeviceCard(String childId) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref("users/children/$childId").onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> childSnapshot) {
        if (!childSnapshot.hasData ||
            childSnapshot.data!.snapshot.value == null) {
          return const SizedBox.shrink();
        }

        final childData = Map<dynamic, dynamic>.from(
          childSnapshot.data!.snapshot.value as Map,
        );
        String childName = childData['name'] ?? "Unknown Child";

        return StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref("devices_data/$childId")
              .onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> statusSnapshot) {
            int battery = 0;
            bool isOnline = false;

            if (statusSnapshot.hasData &&
                statusSnapshot.data!.snapshot.value != null) {
              var statusMap = statusSnapshot.data!.snapshot.value as Map;
              battery = statusMap['battery_level'] ?? 0;
              isOnline = statusMap['is_online'] ?? false;
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  // 1. انتظر انتهاء عملية الحفظ تماماً
                  await _saveChildData(childId, childName);

                  // 2. تأكد أن البيانات طُبعت في الـ Console قبل الخروج
                  debugPrint(
                    "💾 [DevicesScreen] Final Save Check: ID=$childId",
                  );

                  if (context.mounted) {
                    // 3. ارجع للداشبورد
                    Navigator.pop(context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: navyBlue.withOpacity(0.1),
                            child: Text(
                              BackgroundGenerator.getFirstCharacters(childName),
                              style: TextStyle(
                                color: navyBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                childName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                isOnline ? "Active Now" : "Offline",
                                style: TextStyle(
                                  color: isOnline ? Colors.green : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildBatteryIndicator(battery),
                        ],
                      ),
                      const Divider(height: 30),
                      _buildActionButtons(childId, childName),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBatteryIndicator(int battery) {
    return Column(
      children: [
        Icon(
          battery > 20 ? Icons.battery_full : Icons.battery_alert,
          color: battery > 20 ? Colors.green : Colors.red,
          size: 20,
        ),
        Text("$battery%", style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildActionButtons(String id, String name) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.history, size: 16),
            label: const Text("Usage"),
            onPressed: () async {
              await _saveChildData(id, name);
              // Navigator.pushNamed(context, '/usage');
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.settings_outlined, size: 16),
            label: const Text("Rules"),
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _saveChildData(id, name);
              // Navigator.pushNamed(context, '/rules');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 100,
            color: navyBlue.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
          Text(
            "No devices paired yet",
            style: TextStyle(
              color: navyBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text("Add your child's device to start monitoring"),
        ],
      ),
    );
  }
}
