import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // needed for MethodChannel

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  // This MUST match the exact string in MainActivity.java
  static const _channel = MethodChannel('com.kidsafe/apps');

  List<Map<String, String>> _apps = []; // will hold the app list
  bool _loading = true; // shows spinner while loading
  String? _error; // holds error message if something fails

  @override
  void initState() {
    super.initState();
    _loadApps(); // automatically load apps when screen opens
  }

  // This function calls Java through the channel
  Future<void> _loadApps() async {
    try {
      // This line calls Java's getInstalledApps() method
      final List result = await _channel.invokeMethod('getInstalledApps');

      // Convert the result into a Dart list
      setState(() {
        _apps = result.map((e) => Map<String, String>.from(e)).toList();
        _loading = false;
      });
    } on PlatformException catch (e) {
      // If Java throws an error, show it on screen
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Apps'),
        actions: [
          // Refresh button — reloads the app list
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _loadApps();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show spinner while loading
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show error if something went wrong
    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    // Show empty message
    if (_apps.isEmpty) {
      return const Center(child: Text('No apps found'));
    }
    // Show the list of apps
    return ListView.separated(
      itemCount: _apps.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final app = _apps[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.android)),
          title: Text(app['name'] ?? ''), // app name
          subtitle: Text(
            app['package'] ?? '', // package name below
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}
