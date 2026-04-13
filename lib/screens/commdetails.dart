import 'package:flutter/material.dart';
import 'package:gardians/services/guardian_native_bridge.dart';

class CommunicationDetailsScreen extends StatefulWidget {
  const CommunicationDetailsScreen({super.key});

  @override
  State<CommunicationDetailsScreen> createState() => _CommunicationDetailsScreenState();
}


class _CommunicationDetailsScreenState extends State<CommunicationDetailsScreen> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color.fromARGB(255, 151, 207, 220);
  
  String _activeTab = "Calls"; 
  bool _loading = false;
  List<Map<String, dynamic>> _calls = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _contacts = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _startMonitoring,
                          child: const Text('Start Monitoring'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading ? null : _stopMonitoring,
                          child: const Text('Stop Monitoring'),
                        ),
                      ),
                      IconButton(
                        onPressed: _loading ? null : _refreshLogs,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildActiveTabList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeTab == 'Contacts') {
      if (_contacts.isEmpty) {
        return const Center(child: Text('No contacts yet. Pair child then refresh.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final item = _contacts[index];
          final name = (item['contactName'] ?? 'Unknown').toString();
          final number = (item['contactNumber'] ?? '').toString();
          return _buildContactItem(name, number);
        },
      );
    }

    final List<Map<String, dynamic>> list = _activeTab == 'Calls' ? _calls : _messages;
    if (list.isEmpty) {
      return const Center(child: Text('No logs yet. Start monitoring then refresh.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> item = list[index];
        if (_activeTab == 'Calls') {
          final String title = (item['contactName'] ?? item['phoneNumber'] ?? 'Unknown').toString();
          final String callType = (item['callType'] ?? 'Call').toString();
          final String duration = (item['callDurationInSeconds'] ?? '-').toString();
          return _buildLogItem(
            title: title,
            subtitle: '$callType • ${duration}s',
            time: (item['callTime'] ?? '').toString(),
            icon: Icons.call,
            color: Colors.green,
          );
        }

        final String title = (item['contactName'] ?? item['senderPhoneNumber'] ?? 'Unknown').toString();
        return _buildLogItem(
          title: title,
          subtitle: (item['messageBody'] ?? '').toString(),
          time: (item['timeReceived'] ?? '').toString(),
          icon: Icons.chat_bubble_outline,
          color: Colors.purple,
        );
      },
    );
  }

  Future<void> _startMonitoring() async {
    try {
      setState(() => _loading = true);
      await GuardianNativeBridge.startMonitoring();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monitoring started')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Start failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _stopMonitoring() async {
    try {
      await GuardianNativeBridge.stopMonitoring();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monitoring stopped')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stop failed: $e')));
    }
  }

  Future<void> _refreshLogs() async {
    try {
      setState(() => _loading = true);
      final calls = await GuardianNativeBridge.getCallLogs();
      final messages = await GuardianNativeBridge.getSmsLogs();
      final contacts = await GuardianNativeBridge.getContacts();
      if (!mounted) return;
      setState(() {
        _calls = calls.reversed.toList();
        _messages = messages.reversed.toList();
        _contacts = contacts;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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