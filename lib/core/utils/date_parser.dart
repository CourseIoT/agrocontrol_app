import 'package:intl/intl.dart';

DateTime? parseDate(String? dateString) {
  if (dateString == null || dateString.trim().isEmpty) {
    return null;
  }

  try {
    return DateTime.parse(dateString);
  } catch (_) {
  }

  final knownFormats = [
    DateFormat("EEE MMM dd yyyy HH:mm:ss 'GMT'Z", 'en_US'),
    DateFormat('EEE MMM dd yyyy', 'en_US'),
  ];

  final cleanedDateString = dateString.contains('(')
      ? dateString.substring(0, dateString.indexOf(' (')).trim()
      : dateString;

  for (final format in knownFormats) {
    try {
      return format.parse(cleanedDateString);
    } catch (_) {
    }
  }

  return null;
}