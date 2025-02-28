import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;

  TextEditingController codigoController = TextEditingController();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  RegisterViewModel(this._authService);

  // Método para registrar al paciente
  Future<void> register(BuildContext context) async {
    String codigo = codigoController.text.trim();
    String usuario = usuarioController.text.trim();
    String password = passwordController.text.trim();

    if (codigo.isEmpty || usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    // Intentar registrar al usuario
    bool success = await _authService.register(codigo, usuario, password);

    isLoading = false;
    notifyListeners();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro exitoso")),
      );
      Navigator.pop(context); // Redirigir a la pantalla de inicio de sesión
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al registrar usuario")),
      );
    }
  }
}
