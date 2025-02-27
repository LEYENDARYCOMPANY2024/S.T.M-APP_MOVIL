import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
      print('Error en login: $e');
      return false;
    }
  }
}
