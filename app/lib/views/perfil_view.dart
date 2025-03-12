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
                  ? PerfilDesign(paciente: perfilViewModel.paciente!)
                  : _buildEmptyProfileView(), // Nueva función para manejar datos nulos
    );
  }

  // 📌 Muestra error con opción de reintentar
  Widget _buildErrorView(PerfilViewModel perfilViewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red.shade700, size: 50),
          const SizedBox(height: 10),
          Text(perfilViewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              perfilViewModel.cargarDatos();
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
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
