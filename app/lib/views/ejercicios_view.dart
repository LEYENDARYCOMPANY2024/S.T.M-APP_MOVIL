import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ejercicios_viewmodel.dart';

class EjerciciosView extends StatelessWidget {
  const EjerciciosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ejerciciosViewModel = Provider.of<EjerciciosViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text(
          "Ejercicios",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/perfil');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ejerciciosViewModel.recargarDatos(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Lógica de logout
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: ejerciciosViewModel.niveles
              .asMap()
              .entries
              .map((entry) => _buildNivelCard(
                    entry.value.nombre,
                    entry.value.descripcion,
                    entry.value.completado,
                    context,
                    () {
                      ejerciciosViewModel.completarNivel(entry.key);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildNivelCard(
    String nivel,
    String descripcion,
    bool completado,
    BuildContext context,
    VoidCallback onCompletar,
  ) {
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
                Icon(Icons.fitness_center, color: Colors.blue[300]),
                SizedBox(width: 10),
                Text(
                  nivel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (completado)
                  Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              descripcion,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onCompletar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
                foregroundColor: Colors.white,
              ),
              child: const Text("Completar nivel"),
            ),
          ],
        ),
      ),
    );
  }
}