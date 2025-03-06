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
    // Llamamos a cargarDatos cuando la vista esté completamente inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final perfilViewModel = Provider.of<PerfilViewModel>(context, listen: false);
      perfilViewModel.cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final perfilViewModel = Provider.of<PerfilViewModel>(context);

    return perfilViewModel.isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : perfilViewModel.paciente != null
            ? PerfilDesign(paciente: perfilViewModel.paciente!)
            : const Scaffold(
                body: Center(
                  child: Text(
                    "No se ha cargado la información del perfil.",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                  ),
                ),
              );
  }
}
