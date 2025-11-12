import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

enum UserType { producer, distributor }

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  final Color _focusGreen = Colors.green.shade700;

  final InputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
  );

  final InputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
  );

  final TextStyle _labelStyle = TextStyle(color: Colors.grey.shade600);
  final TextStyle _floatingLabelStyle = TextStyle(color: Colors.green.shade700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "AgroControl",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _focusGreen,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Crea una cuenta",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                cursorColor: _focusGreen,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: _labelStyle,
                  border: _inputBorder,
                  enabledBorder: _inputBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: _floatingLabelStyle,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: _focusGreen,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: _labelStyle,
                  border: _inputBorder,
                  enabledBorder: _inputBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: _floatingLabelStyle,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: _focusGreen,
                obscureText: _isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: _labelStyle,
                  border: _inputBorder,
                  enabledBorder: _inputBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: _floatingLabelStyle,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() { _isPasswordObscured = !_isPasswordObscured; });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: _focusGreen,
                obscureText: _isConfirmPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Confirma la contraseña',
                  labelStyle: _labelStyle,
                  border: _inputBorder,
                  enabledBorder: _inputBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: _floatingLabelStyle,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() { _isConfirmPasswordObscured = !_isConfirmPasswordObscured; });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: _focusGreen,
                decoration: InputDecoration(
                  labelText: 'Ciudad',
                  labelStyle: _labelStyle,
                  border: _inputBorder,
                  enabledBorder: _inputBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: _floatingLabelStyle,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: _focusGreen,
                decoration: InputDecoration(
                  labelText: 'País',
                  labelStyle: _labelStyle,
                  border: _inputBorder,
                  enabledBorder: _inputBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: _floatingLabelStyle,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: _focusGreen,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: _labelStyle,
                  border: _inputBorder,
                  enabledBorder: _inputBorder,
                  focusedBorder: _focusedBorder,
                  floatingLabelStyle: _floatingLabelStyle,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                },
                child: const Text("REGISTRAR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  children: [
                    const TextSpan(text: "Tienes una cuenta? "),
                    TextSpan(
                      text: "Iniciar sesión",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                        },
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
