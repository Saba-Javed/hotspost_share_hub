import 'package:intl/intl.dart';

class Formatters {
  static String duration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String dataSize(double mb) {
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(2)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  static String dateTime(DateTime dt) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  }

  static String time(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  static String date(DateTime dt) {
    return DateFormat('MMM d, yyyy').format(dt);
  }

  static String durationLabel(int minutes) {
    if (minutes == 0) return 'Unlimited';
    if (minutes < 60) return '$minutes min';
    final hours = minutes / 60;
    if (hours == hours.roundToDouble()) {
      return '${hours.toInt()} hr';
    }
    return '${hours.toStringAsFixed(1)} hr';
  }
}
