import 'package:agrocontrol_app/core/utils/date_parser.dart';

class Activity {
  final int id;
  final int agriculturalProcessId;
  final String activityType;
  final DateTime date;
  final String activityStatus;
  final double workersTotalCost;
  final int? hoursIrrigated;
  final String? plantType;
  final int? quantityPlanted;
  final String? treatmentType;
  final double? quantityInKg;
  final double? pricePerKg;
  final double? totalIncome;
  // Nota: La lista de 'resources' se mantiene como dynamic por simplicidad.
  // En el futuro, podrías crear un modelo específico para Resource.
  final List<dynamic> resources;

  Activity({
    required this.id,
    required this.agriculturalProcessId,
    required this.activityType,
    required this.date,
    required this.activityStatus,
    required this.workersTotalCost,
    this.hoursIrrigated,
    this.plantType,
    this.quantityPlanted,
    this.treatmentType,
    this.quantityInKg,
    this.pricePerKg,
    this.totalIncome,
    required this.resources,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    final parsedDate = parseDate(json['date'] as String?);
    if (parsedDate == null) {
      throw const FormatException('Invalid or null format for date');
    }

    return Activity(
      id: json['id'] as int,
      agriculturalProcessId: json['agriculturalProcessId'] as int,
      activityType: json['activityType'] as String,
      date: parsedDate,
      activityStatus: json['activityStatus'] as String,
      workersTotalCost: (json['workersTotalCost'] as num).toDouble(),
      hoursIrrigated: (json['hoursIrrigated']),
      plantType: json['plantType'] as String?,
      quantityPlanted: json['quantityPlanted'] as int?,
      treatmentType: json['treatmentType'] as String?,
      quantityInKg: (json['quantityInKg'] as num).toDouble(),
      pricePerKg: (json['pricePerKg']as num).toDouble(),
      totalIncome: (json['totalIncome']as num).toDouble(),
      resources: json['resources'] as List<dynamic>,
    );
  }

  Activity copyWith({
    int? id,
    int? agriculturalProcessId,
    String? activityType,
    DateTime? date,
    String? activityStatus,
    double? workersTotalCost,
    int? hoursIrrigated,
    String? plantType,
    int? quantityPlanted,
    String? treatmentType,
    double? quantityInKg,
    double? pricePerKg,
    double? totalIncome,
    List<dynamic>? resources,
  }) {
    return Activity(
      id: id ?? this.id,
      agriculturalProcessId: agriculturalProcessId ?? this.agriculturalProcessId,
      activityType: activityType ?? this.activityType,
      date: date ?? this.date,
      activityStatus: activityStatus ?? this.activityStatus,
      workersTotalCost: workersTotalCost ?? this.workersTotalCost,
      hoursIrrigated: hoursIrrigated ?? this.hoursIrrigated,
      plantType: plantType ?? this.plantType,
      quantityPlanted: quantityPlanted ?? this.quantityPlanted,
      treatmentType: treatmentType ?? this.treatmentType,
      quantityInKg: quantityInKg ?? this.quantityInKg,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      totalIncome: totalIncome ?? this.totalIncome,
      resources: resources ?? this.resources,
    );
  }
}
