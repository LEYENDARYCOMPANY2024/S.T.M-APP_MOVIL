import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../services/token_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  LoginViewModel(this._authService);

  Future<bool> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    
    isLoading = true;
    notifyListeners();

    try {
      bool success = await _authService.login(username, password);
      
      isLoading = false;
      notifyListeners();

      return success;
    } catch (e) {
      print('⚠️ Error en login: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print('⚠️ Error en logout: $e');
    }
  }

  // Obtener el ID del usuario actual
  Future<int?> getCurrentUserId() async {
    return await TokenService.getUserId();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}