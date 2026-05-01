import 'package:flutter/material.dart';
import 'package:gardians/screens/profile/profile_constants.dart';
import 'package:gardians/screens/profile/simple_settings_scaffold.dart';
import 'childmodel.dart';
import 'sound_sheet.dart';

// ── Mock data ────────────────────────────────────────────────
const List<ChildDevice> _mockDevices = [
  ChildDevice(
    id: 'device_001',
    childName: 'Layla Mohamed',
    deviceName: "iPhone 14 · Layla's Phone",
    initials: 'LM',
    avatarColorIndex: 0,
  ),
  ChildDevice(
    id: 'device_002',
    childName: 'Kareem Mohamed',
    deviceName: "Samsung A54 · Kareem's Tab",
    initials: 'KM',
    avatarColorIndex: 1,
  ),
];

// Avatar color pairs: [background, foreground]
const List<List<Color>> _avatarColors = [
  [Color(0xFFE6F1FB), Color(0xFF185FA5)], // blue
  [Color(0xFFFAECE7), Color(0xFF993C1D)], // coral
  [Color(0xFFE1F5EE), Color(0xFF0F6E56)], // teal
  [Color(0xFFFBEAF0), Color(0xFF993556)], // pink
];

// ── Screen ────────────────────────────────────────────────────
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Global toggles
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _securityAlerts = true;

  // Per-device sound map: deviceId → NotificationSound
  final Map<String, NotificationSound> _deviceSounds = {
    'device_001': kPredefinedSounds.first,
    'device_002': kPredefinedSounds.first,
  };

  void _openSoundPicker(ChildDevice device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SoundPickerBottomSheet(
        device: device,
        currentSound: _deviceSounds[device.id] ?? kPredefinedSounds.first,
        onSoundSelected: (sound) {
          setState(() => _deviceSounds[device.id] = sound);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleSettingsScaffold(
      title: 'Notifications',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Global toggles ──
          _sectionLabel('General'),
          const SizedBox(height: 8),
          _toggleTile(
            title: 'Push notifications',
            subtitle: 'Receive in-app alerts on this device',
            value: _pushEnabled,
            onChanged: (v) => setState(() => _pushEnabled = v),
          ),
          _toggleTile(
            title: 'Email alerts',
            subtitle: 'Get security events by email',
            value: _emailEnabled,
            onChanged: (v) => setState(() => _emailEnabled = v),
          ),
          _toggleTile(
            title: 'SMS alerts',
            subtitle: 'Critical alerts by text message',
            value: _smsEnabled,
            onChanged: (v) => setState(() => _smsEnabled = v),
          ),
          _toggleTile(
            title: 'Security & privacy updates',
            subtitle: 'Important policy and account updates',
            value: _securityAlerts,
            onChanged: (v) => setState(() => _securityAlerts = v),
          ),

          const SizedBox(height: 8),

          // ── Per-child sound ──
          _sectionLabel('Per-child notification sound'),
          const SizedBox(height: 8),

          ..._mockDevices.map((device) => _childSoundCard(device)),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF74839A),
          letterSpacing: 0.06 * 11,
        ),
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECF4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ProfileColors.navyBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF74839A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _childSoundCard(ChildDevice device) {
    final colors =
        _avatarColors[device.avatarColorIndex % _avatarColors.length];
    final sound = _deviceSounds[device.id] ?? kPredefinedSounds.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECF4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Child info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors[0],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    device.initials,
                    style: TextStyle(
                      color: colors[1],
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.childName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: ProfileColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.deviceName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF74839A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sound row
          InkWell(
            onTap: () => _openSoundPicker(device),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(14),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F3F9))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      size: 16,
                      color: Color(0xFF3A7CF8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sound.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ProfileColors.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: sound.isCustom
                                ? const Color(0xFFFFF0EA)
                                : const Color(0xFFEAF1FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            sound.isCustom ? 'Custom' : 'Predefined',
                            style: TextStyle(
                              fontSize: 11,
                              color: sound.isCustom
                                  ? const Color(0xFF993C1D)
                                  : const Color(0xFF3A7CF8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF74839A),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
