import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sesion.dart';
import '../models/terapeuta.dart';

class SesionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todos los terapeutas que han tenido sesiones con un paciente
  Future<List<Terapeuta>> getTerapeutasPaciente(int pacienteId) async {
  try {
    // Obtener terapeutas actuales del paciente desde terapeuta_paciente
    final response = await _supabase
        .from('terapeuta_paciente')
        .select('id_terapeuta_tp_fk')
        .eq('id_paciente_tp_fk', pacienteId);

    List<int> idsTerapeutas = response.map((item) => item['id_terapeuta_tp_fk'] as int).toList();

    // Verificar en historial_progreso si hay más terapeutas
    final historialResponse = await _supabase
        .from('historial_progreso')
        .select('terapeuta_paciente!inner(id_terapeuta_tp_fk)')
        .filter('terapeuta_paciente.id_paciente_tp_fk', 'eq', pacienteId);

    List<int> idsHistorialTerapeutas = historialResponse
        .where((item) => item['terapeuta_paciente'] != null) // Evitar nulls
        .map((item) => item['terapeuta_paciente']['id_terapeuta_tp_fk'] as int)
        .toList();

    // Unir listas sin duplicar valores
    Set<int> idsTodosTerapeutas = {...idsTerapeutas, ...idsHistorialTerapeutas};

    if (idsTodosTerapeutas.isEmpty) return [];

    // Consultar detalles de los terapeutas
    List<Terapeuta> terapeutas = [];
    for (int terapeutaId in idsTodosTerapeutas) {
      final terapeutaData = await _supabase
          .from('terapeutas')
          .select()
          .eq('id_terapeuta', terapeutaId)
          .maybeSingle();

      if (terapeutaData != null) {
        terapeutas.add(Terapeuta.fromMap(terapeutaData));
      }
    }

    return terapeutas;
  } catch (e) {
    print('❌ Error al obtener terapeutas con sesiones e historial: $e');
    return [];
  }
}



  // Obtener las sesiones de un paciente con un terapeuta específico
  Future<List<Sesion>> getSesionesPacienteConTerapeuta(int pacienteId, int terapeutaId) async {
  try {
    final terapeutaData = await _supabase
        .from('terapeutas')
        .select()
        .eq('id_terapeuta', terapeutaId)
        .maybeSingle();

    String nombreTerapeuta = terapeutaData != null
        ? Terapeuta.fromMap(terapeutaData).nombreCompleto
        : "Terapeuta desconocido";

    final response = await _supabase
        .from('paciente_sesiones_p')
        .select('sesiones(*)')
        .eq('id_paciente_ps_fk', pacienteId);

    List<Sesion> sesiones = [];
    for (var item in response) {
      final sesionData = item['sesiones'];

      // Verificar si el terapeuta tuvo relación con el paciente en terapeuta_paciente
      final relacionTerapeuta = await _supabase
          .from('terapeuta_paciente')
          .select()
          .eq('id_paciente_tp_fk', pacienteId)
          .eq('id_terapeuta_tp_fk', terapeutaId)
          .maybeSingle();

      if (relacionTerapeuta != null) {
        sesiones.add(Sesion.fromMap(sesionData, nombreTerapeuta));
      }
    }

    return sesiones;
  } catch (e) {
    print('❌ Error al obtener sesiones: $e');
    return [];
  }
}



  // Función para buscar un terapeuta por nombre
  Future<List<Terapeuta>> buscarTerapeuta(int pacienteId, String query) async {
    try {
      List<Terapeuta> todosTerapeutas = await getTerapeutasPaciente(pacienteId);
      if (query.isEmpty) return todosTerapeutas;

      query = query.toLowerCase();
      return todosTerapeutas
          .where((terapeuta) => terapeuta.nombreCompleto.toLowerCase().contains(query))
          .toList();
    } catch (e) {
      print('❌ Error al buscar terapeuta: $e');
      return [];
    }
  }
}
