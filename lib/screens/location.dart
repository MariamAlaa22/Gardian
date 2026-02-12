import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // 1. مكتبة لفتح خرائط جوجل الخارجية

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  // 2. بيانات الموقع (مستقبلاً هتيجي من الـ Firebase Stream)
  final LatLng _childPos = const LatLng(30.0444, 31.2357);
  final String childName = "Yassin"; // ممكن نربطها بـ SharedPrefs أو الـ Model
  final String address = "22 Tahrir Street, Dokki, Giza";

  late GoogleMapController mapController;

  // ميثود لفتح خرائط جوجل الخارجية للاتجاهات
  Future<void> _openMapsDirections() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${_childPos.latitude},${_childPos.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _childPos, zoom: 15),
            onMapCreated: (controller) => mapController = controller,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('child_location'),
                position: _childPos,
                infoWindow: InfoWindow(title: "$childName is here 🛡️"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ), // تغيير لون الماركر ليكون مميز
              ),
            },
          ),

          // زرار لإعادة التمركز على الطفل (Floating Action Button يدوي)
          // زرار لإعادة التمركز على الطفل (Floating Action Button يدوي)
          Positioned(
            top: 50,
            right: 15,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                mapController.animateCamera(CameraUpdate.newLatLng(_childPos));
              },
              child: const Icon(Icons.my_location, color: Color(0xFF042459)),
            ),
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          children: [
            // سحبة الـ Modal الصغير اللي فوق
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "$childName's Location",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 5),
                Text(address, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF042459),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _openMapsDirections, // ربط الأكشن
              child: const Text(
                "Get Directions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
