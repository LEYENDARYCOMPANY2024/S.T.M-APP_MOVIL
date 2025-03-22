import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_services.dart';
import '../models/nivel.dart';
import '../models/ejercicio.dart';

class EjerciciosService {
  final SupabaseClient _supabaseClient;
  final AuthService _authService;

  EjerciciosService(this._supabaseClient, this._authService);

  Future<List<Nivel>> obtenerNivelesConEjercicios() async {
    try {
      // Obtener el id del paciente desde el token
      final idPaciente = await _authService.obtenerIdPacienteDesdeToken();
      if (idPaciente == null) {
        throw Exception('No se pudo obtener el ID del paciente.');
      }
      
      print('🔎 ID del Paciente: $idPaciente');

      // Obtener los niveles ordenados por el campo 'orden'
      final respNiveles = await _supabaseClient
          .from('niveles')
          .select()
          .order('orden', ascending: true);

      List<Nivel> niveles = (respNiveles as List)
          .map((nivel) => Nivel.fromMap(nivel))
          .toList();
      
      print('📋 Niveles recuperados: ${niveles.length}');

      // Obtener TODOS los registros de paciente_nivel para este paciente de una sola vez
      final respPacienteNiveles = await _supabaseClient
          .from('paciente_nivel')
          .select()
          .eq('id_paciente_fk', idPaciente);
          
      print('📋 Registros paciente_nivel: ${respPacienteNiveles?.length ?? 0}');
      
      // Crear un mapa para acceso rápido
      Map<int, dynamic> nivelStatusMap = {};
      if (respPacienteNiveles != null) {
        for (var registro in respPacienteNiveles) {
          nivelStatusMap[registro['id_nivel_fk']] = registro;
        }
      }

      // Procesar cada nivel
      for (int i = 0; i < niveles.length; i++) {
        var nivel = niveles[i];
        
        // Verificar si existe un registro para este nivel
        if (nivelStatusMap.containsKey(nivel.id)) {
          final estadoNivel = nivelStatusMap[nivel.id]['estado'].toString().toLowerCase().trim();
          print('✅ Estado recuperado para Nivel ${nivel.id} (Orden ${nivel.orden}): $estadoNivel');
          nivel = nivel.copyWith(estado: estadoNivel);
        } else {
          print('⚠️ No se encontró registro en paciente_nivel para el Nivel ${nivel.id} (Orden ${nivel.orden})');
          nivel = nivel.copyWith(estado: 'bloqueado');
        }
        
        // Lógica de desbloqueo progresivo modificada
        if (niveles.length > 1 && i > 0) {
          final nivelAnterior = niveles[i - 1];
          print('🔍 Verificando nivel anterior: ${nivelAnterior.nombre} (${nivelAnterior.estado})');
          
          if (nivelAnterior.estado != 'desbloqueado') {
            nivel = nivel.copyWith(estado: 'bloqueado');
            print('🔒 Nivel ${nivel.orden} bloqueado porque el anterior no está desbloqueado.');
          }
        }
        
        // Actualizar el nivel en la lista
        niveles[i] = nivel;

        // Obtener los ejercicios relacionados con el nivel
        final respEjercicios = await _supabaseClient
            .from('niveles_ejercicios')
            .select('ejercicios(*)')
            .eq('id_nivel_fk', nivel.id);

        List<Ejercicio> ejercicios = (respEjercicios as List).map((item) {
          return Ejercicio.fromMap(item['ejercicios']);
        }).toList();

        niveles[i] = niveles[i].copyWith(ejercicios: ejercicios);
      }

      return niveles;
    } catch (e) {
      print('❌ Error al obtener niveles y ejercicios: $e');
      rethrow;
    }
  }
}
