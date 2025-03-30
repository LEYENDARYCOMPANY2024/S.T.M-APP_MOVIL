import 'package:flutter/material.dart';
import '../services/paciente_service.dart';
import '../services/token_service.dart';
import '../models/terapeuta.dart';
import '../models/paciente.dart'; // Asegúrate de importar el modelo de Paciente
import '../services/sesion_service.dart';

class HomeViewModel extends ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  
  Terapeuta? terapeuta; // Datos del terapeuta
  Paciente? paciente; // Datos del paciente
  Map<String, dynamic>? proximaSesion; // Datos de la próxima sesión
  Map<String, dynamic>? datosProgreso; // Datos del progreso
  
  bool isLoading = true; // Estado de carga
  String? errorMessage; // Mensaje de error en caso de falla

  List<Map<String, dynamic>>? graficasSesiones;

  // Cargar todos los datos necesarios para la pantalla Home
  Future<void> cargarDatos() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      final userId = await TokenService.getUserId();
      
      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        isLoading = false;
        notifyListeners();
        return;
      }
      
      // Obtener los datos del terapeuta asignado
      terapeuta = await _pacienteService.getTerapeutaAsignado(userId);
      
      // Obtener los datos del paciente
      paciente = await _pacienteService.getPaciente(userId);
      
      // Obtener datos de la próxima sesión
      proximaSesion = await _pacienteService.getProximaSesion(userId);
      
      // Obtener datos de progreso del paciente
      datosProgreso = await _pacienteService.getDatosProgreso(userId);
      
      // Cargar datos de gráficas
      final sesionService = SesionService();
      graficasSesiones = await sesionService.obtenerGraficasSesiones(userId);
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar datos de Home: $e');
      errorMessage = "Ocurrió un error al cargar los datos";
      isLoading = false;
      notifyListeners();
    }
  }

  // Recargar datos (modificado para RefreshIndicator)
  Future<void> recargarDatos() async {
    try {
      await cargarDatos();
      return;
    } catch (e) {
      print('❌ Error al recargar datos: $e');
      errorMessage = "Ocurrió un error al recargar los datos";
      isLoading = false;
      notifyListeners();
      throw e; // Importante para que el RefreshIndicator sepa que hubo un error
    }
  }

  // Cargar datos del perfil
  Future<void> cargarPerfil() async {
    try {
      isLoading = true;
      errorMessage = null;
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
      errorMessage = "Ocurrió un error al cargar los datos del perfil";
      isLoading = false;
      notifyListeners();
    }
  }
}
