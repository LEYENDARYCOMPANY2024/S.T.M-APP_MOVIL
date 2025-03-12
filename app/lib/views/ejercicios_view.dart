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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Ejercicios"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progreso"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('/progreso');
          }
        },
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
