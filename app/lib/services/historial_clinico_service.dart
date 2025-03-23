import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/historial_clinico.dart';
import 'auth_services.dart';

class HistorialClinicoService {
  final SupabaseClient _supabase;
  final AuthService _authService;

  // Constructor que asigna los parámetros a las variables
  HistorialClinicoService(this._supabase, this._authService);

  // Obtener historial clínico del paciente actual
  Future<HistorialClinico?> getHistorialClinico() async {
    try {
      // Obtener ID del paciente actual desde el token
      final pacienteId = await _authService.obtenerIdPacienteDesdeToken();
      if (pacienteId == null) {
        print('❌ No se pudo obtener el ID del paciente');
        return null;
      }

      return await getHistorialClinicoPorId(pacienteId);
    } catch (e) {
      print('❌ Error al obtener historial clínico: $e');
      return null;
    }
  }

  // Obtener historial clínico por ID de paciente específico
  Future<HistorialClinico?> getHistorialClinicoPorId(int pacienteId) async {
    try {
      final historialData = await _supabase
          .from('historial_clinico')
          .select('*')
          .eq('id_paciente_hc_fk', pacienteId)
          .maybeSingle();

      print('📦 Datos del historial clínico: $historialData');

      if (historialData == null) {
        print('ℹ️ No existe historial clínico para el paciente ID: $pacienteId');
        return null;
      }

      return HistorialClinico.fromMap(historialData);
    } catch (e) {
      print('❌ Error al obtener historial clínico por ID: $e');
      return null;
    }
  }

  // Calcular IMC a partir de peso y estatura (mantener para mostrar el cálculo)
  double calcularIMC(double peso, double estatura) {
    // Estatura en metros para el cálculo (estatura viene en cm)
    double estaturaEnMetros = estatura / 100;
    return peso / (estaturaEnMetros * estaturaEnMetros);
  }

  // Formatear valor de IMC con interpretación (mantener para mostrar la interpretación)
  String formatearIMC(double imc) {
    String interpretacion = '';
    if (imc < 18.5) {
      interpretacion = 'Bajo peso';
    } else if (imc >= 18.5 && imc < 25) {
      interpretacion = 'Peso normal';
    } else if (imc >= 25 && imc < 30) {
      interpretacion = 'Sobrepeso';
    } else {
      interpretacion = 'Obesidad';
    }
    
    return '${imc.toStringAsFixed(2)} - $interpretacion';
  }
}