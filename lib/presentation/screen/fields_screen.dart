import 'dart:convert';
import 'package:agrocontrol_app/models/field.dart';
import 'package:agrocontrol_app/presentation/screen/add_field_screen.dart';
import 'package:agrocontrol_app/presentation/screen/edit_field_screen.dart';
import 'package:agrocontrol_app/presentation/screen/field_detail_screen.dart';
import 'package:agrocontrol_app/presentation/widgets/custom_loading_indicator.dart';
import 'package:agrocontrol_app/services/api_service.dart';
import 'package:agrocontrol_app/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Field>> _fieldsFuture;
  bool _sortByNewest = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFields();
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void _loadFields() {
    setState(() {
      _fieldsFuture = () async {
        await Future.delayed(const Duration(seconds: 1));
        final userId = SessionService().userId;
        if (userId != null) {
          return _apiService.getFieldsByUserId(userId);
        } else {
          return <Field>[];
        }
      }();
    });
  }

  void _navigateToAddField() async {
    final newField = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddFieldScreen()),
    );
    if (newField != null) {
      _loadFields();
    }
  }

  void _navigateToDetailScreen(Field field) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FieldDetailScreen(field: field)),
    );
  }

  void _navigateToEditFieldScreen(Field field) async {
    final updatedField = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditFieldScreen(field: field)),
    );
    if (updatedField != null) {
      _loadFields();
    }
  }

  Widget _buildFilterControls() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            icon: Icon(
                _sortByNewest ? Icons.arrow_downward : Icons.arrow_upward,
                size: 18, color: Colors.grey.shade700),
            label: Text(
              _sortByNewest ? 'Más Recientes' : 'Más Antiguos',
              style: TextStyle(
                  color: Colors.grey.shade800, fontWeight: FontWeight.normal),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              side: BorderSide(color: Colors.grey.shade400, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () {
              setState(() {
                _sortByNewest = !_sortByNewest;
              });
            },
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
                foregroundColor: Colors.green),
            onPressed: _navigateToAddField,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _deleteField(int fieldId) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Confirmar Eliminación'),
            content: const Text(
                '¿Estás seguro de que quieres eliminar este campo?'),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar')
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    ) ?? false;

    if (confirm) {
      try {
        await _apiService.deleteField(fieldId);
        _loadFields();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionService();
    final userName = session.userProfile?.fullName
        .split(' ')
        .first ?? 'Usuario';

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: const Color(0xFF2E8B57),
        strokeWidth: 3.0,
        onRefresh: () async => _loadFields(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $userName',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    const WeatherCard(),
                    const SizedBox(height: 32),
                    const Text('Mis Campos', style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverFilterBarDelegate(
                child: _buildFilterControls(),
                height: 60.0,
              ),
            ),

            FutureBuilder<List<Field>>(
              future: _fieldsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CustomLoadingIndicator(
                        message: 'Cargando campos...')),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 48.0, horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grass_outlined, size: 80,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 24),
                            Text('No hay campos registrados', style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700)),
                            const SizedBox(height: 8),
                            Text('Presiona "Agregar Campo" para empezar.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final fields = snapshot.data!;
                fields.sort((a, b) {
                  if (_sortByNewest) {
                    return b.id.compareTo(a.id);
                  } else {
                    return a.id.compareTo(b.id);
                  }
                });

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final field = fields[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: FieldCard(
                            field: field,
                            onTap: () => _navigateToDetailScreen(field),
                            onEdit: () => _navigateToEditFieldScreen(field),
                            onDelete: () => _deleteField(field.id),
                          ),
                        );
                      },
                      childCount: fields.length,
                    ),
                  ),
                );
              },
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
    const String apiUrl = 'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city';

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
            location: 'Cargando...',
            date: '...',
            temperature: '--',
            icon: Icons.hourglass_empty,
          );
        }

        if (snapshot.hasError) {
          return const _WeatherCardUI(
            color: Colors.redAccent,
            location: 'Error',
            date: 'No se pudo obtener el clima',
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
          date: DateFormat('E, MMM d, yyyy', 'es_ES').format(DateTime.now()),
          temperature: temp,
          icon: _getWeatherIcon(weatherCondition),
        );
      },
    );
  }

  IconData _getWeatherIcon(String weatherCondition) {
    final condition = weatherCondition.toLowerCase();
    if (condition.contains('cloudy') || condition.contains('overcast')) {
      return Icons.wb_cloudy_outlined;
    } else if (condition.contains('rain')) {
      return Icons.umbrella_outlined;
    } else if (condition.contains('sunny') || condition.contains('clear')) {
      return Icons.wb_sunny_outlined;
    }
    return Icons.thermostat;
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
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
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
              Text('$temperature°C', style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
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
    required this.field,required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> fieldImages = [
      'assets/images/farm_background.png',
      'assets/images/field_1.png',
      'assets/images/field_2.png',
      'assets/images/field_3.png',
      'assets/images/field_4.png',
    ];

    final imagePath = fieldImages[field.id % fieldImages.length];

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[50],
        elevation: 2.0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                        size: 50,
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    field.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2.0, color: Colors.black45)],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Wrap(
                spacing: 16.0,
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
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Eliminar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
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
        Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
      ],
    );
  }
}

class _SliverFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverFilterBarDelegate({
    required this.child,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.0)),
      ),
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SliverFilterBarDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}
