import 'package:flutter/material.dart';

// 1. موديل بيانات الاتصال
class CommLog {
  final String name;
  final String detail; // مدة المكالمة أو نص الرسالة أو رقم الهاتف
  final String time;
  final String type; // Calls, Messages, Contacts
  final IconData icon;
  final Color color;

  CommLog({
    required this.name,
    required this.detail,
    required this.time,
    required this.type,
    required this.icon,
    required this.color,
  });
}

class CommunicationDetailsScreen extends StatefulWidget {
  const CommunicationDetailsScreen({super.key});

  @override
  State<CommunicationDetailsScreen> createState() =>
      _CommunicationDetailsScreenState();
}

class _CommunicationDetailsScreenState
    extends State<CommunicationDetailsScreen> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color.fromARGB(255, 151, 207, 220);

  String _activeTab = "Calls";
  String _searchQuery = "";

  // 2. قائمة بيانات تجريبية (Mock Data)
  final List<CommLog> _allLogs = [
    CommLog(
      name: "Dad",
      detail: "Incoming • 5m 12s",
      time: "10:30 AM",
      type: "Calls",
      icon: Icons.call_received,
      color: Colors.green,
    ),
    CommLog(
      name: "Mom",
      detail: "See you soon!",
      time: "09:15 AM",
      type: "Messages",
      icon: Icons.chat_bubble_outline,
      color: Colors.purple,
    ),
    CommLog(
      name: "Youssef Mohamed",
      detail: "+20 123 456 789",
      time: "",
      type: "Contacts",
      icon: Icons.person,
      color: Colors.blue,
    ),
    CommLog(
      name: "Sister",
      detail: "Missed Call",
      time: "Yesterday",
      type: "Calls",
      icon: Icons.call_missed,
      color: Colors.red,
    ),
    CommLog(
      name: "Coach",
      detail: "Training at 5",
      time: "08:00 AM",
      type: "Messages",
      icon: Icons.chat_bubble_outline,
      color: Colors.purple,
    ),
    CommLog(
      name: "Grandma",
      detail: "+20 987 654 321",
      time: "",
      type: "Contacts",
      icon: Icons.person,
      color: Colors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 3. فلترة الداتا بناءً على الـ Tab المختار والبحث
    final filteredLogs = _allLogs.where((log) {
      bool matchesTab = log.type == _activeTab;
      bool matchesSearch = log.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: skyBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Communication Logs",
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: skyBlue,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab("Calls"),
                _buildTab("Messages"),
                _buildTab("Contacts"),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (val) =>
                  setState(() => _searchQuery = val), // ربط البحث
              decoration: InputDecoration(
                hintText: "Search $_activeTab...",
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
            child: filteredLogs.isEmpty
                ? Center(child: Text("No items found in $_activeTab"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      if (_activeTab == "Contacts") {
                        return _buildContactItem(log.name, log.detail);
                      } else {
                        return _buildLogItem(
                          title: log.name,
                          subtitle: log.detail,
                          time: log.time,
                          icon: log.icon,
                          color: log.color,
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ميثود الـ Tab والـ Item فضلت زي ما هي في الـ UI مع ربطها بالـ Model
  Widget _buildTab(String label) {
    bool isSelected = (_activeTab == label);
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? navyBlue : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(String name, String phone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: skyBlue.withOpacity(0.4),
            child: Text(
              name[0],
              style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                phone,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.info_outline, color: navyBlue.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildLogItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }
}
