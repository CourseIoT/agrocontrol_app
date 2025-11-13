import 'package:agrocontrol_app/models/worker.dart';
import 'package:agrocontrol_app/presentation/screen/add_worker_screen.dart';
import 'package:agrocontrol_app/presentation/widgets/custom_loading_indicator.dart';
import 'package:agrocontrol_app/services/api_service.dart';
import 'package:flutter/material.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  late Future<List<Worker>> _workersFuture;
  final _femaleImagePaths = [
    'assets/images/female_1.png',
    'assets/images/female_2.png',
    'assets/images/female_3.png',
  ];
  final _maleImagePaths = [
    'assets/images/male_1.png',
    'assets/images/male_2.png',
    'assets/images/male_3.png',
  ];

  @override
  void initState() {
    super.initState();
    _workersFuture = _fetchWorkers();
  }

  Future<List<Worker>> _fetchWorkers() async {
    await Future.delayed(const Duration(seconds: 2));
    return ApiService().getWorkersByProducerId();
  }

  void _handleRefresh() {
    setState(() {
      _workersFuture = _fetchWorkers();
    });
  }

  void _navigateToAddWorker() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddWorkerScreen()),
    );

    if (result != null && result is Worker) {
      _handleRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: const Color(0xFF2E8B57),
        strokeWidth: 3.0,
        onRefresh: () async => _handleRefresh(),
        child: FutureBuilder<List<Worker>>(
          future: _workersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CustomLoadingIndicator(message: 'Cargando trabajadores...'),
              );
            }
            if (snapshot.hasError) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error al cargar trabajadores: ${snapshot.error}'),
              ));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay empleados registrados.'),
              );
            }

            final workers = snapshot.data!;
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                final firstName = worker.fullName.split(' ').first.toLowerCase();

                List<String> imagePathList;
                if (firstName.endsWith('a')) {
                  imagePathList = _femaleImagePaths;
                } else if (firstName.endsWith('o')) {
                  imagePathList = _maleImagePaths;
                } else {
                  imagePathList = [..._femaleImagePaths, ..._maleImagePaths];
                }

                final imagePath = imagePathList[worker.id % imagePathList.length];

                return Card(
                  color: Colors.grey.shade50,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(imagePath),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    title: Text(worker.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Doc: ${worker.documentNumber}'),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWorker,
        backgroundColor: const Color(0xFF2E8B57),
        tooltip: 'Agregar Empleado',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
