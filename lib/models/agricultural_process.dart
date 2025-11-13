import 'package:agrocontrol_app/core/utils/date_parser.dart';

class AgriculturalProcess {
  final int id;
  final int fieldId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isFinished;

  AgriculturalProcess({
    required this.id,
    required this.fieldId,
    required this.startDate,
    this.endDate,
    required this.isFinished,
  });

  factory AgriculturalProcess.fromJson(Map<String, dynamic> json) {
    final parsedStartDate = parseDate(json['startDate'] as String?);
    if (parsedStartDate == null) {
      throw const FormatException('Invalid or null format for startDate');
    }

    return AgriculturalProcess(
      id: json['id'] as int,
      fieldId: json['fieldId'] as int,
      startDate: parsedStartDate,
      endDate: parseDate(json['endDate'] as String?),
      isFinished: json['isFinished'] as bool,
    );
  }
}
