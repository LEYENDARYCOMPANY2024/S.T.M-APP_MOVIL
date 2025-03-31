import 'package:flutter/material.dart';
import '../models/nivel.dart';
import '../services/ejercicios_services.dart';

class EjerciciosViewModel extends ChangeNotifier {
  final EjerciciosService _ejerciciosService;
  List<Nivel> _niveles = [];
  bool _cargando = false;
  String _error = '';
  Map<String, bool> _videosEnCache = {};

  EjerciciosViewModel(this._ejerciciosService);

  // Getters
  List<Nivel> get niveles => _niveles;
  bool get cargando => _cargando;
  String get error => _error;

  // Nuevos métodos para manejo de videos
  bool videoEstaCargado(String ejercicioId) => _videosEnCache[ejercicioId] ?? false;

  void marcarVideoCargado(String ejercicioId, bool cargado) {
    _videosEnCache[ejercicioId] = cargado;
    notifyListeners();
  }

  void limpiarCacheVideos() {
    _videosEnCache.clear();
    notifyListeners();
  }

  // Cargar niveles y ejercicios
  Future<void> cargarNivelesYEjercicios() async {
    try {
      _cargando = true;
      _error = '';
      notifyListeners();

      _niveles = await _ejerciciosService.obtenerNivelesConEjercicios();
      
      // Validar URLs de videos
      for (var nivel in _niveles) {
        for (var ejercicio in nivel.ejercicios) {
          if (ejercicio.videoUrl != null && ejercicio.videoUrl!.isNotEmpty) {
            try {
              final uri = Uri.parse(ejercicio.videoUrl!);
              if (!uri.hasScheme || !uri.hasAuthority) {
                print('⚠️ URL de video inválida para ejercicio ${ejercicio.id}: ${ejercicio.videoUrl}');
              }
            } catch (e) {
              print('❌ Error al validar URL de video: ${ejercicio.videoUrl}');
            }
          }
        }
      }

      print('Niveles cargados: ${_niveles.map((n) => '${n.nombre}: ${n.estado}').toList()}');
      
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar los niveles y ejercicios: $e';
      _cargando = false;
      notifyListeners();
      throw e; // Importante para que el RefreshIndicator sepa que hubo un error
    }
  }

  // Cambiar el estado de expansión de un nivel
  void toggleExpansion(int index) {
    if (index >= 0 && index < _niveles.length) {
      _niveles[index] = _niveles[index].copyWith(
        expandido: !_niveles[index].expandido
      );
      notifyListeners();
    }
  }

  // Verificar si un nivel está desbloqueado
  bool nivelDesbloqueado(int index) {
    if (index >= 0 && index < _niveles.length) {
      String estadoActual = _niveles[index].estado.toString().toLowerCase().trim();
      return estadoActual.contains('desbloqueado');
    }
    return false;
  }

  @override
  void dispose() {
    limpiarCacheVideos();
    super.dispose();
  }
}
