import 'dart:convert';
import 'package:agrocontrol_app/models/field.dart';
import 'package:agrocontrol_app/presentation/screen/add_field_screen.dart';
import 'package:agrocontrol_app/presentation/screen/edit_field_screen.dart';
import 'package:agrocontrol_app/presentation/screen/field_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  final String _userName = 'Harold';
  final List<Field> _fields = [
    const Field(
      name: 'Fruit Garden',
      location: 'South Dakota, USA',
      imageUrl: 'assets/images/farm_background.png',
      landSize: 5.2,
    ),
    const Field(
      name: 'Vegetable Patch',
      location: 'California, USA',
      imageUrl: 'assets/images/farm_background.png',
      landSize: 10.0,
    ),
  ];

  void _navigateToAddField() async {
    final newField = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddFieldScreen()),
    );

    if (newField != null && newField is Field) {
      setState(() {
        _fields.add(newField);
      });
    }
  }

  void _navigateToDetailScreen(Field field) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FieldDetailScreen(field: field)),
    );
  }

  void _navigateToEditFieldScreen(int index) async {
    final updatedField = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditFieldScreen(field: _fields[index])),
    );

    if (updatedField != null && updatedField is Field) {
      setState(() {
        _fields[index] = updatedField;
      });
    }
  }

  void _deleteField(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este campo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _fields.removeAt(index);
              });
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Color(0xFFD9534F)),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $_userName',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const WeatherCard(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis Campos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _navigateToAddField,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar Campo'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF53A878),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: _fields.asMap().entries.map((entry) {
                int index = entry.key;
                Field field = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: FieldCard(
                    field: field,
                    onTap: () => _navigateToDetailScreen(field),
                    onEdit: () => _navigateToEditFieldScreen(index),
                    onDelete: () => _deleteField(index),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Future<Map<String, dynamic>>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeather();
  }

  Future<Map<String, dynamic>> _fetchWeather() async {
    const String apiKey = '22878a6c51824882b02233236251111';
    const String city = 'Lima';
    const String apiUrl =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the weather service');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _WeatherCardUI(
            color: Colors.grey,
            location: 'Loading...',
            date: '...',
            temperature: '--',
            icon: Icons.hourglass_empty,
          );
        }

        if (snapshot.hasError) {
          return const _WeatherCardUI(
            color: Colors.redAccent,
            location: 'Error',
            date: 'Could not fetch data',
            temperature: ':(',
            icon: Icons.error_outline,
          );
        }

        final data = snapshot.data!;
        final locationData = data['location'];
        final currentData = data['current'];

        final location = locationData['name'] + ', ' + locationData['country'];
        final temp = currentData['temp_c'].toStringAsFixed(0);
        final weatherCondition = currentData['condition']['text'];

        return _WeatherCardUI(
          location: location,
          date: DateFormat('E, MMM d, yyyy').format(DateTime.now()),
          temperature: temp,
          icon: _getWeatherIcon(weatherCondition),
        );
      },
    );
  }

  IconData _getWeatherIcon(String weatherCondition) {
    final condition = weatherCondition.toLowerCase();
    if (condition.contains('cloudy')) {
      return Icons.wb_cloudy_outlined;
    } else if (condition.contains('rain')) {
      return Icons.umbrella_outlined;
    } else if (condition.contains('sunny') || condition.contains('clear')) {
      return Icons.wb_sunny_outlined;
    } else {
      return Icons.thermostat;
    }
  }
}

class _WeatherCardUI extends StatelessWidget {
  final String location, date, temperature;
  final IconData icon;
  final Color color;

  const _WeatherCardUI({
    required this.location,
    required this.date,
    required this.temperature,
    required this.icon,
    this.color = const Color(0xFF53A878),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(location, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 60),
              Text(
                '$temperature°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FieldCard extends StatelessWidget {
  final Field field;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FieldCard({
    super.key,
    required this.field,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[50],
        elevation: 2.0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.asset(
                  field.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    field.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 24.0,
                runSpacing: 8.0,
                children: [
                  _InfoChip(icon: Icons.location_on_outlined, text: field.location),
                  _InfoChip(icon: Icons.landscape_outlined, text: '${field.landSize} ha'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Eliminar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.grey[800], fontSize: 14),
        ),
      ],
    );
  }
}
