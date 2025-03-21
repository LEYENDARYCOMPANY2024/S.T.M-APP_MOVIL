// services/ejercicios_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ejercicio.dart';
import '../models/nivel.dart';

class EjerciciosService {
  final SupabaseClient _supabaseClient;

  EjerciciosService(this._supabaseClient);

  // Obtener todos los niveles con sus ejercicios relacionados
  Future<List<Nivel>> obtenerNivelesConEjercicios(int idPaciente) async {
    try {
      // 1. Obtener todos los niveles en orden
      final respNiveles = await _supabaseClient
          .from('niveles')
          .select()
          .order('orden', ascending: true);

      List<Nivel> niveles = (respNiveles as List)
          .map((nivel) => Nivel.fromMap(nivel))
          .toList();

      // 2. Para cada nivel, verificar si está desbloqueado para el paciente
      for (var i = 0; i < niveles.length; i++) {
        final nivelId = niveles[i].id;
        
        // Buscar la relación paciente-nivel
        final respPacienteNivel = await _supabaseClient
            .from('paciente_nivel')
            .select()
            .eq('id_paciente_fk', idPaciente)
            .eq('id_nivel_fk', nivelId)
            .maybeSingle();

        // Actualizar el estado (bloqueado/desbloqueado)
        String estado = 'bloqueado';
        if (respPacienteNivel != null) {
          estado = respPacienteNivel['estado'] ?? 'bloqueado';
        }

        // 3. Obtener los ejercicios relacionados con el nivel
        final respEjercicios = await _supabaseClient
            .from('niveles_ejercicios')
            .select('ejercicios(*)')
            .eq('id_nivel_fk', nivelId);

        List<Ejercicio> ejercicios = [];
        
        if (respEjercicios != null && respEjercicios.isNotEmpty) {
          ejercicios = (respEjercicios as List).map((item) {
            Map<String, dynamic> ejercicioData = item['ejercicios'];
            return Ejercicio.fromMap(ejercicioData);
          }).toList();
        }

        // Actualizar el nivel con su estado y ejercicios
        niveles[i] = niveles[i].copyWith(
          estado: estado,
          ejercicios: ejercicios,
        );
      }

      return niveles;
    } catch (e) {
      debugPrint('Error al obtener niveles y ejercicios: $e');
      rethrow;
    }
  }

  // Verificar si un nivel está desbloqueado
  Future<bool> nivelDesbloqueado(int idPaciente, int idNivel) async {
    try {
      final response = await _supabaseClient
          .from('paciente_nivel')
          .select()
          .eq('id_paciente_fk', idPaciente)
          .eq('id_nivel_fk', idNivel)
          .eq('estado', 'desbloqueado')
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      debugPrint('Error al verificar estado del nivel: $e');
      return false;
    }
  }
}
