import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  static const LatLng _childPos = LatLng(30.0444, 31.2357);
  
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _childPos,
              zoom: 15,
            ),
            onMapCreated: (controller) => mapController = controller,
            zoomControlsEnabled: false,  
            markers: {
              const Marker(
                markerId: MarkerId('child_location'),
                position: _childPos,
                infoWindow: InfoWindow(title: "Yassin is here 🛡️"),
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
              
              const Text("Yassin's Location", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("22 Tahrir Street, Dokki, Giza", style: TextStyle(color: Colors.grey)),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF042459), minimumSize: const Size(double.infinity, 50)),
                onPressed: () {}, 
                child: const Text("Get Directions", style: TextStyle(color: Colors.white)),
              )
          ],
        ),
      ),
    );
  }
}