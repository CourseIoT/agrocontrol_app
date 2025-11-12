import 'dart:math';
import 'package:agrocontrol_app/models/sensor.dart';
import 'package:flutter/material.dart';

Future<List<Sensor>> fetchSensorData() async {
  await Future.delayed(const Duration(milliseconds: 1200));

  final random = Random();
  final List<Sensor> sensors = [
    Sensor(name: 'Humedad del Aire', icon: Icons.water_drop_outlined, unit: '%', value: 65 + random.nextDouble() * 10, status: 'Óptimo'),
    Sensor(name: 'Temperatura Amb.', icon: Icons.thermostat_outlined, unit: '°C', value: 22 + random.nextDouble() * 5, status: 'Óptimo'),
    Sensor(name: 'Humedad del Suelo', icon: Icons.landscape_outlined, unit: '%', value: 45 + random.nextDouble() * 15, status: 'Óptimo'),
    Sensor(name: 'Luz Solar', icon: Icons.wb_sunny_outlined, unit: 'lx', value: 75000 + random.nextDouble() * 10000, status: 'Bueno'),
    Sensor(name: 'pH del Suelo', icon: Icons.science_outlined, unit: 'pH', value: 6.2 + random.nextDouble() * 0.5, status: 'Estable'),
  ];
  
  if (sensors[0].value < 60) sensors[0].status = 'Bajo';
  if (sensors[1].value > 28) sensors[1].status = 'Alto';

  return sensors;
}

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  late Future<List<Sensor>> _sensorFuture;

  @override
  void initState() {
    super.initState();
    _sensorFuture = fetchSensorData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _sensorFuture = fetchSensorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        backgroundColor: Colors.white,
        color: const Color(0xFF2E8B57),
        strokeWidth: 3.0,
        child: FutureBuilder<List<Sensor>>(
          future: _sensorFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: _CustomLoadingIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No se encontraron sensores.'));
            }

            final sensors = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                return _SensorCard(sensor: sensors[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _CustomLoadingIndicator extends StatefulWidget {
  const _CustomLoadingIndicator();

  @override
  State<_CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<_CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _controller,
          child: const Icon(
            Icons.eco_outlined, // Icono de hoja
            size: 40,
            color: Color(0xFF2E8B57),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Leyendo sensores...',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
        ),
      ],
    );
  }
}


// --- Widget de Tarjeta para Sensor (sin cambios) ---

class _SensorCard extends StatelessWidget {
  final Sensor sensor;

  const _SensorCard({required this.sensor});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'óptimo':
      case 'bueno':
      case 'estable':
        return Colors.green.shade600;
      case 'bajo':
      case 'alto':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF043A3A).withOpacity(0.1),
              child: Icon(sensor.icon, size: 28, color: const Color(0xFF043A3A)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sensor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sensor.value.toStringAsFixed(1)} ${sensor.unit}',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor(sensor.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                sensor.status,
                style: TextStyle(
                  color: _getStatusColor(sensor.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
