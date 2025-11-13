import 'package:agrocontrol_app/models/agricultural_process.dart';
import 'package:agrocontrol_app/models/field.dart';
import 'package:agrocontrol_app/presentation/widgets/custom_loading_indicator.dart';
import 'package:agrocontrol_app/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agrocontrol_app/models/agricultural_producer.dart';
import 'package:agrocontrol_app/services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionService _sessionService = SessionService();
  final ApiService _apiService = ApiService();

  late Future<Map<String, dynamic>> _profileDataFuture;

  static const Color _primaryColor = Color(0xFF2E8B57);
  static const Color _cardBackgroundColor = Color(0xFFF8F8F8);
  static const Color _primaryIconColor = Color(0xFF2E8B57);
  static const Color _textColor = Colors.black87;
  static const Color _subtextColor = Colors.black54;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _loadProfileData();
  }

  Future<Map<String, dynamic>> _loadProfileData() async {
    final userId = _sessionService.userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    final fields = await _apiService.getFieldsByUserId(userId);

    final processFutures = fields
        .map((field) => _apiService.getUnfinishedProcessForField(field.id))
        .toList();

    final processesOrNulls = await Future.wait(processFutures);
    final processes = processesOrNulls.whereType<AgriculturalProcess>().toList();

    return {
      'fields': fields,
      'processes': processes,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AgriculturalProducer? profile = _sessionService.userProfile;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
            child: Text('No se pudo cargar la información del perfil.')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 280.0,
            title: const Text('Perfil'),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/farm_background.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/user_placeholder.png',
                                fit: BoxFit.cover,
                                width: 90.0,
                                height: 90.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Productor Agrícola',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen Agrícola',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textColor),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _profileDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CustomLoadingIndicator(
                                message: 'Cargando resumen...'));
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Error al cargar las estadísticas: ${snapshot.error}'));
                      }

                      final data = snapshot.data!;
                      final fields = data['fields'] as List<Field>;
                      final processes =
                          data['processes'] as List<AgriculturalProcess>;
                      final totalArea = fields.fold<double>(
                          0, (sum, item) => sum + item.landSize);

                      return _buildStatsCard(
                          fields.length, totalArea, processes.length);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textColor),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(profile),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int fieldCount, double totalArea, int activeProcesses) {
    return Card(
      elevation: 1,
      color: _cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(CupertinoIcons.tree, '$fieldCount', 'Campos'),
            _buildStatItem(CupertinoIcons.fullscreen,
                '${totalArea.toStringAsFixed(0)} ha', 'Total'),
            _buildStatItem(CupertinoIcons.arrow_2_circlepath,
                '$activeProcesses', 'Procesos'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: _primaryIconColor.withOpacity(0.1),
          child: Icon(icon, color: _primaryIconColor, size: 24),
        ),
        const SizedBox(height: 12),
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: _subtextColor)),
      ],
    );
  }

  Widget _buildInfoCard(AgriculturalProducer profile) {
    return Card(
      elevation: 1,
      color: _cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildInfoTile(CupertinoIcons.mail_solid, 'Email',
              _sessionService.email ?? 'No disponible'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(
              CupertinoIcons.creditcard_fill, 'DNI', profile.dni),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(
              CupertinoIcons.phone_fill, 'Teléfono', profile.phone),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(CupertinoIcons.placemark_fill, 'Ubicación',
              '${profile.city}, ${profile.country}'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: _primaryIconColor),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: _textColor)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 16, color: _textColor)),
    );
  }
}
