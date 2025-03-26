import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;

  TextEditingController codigoController = TextEditingController();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  RegisterViewModel(this._authService);

  // Método para validar el código
  Future<Map<String, dynamic>> validateCodigo() async {
    String codigo = codigoController.text.trim();
    
    if (codigo.isEmpty) {
      return {'isValid': false, 'message': 'El código no puede estar vacío'};
    }

    try {
      // Validar con el servicio de autenticación
      final validationResult = await _authService.validatePatientCode(codigo);
      
      if (!validationResult['exists']) {
        return {'isValid': false, 'message': 'Código de paciente no existe'};
      }
      
      if (validationResult['hasCredentials']) {
        return {'isValid': false, 'message': 'Código ya registrado'};
      }
      
      return {'isValid': true, 'message': ''};
    } catch (e) {
      return {'isValid': false, 'message': 'Error al validar el código'};
    }
  }

  // Método para verificar si el nombre de usuario ya existe
  Future<Map<String, dynamic>> validateUsername() async {
    String usuario = usuarioController.text.trim();
    
    if (usuario.isEmpty) {
      return {'isValid': false, 'message': 'El nombre de usuario no puede estar vacío'};
    }

    try {
      final bool usernameExists = await _authService.checkUsernameExists(usuario);
      if (usernameExists) {
        return {'isValid': false, 'message': 'Este nombre de usuario ya está en uso'};
      }
      return {'isValid': true, 'message': ''};
    } catch (e) {
      return {'isValid': false, 'message': 'Error al validar el nombre de usuario'};
    }
  }

  // Método para registrar al paciente
  Future<void> register(BuildContext context) async {
    if (isLoading) return;

    String codigo = codigoController.text.trim();
    String usuario = usuarioController.text.trim();
    String password = passwordController.text.trim();

    if (codigo.isEmpty || usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    // Validar el código
    final codigoValidation = await validateCodigo();
    if (!codigoValidation['isValid']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(codigoValidation['message'])),
      );
      return;
    }

    // Validar el nombre de usuario
    final usernameValidation = await validateUsername();
    if (!usernameValidation['isValid']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(usernameValidation['message'])),
      );
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      // Intentar registrar al usuario
      bool success = await _authService.register(codigo, usuario, password);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro exitoso")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al registrar usuario")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error inesperado durante el registro")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
