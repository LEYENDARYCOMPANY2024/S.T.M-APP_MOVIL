import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_ID_KEY = 'user_id';
  static const String APP_INSTALLED_KEY = 'app_installed';
  
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static SharedPreferences? _prefs;

  // Inicializar el servicio
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Verificar si es una nueva instalación
    if (!(_prefs?.getBool(APP_INSTALLED_KEY) ?? false)) {
      await clearAllData();
      await _prefs?.setBool(APP_INSTALLED_KEY, true);
      await _prefs?.commit(); // Forzar la escritura inmediata
    }
  }

  // Guardar token y ID de usuario
  static Future<void> saveAuthData(String token, int userId) async {
    try {
      await _secureStorage.write(key: TOKEN_KEY, value: token);
      await _secureStorage.write(key: USER_ID_KEY, value: userId.toString());
      await _prefs?.setBool(APP_INSTALLED_KEY, true);
      await _prefs?.commit(); // Forzar la escritura inmediata
    } catch (e) {
      print('Error al guardar datos de autenticación: $e');
      rethrow;
    }
  }

  // Verificar si existe token
  static Future<bool> hasToken() async {
    try {
      final token = await _secureStorage.read(key: TOKEN_KEY);
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error al verificar token: $e');
      return false;
    }
  }

  // Obtener el token guardado
  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: TOKEN_KEY);
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  // Obtener el ID del usuario
  static Future<int?> getUserId() async {
    try {
      final userIdStr = await _secureStorage.read(key: USER_ID_KEY);
      return userIdStr != null ? int.tryParse(userIdStr) : null;
    } catch (e) {
      print('Error al obtener ID de usuario: $e');
      return null;
    }
  }

  // Eliminar token y datos de sesión (logout)
  static Future<void> clearAuthData() async {
    try {
      await _secureStorage.delete(key: TOKEN_KEY);
      await _secureStorage.delete(key: USER_ID_KEY);
      await _prefs?.remove(APP_INSTALLED_KEY);
      await _prefs?.commit(); // Forzar la escritura inmediata
    } catch (e) {
      print('Error al limpiar datos de autenticación: $e');
      rethrow;
    }
  }

  // Limpiar todos los datos (incluyendo la marca de instalación)
  static Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
      await _prefs?.clear();
      await _prefs?.commit(); // Forzar la escritura inmediata
    } catch (e) {
      print('Error al limpiar todos los datos: $e');
      rethrow;
    }
  }
}