import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_ID_KEY = 'user_id';

  // Guardar token y ID de usuario
  static Future<void> saveAuthData(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setInt(USER_ID_KEY, userId);
  }

  // Verificar si existe token
  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TOKEN_KEY);
    return token != null && token.isNotEmpty;
  }

  // Obtener el token guardado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Obtener el ID del usuario
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(USER_ID_KEY);
  }

  // Eliminar token y datos de sesión (logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);
  }
}