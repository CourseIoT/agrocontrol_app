import 'package:agrocontrol_app/models/field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _landSizeController = TextEditingController();

  void _submitForm() {
    // Validamos el formulario
    if (_formKey.currentState!.validate()) {
      // Creamos el nuevo objeto Field
      final newField = Field(
        name: _nameController.text,
        location: _locationController.text,
        landSize: double.tryParse(_landSizeController.text) ?? 0.0,
        imageUrl: 'assets/images/farm_background.png',
      );

      Navigator.of(context).pop(newField);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _landSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nuevo Campo'),
        backgroundColor: const Color(0xFF043A3A),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Nombre del Campo',
                icon: Icons.grass,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _locationController,
                labelText: 'Ubicación',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _landSizeController,
                labelText: 'Tamaño (en hectáreas)',
                icon: Icons.landscape_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR CAMPO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
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
