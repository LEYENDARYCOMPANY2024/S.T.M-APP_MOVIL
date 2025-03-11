import 'package:flutter/material.dart';
import '../services/paciente_service.dart';
import '../services/token_service.dart';
import '../models/paciente.dart';

class PerfilViewModel extends ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  Paciente? paciente; // Datos del paciente

  bool isLoading = true; // Estado de carga
  String? errorMessage; // Mensaje de error en caso de falla
  String? successMessage; // Mensaje de éxito

  // Cargar los datos del paciente para la pantalla de perfil
  Future<void> cargarDatos() async {
    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();

      // Obtener el ID del usuario actual desde el servicio de tokens
      final userId = await TokenService.getUserId();

      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Obtener los datos del paciente
      paciente = await _pacienteService.getPaciente(userId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar datos del perfil: $e');
      errorMessage = "Ocurrió un error al cargar los datos";
      isLoading = false;
      notifyListeners();
    }
  }

  // Verificar contraseña y actualizar datos del usuario
  Future<bool> actualizarDatos({
    required String contrasenaActual,
    String? nuevoUsuario,
    String? nuevoCorreo,
  }) async {
    try {
      // Resetear mensajes
      errorMessage = null;
      successMessage = null;
      notifyListeners();

      // Verificar si hay algo que actualizar
      if ((nuevoUsuario == null || nuevoUsuario.isEmpty) && 
          (nuevoCorreo == null || nuevoCorreo.isEmpty)) {
        errorMessage = "No se ingresaron datos para actualizar";
        notifyListeners();
        return false;
      }

      // Obtener el ID del usuario actual
      final userId = await TokenService.getUserId();
      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        notifyListeners();
        return false;
      }

      // Verificar la contraseña
      bool contrasenaCorrecta = await _pacienteService.verificarContrasena(
        userId, 
        contrasenaActual
      );

      if (!contrasenaCorrecta) {
        errorMessage = "La contraseña ingresada es incorrecta";
        notifyListeners();
        return false;
      }

      // Actualizar los datos del paciente
      bool actualizado = await _pacienteService.actualizarDatosPaciente(
        userId,
        nuevoUsuario: nuevoUsuario,
        nuevoCorreo: nuevoCorreo,
      );

      if (actualizado) {
        // Actualización exitosa, volver a cargar los datos
        successMessage = "Datos actualizados correctamente";
        await cargarDatos(); // Recargar los datos del paciente
        return true;
      } else {
        errorMessage = "No se pudieron actualizar los datos";
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error al actualizar datos: $e');
      errorMessage = "Ocurrió un error inesperado";
      notifyListeners();
      return false;
    }
  }

  // Limpiar mensajes
  void limpiarMensajes() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}