import 'package:supabase_flutter/supabase_flutter.dart';
import 'hash_services.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 🔹 LOGIN (Verifica contraseña hasheada)
  Future<bool> login(String username, String password) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('contrasena_p')
          .eq('nombre_usuario_p', username)
          .maybeSingle();

      if (response == null) {
        print('❌ Usuario no encontrado');
        return false;
      }

      String hashedPassword = response['contrasena_p'];

      // Verificar la contraseña ingresada con la hasheada
      if (HashService.verifyPassword(password, hashedPassword)) {
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
}
