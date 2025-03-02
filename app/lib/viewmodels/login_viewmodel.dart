import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginViewModel(this._authService);

  Future<bool> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    try {
      bool success = await _authService.login(username, password);

      if (success) {
        print('✅ Login exitoso');
      } else {
        print('❌ Credenciales incorrectas');
      }

      return success;
    } catch (e) {
      print('⚠️ Error en login: $e');
      return false;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
