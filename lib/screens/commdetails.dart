import 'package:flutter/material.dart';

class CommunicationDetailsScreen extends StatefulWidget {
  const CommunicationDetailsScreen({super.key});

  @override
  State<CommunicationDetailsScreen> createState() => _CommunicationDetailsScreenState();
}


class _CommunicationDetailsScreenState extends State<CommunicationDetailsScreen> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color.fromARGB(255, 151, 207, 220);
  
  String _activeTab = "Calls"; 

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 8, 
              itemBuilder: (context, index) {
                if (_activeTab == "Contacts") {
                  return _buildContactItem("Youssef Mohamed", "+20 123 456 789");
                } else {
                  return _buildLogItem(
                    title: _activeTab == "Calls" ? "Dad" : "Mom",
                    subtitle: _activeTab == "Calls" ? "Incoming • 5m 12s" : "See you soon!",
                    time: "10:30 AM",
                    icon: _activeTab == "Calls" ? Icons.call_received : Icons.chat_bubble_outline,
                    color: _activeTab == "Calls" ? Colors.green : Colors.purple,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    bool isSelected = (_activeTab == label);
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? navyBlue : Colors.white.withValues(alpha: 0.3),
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
            backgroundColor: skyBlue.withValues(alpha: 0.4),
            child: Text(name[0], style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(phone, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const Spacer(),
          Icon(Icons.info_outline, color: navyBlue.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildLogItem({required String title, required String subtitle, required String time, required IconData icon, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }
}