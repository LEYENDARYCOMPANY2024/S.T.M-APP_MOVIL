import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/sesion_service.dart';
import '../models/terapeuta.dart';
import '../models/sesion.dart';

class SesionesViewModel extends ChangeNotifier {
  final SesionService _sesionService = SesionService();
  
  List<Terapeuta> terapeutas = [];
  Map<int, List<Sesion>> sesionesPorTerapeuta = {};
  Map<int, bool> terapeutasExpandidos = {};
  
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = "";
  
  // Cargar todos los terapeutas del paciente
  Future<void> cargarTerapeutas() async {
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

      // Obtener todos los terapeutas (de sesiones y de historial)
      terapeutas = await _sesionService.getTerapeutasPaciente(userId);
      
      // Limpiar datos anteriores
      sesionesPorTerapeuta.clear();
      terapeutasExpandidos.clear();
      
      // Inicializar mapa de terapeutas expandidos
      for (var terapeuta in terapeutas) {
        terapeutasExpandidos[terapeuta.id] = false;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar terapeutas con historial: $e');
      errorMessage = "Ocurrió un error al cargar los datos de terapeutas";
      isLoading = false;
      notifyListeners();
    }
  }
  
  // Cargar las sesiones de un terapeuta específico
  Future<void> cargarSesionesTerapeuta(int terapeutaId) async {
    try {
      if (sesionesPorTerapeuta.containsKey(terapeutaId)) {
        // Ya se cargaron las sesiones para este terapeuta
        return;
      }
      
      // Marcar como loading para este terapeuta específico
      terapeutasExpandidos[terapeutaId] = true;
      notifyListeners();
      
      final userId = await TokenService.getUserId();
      if (userId == null) {
        return;
      }
      
      // Obtener las sesiones del paciente con este terapeuta
      List<Sesion> sesiones = await _sesionService.getSesionesPacienteConTerapeuta(userId, terapeutaId);
      
      // Actualizar el mapa de sesiones por terapeuta
      sesionesPorTerapeuta[terapeutaId] = sesiones;
      
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar sesiones del terapeuta $terapeutaId: $e');
      sesionesPorTerapeuta[terapeutaId] = [];
      notifyListeners();
    }
  }
  
  // Cambiar el estado de expansión de un terapeuta
  void toggleTerapeutaExpansion(int terapeutaId) async {
    if (terapeutasExpandidos[terapeutaId] == true) {
      terapeutasExpandidos[terapeutaId] = false;
      notifyListeners();
    } else {
      terapeutasExpandidos[terapeutaId] = true;
      notifyListeners();
      
      // Cargar las sesiones si es necesario
      if (!sesionesPorTerapeuta.containsKey(terapeutaId)) {
        await cargarSesionesTerapeuta(terapeutaId);
      }
    }
  }
  
  // Buscar terapeuta por nombre
  Future<void> buscarTerapeuta(String query) async {
    try {
      searchQuery = query;
      isLoading = true;
      notifyListeners();
      
      final userId = await TokenService.getUserId();
      
      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        isLoading = false;
        notifyListeners();
        return;
      }
      
      // Buscar terapeutas por nombre
      terapeutas = await _sesionService.buscarTerapeuta(userId, query);
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al buscar terapeuta: $e');
      errorMessage = "Ocurrió un error al buscar terapeutas";
      isLoading = false;
      notifyListeners();
    }
  }
  
  // Recargar todos los datos
  void recargarDatos() {
    sesionesPorTerapeuta.clear();
    terapeutasExpandidos.clear();
    cargarTerapeutas();
  }
}