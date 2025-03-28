import 'package:flutter/material.dart';
import '../models/sesion.dart';
import '../viewmodels/detalle_sesion_viewmodel.dart';
import 'package:provider/provider.dart';

class DetalleSesionWidget extends StatelessWidget {
  final Sesion? sesion;
  final bool isLoading;
  final String? errorMessage;

  const DetalleSesionWidget({
    Key? key,
    required this.sesion,
    required this.isLoading,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingView();
    }

    if (errorMessage != null) {
      return _buildErrorView(errorMessage!);
    }

    if (sesion == null) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: () => Provider.of<DetalleSesionViewModel>(context, listen: false).recargarDatos(),
      color: Colors.blue[900],
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: "Descripción",
              content: sesion!.descripcion,
              icon: Icons.description,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Fecha y Hora",
              content: "${sesion!.fechaFormateada} - ${sesion!.horaFormateada}",
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Terapeuta",
              content: sesion!.nombreTerapeuta,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Nota Evolutiva",
              content: sesion!.notaEvolutiva ?? "Sin nota evolutiva",
              icon: Icons.note,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(
              height: 24,
              thickness: 1,
              color: Colors.white24,
            ),
            Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            "Cargando detalles...",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 60),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, color: Colors.white, size: 60),
          SizedBox(height: 20),
          Text(
            "No se encontraron detalles de la sesión",
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
