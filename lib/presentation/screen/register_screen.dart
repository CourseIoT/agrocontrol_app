import 'package:agrocontrol_app/services/api_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dniController = TextEditingController();

  bool _isLoading = false;

  final Color _focusGreen = Colors.green.shade700;
  final OutlineInputBorder _defaultBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
  );
  final OutlineInputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
  );

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'fullName': _fullNameController.text,
        'city': _cityController.text,
        'country': _countryController.text,
        'phone': _phoneController.text,
        'dni': _dniController.text,
      };

      try {
        final user = await _apiService.signUpAgriculturalProducer(data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Registro exitoso para ${user.email}!')),
        );
        Navigator.of(context).pop();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('AgroControl', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF2E8B57), fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Crea una cuenta', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),

                _buildTextFormField(controller: _fullNameController, labelText: 'Nombre Completo'),
                const SizedBox(height: 16),
                _buildTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@') || !value.contains('.')) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextFormField(controller: _passwordController, labelText: 'Contraseña', obscureText: true),
                const SizedBox(height: 16),
                _buildTextFormField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirma la contraseña',
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextFormField(controller: _cityController, labelText: 'Ciudad'),
                const SizedBox(height: 16),
                _buildTextFormField(controller: _countryController, labelText: 'País'),
                const SizedBox(height: 16),
                _buildTextFormField(
                    controller: _phoneController,
                    labelText: 'Teléfono',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.length < 9) {
                        return 'El teléfono debe tener al menos 9 dígitos';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextFormField(
                    controller: _dniController,
                    labelText: 'DNI',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'El DNI debe tener al menos 8 dígitos';
                      }
                      return null;
                    }),
                const SizedBox(height: 24),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("REGISTRAR"),
                ),
                const SizedBox(height: 16),

                Text.rich(
                  TextSpan(
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                    children: [
                      const TextSpan(text: "¿Ya tienes una cuenta? "),
                      TextSpan(
                        text: "Iniciar sesión",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      obscureText: obscureText,
      cursorColor: _focusGreen,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        floatingLabelStyle: TextStyle(color: _focusGreen),
        border: _defaultBorder,
        enabledBorder: _defaultBorder,
        focusedBorder: _focusedBorder,
      ),
    );
  }
}