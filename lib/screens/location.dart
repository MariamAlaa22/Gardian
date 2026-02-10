import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  // 1. تحديد إحداثيات الطفل (مؤقتاً القاهرة)
  static const LatLng _childPos = LatLng(30.0444, 31.2357);
  
  // 2. كود التحكم في الخريطة
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 3. الـ Widget الحقيقي للخريطة
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _childPos,
              zoom: 15,
            ),
            onMapCreated: (controller) => mapController = controller,
            zoomControlsEnabled: false, // بنقفل الزراير عشان شكل الـ UI يبقى نظيف
            markers: {
              const Marker(
                markerId: MarkerId('child_location'),
                position: _childPos,
                infoWindow: InfoWindow(title: "Yassin is here 🛡️"),
              ),
            },
          ),

          // 4. زرار الرجوع (نفس الـ UI اللي عملناه)
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF042459), size: 18),
            ),
          ),

          // 5. الكارت السفلي اللي فيه البيانات
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
             // حطي هنا الـ Column اللي عملناه قبل كدة (الاسم، العنوان، البطارية)
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