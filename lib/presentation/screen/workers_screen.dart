import 'package:agrocontrol_app/data/app_data.dart';
import 'package:agrocontrol_app/models/worker.dart';
import 'package:agrocontrol_app/presentation/screen/add_worker_screen.dart';
import 'package:flutter/material.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {

  void _navigateToAddWorker() async {
    final newWorker = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddWorkerScreen()),
    );

    if (newWorker != null && newWorker is Worker) {
      AppData.workers.add(newWorker);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: AppData.workers.isEmpty
          ? const Center(
              child: Text('No hay empleados registrados.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: AppData.workers.length,
              itemBuilder: (context, index) {
                final worker = AppData.workers[index];
                return Dismissible(
                  key: ObjectKey(worker),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text('Confirmar Eliminación'),
                        content: Text('¿Estás seguro de que quieres eliminar a ${worker.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) {
                    setState(() {
                      AppData.workers.removeAt(index);
                    });
                  },
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Color(0xFFD9534F),
                    ),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: Card(
                    color: Colors.grey.shade50,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(worker.name),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWorker,
        backgroundColor: Colors.green.shade700,
        tooltip: 'Agregar Empleado',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
