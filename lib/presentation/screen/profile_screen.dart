import 'package:agrocontrol_app/models/agricultural_producer.dart';
import 'package:agrocontrol_app/services/session_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService();
    final AgriculturalProducer? profile = session.userProfile;

    const Color primaryColor = Color(0xFF043A3A);

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil de Usuario'),
          backgroundColor: primaryColor,
        ),
        body: const Center(
          child: Text('No se pudo cargar la información del perfil.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/user_placeholder.png'),
            ),
            const SizedBox(height: 16),
            Text(
              profile.fullName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              'Productor Agrícola',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            _buildInfoTile(icon: Icons.email_outlined, label: 'Email', value: session.email ?? 'No disponible'),
            _buildInfoTile(icon: Icons.badge_outlined, label: 'DNI', value: profile.dni),
            _buildInfoTile(icon: Icons.phone_outlined, label: 'Teléfono', value: profile.phone),
            _buildInfoTile(icon: Icons.location_city_outlined, label: 'Ciudad', value: profile.city),
            _buildInfoTile(icon: Icons.public_outlined, label: 'País', value: profile.country),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.grey.shade700),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade900)),
        ),
      ),
    );
  }
}
