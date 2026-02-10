import 'package:flutter/material.dart';

class AlertsSettingsScreen extends StatefulWidget {
  const AlertsSettingsScreen({super.key});

  @override
  State<AlertsSettingsScreen> createState() => _AlertsSettingsScreenState();
}

class _AlertsSettingsScreenState extends State<AlertsSettingsScreen> {
  bool _locationAlerts = true;
  bool _timeLimits = true;
  bool _contentAlerts = true;
  bool _batteryAlerts = false;

  final Color navyBlue = const Color(0xFF042459);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9ED7EB), 
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Alerts Settings", 
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Notification Preferences", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          const Text("Choose which activities you want to be notified about.", 
            style: TextStyle(color: Colors.grey, fontSize: 14)),
          
          const SizedBox(height: 30),

          _buildSwitchTile(
            "Location Alerts", 
            "Receive alerts when child enters or leaves safe zones", 
            _locationAlerts, 
            (val) => setState(() => _locationAlerts = val)
          ),
          const Divider(),
          _buildSwitchTile(
            "Time Limits", 
            "Notify when daily screen time limit is reached", 
            _timeLimits, 
            (val) => setState(() => _timeLimits = val)
          ),
          const Divider(),
          _buildSwitchTile(
            "Content Safety", 
            "Notify when harmful content is detected or blocked", 
            _contentAlerts, 
            (val) => setState(() => _contentAlerts = val)
          ),
          const Divider(),
          _buildSwitchTile(
            "Battery Alerts", 
            "Notify when child's device battery is low (below 15%)", 
            _batteryAlerts, 
            (val) => setState(() => _batteryAlerts = val)
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String sub, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white, 
        activeTrackColor: navyBlue, 
        inactiveThumbColor: Colors.grey[300], 
        inactiveTrackColor: Colors.grey[100],
      ),
    );
  }
}