import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=parent'),
            ),
            const SizedBox(height: 15),
            Text(
              "Jone Moller",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navyBlue),
            ),
            const Text(
              "jonegriffin@gmail.com",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () {},
              child: const Text("Upgrade now - Go Pro", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),

            _buildProfileOption(Icons.person_outline, "Change Account"),
            _buildProfileOption(Icons.group_outlined, "Sub-account"),
            _buildProfileOption(Icons.phone_android_outlined, "Device Management"),
            _buildProfileOption(Icons.language_outlined, "APP Language"),
            _buildProfileOption(Icons.share_outlined, "Share"),
            _buildProfileOption(Icons.lock_outline, "Pin Set"),
            _buildProfileOption(Icons.volume_up_outlined, "Sound Settings"),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0x4D9ED7EB), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF042459)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF042459)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF042459)),
        onTap: () {},
      ),
    );
  }
}