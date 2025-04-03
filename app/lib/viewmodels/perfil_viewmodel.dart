import 'package:flutter/material.dart';
import '../services/paciente_service.dart';
import '../services/token_service.dart';
import '../models/paciente.dart';

enum PerfilErrorType {
  none,
  connection,    // Error de conexión que muestra la pantalla completa
  password,     // Error de contraseña que solo muestra SnackBar
  unknown       // Error desconocido que muestra la pantalla completa
}

class PerfilViewModel extends ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  Paciente? paciente;

  bool isLoading = true;
  String? errorMessage;
  String? successMessage;
  PerfilErrorType errorType = PerfilErrorType.none;

  // 🔹 Cargar datos del paciente
  Future<void> cargarDatos() async {
    try {
      print("🔄 Cargando datos del perfil...");
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      errorType = PerfilErrorType.none;
      notifyListeners();

      final userId = await TokenService.getUserId();
      print("📢 ID del usuario obtenido: $userId");

      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        errorType = PerfilErrorType.unknown;
        isLoading = false;
        notifyListeners();
        return;
      }

      final nuevoPaciente = await _pacienteService.getPaciente(userId);
      print("📢 Datos del paciente recibidos: ${nuevoPaciente?.toMap()}");

      if (nuevoPaciente == null) {
        errorMessage = "No se encontraron datos del paciente";
        errorType = PerfilErrorType.unknown;
      }

      paciente = nuevoPaciente;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar datos del perfil: $e');
      errorMessage = "Ocurrió un error al cargar los datos";
      errorType = PerfilErrorType.connection;
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Actualizar datos del paciente
  Future<bool> actualizarDatos({
    required String contrasenaActual,
    String? nuevoUsuario,
    String? nuevoCorreo,
  }) async {
    try {
      errorMessage = null;
      successMessage = null;
      errorType = PerfilErrorType.none;
      notifyListeners();

      if ((nuevoUsuario == null || nuevoUsuario.isEmpty) &&
          (nuevoCorreo == null || nuevoCorreo.isEmpty)) {
        errorMessage = "No se ingresaron datos para actualizar";
        errorType = PerfilErrorType.unknown;
        notifyListeners();
        return false;
      }

      final userId = await TokenService.getUserId();
      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        errorType = PerfilErrorType.unknown;
        notifyListeners();
        return false;
      }

      bool contrasenaCorrecta = await _pacienteService.verificarContrasena(
        userId,
        contrasenaActual,
      );

      if (!contrasenaCorrecta) {
        errorMessage = "La contraseña ingresada es incorrecta";
        errorType = PerfilErrorType.password;
        notifyListeners();
        return false;
      }

      bool actualizado = await _pacienteService.actualizarDatosPaciente(
        userId,
        nuevoUsuario: nuevoUsuario,
        nuevoCorreo: nuevoCorreo,
      );

      if (actualizado) {
        successMessage = "Datos actualizados correctamente";

        // 🔹 Optimización: Solo actualiza los datos en memoria sin recargar toda la vista
        if (paciente != null) {
          paciente = paciente!.copyWith(
            nombreUsuario: nuevoUsuario ?? paciente!.nombreUsuario,
            correoElectronico: nuevoCorreo ?? paciente!.correoElectronico,
          );
        } else {
          // Si `paciente` es nulo, recargamos los datos completos
          await cargarDatos();
        }

        notifyListeners();
        return true;
      } else {
        errorMessage = "No se pudieron actualizar los datos";
        errorType = PerfilErrorType.unknown;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("❌ Error al actualizar datos: $e");
      errorMessage = "Ocurrió un error inesperado";
      errorType = PerfilErrorType.connection;
      notifyListeners();
      return false;
    }
  }

  // 🔹 Actualizar información personal del paciente
  Future<bool> actualizarInformacionPersonal({
    required String nombre,
    required String primerApellido,
    required String segundoApellido,
    required int edad,
    required String genero,
    String? estadoCivil,
    String? escolaridad,
    required String ocupacion,
    required String contrasenaActual,
  }) async {
    try {
      errorMessage = null;
      errorType = PerfilErrorType.none;
      notifyListeners();

      // Verificar contraseña
      bool contrasenaValida = await _pacienteService.verificarContrasena(
        paciente!.id,
        contrasenaActual,
      );

      if (!contrasenaValida) {
        errorMessage = "Contraseña incorrecta";
        errorType = PerfilErrorType.password;
        notifyListeners();
        return false;
      }

      // Actualizar información
      bool actualizado = await _pacienteService.actualizarInformacionPersonal(
        paciente!.id,
        nombre: nombre,
        primerApellido: primerApellido,
        segundoApellido: segundoApellido,
        edad: edad,
        genero: genero,
        estadoCivil: estadoCivil,
        escolaridad: escolaridad,
        ocupacion: ocupacion,
      );

      if (actualizado) {
        // Actualizar el modelo local
        paciente = paciente!.copyWith(
          nombre: nombre,
          primerApellido: primerApellido,
          segundoApellido: segundoApellido,
          edad: edad,
          genero: genero,
          estadoCivil: estadoCivil,
          escolaridad: escolaridad,
          ocupacion: ocupacion,
        );
        notifyListeners();
      }

      return actualizado;
    } catch (e) {
      errorMessage = "Error al actualizar la información personal";
      errorType = PerfilErrorType.connection;
      notifyListeners();
      return false;
    }
  }

  // 🔹 Limpiar mensajes después de mostrarlos
  void limpiarMensajes() {
    errorMessage = null;
    successMessage = null;
    errorType = PerfilErrorType.none;
    notifyListeners();
  }
}
