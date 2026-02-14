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
        // 1. مراقبة قائمة الـ IDs اللي تحت الأب
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
              // الـ key هنا هو الـ ID بتاع الطفل
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
    // 2. جلب "اسم الطفل" من نود users/children
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

        // 3. جلب "الحالة الحية" من نود devices_data
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
              padding: const EdgeInsets.all(15),
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
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      // حفظ البيانات لكي يقرأها الـ Dashboard فوراً
                      await SharedPrefsUtils.setString(
                        Constants.childId,
                        childId,
                      );
                      await SharedPrefsUtils.setString(
                        Constants.childName,
                        childName,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Row(
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
                  ),
                  const Divider(height: 30),
                  _buildActionButtons(),
                ],
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.history, size: 16),
            label: const Text("Usage"),
            onPressed: () {},
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
            onPressed: () {},
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
