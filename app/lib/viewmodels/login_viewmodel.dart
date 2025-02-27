import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginViewModel(this._authService);

  Future<void> login() async {
    String username = usernameController.text;
    String password = passwordController.text;
    bool success = await _authService.login(username, password);
    if (success) {
      print('Login exitoso');
    } else {
      print('Credenciales incorrectas');
    }
  }
}
