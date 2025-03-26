import 'package:flutter/material.dart';
import '../models/sesion.dart';

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

    return SingleChildScrollView(
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
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text("No se encontraron detalles de la sesión"),
    );
  }
}
