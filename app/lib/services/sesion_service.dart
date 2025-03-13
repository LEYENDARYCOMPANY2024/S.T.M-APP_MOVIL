import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sesion.dart';
import '../models/terapeuta.dart';

class SesionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todos los terapeutas que han tenido sesiones con un paciente
  Future<List<Terapeuta>> getTerapeutasPaciente(int pacienteId) async {
    try {
      // Consulta para obtener los terapeutas del paciente tanto actuales como pasados
      final response = await _supabase
          .from('terapeuta_paciente')
          .select('id_terapeuta_tp_fk')
          .eq('id_paciente_tp_fk', pacienteId);

      List<int> idsTerapeutas = [];
      for (var item in response) {
        idsTerapeutas.add(item['id_terapeuta_tp_fk']);
      }

      if (idsTerapeutas.isEmpty) {
        return [];
      }

      // También consultar historial_progreso para encontrar terapeutas pasados
      final historicoResponse = await _supabase
          .from('historial_progreso')
          .select('terapeuta_paciente!inner(id_terapeuta_tp_fk, id_paciente_tp_fk)')
          .eq('terapeuta_paciente.id_paciente_tp_fk', pacienteId);

      for (var item in historicoResponse) {
        if (item['terapeuta_paciente'] != null && 
            item['terapeuta_paciente']['id_terapeuta_tp_fk'] != null) {
          int terapeutaId = item['terapeuta_paciente']['id_terapeuta_tp_fk'];
          if (!idsTerapeutas.contains(terapeutaId)) {
            idsTerapeutas.add(terapeutaId);
          }
        }
      }

      // Obtener los datos de cada terapeuta
      List<Terapeuta> terapeutas = [];
      for (int terapeutaId in idsTerapeutas) {
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
      print('❌ Error al obtener terapeutas del paciente: $e');
      return [];
    }
  }

  // Obtener las sesiones de un paciente con un terapeuta específico
  Future<List<Sesion>> getSesionesPacienteConTerapeuta(int pacienteId, int terapeutaId) async {
    try {
      // Obtener el nombre del terapeuta para incluirlo en las sesiones
      final terapeutaData = await _supabase
          .from('terapeutas')
          .select()
          .eq('id_terapeuta', terapeutaId)
          .maybeSingle();

      String nombreTerapeuta = "Terapeuta desconocido";
      if (terapeutaData != null) {
        final terapeuta = Terapeuta.fromMap(terapeutaData);
        nombreTerapeuta = terapeuta.nombreCompleto;
      }

      // Consulta para obtener las sesiones del paciente con ese terapeuta
      final response = await _supabase
          .rpc('obtener_sesiones_paciente_terapeuta', params: {
            'p_id_paciente': pacienteId,
            'p_id_terapeuta': terapeutaId
          });

      List<Sesion> sesiones = [];
      for (var item in response) {
        sesiones.add(Sesion.fromMap(item, nombreTerapeuta));
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
      // Primero obtenemos todos los terapeutas del paciente
      List<Terapeuta> todosTerapeutas = await getTerapeutasPaciente(pacienteId);
      
      // Filtramos los resultados por la búsqueda
      if (query.isEmpty) {
        return todosTerapeutas;
      }
      
      query = query.toLowerCase();
      return todosTerapeutas.where((terapeuta) {
        return terapeuta.nombreCompleto.toLowerCase().contains(query);
      }).toList();
    } catch (e) {
      print('❌ Error al buscar terapeuta: $e');
      return [];
    }
  }
}