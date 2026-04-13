import 'package:flutter/material.dart';
import 'package:gardians/services/guardian_native_bridge.dart';
import 'package:gardians/screens/otp.dart';
import 'package:gardians/screens/pairing.dart';

class LegacyBridgeTestScreen extends StatefulWidget {
  const LegacyBridgeTestScreen({super.key});

  @override
  State<LegacyBridgeTestScreen> createState() => _LegacyBridgeTestScreenState();
}

class _LegacyBridgeTestScreenState extends State<LegacyBridgeTestScreen> {
  final TextEditingController _childEmailController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController(text: 'Child');

  bool _loading = false;
  String _status = 'Idle';
  Map<String, dynamic> _location = <String, dynamic>{};
  List<Map<String, dynamic>> _calls = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardian Legacy Bridge Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(onPressed: _loading ? null : _startMonitoring, child: const Text('Start Monitoring')),
                OutlinedButton(onPressed: _loading ? null : _stopMonitoring, child: const Text('Stop Monitoring')),
                ElevatedButton(onPressed: _loading ? null : _loadCalls, child: const Text('Get Call Logs')),
                ElevatedButton(onPressed: _loading ? null : _loadMessages, child: const Text('Get SMS Logs')),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PairingCodeScreen())),
                  child: const Text('Parent OTP Screen'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OTPScreen())),
                  child: const Text('Child OTP Screen'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Geofence', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _childEmailController,
              decoration: const InputDecoration(
                labelText: 'Child email (must exist in users/childs/*/email)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _childNameController,
              decoration: const InputDecoration(
                labelText: 'Child name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(onPressed: _loading ? null : _startGeofence, child: const Text('Start Geofence')),
                OutlinedButton(onPressed: _loading ? null : _stopGeofence, child: const Text('Stop Geofence')),
                ElevatedButton(onPressed: _loading ? null : _loadLocation, child: const Text('Get Last Location')),
              ],
            ),
            const SizedBox(height: 12),
            Text('Location: $_location'),
            const Divider(height: 30),
            Text('Calls (${_calls.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._calls.take(10).map((e) => Text(e.toString())),
            const Divider(height: 30),
            Text('Messages (${_messages.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._messages.take(10).map((e) => Text(e.toString())),
          ],
        ),
      ),
    );
  }

  Future<void> _startMonitoring() async {
    await _run(() async {
      await GuardianNativeBridge.startMonitoring();
      _status = 'Monitoring started';
    });
  }

  Future<void> _stopMonitoring() async {
    await _run(() async {
      await GuardianNativeBridge.stopMonitoring();
      _status = 'Monitoring stopped';
    });
  }

  Future<void> _loadCalls() async {
    await _run(() async {
      _calls = await GuardianNativeBridge.getCallLogs();
      _status = 'Loaded calls';
    });
  }

  Future<void> _loadMessages() async {
    await _run(() async {
      _messages = await GuardianNativeBridge.getSmsLogs();
      _status = 'Loaded messages';
    });
  }

  Future<void> _startGeofence() async {
    final email = _childEmailController.text.trim();
    final name = _childNameController.text.trim().isEmpty ? 'Child' : _childNameController.text.trim();
    if (email.isEmpty) {
      _show('Please provide child email');
      return;
    }
    await _run(() async {
      await GuardianNativeBridge.startGeofence(childEmail: email, childName: name);
      _status = 'Geofence started';
    });
  }

  Future<void> _stopGeofence() async {
    await _run(() async {
      await GuardianNativeBridge.stopGeofence();
      _status = 'Geofence stopped';
    });
  }

  Future<void> _loadLocation() async {
    await _run(() async {
      _location = await GuardianNativeBridge.getLastLocation();
      _status = 'Loaded location';
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      setState(() => _loading = true);
      await action();
      if (mounted) setState(() {});
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _childEmailController.dispose();
    _childNameController.dispose();
    super.dispose();
  }
}
