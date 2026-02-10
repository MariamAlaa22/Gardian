import 'package:flutter/material.dart';
import 'package:gardians/screens/addchild.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  final Color navyBlue = const Color(0xFF042459);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor:Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Paired Devices", style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDeviceCard(
              "Leo's iPhone 13", 
              "Active now", 
              Icons.phone_android, 
              Colors.green, 
              showButtons: true
            ),
            const SizedBox(height: 15),
            _buildDeviceCard(
              "Mila's iPad", 
              "Last seen 5m ago", 
              Icons.tablet_mac, 
              Colors.grey,
              statusText: "OFFLINE"
            ),
            const SizedBox(height: 15),
            _buildDeviceCard(
              "Home Desktop", 
              "Monitoring active", 
              Icons.computer, 
              Colors.orange,
              statusText: "RESTRICTED"
            ),
            const Spacer(),
            const Text("Total: 3 Paired Devices", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor:  Color.fromARGB(255, 47, 152, 168),
        onPressed: () {
          Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddChildScreen()),
    );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDeviceCard(String name, String sub, IconData icon, Color statusColor, {bool showButtons = false, String? statusText}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: statusColor),
                      const SizedBox(width: 5),
                      Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (statusText != null)
                Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10))
              else
                const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
          if (showButtons) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text("Edit"))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                  onPressed: () {}, 
                  child: const Text("Delete", style: TextStyle(color: Colors.white))
                )),
              ],
            )
          ]
        ],
      ),
    );
  }
}