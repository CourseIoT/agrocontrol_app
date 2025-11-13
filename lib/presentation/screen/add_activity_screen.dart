import 'package:agrocontrol_app/models/worker.dart';
import 'package:agrocontrol_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddActivityScreen extends StatefulWidget {
  final int agriculturalProcessId;
  final String activityType;

  const AddActivityScreen({
    super.key,
    required this.agriculturalProcessId,
    required this.activityType,
  });

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;
  String get _normalizedActivityType =>
      widget.activityType.toUpperCase().replaceAll(' ', '_');

  DateTime? _selectedDate;
  final _dateController = TextEditingController();

  final _hoursIrrigatedController = TextEditingController();
  final _plantTypeController = TextEditingController();
  final _quantityPlantedController = TextEditingController();
  String? _selectedTreatmentType;
  final _quantityInKgController = TextEditingController();
  final _pricePerKgController = TextEditingController();

  List<Worker> _workers = [];
  int? _selectedWorkerId;
  bool _isLoadingWorkers = true;

  final Color _focusGreen = Colors.green.shade700;
  final OutlineInputBorder _defaultBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
  );
  final OutlineInputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
  );

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    try {
      final workers = await _apiService.getWorkersByProducerId();
      if (mounted) {
        setState(() {
          _workers = workers;
          _isLoadingWorkers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWorkers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar trabajadores: $e')),
        );
      }
    }
  }
  @override
  void dispose() {
    _dateController.dispose();
    _hoursIrrigatedController.dispose();
    _plantTypeController.dispose();
    _quantityPlantedController.dispose();
    _quantityInKgController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  String _getTitleForActivityType() {
    switch (_normalizedActivityType) {
      case 'IRRIGATION':
        return 'Riego';
      case 'SEEDING':
        return 'Siembra';
      case 'CROP_TREATMENT':
        return 'Tratamiento';
      case 'HARVEST':
        return 'Cosecha';
      default:
        return 'Actividad';
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF043A3A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF043A3A),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una fecha.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final Map<String, dynamic> params = {
        'agriculturalProcessId': widget.agriculturalProcessId,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!), 'activityType': _normalizedActivityType,
      };

      switch (_normalizedActivityType) {
        case 'IRRIGATION':
          params['hoursIrrigated'] = double.tryParse(_hoursIrrigatedController.text) ?? 0.0;
          break;
        case 'SEEDING':
          params['plantType'] = _plantTypeController.text;
          params['quantityPlanted'] = int.tryParse(_quantityPlantedController.text) ?? 0;
          break;
        case 'CROP_TREATMENT':
          params['treatmentType'] = _selectedTreatmentType;
          break;
        case 'HARVEST':
          params['quantityInKg'] = double.tryParse(_quantityInKgController.text) ?? 0.0;
          params['pricePerKg'] = double.tryParse(_pricePerKgController.text) ?? 0.0;
          break;
      }

      try {
        await _apiService.addActivity(params);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actividad registrada con éxito'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la actividad'), backgroundColor: Colors.red),
        );
      } finally {
        if(mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = _getTitleForActivityType();

    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir $title'),
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
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  labelText: 'Fecha de la Actividad',
                  hintText: 'Seleccionar fecha',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: _defaultBorder,
                  enabledBorder: _defaultBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: TextStyle(color: _focusGreen),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona una fecha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                dropdownColor: Colors.white,
                value: _selectedWorkerId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Asignar a trabajador',
                  prefixIcon: _isLoadingWorkers
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.person_outline),
                  border: _defaultBorder,
                  enabledBorder: _defaultBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: TextStyle(color: _focusGreen),
                ),
                hint: Text(_isLoadingWorkers
                    ? 'Cargando trabajadores...'
                    : _workers.isEmpty
                    ? 'No hay trabajadores disponibles'
                    : 'Seleccionar trabajador'),
                items: _workers.map((Worker worker) {
                  return DropdownMenuItem<int>(
                    value: worker.id,
                    child: Text(worker.fullName),
                  );
                }).toList(),
                onChanged: _isLoadingWorkers || _workers.isEmpty
                    ? null
                    : (int? newValue) {
                  setState(() {
                    _selectedWorkerId = newValue;
                  });
                },
              ),
              const SizedBox(height: 24),
              ..._buildSpecificFields(),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSpecificFields() {
    switch (_normalizedActivityType) {
      case 'IRRIGATION':
        return [
          _buildTextFormField(
            controller: _hoursIrrigatedController,
            labelText: 'Horas de Riego',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ];
      case 'SEEDING':
        return [
          _buildTextFormField(controller: _plantTypeController, labelText: 'Tipo de Planta'),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _quantityPlantedController,
            labelText: 'Cantidad Sembrada',
            keyboardType: TextInputType.number,
          ),
        ];
      case 'CROP_TREATMENT':
        return [
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: _selectedTreatmentType,
            decoration: InputDecoration(
              labelText: 'Tipo de Tratamiento',
              border: _defaultBorder,
              enabledBorder: _defaultBorder,
              focusedBorder: _focusedBorder,
              floatingLabelStyle: TextStyle(color: _focusGreen),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Fumigación',
                child: Text('Fumigación'),
              ),
              DropdownMenuItem(
                value: 'Fertilización',
                child: Text('Fertilización'),
              ),
            ],
            onChanged: (String? newValue) {
              setState(() {
                _selectedTreatmentType = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          )
        ];
      case 'HARVEST':
        return [
          _buildTextFormField(
            controller: _quantityInKgController,
            labelText: 'Cantidad Cosechada (Kg)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _pricePerKgController,
            labelText: 'Precio por Kg',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ];
      default:
        return [const Center(child: Text('Error: Tipo de actividad no reconocido.'))];
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: _focusGreen,
      decoration: InputDecoration(
        labelText: labelText,
        border: _defaultBorder,
        enabledBorder: _defaultBorder,
        focusedBorder: _focusedBorder,
        floatingLabelStyle: TextStyle(color: _focusGreen),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}