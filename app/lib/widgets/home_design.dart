import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeDesign {
  // AppBar
  static AppBar buildAppBar({
    required BuildContext context,
    required VoidCallback onProfileTap,
    required VoidCallback onRefreshTap,
    required VoidCallback onLogoutTap,
  }) {
    return AppBar(
      backgroundColor: Colors.blue[900],
      elevation: 0,
      title: const Text(
        "Inicio",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: onProfileTap,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: onRefreshTap,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: onLogoutTap,
        ),
      ],
    );
  }

  // Vista de carga
  static Widget buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            "Cargando información...",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Vista de error
  static Widget buildErrorView({
    required String errorMessage,
    required VoidCallback onRetry,
    required BuildContext context,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 60),
            SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[900],
              ),
              child: Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }

  // Vista de contenido principal
  static Widget buildContentView({
    required HomeViewModel viewModel,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTerapeutaCard(viewModel),
            const SizedBox(height: 20),
            buildProximaSesionCard(viewModel),
            const SizedBox(height: 20),
            buildProgresoCard(viewModel),
          ],
        ),
      ),
    );
  }

  // Tarjeta de información del terapeuta
  static Widget buildTerapeutaCard(HomeViewModel viewModel) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  "Tu Terapeuta",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            viewModel.terapeuta != null
                ? buildTerapeutaInfo(viewModel.terapeuta!)
                : Text(
                    "No tienes un terapeuta asignado actualmente",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
          ],
        ),
      ),
    );
  }

  // Información del terapeuta
  static Widget buildTerapeutaInfo(terapeuta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[300],
              radius: 30,
              child: Text(
                terapeuta.nombre.substring(0, 1) + terapeuta.primerApellido.substring(0, 1),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terapeuta.nombreCompleto,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  Text(
                    terapeuta.correo,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        OutlinedButton.icon(
          icon: Icon(Icons.message_outlined),
          label: Text("Contactar"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.6)),
          ),
          onPressed: () {
            // Implementar funcionalidad para contactar al terapeuta
          },
        ),
      ],
    );
  }

  // Tarjeta de próxima sesión
  static Widget buildProximaSesionCard(HomeViewModel viewModel) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  "Próxima sesión",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            viewModel.proximaSesion != null
                ? buildSessionInfo(viewModel)
                : Text(
                    "No hay sesiones programadas",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
          ],
        ),
      ),
    );
  }

  // Información de la sesión
  static Widget buildSessionInfo(HomeViewModel viewModel) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[300]!.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.calendar_today,
            color: Colors.blue[300],
            size: 30,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.proximaSesion!['fecha'] ?? 'Fecha pendiente',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 5),
              Text(
                "Hora: ${viewModel.proximaSesion!['hora'] ?? 'Pendiente'}",
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
              if (viewModel.terapeuta != null) SizedBox(height: 5),
              if (viewModel.terapeuta != null)
                Text(
                  "Terapeuta: ${viewModel.terapeuta!.nombreCompleto}",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Tarjeta de progreso
  static Widget buildProgresoCard(HomeViewModel viewModel) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.show_chart, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              "Progreso",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BottomNavigationBar
  static Widget buildBottomNavigationBar({required Function(int) onTap}) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue[900],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progreso"),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Ejercicios"),
      ],
      onTap: onTap,
    );
  }

  // FloatingActionButton
  static Widget buildFloatingActionButton({required VoidCallback onPressed}) {
    return FloatingActionButton(
      backgroundColor: Colors.blue[300],
      child: Icon(Icons.event_note, color: Colors.white),
      onPressed: onPressed,
    );
  }
}