import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'childmodel.dart';
import 'package:gardians/screens/profile/profile_constants.dart';

const List<NotificationSound> kPredefinedSounds = [
  NotificationSound(key: 'guardian_bell', label: 'Guardian Bell'),
  NotificationSound(key: 'alert_chime', label: 'Alert Chime'),
  NotificationSound(key: 'soft_ping', label: 'Soft Ping'),
  NotificationSound(key: 'urgent_beep', label: 'Urgent Beep'),
];

class SoundPickerBottomSheet extends StatefulWidget {
  final ChildDevice device;
  final NotificationSound currentSound;
  final ValueChanged<NotificationSound> onSoundSelected;

  const SoundPickerBottomSheet({
    super.key,
    required this.device,
    required this.currentSound,
    required this.onSoundSelected,
  });

  @override
  State<SoundPickerBottomSheet> createState() => _SoundPickerBottomSheetState();
}

class _SoundPickerBottomSheetState extends State<SoundPickerBottomSheet> {
  late NotificationSound _selected;
  List<NotificationSound> _customSounds = [];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSound;
    if (widget.currentSound.isCustom) {
      _customSounds = [widget.currentSound];
    }
  }

  Future<void> _pickCustomSound() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if ((file.size) > 2 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File must be under 2 MB')),
        );
      }
      return;
    }

    final custom = NotificationSound(
      key: 'custom_${file.name}',
      label: file.name,
      isCustom: true,
      filePath: file.path,
    );

    setState(() {
      _customSounds = [
        ..._customSounds.where((s) => s.key != custom.key),
        custom,
      ];
      _selected = custom;
    });
  }

  void _previewSound(NotificationSound sound) {
    // TODO: integrate audioplayers package to play the sound
    // AudioPlayer().play(sound.isCustom
    //   ? DeviceFileSource(sound.filePath!)
    //   : AssetSource('sounds/${sound.key}.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    final allSounds = [...kPredefinedSounds, ..._customSounds];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4D9E4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose a sound for ${widget.device.childName.split(' ').first}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ProfileColors.navyBlue,
                ),
              ),
            ),

            const Divider(height: 20, color: Color(0xFFF0F3F9)),

            // Sound list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allSounds.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF7F9FC)),
              itemBuilder: (context, index) {
                final sound = allSounds[index];
                final isSelected = _selected.key == sound.key;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: Radio<String>(
                    value: sound.key,
                    groupValue: _selected.key,
                    activeColor: const Color(0xFF3A7CF8),
                    onChanged: (_) => setState(() => _selected = sound),
                  ),
                  title: Text(
                    sound.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: ProfileColors.navyBlue,
                    ),
                  ),
                  subtitle: sound.isCustom
                      ? const Text(
                          'Custom upload',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF993C1D),
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: Color(0xFF74839A),
                      size: 22,
                    ),
                    onPressed: () => _previewSound(sound),
                    tooltip: 'Preview',
                  ),
                  selected: isSelected,
                  selectedTileColor: const Color(0xFFF4F8FF),
                  onTap: () => setState(() => _selected = sound),
                );
              },
            ),

            const Divider(height: 1, color: Color(0xFFF7F9FC)),

            // Upload custom sound row
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFB0BAC9),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF74839A),
                  size: 18,
                ),
              ),
              title: const Text(
                'Upload custom sound',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ProfileColors.navyBlue,
                ),
              ),
              subtitle: const Text(
                '.mp3 or .wav · max 2 MB',
                style: TextStyle(fontSize: 12, color: Color(0xFF74839A)),
              ),
              onTap: _pickCustomSound,
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onSoundSelected(_selected);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3A7CF8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
