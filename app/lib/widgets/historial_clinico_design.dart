import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistorialClinicoReadOnlyDesign {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // Constantes de diseño para mantener consistencia
  static const Color _primaryColor = Color(0xFF2C3E50);
  static const Color _accentColor = Color(0xFF3498DB);
  static const Color _cardColor = Color(0xFF34495E);
  static const Color _textColor = Colors.white;
  static const Color _subtitleColor = Color(0xFFBDC3C7);
  static const double _borderRadius = 12.0;
  static const double _elevation = 4.0;

  static Widget buildDatosPaciente(paciente) {
    return _buildCard(
      title: 'Datos del Paciente',
      icon: Icons.person,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Nombre completo', '${paciente.nombre} ${paciente.primerApellido} ${paciente.segundoApellido}'),
          _buildInfoDivider(),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: _buildPatientInfoRow('Sexo', '${paciente.genero}'),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: _buildPatientInfoRow('Edad', '${paciente.edad}'),
              ),
            ],
          ),
          _buildInfoDivider(),
          Row(
            children: [
              Expanded(child: _buildPatientInfoRow('Estado Civil', '${paciente.estadoCivil}')),
              Expanded(child: _buildPatientInfoRow('Ocupación', '${paciente.ocupacion}')),
            ],
          ),
          _buildInfoDivider(),
          _buildPatientInfoRow('Escolaridad', '${paciente.escolaridad}'),
        ],
      ),
    );
  }

  static Widget buildExpedienteSection(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Expediente',
      icon: Icons.folder,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildPatientInfoRow('Número de Expediente', datos['expediente'])),
              Expanded(child: _buildPatientInfoRow('Fecha', datos['fecha'])),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildExploracionFisica(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Exploración Física',
      icon: Icons.accessibility_new,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildPatientInfoRow('Peso (kg)', datos['peso'])),
              Expanded(child: _buildPatientInfoRow('Estatura (cm)', datos['estatura'])),
            ],
          ),
          _buildInfoDivider(),
          _buildPatientInfoRow('IMC', datos['imc'], showCalculation: true),
          _buildInfoDivider(),
          _buildPatientInfoRow('Espasmos o Contractura Muscular', datos['espasmos']),
          if (datos['espasmos'] == 'Sí')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: _buildPatientInfoRow('Sitio/Características', datos['sitioEspasmos']),
            ),
        ],
      ),
    );
  }

  static Widget buildAntecedentesPatologicos(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Antecedentes Patológicos y Heredofamiliares',
      icon: Icons.medical_services,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpandablePatologiaInfo('Diabetes', datos['diabetes'], datos['sitioDiabetes']),
          _buildExpandablePatologiaInfo('Alergia', datos['alergia'], datos['sitioAlergia']),
          _buildExpandablePatologiaInfo('HTA', datos['hta'], datos['sitioHTA']),
          _buildExpandablePatologiaInfo('Cáncer', datos['cancer'], datos['sitioCancer']),
          _buildExpandablePatologiaInfo('Transfusiones', datos['transfusiones'], datos['sitioTransfusiones']),
          _buildExpandablePatologiaInfo('Enf. Reumáticas', datos['reumaticas'], datos['sitioReutmaticas']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Encames', datos['encames']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Accidentes', datos['accidentes']),
        ],
      ),
    );
  }

  static Widget buildHabitosSalud(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Hábitos de Salud',
      icon: Icons.local_hospital,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpandablePatologiaInfo('Alcoholismo', datos['alcoholismo'], datos['sitioAlcoholismo']),
          _buildExpandablePatologiaInfo('Tabaquismo', datos['tabaquismo'], datos['sitioTabaquismo']),
          _buildExpandablePatologiaInfo('Actividad Física', datos['actividadFisica'], datos['sitioActividad']),
        ],
      ),
    );
  }

  static Widget buildDiagnosticoMedico(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Diagnóstico Médico',
      icon: Icons.description,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoMultiline('Diagnóstico Inicial', datos['valoracionInicial']),
          const SizedBox(height: 16),
          _buildInfoMultiline('Valoración Final', datos['valoracionFinal']),
        ],
      ),
    );
  }

  static Widget buildCicatrizQuirurgica(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Cicatriz Quirúrgica',
      icon: Icons.healing,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Cicatrices', datos['cirugias']),
          if (datos['cirugias'] == 'Sí') ...[
            _buildInfoDivider(),
            _buildPatientInfoRow('Tipo de Cicatriz', _getTipoCicatriz(datos)),
            _buildInfoDivider(),
            _buildPatientInfoRow('Características', datos['sitioSitio']),
          ],
        ],
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
    return _buildCard(
      title: 'Marcha y Deambulación',
      icon: Icons.directions_walk,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Tipo de Marcha', _getTipoMarcha(datos)),
          _buildInfoDivider(),
          _buildPatientInfoRow('Características', datos['observacionesMarcha']),
          _buildInfoDivider(),
          
          // Sección de tipos específicos con un contenedor especial
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipos Específicos:', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: _subtitleColor,
                    fontSize: 14,
                  )
                ),
                const SizedBox(height: 8),
                _buildTipoMarchaRow('Atáxica', datos['ataxica']),
                _buildTipoMarchaRow('Espástica', datos['espasticas']),
                _buildTipoMarchaRow('Claudicante', datos['claudicante']),
                _buildTipoMarchaRow('Otros', datos['otrosMarcha']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTipoMarchaRow(String tipo, String? valor) {
    final bool isPresent = valor == 'Sí';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isPresent ? Icons.check_circle : Icons.remove_circle_outline,
            color: isPresent ? Colors.green : Colors.red.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            tipo,
            style: TextStyle(
              color: _textColor,
              fontWeight: isPresent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
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
    return _buildCard(
      title: 'Traslados y Movilidad',
      icon: Icons.transfer_within_a_station,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Independencia', _getNivelIndependencia(datos)),
          _buildInfoDivider(),
          _buildPatientInfoRow('Observaciones', datos['abierta']),
        ],
      ),
    );
  }

  static String _getNivelIndependencia(Map<String, dynamic> datos) {
    if (datos['conAyuda'] == 'Sí') return 'Con Ayuda';
    if (datos['libre'] == 'Sí') return 'Independiente';
    return 'No especificado';
  }

  static Widget buildInformacionMujeres(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Información Gineco-Obstétrica',
      icon: Icons.pregnant_woman,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Embarazos', datos['embarazo']),
          if (datos['embarazo'] == 'Sí') ...[
            _buildInfoDivider(),
            _buildPatientInfoRow('Número de Hijos', datos['hijos']),
            _buildInfoDivider(),
            _buildPatientInfoRow('Observaciones', datos['sitioMujeres']),
          ],
        ],
      ),
    );
  }

  // Widget para construir tarjetas con formato consistente
  static Widget _buildCard({
    required String title, 
    required Widget content, 
    required IconData icon,
  }) {
    return Card(
      color: _cardColor,
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la tarjeta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_borderRadius),
                topRight: Radius.circular(_borderRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: _accentColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title, 
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          ),
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
        ],
      ),
    );
  }

  // Widget para mostrar información del paciente
  static Widget _buildPatientInfoRow(String label, dynamic value, {bool showCalculation = false}) {
    final String displayValue = (value == null || value.toString().isEmpty) 
      ? 'No especificado' 
      : value.toString();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: _subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              displayValue,
              style: TextStyle(
                color: _textColor,
                fontWeight: showCalculation ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para crear una línea divisoria
  static Widget _buildInfoDivider() {
    return const Divider(
      color: Colors.white24,
      height: 20,
      thickness: 0.5,
    );
  }

  // Widget para mostrar información multilínea
  static Widget _buildInfoMultiline(String label, dynamic value) {
    final String displayValue = (value == null || value.toString().isEmpty) 
      ? 'No especificado' 
      : value.toString();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: _subtitleColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            displayValue,
            style: const TextStyle(color: _textColor),
          ),
        ),
      ],
    );
  }

  // Widget para mostrar información de patologías
  static Widget _buildExpandablePatologiaInfo(String titulo, String? valor, String? detalle) {
    final bool hasCondition = valor == 'Sí';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              hasCondition ? Icons.check_circle : Icons.cancel,
              color: hasCondition ? Colors.red : Colors.green.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(
                color: _subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: hasCondition ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasCondition ? 'Sí' : 'No',
                style: TextStyle(
                  color: hasCondition ? Colors.red[300] : Colors.green[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (hasCondition && detalle != null && detalle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 28.0, top: 4.0, bottom: 8.0),
            child: Text(
              detalle,
              style: const TextStyle(
                color: _textColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        _buildInfoDivider(),
      ],
    );
  }

  static Widget buildHabitosMedicacion(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Medicación y Sustancias',
      icon: Icons.medication,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpandablePatologiaInfo('Drogas', datos['drogas'], datos['sitioDrogas']),
          _buildExpandablePatologiaInfo('Automedicación', datos['automedica'], datos['sitioAutomedica']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Observaciones adicionales', datos['sitioHabitos']),
        ],
      ),
    );
  }

  static Widget buildCondicionesFisicas(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Fracturas y Condiciones Físicas',
      icon: Icons.fitness_center,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpandablePatologiaInfo('Fracturas', datos['fracturas'], datos['sitioFracturas']),
          _buildExpandablePatologiaInfo('Cardiopatías', datos['cardiopatias'], null),
          _buildInfoDivider(),
          _buildPatientInfoRow('Otras condiciones', datos['sitioOtros']),
        ],
      ),
    );
  }

  static Widget buildRespuestasSensoriales(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Respuestas Sensoriales y Reflejos',
      icon: Icons.touch_app,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Sensibilidad', datos['sitioSensibilidad']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Reflejos', datos['sitioreflejos']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Lenguaje', datos['sitioLenguaje']),
        ],
      ),
    );
  }

  static Widget buildObservacionesFinales(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Observaciones Finales',
      icon: Icons.note_add,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoMultiline('Observaciones', datos['Observacionesfinales']),
        ],
      ),
    );
  }

  static Future<void> generarPDF(Map<String, dynamic> datos, dynamic paciente) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Historial Clínico', 
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold
                )
              ),
            ),
            
            // Datos del Paciente
            _buildPDFSection('Datos del Paciente', [
              'Nombre: ${paciente.nombre} ${paciente.primerApellido} ${paciente.segundoApellido}',
              'Edad: ${paciente.edad}',
              'Género: ${paciente.genero}',
              'Estado Civil: ${paciente.estadoCivil}',
              'Ocupación: ${paciente.ocupacion}',
              'Escolaridad: ${paciente.escolaridad}',
            ]),

            // Expediente
            _buildPDFSection('Expediente', [
              'Número: ${datos['expediente']}',
              'Fecha: ${datos['fecha']}',
            ]),

            // Exploración Física
            _buildPDFSection('Exploración Física', [
              'Peso: ${datos['peso']} kg',
              'Estatura: ${datos['estatura']} cm',
              'IMC: ${datos['imc']}',
              'Espasmos o Contractura Muscular: ${datos['espasmos']}',
              if (datos['espasmos'] == 'Sí') 'Sitio/Características: ${datos['sitioEspasmos']}',
            ]),

            // Antecedentes Patológicos
            _buildPDFSection('Antecedentes Patológicos y Heredofamiliares', [
              'Diabetes: ${datos['diabetes']}',
              if(datos['diabetes'] == 'Sí') 'Detalles: ${datos['sitioDiabetes']}',
              'Alergia: ${datos['alergia']}',
              if(datos['alergia'] == 'Sí') 'Detalles: ${datos['sitioAlergia']}',
              'HTA: ${datos['hta']}',
              if(datos['hta'] == 'Sí') 'Detalles: ${datos['sitioHTA']}',
              'Cáncer: ${datos['cancer']}',
              if(datos['cancer'] == 'Sí') 'Detalles: ${datos['sitioCancer']}',
              'Transfusiones: ${datos['transfusiones']}',
              if(datos['transfusiones'] == 'Sí') 'Detalles: ${datos['sitioTransfusiones']}',
              'Enf. Reumáticas: ${datos['reumaticas']}',
              if(datos['reumaticas'] == 'Sí') 'Detalles: ${datos['sitioReutmaticas']}',
              'Encames: ${datos['encames']}',
              'Accidentes: ${datos['accidentes']}',
            ]),

            // Hábitos de Salud
            _buildPDFSection('Hábitos de Salud', [
              'Alcoholismo: ${datos['alcoholismo']}',
              if(datos['alcoholismo'] == 'Sí') 'Detalles: ${datos['sitioAlcoholismo']}',
              'Tabaquismo: ${datos['tabaquismo']}',
              if(datos['tabaquismo'] == 'Sí') 'Detalles: ${datos['sitioTabaquismo']}',
              'Actividad Física: ${datos['actividadFisica']}',
              if(datos['actividadFisica'] == 'Sí') 'Detalles: ${datos['sitioActividad']}',
            ]),

            // Diagnóstico Médico
            _buildPDFSection('Diagnóstico Médico', [
              'Diagnóstico Inicial: ${datos['valoracionInicial']}',
              'Valoración Final: ${datos['valoracionFinal']}',
            ]),

            // Cicatriz Quirúrgica
            _buildPDFSection('Cicatriz Quirúrgica', [
              'Cicatrices: ${datos['cirugias']}',
              if (datos['cirugias'] == 'Sí') ...[
                'Tipo de Cicatriz: ${_getTipoCicatriz(datos)}',
                'Características: ${datos['sitioSitio']}',
              ],
            ]),

            // Marcha y Deambulación
            _buildPDFSection('Marcha y Deambulación', [
              'Tipo de Marcha: ${_getTipoMarcha(datos)}',
              'Características: ${datos['observacionesMarcha']}',
              'Atáxica: ${datos['ataxica']}',
              'Espástica: ${datos['espasticas']}',
              'Claudicante: ${datos['claudicante']}',
              'Otros: ${datos['otrosMarcha']}',
            ]),

            // Traslados
            _buildPDFSection('Traslados y Movilidad', [
              'Independencia: ${_getNivelIndependencia(datos)}',
              'Observaciones: ${datos['abierta']}',
            ]),

            // Medicación y Sustancias
            _buildPDFSection('Medicación y Sustancias', [
              'Drogas: ${datos['drogas']}',
              if(datos['drogas'] == 'Sí') 'Detalles: ${datos['sitioDrogas']}',
              'Automedicación: ${datos['automedica']}',
              if(datos['automedica'] == 'Sí') 'Detalles: ${datos['sitioAutomedica']}',
              'Observaciones adicionales: ${datos['sitioHabitos']}',
            ]),

            // Respuestas Sensoriales
            _buildPDFSection('Respuestas Sensoriales y Reflejos', [
              'Sensibilidad: ${datos['sitioSensibilidad']}',
              'Reflejos: ${datos['sitioreflejos']}',
              'Lenguaje: ${datos['sitioLenguaje']}',
            ]),

            // Observaciones Finales
            _buildPDFSection('Observaciones Finales', [
              '${datos['Observacionesfinales']}',
            ]),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Historial_Clinico_${paciente.nombre}',
      format: PdfPageFormat.a4.copyWith(
        marginLeft: 32,
        marginTop: 32,
        marginRight: 32,
        marginBottom: 32,
      ),
    );
  }

  static pw.Widget _buildPDFSection(String title, List<String> items) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold
            ),
          ),
          pw.SizedBox(height: 5),
          ...items.map((item) => pw.Text(item)),
        ],
      ),
    );
  }

  static Widget buildGenerarPdfButton(VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      width: 220,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.picture_as_pdf, 
          color: Colors.white,
          size: 22,
        ),
        label: const Text(
          'Generar PDF', 
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          elevation: 3,
          shadowColor: _accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}