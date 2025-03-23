import 'package:flutter/material.dart';

class HistorialClinicoReadOnlyDesign {
  static Widget buildDatosPaciente(paciente) {
    return Card(
      color: Colors.grey[800],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Datos del Paciente', style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            Text('Nombre: ${paciente.nombre} ${paciente.primerApellido} ${paciente.segundoApellido}'),
            Text('Sexo: ${paciente.genero}'),
            Text('Edad: ${paciente.edad}'),
            Text('Estado Civil: ${paciente.estadoCivil}'),
            Text('Ocupación: ${paciente.ocupacion}'),
            Text('Escolaridad: ${paciente.escolaridad}'),
          ],
        ),
      ),
    );
  }

  static Widget buildExpedienteSection(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expediente', style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            _buildInfoRow('Número de Expediente', datos['expediente']),
            _buildInfoRow('Fecha', datos['fecha']),
          ],
        ),
      ),
    );
  }

  static Widget buildExploracionFisica(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exploración Física', style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoRow('Peso (kg)', datos['peso'])),
                Expanded(child: _buildInfoRow('Estatura (cm)', datos['estatura'])),
              ],
            ),
            _buildInfoRow('IMC', datos['imc']),
            _buildInfoRow('Espasmos o Contractura Muscular', datos['espasmos']),
            if (datos['espasmos'] == 'Sí')
              _buildInfoRow('Sitio/Características', datos['sitioEspasmos']),
          ],
        ),
      ),
    );
  }

  static Widget buildAntecedentesPatologicos(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Antecedentes Patológicos y Heredofamiliares', 
              style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            _buildPatologiaInfo('Diabetes', datos['diabetes'], datos['sitioDiabetes']),
            _buildPatologiaInfo('Alergia', datos['alergia'], datos['sitioAlergia']),
            _buildPatologiaInfo('HTA', datos['hta'], datos['sitioHTA']),
            _buildPatologiaInfo('Cáncer', datos['cancer'], datos['sitioCancer']),
            _buildPatologiaInfo('Transfusiones', datos['transfusiones'], datos['sitioTransfusiones']),
            _buildPatologiaInfo('Enf. Reumáticas', datos['reumaticas'], datos['sitioReutmaticas']),
            _buildInfoRow('Encames', datos['encames']),
            _buildInfoRow('Accidentes', datos['accidentes']),
          ],
        ),
      ),
    );
  }

  static Widget buildHabitosSalud(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hábitos de Salud', style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            _buildHabitoInfo('Alcoholismo', datos['alcoholismo'], datos['sitioAlcoholismo']),
            _buildHabitoInfo('Tabaquismo', datos['tabaquismo'], datos['sitioTabaquismo']),
            _buildHabitoInfo('Actividad Física', datos['actividadFisica'], datos['sitioActividad']),
          ],
        ),
      ),
    );
  }

  static Widget buildDiagnosticoMedico(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Diagnóstico Médico', style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            _buildInfoMultiline('Diagnóstico', datos['valoracionInicial']),
            _buildInfoMultiline('Valoración Final', datos['valoracionFinal']),
          ],
        ),
      ),
    );
  }

  static Widget buildCicatrizQuirurgica(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cicatriz Quirúrgica', style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            _buildInfoRow('Cicatrices', datos['cirugias']),
            if (datos['cirugias'] == 'Sí') ...[
              _buildInfoRow('Tipo de Cicatriz', _getTipoCicatriz(datos)),
              _buildInfoRow('Características', datos['sitioSitio']),
            ],
          ],
        ),
      ),
    );
  }

  static String _getTipoCicatriz(Map<String, dynamic> datos) {
    List<String> tipos = [];
    
    if (datos['queloide'] == 'Sí') tipos.add('Queloide');
    if (datos['retractil'] == 'Sí') tipos.add('Retráctil');
    if (datos['hipertrofica'] == 'Sí') tipos.add('Hipertrófica');
    if (datos['adherencia'] == 'Sí') tipos.add('Adherencia');
    
    return tipos.isEmpty ? 'No especificado' : tipos.join(', ');
  }

  static Widget buildMarchaDeambulacion(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Marcha y Deambulación', style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            _buildInfoRow('Tipo de Marcha', _getTipoMarcha(datos)),
            _buildInfoRow('Características', datos['observacionesMarcha']),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Tipos Específicos:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow('Atáxica', datos['ataxica']),
            _buildInfoRow('Espástica', datos['espasticas']),
            _buildInfoRow('Claudicante', datos['claudicante']),
            _buildInfoRow('Otros', datos['otrosMarcha']),
          ],
        ),
      ),
    );
  }

  static String _getTipoMarcha(Map<String, dynamic> datos) {
    List<String> tipos = [];
    
    if (datos['ataxica'] == 'Sí') tipos.add('Atáxica');
    if (datos['espasticas'] == 'Sí') tipos.add('Espástica');
    if (datos['claudicante'] == 'Sí') tipos.add('Claudicante');
    
    return tipos.isEmpty ? 'Normal' : tipos.join(', ');
  }

  static Widget buildTraslados(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Traslados y Movilidad', style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            _buildInfoRow('Independencia', _getNivelIndependencia(datos)),
            _buildInfoRow('Observaciones', datos['abierta']),
          ],
        ),
      ),
    );
  }

  static String _getNivelIndependencia(Map<String, dynamic> datos) {
    if (datos['conAyuda'] == 'Sí') return 'Con Ayuda';
    if (datos['libre'] == 'Sí') return 'Independiente';
    return 'No especificado';
  }

  static Widget buildInformacionMujeres(Map<String, dynamic> datos) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información Gineco-Obstétrica', 
              style: TextStyle(fontSize: 18, color: Colors.white,)),
            const SizedBox(height: 16),
            _buildInfoRow('Embarazos', datos['embarazo']),
            if (datos['embarazo'] == 'Sí') ...[
              _buildInfoRow('Número de Hijos', datos['hijos']),
              _buildInfoRow('Observaciones', datos['sitioMujeres']),
            ],
          ],
        ),
      ),
    );
  }

  // Widgets de ayuda para mostrar información
  static Widget _buildInfoRow(String label, dynamic value) {
    final String displayValue = (value == null || value.toString().isEmpty) 
      ? 'No especificado' 
      : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(displayValue),
          ),
        ],
      ),
    );
  }


  static Widget _buildInfoMultiline(String label, dynamic value) {
    final String displayValue = (value == null || value.toString().isEmpty) 
      ? 'No especificado' 
      : value.toString();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(displayValue),
          ),
        ],
      ),
    );
  }


  static Widget _buildPatologiaInfo(String titulo, String? valor, String? detalle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(titulo, valor ?? 'No especificado'),
        if (valor == 'Sí')
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
            child: _buildInfoRow('Detalle', detalle ?? 'No especificado'),
          ),
      ],
    );
  }


  static Widget _buildHabitoInfo(String titulo, String? valor, String? detalle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(titulo, valor ?? 'No especificado'),
        if (valor == 'Sí')
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
            child: _buildInfoRow('Detalle', detalle ?? 'No especificado'),
        ),
      ],
    );
  }

  static Widget buildGenerarPdfButton(VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        ),
        child: const Text('Generar PDF',style: TextStyle(color: Colors.white, fontSize: 16),),
      ),
    );
  }


}