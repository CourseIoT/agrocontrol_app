import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/field.dart';
import 'fields_screen.dart'; // Para poder usar la clase Field

class EditFieldScreen extends StatefulWidget {
  final Field field; // El campo existente que vamos a editar

  const EditFieldScreen({super.key, required this.field});

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _landSizeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field.name);
    _locationController = TextEditingController(text: widget.field.location);
    _landSizeController = TextEditingController(text: widget.field.landSize.toString());
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedField = Field(
        name: _nameController.text,
        location: _locationController.text,
        landSize: double.tryParse(_landSizeController.text) ?? 0.0,
        imageUrl: widget.field.imageUrl,
      );
      Navigator.of(context).pop(updatedField);
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
        title: const Text('Editar Campo'),
        backgroundColor: const Color(0xFF043A3A),
        iconTheme: const IconThemeData(color: Colors.white),
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
                label: const Text('ACTUALIZAR CAMPO'),
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
