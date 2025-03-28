import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/perfil_viewmodel.dart';
import '../widgets/perfil_design.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({Key? key}) : super(key: key);

  @override
  _PerfilViewState createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final perfilViewModel = Provider.of<PerfilViewModel>(context, listen: false);
      perfilViewModel.cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final perfilViewModel = Provider.of<PerfilViewModel>(context);

    return Scaffold(
      body: perfilViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : perfilViewModel.errorMessage != null
              ? _buildErrorView(perfilViewModel) // Nueva función para manejar errores
              : perfilViewModel.paciente != null
                  ? RefreshIndicator(
                      onRefresh: () => perfilViewModel.cargarDatos(),
                      color: Color(0xFF1565C0),
                      child: PerfilDesign(paciente: perfilViewModel.paciente!),
                    )
                  : _buildEmptyProfileView(), // Nueva función para manejar datos nulos
    );
  }

  // 📌 Muestra error con opción de reintentar
  Widget _buildErrorView(PerfilViewModel perfilViewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
      ),
      child: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 32),
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.red.shade700,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "¡Ups! Algo salió mal",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "No se pudieron cargar los datos del perfil.\nPor favor, revise su conexión a internet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      perfilViewModel.cargarDatos();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      "Reintentar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  perfilViewModel.errorMessage ?? "Error desconocido",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📌 Muestra mensaje si no hay datos del perfil
  Widget _buildEmptyProfileView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, color: Colors.grey, size: 50),
          SizedBox(height: 10),
          Text(
            "No se ha cargado la información del perfil.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
