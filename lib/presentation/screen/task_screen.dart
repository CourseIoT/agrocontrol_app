import 'package:agrocontrol_app/data/app_data.dart';
import 'package:agrocontrol_app/models/task.dart';
import 'package:agrocontrol_app/models/worker.dart';
import 'package:agrocontrol_app/presentation/screen/add_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  final String taskType;

  const TaskScreen({super.key, required this.taskType});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  static const Color colorPrimary = Color(0xFF043A3A);
  static const Color colorPrimaryLight = Color(0xFFE6F2F2);
  static const Color colorAccent = Color(0xFF2E8B57);
  static const Color colorError = Color(0xFFD9534F);

  final Map<String, List<Task>> _allTasks = {
    'Riego': [
      Task(date: DateTime(2023, 11, 10), hours: 2, worker: AppData.workers[0]),
    ],
    'Fumigación': [
      Task(date: DateTime(2023, 11, 8), hours: 4, worker: AppData.workers[1]),
      Task(date: DateTime(2023, 11, 2), hours: 3, worker: AppData.workers[2]),
      Task(date: DateTime(2023, 10, 28), hours: 4.5, worker: AppData.workers[1]),
    ],
    'Fertilizantes': [],
  };

  late List<Task> _currentTasks;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _currentTasks = _allTasks.putIfAbsent(widget.taskType, () => []);
    _currentTasks.sort((a, b) => b.date.compareTo(a.date));
  }

  IconData _getTaskIcon() {
    switch (widget.taskType) {
      case 'Riego':
        return Icons.water_drop_outlined;
      case 'Fumigación':
        return Icons.pest_control_outlined;
      case 'Fertilizantes':
        return Icons.eco_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  void _sortTasks() {
    setState(() {
      _sortAscending = !_sortAscending;
      _currentTasks.sort((a, b) {
        return _sortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date);
      });
    });
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Eliminación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este registro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _currentTasks.removeAt(index);
              });
              Navigator.of(ctx).pop();
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registro eliminado correctamente'),
                  backgroundColor: colorError,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddTask() async {
    final List<Worker> availableWorkers = AppData.workers;

    if (availableWorkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No hay trabajadores registrados.'),
          backgroundColor: Colors.grey.shade800,
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
      return;
    }

    final newTask = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
            taskType: widget.taskType, availableWorkers: availableWorkers),
      ),
    );

    if (newTask != null && newTask is Task) {
      setState(() {
        _currentTasks.add(newTask);
        _currentTasks.sort((a, b) => _sortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.taskType),
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_currentTasks.isNotEmpty)
            IconButton(
              icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: _sortTasks,
              tooltip: 'Ordenar por fecha',
            ),
        ],
      ),
      body: _currentTasks.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _currentTasks.length,
        itemBuilder: (context, index) {
          final task = _currentTasks[index];
          return _buildTaskCard(task, index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTask,
        label: const Text('Agregar Registro'),
        icon: const Icon(Icons.add),
        backgroundColor: colorAccent,
        foregroundColor: Colors.white,
      ),
    );
  }


  Widget _buildTaskCard(Task task, int index) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      color: Colors.grey.shade100,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorPrimaryLight,
          foregroundColor: colorPrimary,
          child: Icon(_getTaskIcon(), size: 22),
        ),
        title: Text(
          task.worker.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(dateFormat.format(task.date),
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('${task.hours}h',
                  style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: colorError.withOpacity(0.8)),
          onPressed: () => _deleteTask(index),
          tooltip: 'Eliminar',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(_getTaskIcon(), size: 60, color: colorPrimary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin registros de ${widget.taskType}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón para añadir el primero.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}