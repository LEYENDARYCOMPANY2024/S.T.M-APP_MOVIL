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

      // Obtener los terapeutas que han tenido sesiones con el paciente
      final sesionesResponse = await _supabase
          .from('paciente_sesiones_p')
          .select('id_terapeuta_fk')
          .eq('id_paciente_ps_fk', pacienteId);

      List<int> idsSesionesTerapeutas = sesionesResponse
          .map((item) => item['id_terapeuta_fk'] as int)
          .toList();

      // Verificar en historial_progreso si hay más terapeutas
      final historialResponse = await _supabase
          .from('historial_progreso')
          .select('terapeuta_paciente!inner(id_terapeuta_tp_fk)')
          .eq('terapeuta_paciente.id_paciente_tp_fk', pacienteId);

      List<int> idsHistorialTerapeutas = historialResponse
          .where((item) => item['terapeuta_paciente'] != null)
          .map((item) => item['terapeuta_paciente']['id_terapeuta_tp_fk'] as int)
          .toList();

      // Unir todas las listas sin duplicar valores
      Set<int> idsTodosTerapeutas = {
        ...idsTerapeutas,
        ...idsSesionesTerapeutas,
        ...idsHistorialTerapeutas
      };

      if (idsTodosTerapeutas.isEmpty) return [];

      // Convertir a lista y filtrar solo enteros válidos
      final List<int> idsList = idsTodosTerapeutas.whereType<int>().toList();

      // Consultar detalles de los terapeutas en una sola consulta
      final terapeutasResponse = await _supabase
          .from('terapeutas')
          .select()
          .filter('id_terapeuta', 'in', idsList);

      List<Terapeuta> terapeutas = terapeutasResponse
          .map<Terapeuta>((data) => Terapeuta.fromMap(data))
          .toList();

      return terapeutas;
    } catch (e) {
      print('❌ Error al obtener terapeutas con sesiones e historial: $e');
      return [];
    }
  }

  // Obtener las sesiones de un paciente con un terapeuta específico
  Future<List<Sesion>> getSesionesPacienteConTerapeuta(int pacienteId, int terapeutaId) async {
    try {
      // Obtener el nombre del terapeuta
      final terapeutaData = await _supabase
          .from('terapeutas')
          .select()
          .eq('id_terapeuta', terapeutaId)
          .single();

      String nombreTerapeuta = terapeutaData.isNotEmpty
        ? Terapeuta.fromMap(terapeutaData).nombreCompleto
        : "Terapeuta desconocido";


      // Obtener las sesiones directamente de paciente_sesiones_p
      final sesionesResponse = await _supabase
          .from('paciente_sesiones_p')
          .select('id_sesion_ps_fk, sesiones(*)')
          .eq('id_paciente_ps_fk', pacienteId)
          .eq('id_terapeuta_fk', terapeutaId);

      List<Sesion> sesiones = [];
      for (var item in sesionesResponse) {
        if (item['sesiones'] != null) {
          sesiones.add(Sesion.fromMap(item['sesiones'], nombreTerapeuta));
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

  Future<List<Map<String, dynamic>>> obtenerGraficasSesiones(int pacienteId) async {
    try {
      final now = DateTime.now();
      final sesionesResponse = await _supabase
          .from('paciente_sesiones_p')
          .select('''
            sesiones!inner(
              id_sesion,
              fecha_inicio,
              nota_evolutiva,
              graficas_tablas_movil(
                datos_graficas,
                fecha_registro
              )
            )
          ''')
          .eq('id_paciente_ps_fk', pacienteId)
          .order('sesiones(fecha_inicio)', ascending: false);

      if (sesionesResponse.isEmpty) return [];

      List<Map<String, dynamic>> sesiones = [];
      
      for (var sesion in sesionesResponse) {
        if (sesion['sesiones']['graficas_tablas_movil'].isEmpty) continue;
        
        final fechaSesion = DateTime.parse(sesion['sesiones']['fecha_inicio']);
        final graficaData = sesion['sesiones']['graficas_tablas_movil'][0];
        
        sesiones.add({
          'id_sesion': sesion['sesiones']['id_sesion'],
          'fecha': sesion['sesiones']['fecha_inicio'],
          'datos_graficas': graficaData['datos_graficas'],
          'fecha_registro': graficaData['fecha_registro'],
          'es_antigua': fechaSesion.isBefore(now.subtract(Duration(days: 7))),
          'nota_evolutiva': sesion['sesiones']['nota_evolutiva'],
        });
      }

      return sesiones;
    } catch (e) {
      print('❌ Error al obtener gráficas de sesiones: $e');
      return [];
    }
  }
}
