import 'package:flutter/material.dart';
import 'package:gardians/screens/profile/profile_constants.dart';
import 'package:gardians/screens/profile/simple_settings_scaffold.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleSettingsScaffold(
      title: 'Settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD7DFEA)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY PRIVACY',
                  style: TextStyle(
                    color: Color(0xFF1D5A69),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Update Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    color: ProfileColors.navyBlue,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please enter your current password and choose a strong new one.',
                  style: TextStyle(color: Color(0xFF5E697E), fontSize: 16),
                ),
                const SizedBox(height: 20),
                _passwordField(
                  label: 'Current Password',
                  controller: _currentController,
                  obscure: _hideCurrent,
                  onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
                ),
                const SizedBox(height: 16),
                _passwordField(
                  label: 'New Password',
                  controller: _newController,
                  obscure: _hideNew,
                  hint: 'Minimum 8 characters',
                  onToggle: () => setState(() => _hideNew = !_hideNew),
                ),
                const SizedBox(height: 16),
                _passwordField(
                  label: 'Confirm New Password',
                  controller: _confirmController,
                  obscure: _hideConfirm,
                  hint: 'Re-enter new password',
                  onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _newController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Passwords must contain at least one uppercase letter, one number, and one special character.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF445268),
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _updatePassword,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Update Password'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: const Color(0xFF8CD8EE),
                      foregroundColor: ProfileColors.navyBlue,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ProfileColors.navyBlue,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                if (label == 'New Password' && value.length < 8) {
                  return 'Must be at least 8 characters';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              label == 'Current Password'
                  ? Icons.lock_outline_rounded
                  : label == 'New Password'
                  ? Icons.vpn_key_outlined
                  : Icons.shield_outlined,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _updatePassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully.')),
    );
    Navigator.pop(context);
  }
}
