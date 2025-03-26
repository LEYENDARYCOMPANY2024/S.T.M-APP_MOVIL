import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:math';
import 'hash_services.dart';
import 'token_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Dio _dio = Dio();

  // 🔹 LOGIN (Verifica contraseña hasheada y genera token)
  Future<bool> login(String username, String password) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('id_paciente, contrasena_p')
          .eq('nombre_usuario_p', username)
          .maybeSingle();

      if (response == null) {
        print('❌ Usuario no encontrado');
        return false;
      }

      int userId = response['id_paciente'];
      String hashedPassword = response['contrasena_p'];

      // Verificar la contraseña ingresada con la hasheada
      if (HashService.verifyPassword(password, hashedPassword)) {
        // Generar y guardar token
        final token = _generateToken(username, userId);
        await TokenService.saveAuthData(token, userId);
        
        print('✅ Login exitoso');
        return true;
      } else {
        print('❌ Contraseña incorrecta');
        return false;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return false;
    }
  }

  // 🔹 VERIFICAR TOKEN (Comprueba si el token es válido)
  Future<bool> verifyToken() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return false;
      
      return true;
    } catch (e) {
      print('❌ Error al verificar token: $e');
      return false;
    }
  }

  // 🔹 LOGOUT (Eliminar token y datos de sesión)
  Future<void> logout() async {
    await TokenService.clearAuthData();
  }

  // 🔹 REGISTRO (Hashea la contraseña antes de guardarla)
  Future<bool> register(String codigo, String username, String password) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('id_paciente, nombre_usuario_p')
          .eq('codigo', codigo)
          .maybeSingle();

      if (response == null) {
        print('❌ Código de paciente no válido');
        return false;
      }

      final int pacienteId = response['id_paciente'];

      final usernameExists = await _supabase
          .from('pacientes')
          .select('id_paciente')
          .eq('nombre_usuario_p', username)
          .maybeSingle();

      if (usernameExists != null) {
        print('❌ Nombre de usuario ya está en uso');
        return false;
      }

      String hashedPassword = HashService.hashPassword(password);

      await _supabase.from('pacientes').update({
        'nombre_usuario_p': username,
        'contrasena_p': hashedPassword,
      }).eq('id_paciente', pacienteId);

      print('✅ Registro exitoso');
      return true;
    } catch (e) {
      print('❌ Error en registro: $e');
      return false;
    }
  }
  
  // Método privado para generar un token
  String _generateToken(String username, int userId) {
    final random = Random();
    final randomBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final payload = {
      'user_id': userId,
      'username': username,
      'timestamp': timestamp,
      'random': base64Encode(randomBytes),
    };

    final token = base64Encode(utf8.encode(json.encode(payload)));
    return token;
  }

  // 🔹 Obtener ID del Paciente desde el Token
  Future<int?> obtenerIdPacienteDesdeToken() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No hay token disponible');
        return null;
      }
      
      final decoded = json.decode(utf8.decode(base64Decode(token)));
      if (decoded is Map<String, dynamic> && decoded.containsKey('user_id')) {
        return decoded['user_id'] as int?;
      } else {
        print('❌ Error: El token no contiene un ID de paciente válido.');
        return null;
      }
    } catch (e) {
      print('❌ Error al obtener ID de paciente desde el token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> validatePatientCode(String code) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('nombre_usuario_p, contrasena_p')
          .eq('codigo', code)
          .maybeSingle();

      if (response == null) {
        // El código no existe en la base de datos
        return {
          'exists': false,
          'hasCredentials': false
        };
      }

      // Verificar si ya tiene credenciales (usuario y contraseña)
      bool hasCredentials = response['nombre_usuario_p'] != null && 
                           response['contrasena_p'] != null;

      return {
        'exists': true,
        'hasCredentials': hasCredentials
      };

    } catch (e) {
      print('❌ Error al validar código: $e');
      throw Exception('Error al validar el código');
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('id_paciente')
          .eq('nombre_usuario_p', username)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('❌ Error al verificar nombre de usuario: $e');
      throw Exception('Error al verificar nombre de usuario');
    }
  }
}
