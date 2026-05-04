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

  void _previewSound(NotificationSound sound) {}

  @override
  Widget build(BuildContext context) {
    final allSounds = [...kPredefinedSounds, ..._customSounds];

    return SafeArea(
      child: Container(
        color: const Color(0xFFEEF8FC),
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

              const Divider(height: 20, color: Color(0xFFEAF6FB)),
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

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEAF6FB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFBFE7F5)
                            : const Color(0xFFE5EBF4),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: ProfileColors.navyBlue,
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
                                color: Color(0xFF6B7C85),
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.play_circle_outline_rounded,
                          color: ProfileColors.navyBlue,
                          size: 22,
                        ),
                        onPressed: () => _previewSound(sound),
                        tooltip: 'Preview',
                      ),
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFF4F8FF),
                      onTap: () => setState(() => _selected = sound),
                    ),
                  );
                },
              ),

              const Divider(height: 1, color: Color(0xFFF7F9FC)),

              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: ProfileColors.navyBlue,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Upload custom sound',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ProfileColors.navyBlue,
                  ),
                ),
                subtitle: const Text(
                  '.mp3 or .wav · max 2 MB',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7C85)),
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
                      backgroundColor: const Color(0xFF9ED7EB), // 👈 primary
                      foregroundColor: ProfileColors.navyBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
