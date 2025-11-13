import 'package:agrocontrol_app/presentation/widgets/custom_loading_indicator.dart';
import 'package:agrocontrol_app/services/api_service.dart';
import 'package:agrocontrol_app/services/session_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _sessionService = SessionService();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _rememberMe = false;
  bool _isPasswordObscured = true;
  final Color _focusGreen = Colors.green.shade700;
  final OutlineInputBorder _defaultBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: Colors.black, width: 2.0),
  );
  final OutlineInputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: Colors.green.shade700, width: 2.5),
  );

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = await _apiService.signIn(
          _emailController.text,
          _passwordController.text,
        );

        if (user.roles.contains('ROLE_AGRICULTURAL_PRODUCER') && user.token != null) {
          await _sessionService.saveSession(user.id, user.email, user.token!, user.roles);
          
          final profile = await _apiService.getAgriculturalProducerProfile(user.id);
          _sessionService.userProfile = profile;

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          throw Exception('Rol de usuario no autorizado o token no recibido.');
        }

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/farm_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(decoration: const BoxDecoration(color: Colors.black54)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w300),
                        children: [
                          const TextSpan(text: 'Bienvenido a '),
                          TextSpan(
                            text: 'AgroControl',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade400),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),
                    OutlinedButton.icon(
                      icon: Image.asset('assets/images/google_logo.png', height: 24.0),
                      label: const Text('Continuar con google'),
                      onPressed: () { },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white.withAlpha(230),
                        side: const BorderSide(color: Colors.black, width: 2.0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const Text('o', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: _emailController,
                      cursorColor: _focusGreen,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        filled: true,
                        fillColor: Colors.white.withAlpha(230),
                        border: _defaultBorder,
                        enabledBorder: _defaultBorder,
                        focusedBorder: _focusedBorder,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || !value.contains('@')) ? 'Email no válido' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      cursorColor: _focusGreen,
                      obscureText: _isPasswordObscured,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade700),
                          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                        ),
                        filled: true,
                        fillColor: Colors.white.withAlpha(230),
                        border: _defaultBorder,
                        enabledBorder: _defaultBorder,
                        focusedBorder: _focusedBorder,
                      ),
                       validator: (value) => (value == null || value.isEmpty) ? 'La contraseña no puede estar vacía' : null,
                    ),
                    const SizedBox(height: 24.0),
                    _isLoading
                        ? const Center(child: CustomLoadingIndicator())
                        : OutlinedButton(
                            onPressed: _submitForm,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white.withAlpha(230),
                              side: const BorderSide(color: Colors.black, width: 2.0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: const Text('Log In'),
                          ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (bool? value) => setState(() => _rememberMe = value ?? false),
                                side: const BorderSide(color: Colors.white, width: 1.5),
                                activeColor: Colors.green.shade700,
                                checkColor: Colors.white,
                              ),
                              const Flexible(
                                child: Text('Recuérdame', style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          child: const Text('Olvidé mi contraseña', style: TextStyle(color: Colors.white)),
                          onPressed: () {  },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        children: [
                          const TextSpan(text: "¿No tienes una cuenta? "),
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade300),
                            recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushNamed(context, '/register'),
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
        ],
      ),
    );
  }
}
