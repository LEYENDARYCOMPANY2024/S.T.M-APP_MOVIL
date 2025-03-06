import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:math';
import 'hash_services.dart';
import 'token_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
      
      // Aquí puedes implementar verificación adicional del token si lo deseas
      // Por ejemplo, validar que no haya expirado o verificar contra Supabase
      
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

      // Verificar si el usuario ya está en uso
      final usernameExists = await _supabase
          .from('pacientes')
          .select('id_paciente')
          .eq('nombre_usuario_p', username)
          .maybeSingle();

      if (usernameExists != null) {
        print('❌ Nombre de usuario ya está en uso');
        return false;
      }

      // 🔹 Hashear la contraseña antes de guardarla
      String hashedPassword = HashService.hashPassword(password);

      // Guardar usuario y contraseña hasheada
      await _supabase.from('pacientes').update({
        'nombre_usuario_p': username,
        'contrasena_p': hashedPassword,  // Se guarda encriptada
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
    
    // Crear un payload con información básica
    final payload = {
      'user_id': userId,
      'username': username,
      'timestamp': timestamp,
      'random': base64Encode(randomBytes),
    };
    
    // Codificar el payload en base64
    final token = base64Encode(utf8.encode(json.encode(payload)));
    return token;
  }
}