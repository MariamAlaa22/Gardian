import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gardians/screens/profile/app_language_screen.dart';
import 'package:gardians/screens/profile/change_password_screen.dart';
import 'package:gardians/screens/profile/notification_settings_screen.dart';
import 'package:gardians/screens/profile/help_support_screen.dart';
import 'package:gardians/screens/profile/privacy_policy_screen.dart';
import 'package:gardians/screens/profile/terms_of_service_screen.dart';
import 'package:gardians/screens/welcome.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);
  final Color backgroundGrey = const Color(0xFFF8F9FA);

  String _displayName = 'Sarah Miller';
  final String _email = 'sarah.miller@guardian-app.com';
  File? _profilePhoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey, 
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        title: Text("Profile", style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildSettingsSection(
              title: "ACCOUNT SETTINGS",
              children: [
                _buildOptionTile(Icons.language_rounded, "App Language", "English (US)", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AppLanguageScreen()));
                }),
                _buildOptionTile(Icons.lock_outline_rounded, "Change Password", "Security settings", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                }),
                _buildOptionTile(Icons.notifications_none_rounded, "Notifications", "Alerts & Sounds", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()));
                }, isLast: true),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingsSection(
              title: "SUPPORT & LEGAL",
              children: [
                _buildOptionTile(Icons.help_outline_rounded, "Help & Support", "FAQs", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                }),
                _buildOptionTile(Icons.privacy_tip_outlined, "Privacy Policy", "Data safety", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                }),
                _buildOptionTile(Icons.description_outlined, "Terms of Service", "User agreement", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
                }, isLast: true),
              ],
            ),
            const SizedBox(height: 30),
            _buildLogoutButton(),
            const SizedBox(height: 20),
            Text(
              "App Version 2.4.12",
              style: TextStyle(color: navyBlue.withValues(alpha: 0.4), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: skyBlue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 15),
          _buildEditableName(), 
          Text(_email, style: TextStyle(color: navyBlue.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildEditableName() {
    return GestureDetector(
      onTap: _showEditNameDialog, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _displayName,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navyBlue),
          ),
          const SizedBox(width: 8),
          Icon(Icons.edit_rounded, size: 18, color: navyBlue.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 52,
            backgroundImage: _profilePhoto != null 
                ? FileImage(_profilePhoto!) 
                : const NetworkImage('https://i.pravatar.cc/150?img=5') as ImageProvider,
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: GestureDetector(
            onTap: _showPhotoSourceSheet,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: navyBlue,
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: navyBlue.withValues(alpha: 0.5))),
        ),
        Container(
          decoration: BoxDecoration(
            color: skyBlue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isLast = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: navyBlue, size: 22),
      ),
      title: Text(title, style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: navyBlue.withValues(alpha: 0.5), fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: navyBlue.withValues(alpha: 0.3), size: 16),
      shape: isLast ? null : Border(bottom: BorderSide(color: navyBlue.withValues(alpha: 0.05))),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Welcome()));
      },
      icon: const Icon(Icons.logout_rounded, color: Color(0xFFC24747), size: 18),
      label: const Text('Logout Account', style: TextStyle(color: Color(0xFFC24747), fontWeight: FontWeight.w600, fontSize: 18)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        side: const BorderSide(color: Color(0xFFE3E7EF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: navyBlue,
      ),
    );
  }

  
  Future<void> _showEditNameDialog() async {
    final TextEditingController controller = TextEditingController(text: _displayName);
    final String? updatedName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Update Name', style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: navyBlue))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: navyBlue),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updatedName != null && updatedName.isNotEmpty) {
      setState(() => _displayName = updatedName);
    }
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) setState(() => _profilePhoto = File(pickedFile.path));
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Change Profile Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navyBlue)),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: navyBlue),
                title: const Text("Gallery"),
                onTap: () { Navigator.pop(context); _pickProfileImage(ImageSource.gallery); },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: navyBlue),
                title: const Text("Camera"),
                onTap: () { Navigator.pop(context); _pickProfileImage(ImageSource.camera); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}