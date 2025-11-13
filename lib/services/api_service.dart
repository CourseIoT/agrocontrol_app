import 'dart:convert';
import 'package:agrocontrol_app/core/config.dart';
import 'package:agrocontrol_app/models/agricultural_producer.dart';
import 'package:agrocontrol_app/models/field.dart';
import 'package:agrocontrol_app/models/user.dart';
import 'package:agrocontrol_app/models/worker.dart';
import 'package:agrocontrol_app/services/session_service.dart';
import 'package:http/http.dart' as http;

import '../models/activity.dart';
import '../models/agricultural_process.dart';

class ApiService {

  Future<Activity> executeActivityAction({
    required int activityId,
    required int agriculturalProcessId,
    required String action,
  }) async {
    final token = SessionService().token;
    if (token == null) throw Exception('Usuario no autenticado.');

    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/agricultural-processes/activity/$activityId/execute');

    final body = json.encode({
      'agriculturalProcessId': agriculturalProcessId,
      'action': action,
    });

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Activity.fromJson(json.decode(response.body));
      } else {
        if (response.body.isNotEmpty) {
          try {
            final errorBody = json.decode(response.body);
            throw Exception('Error al ejecutar la acción: ${errorBody['message'] ?? response.body}');
          } catch (e) {
            throw Exception('Error al ejecutar la acción: ${response.body}');
          }
        } else {
          throw Exception('Error al ejecutar la acción (código: ${response.statusCode})');
        }
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  // --- Fields ---
  Future<List<Activity>> getActivities(int processId, String activityType) async {
    final token = SessionService().token;
    if (token == null) throw Exception('Usuario no autenticado.');

    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/agricultural-processes/$processId/activities/$activityType');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Activity.fromJson(json)).toList();
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        return [];
      } else {
        throw Exception('Error al cargar actividades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<Activity> addActivity(Map<String, dynamic> params) async {
    final token = SessionService().token;
    if (token == null) throw Exception('Usuario no autenticado.');

    final activityType = params['activityType'] as String?;

    switch (activityType) {
      case 'IRRIGATION':
        if (params['hoursIrrigated'] == null || (params['hoursIrrigated'] as num) <= 0) {
          throw Exception('Las horas de riego deben ser un número mayor a 0.');
        }
        break;
      case 'SEEDING':
        if (params['plantType'] == null || params['quantityPlanted'] == null || (params['quantityPlanted'] as num) <= 0) {
          throw Exception('El tipo de planta es requerido y la cantidad sembrada debe ser mayor a 0.');
        }
        break;
      case 'CROP_TREATMENT':
        if (params['treatmentType'] == null || (params['treatmentType'] as String).isEmpty) {
          throw Exception('El tipo de tratamiento es requerido.');
        }
        break;
      case 'HARVEST':
        if (params['quantityInKg'] == null ||
            (params['quantityInKg'] as num) <= 0 ||
            params['pricePerKg'] == null ||
            (params['pricePerKg'] as num) <= 0) {
          throw Exception('La cantidad y el precio por kg deben ser mayores a 0.');
        }
        break;
      default:
        throw Exception('Tipo de actividad no válido o no especificado.');
    }
    
    final queryParameters = params.map((key, value) => MapEntry(key, value.toString()));

    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/agricultural-processes/add-activity')
        .replace(queryParameters: queryParameters);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Activity.fromJson(json.decode(response.body));
      } else {
        if (response.body.isNotEmpty) {
          try {
            final errorBody = json.decode(response.body);
            throw Exception('Error al añadir actividad: ${errorBody['message'] ?? response.body}');
          } catch (e) {
            throw Exception('Error al añadir actividad: ${response.body}');
          }
        } else {
          throw Exception('Error al añadir actividad (código: ${response.statusCode})');
        }
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }
  
  Future<AgriculturalProcess> createAgriculturalProcess(int fieldId) async {
    final token = SessionService().token;
    if (token == null) throw Exception('Usuario no autenticado.');
    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/agricultural-processes');
    final body = json.encode({'fieldId': fieldId});
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        return AgriculturalProcess.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Error al crear el proceso: ${errorBody['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<AgriculturalProcess> finishAgriculturalProcess(int processId) async {
    final token = SessionService().token;
    if (token == null) throw Exception('Usuario no autenticado.');

    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/agricultural-processes/finish/$processId');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AgriculturalProcess.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Error al finalizar el proceso: ${errorBody['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<AgriculturalProcess?> getUnfinishedProcessForField(int fieldId) async {
    final token = SessionService().token;
    if (token == null) throw Exception('Usuario no autenticado.');

    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/agricultural-processes/field/$fieldId/unfinished');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AgriculturalProcess.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al cargar el proceso: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<List<Field>> getFieldsByUserId(int userId) async {
    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/fields/user/$userId');
    final String? token = SessionService().token;

    if (token == null) throw Exception('No se ha iniciado sesión.');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Field.fromJson(json)).toList();
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        return [];
      } else {
        throw Exception('Error al cargar los campos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<Field> createField(String fieldName, String location, double size) async {
    final session = SessionService();
    final producerId = session.userProfile?.agriculturalProducerId;
    final token = session.token;

    if (producerId == null || token == null) {
      throw Exception('Usuario no autenticado correctamente.');
    }

    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/fields');
    final body = json.encode({
      'producerId': producerId,
      'fieldName': fieldName,
      'location': location,
      'size': size,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Field.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Error al crear el campo: ${errorBody['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<Field> updateField(int fieldId, String name, String location, double size) async {
    final session = SessionService();
    final producerId = session.userProfile?.agriculturalProducerId;
    final token = session.token;

    if (producerId == null || token == null) {
      throw Exception('Usuario no autenticado correctamente.');
    }

    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/fields/$fieldId/update-field');
    final body = json.encode({
      'name': name,
      'location': location,
      'size': size,
      'producerId': producerId,
    });

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Field.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Error al actualizar el campo: ${errorBody['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<void> deleteField(int fieldId) async {
    final session = SessionService();
    final producerId = session.userProfile?.agriculturalProducerId;
    final token = session.token;

    if (producerId == null || token == null) {
      throw Exception('Usuario no autenticado correctamente.');
    }

    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/fields/$fieldId?producerId=$producerId');

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar el campo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<Worker> createWorker(String fullName, String documentNumber) async {
    final session = SessionService();
    final producerId = session.userProfile?.agriculturalProducerId;
    final token = session.token;

    if (producerId == null || token == null) {
      throw Exception('Usuario no autenticado correctamente.');
    }

    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/workers');
    final body = json.encode({
      'producerId': producerId,
      'fullName': fullName,
      'documentNumber': documentNumber,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return Worker.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Error al crear el trabajador: ${errorBody['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<List<Worker>> getWorkersByProducerId() async {
    final session = SessionService();
    final producerId = session.userProfile?.agriculturalProducerId;
    final token = session.token;

    if (producerId == null || token == null) {
      throw Exception('Usuario no autenticado correctamente.');
    }

    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/workers/$producerId');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Worker.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        return [];
      } else {
        throw Exception('Error al cargar los trabajadores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<User> signIn(String email, String password) async {
    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/authentication/sign-in');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Error en el inicio de sesión: ${errorBody['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  Future<User> signUpAgriculturalProducer(Map<String, String> data) async {
    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/authentication/sign-up/agricultural-producer');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Error en el registro: ${errorBody['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  // --- Profile ---

  Future<AgriculturalProducer> getAgriculturalProducerProfile(int userId) async {
    final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/v1/profiles/agricultural-producer/$userId');
    final String? token = SessionService().token;

    if (token == null) throw Exception('Usuario no autenticado.');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AgriculturalProducer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar el perfil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }
}
