import 'package:flutter/material.dart';

class AppRulesScreen extends StatefulWidget {  
  const AppRulesScreen({super.key});

  @override
  State<AppRulesScreen> createState() => _AppRulesScreenState();
}

class _AppRulesScreenState extends State<AppRulesScreen> {
  final Color navyBlue = const Color(0xFF042459);
  
  String _activeTab = "All";

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
        title: Text("Control Apps", style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
        color: const Color.fromARGB(255, 151, 207, 220),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTab("All"),
                _buildTab("Blocked"),
                _buildTab("Limited"),
                _buildTab("Allowed"),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search apps...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
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

  Widget _buildTab(String label) {
    bool isSelected = (_activeTab == label);
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = label; 
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? navyBlue : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFilteredList() {
    List<Widget> items = [];

    if (_activeTab == "All" || _activeTab == "Allowed" || _activeTab == "Blocked") {
      items.add(_buildCategoryHeader("Communication", ""));
      
      if (_activeTab == "All" || _activeTab == "Allowed") {
        items.add(_buildAppRuleItem("WhatsApp", Icons.chat, "Allowed", Colors.green));
      }
      if (_activeTab == "All") {
        items.add(_buildAppRuleItem("Instagram", Icons.camera_alt, "12+", Colors.grey));
      }
      if (_activeTab == "All" || _activeTab == "Blocked") {
        items.add(_buildAppRuleItem("Snapchat", Icons.snapchat, "Blocked", Colors.red));
      }
    }

    items.add(const SizedBox(height: 20));

    if (_activeTab == "All" || _activeTab == "Limited") {
      items.add(_buildCategoryHeader("Games", ""));
      items.add(_buildAppRuleItem("Roblox", Icons.gamepad, "Limited", Colors.orange));
    }

    return items;
  }

  Widget _buildCategoryHeader(String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Icon(Icons.keyboard_arrow_up),
        ],
      ),
    );
  }

  Widget _buildAppRuleItem(String name, IconData icon, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.radio_button_off, color: Colors.grey),
          const SizedBox(width: 10),
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}