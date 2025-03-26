import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/paciente_service.dart';
import '../models/sesion.dart';

class DetalleSesionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PacienteService _pacienteService = PacienteService();

  Future<Sesion?> obtenerDetalleSesion(int sesionId) async {
    try {
      // Obtener todas las sesiones del paciente
      final response = await _supabase
          .from('paciente_sesiones_p')
          .select('sesiones(*)')
          .eq('sesiones.id_sesion', sesionId)
          .single();

      if (response == null) return null;

      final sesionData = response['sesiones'];
      // Asumimos que el nombre del terapeuta vendrá de la vista anterior
      return Sesion.fromMap(sesionData, ""); // El nombre del terapeuta ya lo tenemos de la vista anterior
    } catch (e) {
      print('❌ Error al obtener detalle de sesión: $e');
      return null;
    }
  }
}
