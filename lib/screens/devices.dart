import 'package:flutter/material.dart';
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

  // القائمة الأساسية
  List<Map<String, dynamic>> pairedDevices = [
    {
      "id": "dev_1",
      "name": "Leo's iPhone 13",
      "sub": "Active now",
      "icon": Icons.phone_android,
      "color": Colors.green,
      "status": null,
    },
    {
      "id": "dev_2",
      "name": "Mila's iPad",
      "sub": "Last seen 5m ago",
      "icon": Icons.tablet_mac,
      "color": Colors.grey,
      "status": "OFFLINE",
    },
    {
      "id": "dev_3",
      "name": "Home Desktop",
      "sub": "Monitoring active",
      "icon": Icons.computer,
      "color": Colors.orange,
      "status": "RESTRICTED",
    },
  ];

  @override
  void initState() {
    super.initState();
    _syncDevicesWithStorage();
  }

  // ميثود لمزامنة القائمة مع المحذوفات والأسماء المعدلة
  void _syncDevicesWithStorage() {
    setState(() {
      // 1. استرجاع قائمة الـ IDs اللي اليوزر مسحها
      List<String> deletedIds =
          SharedPrefsUtils.getStringList("deleted_devices") ?? [];

      // 2. فلترة القائمة الأساسية (نشيل منها أي ID موجود في قائمة المسح)
      pairedDevices.removeWhere((device) => deletedIds.contains(device["id"]));

      // 3. تحديث الأسماء المعدلة للأجهزة اللي فضلت
      for (var device in pairedDevices) {
        String? savedName = SharedPrefsUtils.getString(
          "device_name_${device['id']}",
        );
        if (savedName != null) {
          device["name"] = savedName;
        }
      }
    });
  }

  // ميثود الحذف الدائم
  void _deleteDevicePermanently(int index, String id) async {
    // 1. نجيب قائمة المحذوفات الحالية
    List<String> deletedIds =
        SharedPrefsUtils.getStringList("deleted_devices") ?? [];

    // 2. نضيف الـ ID الجديد للقائمة
    deletedIds.add(id);

    // 3. نحفظ القائمة المحدثة في الذاكرة
    await SharedPrefsUtils.setStringList("deleted_devices", deletedIds);

    // 4. نحدث الـ UI فوراً
    setState(() {
      pairedDevices.removeAt(index);
    });
  }

  void _showEditDialog(int index, String currentName) {
    TextEditingController _editController = TextEditingController(
      text: currentName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Device Name", style: TextStyle(color: navyBlue)),
        content: TextField(controller: _editController, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: navyBlue),
            onPressed: () async {
              if (_editController.text.isNotEmpty) {
                setState(
                  () => pairedDevices[index]["name"] = _editController.text,
                );
                await SharedPrefsUtils.setString(
                  "device_name_${pairedDevices[index]['id']}",
                  _editController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: pairedDevices.isEmpty
            ? const Center(child: Text("No devices paired."))
            : ListView.separated(
                itemCount: pairedDevices.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) =>
                    _buildDeviceCard(index, pairedDevices[index]),
              ),
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

  Widget _buildDeviceCard(int index, Map<String, dynamic> device) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              await SharedPrefsUtils.setString(
                Constants.childName,
                device["name"],
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: device["color"].withOpacity(0.1),
                  child: Icon(device["icon"], color: device["color"]),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      device["sub"],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.blue,
                  size: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  onPressed: () => _showEditDialog(index, device["name"]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () =>
                      _deleteDevicePermanently(index, device["id"]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
