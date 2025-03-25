import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;

  TextEditingController codigoController = TextEditingController();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  RegisterViewModel(this._authService);

  // Agregar método para validar el código
  Future<bool> validateCodigo() async {
    String codigo = codigoController.text.trim();
    
    if (codigo.isEmpty) {
      return false;
    }

    // Aquí deberías hacer la validación con tu servicio
    try {
      bool isValid = await _authService.validatePatientCode(codigo);
      return isValid;
    } catch (e) {
      return false;
    }
  }

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

    // Validar el código antes de continuar con el registro
    bool isValidCode = await validateCodigo();
    if (!isValidCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El código de paciente no es válido")),
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
