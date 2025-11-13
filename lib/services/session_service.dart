import 'package:agrocontrol_app/models/agricultural_producer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  int? userId;
  String? email;
  String? token;
  List<String>? roles;
  AgriculturalProducer? userProfile;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    email = prefs.getString('email');
    token = prefs.getString('token');
    roles = prefs.getStringList('roles');
  }

  Future<void> saveSession(int userId, String email, String token, List<String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    this.userId = userId;
    this.email = email;
    this.token = token;
    this.roles = roles;

    await prefs.setInt('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('token', token);
    await prefs.setStringList('roles', roles);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userId = null;
    email = null;
    token = null;
    roles = null;
    userProfile = null;
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;
}
