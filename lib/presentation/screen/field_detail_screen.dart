import 'package:agrocontrol_app/models/field.dart';
import 'package:agrocontrol_app/presentation/screen/add_planting_screen.dart';
import 'package:agrocontrol_app/presentation/screen/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FieldDetailScreen extends StatefulWidget {
  final Field field;

  const FieldDetailScreen({super.key, required this.field});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  Plantation? _currentPlanting;

  static const Color colorPrimary = Color(0xFF043A3A);
  static const Color colorPrimaryLight = Color(0xFFE6F2F2);
  static const Color colorAccent = Color(0xFF2E8B57);
  static const Color colorError = Color(0xFFD9534F);

  @override
  void initState() {
    super.initState();
    _currentPlanting = Plantation(
      seedName: 'Zanahorias (Nantes)',
      quantity: 30,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      finishDate: null,
    );
  }

  void _navigateToCreatePlanting() async {
    final newPlanting = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddPlantingScreen()),
    );

    if (newPlanting != null && newPlanting is Plantation) {
      setState(() {
        _currentPlanting = newPlanting;
      });
    }
  }

  void _finishPlanting() {
    if (_currentPlanting != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Finalizar Plantación'),
          content: const Text(
              '¿Estás seguro de que quieres marcar esta plantación como finalizada?'),
          actions: [
            TextButton(
              style:  TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Color(0xFFD9534F)),
              child: const Text('Finalizar'),
              onPressed: () {
                setState(() {
                  _currentPlanting!.finishDate = DateTime.now();
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plantación finalizada con éxito.'),
                    backgroundColor: colorAccent,
                  ),
                );
                HapticFeedback.mediumImpact();
              },
            ),
          ],
        ),
      );
    }
  }

  void _navigateToTaskScreen(String taskType) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TaskScreen(taskType: taskType)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field.name),
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              widget.field.imageUrl,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Plantación',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildPlantingSection(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Mantenimiento y Tareas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildTaskCard(
                    title: 'Riego',
                    details: 'Añadir o ver registros',
                    icon: Icons.water_drop_outlined,
                    onTap: () => _navigateToTaskScreen('Riego'),
                  ),
                  const SizedBox(height: 12),
                  _buildTaskCard(
                    title: 'Fumigación',
                    details: 'Añadir o ver registros',
                    icon: Icons.bug_report_outlined,
                    onTap: () => _navigateToTaskScreen('Fumigación'),
                  ),
                  const SizedBox(height: 12),
                  _buildTaskCard(
                    title: 'Fertilizantes',
                    details: 'Añadir o ver registros',
                    icon: Icons.eco_outlined,
                    onTap: () => _navigateToTaskScreen('Fertilizantes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantingSection() {
    if (_currentPlanting == null) {
      return Center(
        child: Column(
          children: [
            const Text('No hay una plantación activa en este campo.'),
            const SizedBox(height: 16),
            _buildCreateButton(),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPlantingCard(_currentPlanting!),
        const SizedBox(height: 20),
        if (_currentPlanting!.finishDate == null)
          _buildFinishButton()
        else
          _buildCreateButton(text: 'Crear Nueva Plantación'),
      ],
    );
  }

  Widget _buildCreateButton({String text = 'Crear Plantación'}) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_circle_outline),
      label: Text(text),
      onPressed: _navigateToCreatePlanting,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFinishButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.check_circle_outline),
      label: const Text('Finalizar Plantación'),
      onPressed: _finishPlanting,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorError,
        side: BorderSide(color: colorError, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPlantingCard(Plantation planting) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    bool isFinished = planting.finishDate != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isFinished ? Colors.grey.shade100 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planting.seedName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isFinished ? Colors.grey.shade700 : colorPrimary,
                decoration: isFinished ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.format_list_numbered,
              'Cantidad',
              planting.quantity.toString(),
              isFinished: isFinished,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Fecha Inicio',
              dateFormat.format(planting.startDate),
              isFinished: isFinished,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.flag_outlined,
              'Estado',
              isFinished
                  ? 'Finalizado el ${dateFormat.format(planting.finishDate!)}'
                  : 'En progreso',
              highlight: !isFinished,
              isFinished: isFinished,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool highlight = false, bool isFinished = false}) {
    Color activeColor = highlight ? colorAccent : Colors.black87;
    Color color = isFinished ? Colors.grey.shade600 : activeColor;

    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 16),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isFinished ? Colors.grey.shade600 : Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String details,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorPrimaryLight,
                foregroundColor: colorPrimary,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(details,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
