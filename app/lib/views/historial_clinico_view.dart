import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/historial_clinico_viewmodel.dart';
import '../widgets/historial_clinico_design.dart';

class HistorialClinicoReadOnlyView extends StatefulWidget {
  const HistorialClinicoReadOnlyView({Key? key}) : super(key: key);

  @override
  _HistorialClinicoReadOnlyViewState createState() => _HistorialClinicoReadOnlyViewState();
}

class _HistorialClinicoReadOnlyViewState extends State<HistorialClinicoReadOnlyView> {
  late HistorialClinicoViewModel _viewModel;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<HistorialClinicoViewModel>(context, listen: false);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Clínico'),
        backgroundColor: Colors.blue[900],
      ),
      backgroundColor: Colors.blue[700],
      body: Consumer<HistorialClinicoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white)
            );
          }

          if (viewModel.historialClinico == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 100,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No tienes historial clínico',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildView(viewModel);
        },
      ),
    );
  }

  Widget _buildView(HistorialClinicoViewModel viewModel) {
    final historial = viewModel.historialClinico!;
    final datos = historial.datosHistorialClinico;
    final paciente = viewModel.paciente!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HistorialClinicoReadOnlyDesign.buildDatosPaciente(paciente),
            const SizedBox(height: 16),
            HistorialClinicoReadOnlyDesign.buildExpedienteSection(datos),
            const SizedBox(height: 16),
            HistorialClinicoReadOnlyDesign.buildExploracionFisica(datos),
            const SizedBox(height: 16),
            HistorialClinicoReadOnlyDesign.buildAntecedentesPatologicos(datos),
            const SizedBox(height: 16),
            HistorialClinicoReadOnlyDesign.buildHabitosSalud(datos),
            const SizedBox(height: 16),
            HistorialClinicoReadOnlyDesign.buildDiagnosticoMedico(datos),
            const SizedBox(height: 16),
            HistorialClinicoReadOnlyDesign.buildCicatrizQuirurgica(datos),
            const SizedBox(height: 16),
            HistorialClinicoReadOnlyDesign.buildMarchaDeambulacion(datos),
            const SizedBox(height: 16),
            HistorialClinicoReadOnlyDesign.buildTraslados(datos),
            
            // Sección específica para mujeres (solo se muestra si es mujer)
            if (viewModel.esMujer) ...[
              const SizedBox(height: 16),
              HistorialClinicoReadOnlyDesign.buildInformacionMujeres(datos),
            ],

            const SizedBox(height: 24),
            Center(
              child: HistorialClinicoReadOnlyDesign.buildGenerarPdfButton(() {
                HistorialClinicoReadOnlyDesign.generarPDF(datos, paciente);
              }),
            ),
          ],
        ),
      ),
    );
  }
}