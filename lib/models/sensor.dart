import 'package:flutter/material.dart';

class Sensor {
  final String name;
  final IconData icon;
  final String unit;
  double value;
  String status;

  Sensor({
    required this.name,
    required this.icon,
    required this.unit,
    required this.value,
    required this.status,
  });
}
