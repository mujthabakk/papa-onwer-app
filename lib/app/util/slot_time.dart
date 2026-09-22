/// Slot times always display / store as 12-hour clock: `hh:mm AM/PM`.
class SlotTime {
  SlotTime._();

  /// Convert any common API/UI time string to clean 12-hour form.
  /// Handles: `13:00`, `13:00 PM`, `1:00 pm`, `01:00 AM`, `10:00AM`.
  static String to12Hour(String? raw) {
    if (raw == null) return '';
    final cleaned = raw.trim();
    if (cleaned.isEmpty || cleaned.toUpperCase() == 'NA') return '';

    final minutes = toMinutes(cleaned);
    if (minutes == null) return cleaned;
    return fromMinutes(minutes);
  }

  /// Minutes from midnight, or null if unparseable.
  static int? toMinutes(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.trim().toUpperCase().replaceAll('.', '');
    if (cleaned.isEmpty) return null;

    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$').firstMatch(cleaned);
    if (match == null) return null;

    var hour = int.tryParse(match.group(1)!) ?? 0;
    final minute = int.tryParse(match.group(2)!) ?? 0;
    final period = match.group(3);

    if (minute < 0 || minute > 59) return null;

    // Hour already in 24h range (e.g. "13:00" or broken "13:00 PM").
    if (hour > 12) {
      if (hour > 23) return null;
      return hour * 60 + minute;
    }

    if (period == null) {
      // Bare time — treat as 24h when hour is 0-23; 0-12 stay as-is morning.
      if (hour > 23) return null;
      return hour * 60 + minute;
    }

    if (hour == 0) hour = 12;
    if (hour < 1 || hour > 12) return null;

    var hour24 = hour;
    if (period == 'AM') {
      if (hour == 12) hour24 = 0;
    } else {
      if (hour != 12) hour24 = hour + 12;
    }
    return hour24 * 60 + minute;
  }

  static String fromMinutes(int totalMinutes) {
    var mins = totalMinutes % (24 * 60);
    if (mins < 0) mins += 24 * 60;
    final hour24 = mins ~/ 60;
    final minute = mins % 60;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  static String fromTimeOfDay({required int hour24, required int minute}) {
    return fromMinutes(hour24 * 60 + minute);
  }
}
