class ChildDevice {
  final String id;
  final String childName;
  final String deviceName;
  final String initials;
  final int avatarColorIndex; // maps to a color in your palette

  const ChildDevice({
    required this.id,
    required this.childName,
    required this.deviceName,
    required this.initials,
    required this.avatarColorIndex,
  });
}

class NotificationSound {
  final String key;
  final String label;
  final bool isCustom;
  final String? filePath; // only set for custom uploads

  const NotificationSound({
    required this.key,
    required this.label,
    this.isCustom = false,
    this.filePath,
  });
}
