import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  GoogleMapController? mapController;

  Future<Map<String, String>> _getChildData() async {
    String id = SharedPrefsUtils.getString(Constants.childId) ?? "";
    String name = SharedPrefsUtils.getString(Constants.childName) ?? "Child";

    debugPrint("📍 [Location] Loaded ID: $id");

    return {"id": id, "name": name};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getChildData(),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final String childUid = dataSnapshot.data?['id'] ?? "";
          final String childName = dataSnapshot.data?['name'] ?? "Child";

          if (childUid.isEmpty) {
            return _buildSelectionRequiredUI();
          }

          return StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref("devices_data/$childUid/location")
                .onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return _buildNoDataUI(childName);
              }

              try {
                final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                final double lat = (data['latitude'] as num).toDouble();
                final double lng = (data['longitude'] as num).toDouble();
                final LatLng currentPos = LatLng(lat, lng);

                // تحريك الكاميرا تلقائياً
                mapController?.animateCamera(
                  CameraUpdate.newLatLng(currentPos),
                );

                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: currentPos,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) => mapController = controller,
                      myLocationButtonEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('child_marker'),
                          position: currentPos,
                          infoWindow: InfoWindow(title: "$childName is here"),
                        ),
                      },
                    ),
                    _buildInfoCard(lat, lng, childName),
                  ],
                );
              } catch (e) {
                return Center(child: Text("Error: $e"));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectionRequiredUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            "Please select a child first",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("Go to Devices Screen and pick a device"),
        ],
      ),
    );
  }

  Widget _buildNoDataUI(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.red.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "Location not shared by $name",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "Ensure GPS is enabled on the child's phone.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(double lat, double lng, String name) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$name's Current Position",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text("Open in Google Maps"),
              onPressed: () => _launchMaps(lat, lng),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                backgroundColor: const Color(0xFF042459),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchMaps(double lat, double lng) async {
    // تعديل الرابط ليكون صحيحاً ويعمل على التطبيقات الخارجية
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $googleMapsUrl");
    }
  }
}
