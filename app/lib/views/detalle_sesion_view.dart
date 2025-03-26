import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/detalle_sesion_viewmodel.dart';
import '../widgets/detalle_sesion_widget.dart';
import '../models/sesion.dart';

class DetalleSesionView extends StatefulWidget {
  final Sesion sesion;

  const DetalleSesionView({
    Key? key,
    required this.sesion,
  }) : super(key: key);

  @override
  _DetalleSesionViewState createState() => _DetalleSesionViewState();
}

class _DetalleSesionViewState extends State<DetalleSesionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetalleSesionViewModel>().setSesion(widget.sesion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        title: const Text(
          'Detalle de Sesión',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<DetalleSesionViewModel>(
        builder: (context, viewModel, _) {
          return DetalleSesionWidget(
            sesion: viewModel.sesion,
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
          );
        },
      ),
    );
  }
}
