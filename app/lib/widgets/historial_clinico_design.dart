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

  static String _formatearSiNo(String? valor) {
    if (valor == null || valor.isEmpty) return 'No';
    if (valor.toLowerCase().contains('si')) return 'Sí';
    if (valor.toLowerCase().contains('no')) return 'No';
    return valor;
  }

  static bool _esSi(String? valor) {
    if (valor == null || valor.isEmpty) return false;
    return valor.toLowerCase().contains('si');
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
              Expanded(child: _buildPatientInfoRow('Peso (kg)', datos['peso'] ?? 'No especificado')),
              Expanded(child: _buildPatientInfoRow('Estatura (cm)', datos['estatura'] ?? 'No especificado')),
            ],
          ),
          _buildInfoDivider(),
          _buildPatientInfoRow('IMC', datos['imc'] ?? 'No especificado', showCalculation: true),
          _buildInfoDivider(),
          _buildPatientInfoRow('Espasmos o Contractura Muscular', 
            _formatearSiNo(datos['espasmos'] ?? 'No')),
          if (_esSi(datos['espasmos'] ?? 'No'))
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: _buildPatientInfoRow('Sitio/Características', datos['sitioEspasmos'] ?? 'No especificado'),
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
          _buildPatientInfoRow('Encames', datos['encames']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Accidentes', datos['accidentes']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Cardiopatías', datos['cardiopatias']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Cirugías', datos['cirugias']),
          _buildInfoDivider(),
          _buildExpandablePatologiaInfo('Fracturas', datos['fracturas'], datos['sitioFracturas']),
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
          // Tabaquismo
          _buildExpandablePatologiaInfo('Tabaquismo', datos['tabaquismo'], datos['sitioHabitos']),
          
          // Alcoholismo
          _buildExpandablePatologiaInfo('Alcoholismo', datos['alcoholismo'], datos['sitioAlcoholismo']),
          
          // Drogas
          _buildExpandablePatologiaInfo('Drogas', datos['drogas'], datos['sitioDrogas']),
          
          // Actividad Física
          _buildExpandablePatologiaInfo('Actividad Física', datos['actividadFisica'], datos['sitioActividad']),
          
          // Automedicación
          _buildExpandablePatologiaInfo('Se Automedica', datos['automedica'], datos['sitioAutomedica']),
          
          // Pasatiempo (input de texto)
          _buildInfoDivider(),
          _buildPatientInfoRow('Pasatiempo', datos['sitioHabitos'] ?? 'No especificado'),
        ],
      ),
    );
  }

  static Widget buildDiagnosticoMedico(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Diagnóstico Médico en Rehabilitación',
      icon: Icons.medical_services,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Reflejos', datos['sitioreflejos']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Sensibilidad', datos['sitioSensibilidad']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Lenguaje/Orientación', datos['sitioLenguaje']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Otros', datos['sitioOtros']),
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
          _buildPatientInfoRow('Sitio', datos['sitioSitio']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Queloide', _formatearSiNo(datos['queloide'])),
          _buildPatientInfoRow('Abierta', _formatearSiNo(datos['abierta'])),
          _buildPatientInfoRow('Retráctil', _formatearSiNo(datos['retractil'])),
          _buildPatientInfoRow('Con Adherencia', _formatearSiNo(datos['adherencia'])),
          _buildPatientInfoRow('Hipertrófica', _formatearSiNo(datos['hipertrofica'])),
        ],
      ),
    );
  }

  static Widget buildMarchaDeambulacion(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Marcha y Deambulación',
      icon: Icons.directions_walk,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Libre', _formatearSiNo(datos['libre'])),
          _buildPatientInfoRow('Espásticas', _formatearSiNo(datos['espasticas'])),
          _buildPatientInfoRow('Claudicante', _formatearSiNo(datos['claudicante'])),
          _buildPatientInfoRow('Atáxica', _formatearSiNo(datos['ataxica'])),
          _buildPatientInfoRow('Con Ayuda', _formatearSiNo(datos['conAyuda'])),
          _buildInfoDivider(),
          _buildPatientInfoRow('Otros', datos['otrosMarcha']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Observaciones', datos['observacionesMarcha']),
        ],
      ),
    );
  }

  static Widget buildTraslados(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Traslados',
      icon: Icons.transfer_within_a_station,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Valoración Inicial', datos['valoracionInicial']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Valoración Final', datos['valoracionFinal']),
          _buildInfoDivider(),
          _buildPatientInfoRow('Observaciones', datos['Observacionesfinales']),
        ],
      ),
    );
  }

  static Widget buildInformacionMujeres(Map<String, dynamic> datos) {
    return _buildCard(
      title: 'Información Específica para Mujeres',
      icon: Icons.pregnant_woman,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoRow('Está embarazada', _formatearSiNo(datos['embarazo'])),
          _buildInfoDivider(),
          _buildPatientInfoRow('Número de hijos', datos['hijos']),
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
    final bool hasCondition = _esSi(valor ?? '');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasCondition ? Icons.check_circle : Icons.cancel,
              color: hasCondition ? Colors.green.withOpacity(0.7) : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: _subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: hasCondition ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasCondition ? 'Sí' : 'No',
                style: TextStyle(
                  color: hasCondition ? Colors.green[300] : Colors.red[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Solo mostrar el detalle si la condición es Sí y hay información
        if (hasCondition && detalle != null && detalle.isNotEmpty && detalle != "No aplica")
          Padding(
            padding: const EdgeInsets.only(left: 28.0, top: 4.0, bottom: 8.0),
            child: Text(
              detalle,
              style: const TextStyle(
                color: _textColor,
                fontStyle: FontStyle.italic,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
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

    // Definir estilos consistentes
    final titleStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue900
    );
    
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue800
    );
    
    final labelStyle = pw.TextStyle(
      fontSize: 12,
      color: PdfColors.grey800,
      fontWeight: pw.FontWeight.bold
    );
    
    final valueStyle = pw.TextStyle(
      fontSize: 12,
      color: PdfColors.black
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 20),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue900))
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Historial Clínico', style: titleStyle),
              pw.Text(
                'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: valueStyle
              ),
            ]
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700
            ),
          ),
        ),
        build: (context) {
          return [
            // Datos del Paciente con diseño mejorado
            _buildPDFSection(
              'Datos del Paciente',
              [
                _buildPDFInfoRow('Nombre completo:', '${paciente.nombre} ${paciente.primerApellido} ${paciente.segundoApellido}'),
                _buildPDFInfoRow('Edad:', '${paciente.edad} años'),
                _buildPDFInfoRow('Género:', paciente.genero),
                _buildPDFInfoRow('Estado Civil:', paciente.estadoCivil),
                _buildPDFInfoRow('Ocupación:', paciente.ocupacion),
                _buildPDFInfoRow('Escolaridad:', paciente.escolaridad),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
              hasBackground: true,
            ),

            pw.SizedBox(height: 20),

            // Expediente
            _buildPDFSection(
              'Expediente',
              [
                _buildPDFInfoRow('Número:', datos['expediente']),
                _buildPDFInfoRow('Fecha:', datos['fecha']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Exploración Física
            _buildPDFSection(
              'Exploración Física',
              [
                _buildPDFInfoRow('Peso:', '${datos['peso']} kg'),
                _buildPDFInfoRow('Estatura:', '${datos['estatura']} cm'),
                _buildPDFInfoRow('IMC:', datos['imc'] ?? 'No especificado'),
                _buildPDFInfoRow('Espasmos o Contractura Muscular:', _formatearSiNo(datos['espasmos'] ?? 'No')),
                if (_esSi(datos['espasmos'] ?? 'No'))
                  _buildPDFInfoRow('Sitio/Características:', datos['sitioEspasmos'] ?? 'No especificado'),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Antecedentes Patológicos
            _buildPDFSection(
              'Antecedentes Patológicos y Heredofamiliares',
              [
                _buildPDFInfoRow('Diabetes:', datos['diabetes']),
                if(datos['diabetes'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioDiabetes']),
                _buildPDFInfoRow('Alergia:', datos['alergia']),
                if(datos['alergia'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioAlergia']),
                _buildPDFInfoRow('HTA:', datos['hta']),
                if(datos['hta'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioHTA']),
                _buildPDFInfoRow('Cáncer:', datos['cancer']),
                if(datos['cancer'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioCancer']),
                _buildPDFInfoRow('Transfusiones:', datos['transfusiones']),
                if(datos['transfusiones'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioTransfusiones']),
                _buildPDFInfoRow('Enf. Reumáticas:', datos['reumaticas']),
                if(datos['reumaticas'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioReutmaticas']),
                _buildPDFInfoRow('Encames:', datos['encames']),
                _buildPDFInfoRow('Accidentes:', datos['accidentes']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Hábitos de Salud
            _buildPDFSection(
              'Hábitos de Salud',
              [
                _buildPDFInfoRow('Alcoholismo:', datos['alcoholismo']),
                if(datos['alcoholismo'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioAlcoholismo']),
                _buildPDFInfoRow('Tabaquismo:', datos['tabaquismo']),
                if(datos['tabaquismo'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioTabaquismo']),
                _buildPDFInfoRow('Actividad Física:', datos['actividadFisica']),
                if(datos['actividadFisica'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioActividad']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Diagnóstico Médico
            _buildPDFSection(
              'Diagnóstico Médico',
              [
                _buildPDFInfoRow('Diagnóstico Inicial:', datos['valoracionInicial']),
                _buildPDFInfoRow('Valoración Final:', datos['valoracionFinal']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Cicatriz Quirúrgica
            _buildPDFSection(
              'Cicatriz Quirúrgica',
              [
                _buildPDFInfoRow('Cicatrices:', datos['cirugias']),
                if (datos['cirugias'] == 'Sí') ...[
                  _buildPDFInfoRow('Tipo de Cicatriz:', _getTipoCicatriz(datos)),
                  _buildPDFInfoRow('Características:', datos['sitioSitio']),
                ],
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Marcha y Deambulación
            _buildPDFSection(
              'Marcha y Deambulación',
              [
                _buildPDFInfoRow('Tipo de Marcha:', _getTipoMarcha(datos)),
                _buildPDFInfoRow('Características:', datos['observacionesMarcha']),
                _buildPDFInfoRow('Atáxica:', _formatearSiNo(datos['ataxica'])),
                _buildPDFInfoRow('Espástica:', _formatearSiNo(datos['espasticas'])),
                _buildPDFInfoRow('Claudicante:', _formatearSiNo(datos['claudicante'])),
                _buildPDFInfoRow('Otros:', datos['otrosMarcha']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Traslados
            _buildPDFSection(
              'Traslados y Movilidad',
              [
                _buildPDFInfoRow('Independencia:', _getNivelIndependencia(datos)),
                _buildPDFInfoRow('Observaciones:', datos['abierta']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Medicación y Sustancias
            _buildPDFSection(
              'Medicación y Sustancias',
              [
                _buildPDFInfoRow('Drogas:', datos['drogas']),
                if(datos['drogas'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioDrogas']),
                _buildPDFInfoRow('Automedicación:', datos['automedica']),
                if(datos['automedica'] == 'Sí') _buildPDFInfoRow('Detalles:', datos['sitioAutomedica']),
                _buildPDFInfoRow('Observaciones adicionales:', datos['sitioHabitos']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Respuestas Sensoriales
            _buildPDFSection(
              'Respuestas Sensoriales y Reflejos',
              [
                _buildPDFInfoRow('Sensibilidad:', datos['sitioSensibilidad']),
                _buildPDFInfoRow('Reflejos:', datos['sitioreflejos']),
                _buildPDFInfoRow('Lenguaje:', datos['sitioLenguaje']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),

            // Observaciones Finales
            _buildPDFSection(
              'Observaciones Finales',
              [
                _buildPDFInfoRow('Observaciones:', datos['Observacionesfinales']),
              ],
              sectionTitleStyle,
              labelStyle,
              valueStyle,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Historial_Clinico_${paciente.nombre}',
      format: PdfPageFormat.a4,
    );
  }

  // Función auxiliar para construir secciones del PDF
  static pw.Widget _buildPDFSection(
    String title,
    List<pw.Widget> content,
    pw.TextStyle titleStyle,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
    {bool hasBackground = false}
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: hasBackground ? PdfColors.blue50 : PdfColors.white,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue200))
            ),
            child: pw.Text(title, style: titleStyle),
          ),
          pw.SizedBox(height: 10),
          ...content,
        ],
      ),
    );
  }

  // Función auxiliar para construir filas de información
  static pw.Widget _buildPDFInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey800,
                fontWeight: pw.FontWeight.bold
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.black
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _getTipoCicatriz(Map<String, dynamic> datos) {
    List<String> tipos = [];
    
    if (_esSi(datos['queloide'])) tipos.add('Queloide');
    if (_esSi(datos['retractil'])) tipos.add('Retráctil');
    if (_esSi(datos['hipertrofica'])) tipos.add('Hipertrófica');
    if (_esSi(datos['adherencia'])) tipos.add('Adherencia');
    
    return tipos.isEmpty ? 'No especificado' : tipos.join(', ');
  }

  static String _getTipoMarcha(Map<String, dynamic> datos) {
    List<String> tipos = [];
    
    if (_esSi(datos['ataxica'])) tipos.add('Atáxica');
    if (_esSi(datos['espasticas'])) tipos.add('Espástica');
    if (_esSi(datos['claudicante'])) tipos.add('Claudicante');
    if (_esSi(datos['libre'])) tipos.add('Libre');
    if (_esSi(datos['conAyuda'])) tipos.add('Con Ayuda');
    
    return tipos.isEmpty ? 'No especificado' : tipos.join(', ');
  }

  static String _getNivelIndependencia(Map<String, dynamic> datos) {
    if (_esSi(datos['conAyuda'])) return 'Con Ayuda';
    if (_esSi(datos['libre'])) return 'Independiente';
    return 'No especificado';
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