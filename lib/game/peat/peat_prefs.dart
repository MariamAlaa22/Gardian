import 'package:shared_preferences/shared_preferences.dart';

enum PeatDayNightMode { auto, alwaysDay, alwaysNight }

/// Local streak + display preferences (no backend).
final class PeatPrefs {
  static const _streakKey = 'peat_streak_days';
  static const _lastOpenDayKey = 'peat_last_open_day_iso';
  static const _dayNightKey = 'peat_day_night_mode';

  Future<int> streakAfterOpen() async {
    final p = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());
    final lastStr = p.getString(_lastOpenDayKey);
    var streak = p.getInt(_streakKey) ?? 0;

    if (lastStr == null) {
      streak = 1;
      await p.setString(_lastOpenDayKey, today.toIso8601String());
      await p.setInt(_streakKey, streak);
      return streak;
    }

    final last = DateTime.tryParse(lastStr);
    if (last == null) {
      streak = 1;
      await p.setString(_lastOpenDayKey, today.toIso8601String());
      await p.setInt(_streakKey, streak);
      return streak;
    }

    final lastDay = _dateOnly(last);
    if (lastDay == today) {
      return streak;
    }

    final diff = today.difference(lastDay).inDays;
    if (diff == 1) {
      streak += 1;
    } else {
      streak = 1;
    }
    await p.setString(_lastOpenDayKey, today.toIso8601String());
    await p.setInt(_streakKey, streak);
    return streak;
  }

  Future<int> readStreak() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_streakKey) ?? 1;
  }

  Future<PeatDayNightMode> readDayNightMode() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt(_dayNightKey) ?? 0;
    return PeatDayNightMode.values[v.clamp(0, PeatDayNightMode.values.length - 1)];
  }

  Future<void> writeDayNightMode(PeatDayNightMode m) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_dayNightKey, m.index);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

bool peatIsNightVisual(PeatDayNightMode mode) {
  switch (mode) {
    case PeatDayNightMode.alwaysNight:
      return true;
    case PeatDayNightMode.alwaysDay:
      return false;
    case PeatDayNightMode.auto:
      final h = DateTime.now().hour;
      return h >= 20 || h < 7;
  }
}

double peatEvolutionScaleFromStreak(int streak) {
  final s = streak.clamp(1, 30);
  return 0.92 + (s / 30) * 0.28;
}
