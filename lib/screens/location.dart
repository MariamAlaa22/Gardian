import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gardians/services/guardian_native_bridge.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  static const LatLng _fallbackPos = LatLng(30.0444, 31.2357);
  
  late GoogleMapController mapController;
  final TextEditingController _childEmailController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController(text: 'Child');
  LatLng _childPos = _fallbackPos;
  bool _outOfFence = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _fallbackPos,
              zoom: 15,
            ),
            onMapCreated: (controller) => mapController = controller,
            zoomControlsEnabled: false,  
            markers: {
              Marker(
                markerId: const MarkerId('child_location'),
                position: _childPos,
                infoWindow: const InfoWindow(title: "Child location"),
              ),
            },
          ),


          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 250,
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          children: [
              const Text("Child's Location", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Lat: ${_childPos.latitude}, Lng: ${_childPos.longitude}", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text("Out of fence: $_outOfFence", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: _childEmailController,
                decoration: const InputDecoration(
                  labelText: 'Child email',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _childNameController,
                decoration: const InputDecoration(
                  labelText: 'Child name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF042459), minimumSize: const Size(double.infinity, 50)),
                onPressed: _loading ? null : _refreshLocation, 
                child: const Text("Get Last Location", style: TextStyle(color: Colors.white)),
              )
              ,
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _startGeofence,
                      child: const Text("Start Geofence"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _stopGeofence,
                      child: const Text("Stop Geofence"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    try {
      setState(() => _loading = true);
      final map = await GuardianNativeBridge.getLastLocation();
      final double? lat = (map['latitude'] as num?)?.toDouble();
      final double? lng = (map['longitude'] as num?)?.toDouble();
      if (!mounted) return;
      if (lat != null && lng != null) {
        _childPos = LatLng(lat, lng);
        mapController.animateCamera(CameraUpdate.newLatLng(_childPos));
      }
      setState(() {
        _outOfFence = map['outOfFence'] == true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startGeofence() async {
    final email = _childEmailController.text.trim();
    final name = _childNameController.text.trim().isEmpty ? 'Child' : _childNameController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter child email')));
      return;
    }

    try {
      setState(() => _loading = true);
      await GuardianNativeBridge.startGeofence(childEmail: email, childName: name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geofence service started')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Start geofence failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _stopGeofence() async {
    try {
      setState(() => _loading = true);
      await GuardianNativeBridge.stopGeofence();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geofence service stopped')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stop geofence failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _childEmailController.dispose();
    _childNameController.dispose();
    super.dispose();
  }
}