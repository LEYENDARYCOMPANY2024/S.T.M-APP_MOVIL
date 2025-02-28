import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Función de login
  Future<bool> login(String username, String password) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('nombre_usuario_p, contrasena_p')
          .eq('nombre_usuario_p', username)
          .eq('contrasena_p', password)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error en login: $e');
      return false;
    }
  }

  // Función de registro
  Future<bool> register(String codigo, String username, String password) async {
    try {
      // 1. Buscar si el código existe y obtener sus datos
      final response = await _supabase
          .from('pacientes')
          .select('id_paciente, nombre_usuario_p, contrasena_p')
          .eq('codigo', codigo)
          .maybeSingle();

      if (response == null) {
        print('❌ Código de paciente no válido');
        return false;
      }

      final int pacienteId = response['id_paciente'];
      final String? existingUsername = response['nombre_usuario_p'];
      final String? existingPassword = response['contrasena_p'];

      // 2. Si el código ya tiene usuario y contraseña, no permitir registro
      if (existingUsername != null && existingPassword != null) {
        print('❌ El código ya ha sido usado y tiene usuario y contraseña registrados.');
        return false;
      }

      // 3. Verificar si el nombre de usuario ya está en uso
      final usernameExistsResponse = await _supabase
          .from('pacientes')
          .select('id_paciente')
          .eq('nombre_usuario_p', username)
          .maybeSingle();

      if (usernameExistsResponse != null) {
        print('❌ El nombre de usuario ya está en uso');
        return false;
      }

      // 4. Registrar el nombre de usuario y la contraseña si el código aún no ha sido usado
      await _supabase.from('pacientes').update({
        'nombre_usuario_p': username,
        'contrasena_p': password,
      }).eq('id_paciente', pacienteId);

      print('✅ Registro exitoso');
      return true;
    } catch (e) {
      print('❌ Error en registro: $e');
      return false;
    }
  }
}
