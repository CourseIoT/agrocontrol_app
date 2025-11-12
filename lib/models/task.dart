import 'package:agrocontrol_app/models/worker.dart';

class Task {
  final DateTime date;
  final int hours;
  final Worker worker;

  Task({required this.date, required this.hours, required this.worker});
}
