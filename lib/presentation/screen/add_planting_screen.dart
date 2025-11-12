import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Plantation {
  final String seedName;
  final int quantity;
  final DateTime startDate;
  DateTime? finishDate;

  Plantation({
    required this.seedName,
    required this.quantity,
    required this.startDate,
    this.finishDate,
  });
}

class AddPlantingScreen extends StatefulWidget {
  const AddPlantingScreen({super.key});

  @override
  State<AddPlantingScreen> createState() => _AddPlantingScreenState();
}

class _AddPlantingScreenState extends State<AddPlantingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _seedNameController = TextEditingController();
  final _quantityController = TextEditingController();


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newPlanting = Plantation(
        seedName: _seedNameController.text,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        startDate: DateTime.now(),
      );
      Navigator.of(context).pop(newPlanting);
    }
  }

  @override
  void dispose() {
    _seedNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Plantación'),
        backgroundColor: const Color(0xFF043A3A),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                controller: _seedNameController,
                labelText: 'Nombre de la Semilla',
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _quantityController,
                labelText: 'Cantidad de Semillas',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('GUARDAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
        ),
        floatingLabelStyle: const TextStyle(color: Colors.black),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}
