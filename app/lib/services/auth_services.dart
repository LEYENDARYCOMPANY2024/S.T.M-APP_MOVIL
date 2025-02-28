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
      // 1. Buscar al paciente por el código
      final response = await _supabase
          .from('pacientes')
          .select('id_paciente')
          .eq('codigo', codigo)
          .maybeSingle();

      // Verifica si la respuesta es nula o no contiene 'id_paciente'
      if (response == null) {
        print('❌ Código de paciente no válido');
        return false;
      }

      final int pacienteId = response['id_paciente']; // Usamos 'id_paciente' en lugar de 'id'
      print('✅ ID del paciente encontrado: $pacienteId');

      // 2. Verificar si el nombre de usuario ya está en uso
      final usernameExistsResponse = await _supabase
          .from('pacientes')
          .select('id_paciente')
          .eq('nombre_usuario_p', username)
          .maybeSingle();

      if (usernameExistsResponse != null) {
        print('❌ El nombre de usuario ya está en uso');
        return false; // Si el nombre de usuario ya existe, no se puede registrar
      }

      // 3. Actualizar los datos del paciente
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
