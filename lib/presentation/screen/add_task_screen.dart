import 'package:agrocontrol_app/models/task.dart';
import 'package:agrocontrol_app/models/worker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddTaskScreen extends StatefulWidget {
  final String taskType;
  final List<Worker> availableWorkers;

  const AddTaskScreen(
      {super.key, required this.taskType, required this.availableWorkers});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final _hoursController = TextEditingController();
  Worker? _selectedWorker;

  @override
  void initState() {
    super.initState();
    if (widget.availableWorkers.length == 1) {
      _selectedWorker = widget.availableWorkers.first;
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una fecha.')),
        );
        return;
      }
      final newTask = Task(
        date: _selectedDate!,
        hours: int.tryParse(_hoursController.text) ?? 0,
        worker: _selectedWorker!,
      );
      Navigator.of(context).pop(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar ${widget.taskType}'),
        backgroundColor: const Color(0xFF043A3A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<Worker>(
                value: _selectedWorker,
                items: widget.availableWorkers.map((worker) {
                  return DropdownMenuItem(value: worker, child: Text(worker.name));
                }).toList(),
                onChanged: (worker) => setState(() => _selectedWorker = worker),
                decoration: const InputDecoration(
                  labelText: 'Trabajador Encargado',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Debes seleccionar un trabajador' : null,
              ),
              const SizedBox(height: 16),
              // Selector de Fecha
              TextFormField(
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  hintText: _selectedDate == null
                      ? 'Selecciona una fecha'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Horas Trabajadas
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'Horas Trabajadas',
                  prefixIcon: Icon(Icons.timer_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Las horas son obligatorias';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('GUARDAR REGISTRO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
