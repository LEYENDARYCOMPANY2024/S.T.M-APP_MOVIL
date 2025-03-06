import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text(
          "Inicio",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // Acción para el perfil de usuario
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              title: "Próxima sesión",
              content: "Terapeuta: [nombre terapeuta]\nHora y fecha: [hora y fecha]",
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "Progreso General",
              content: "Gráficos de progreso",
              showArrow: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progreso"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Mensajes"),
        ],
        onTap: (index) {
          // Manejo de navegación en el BottomNavigationBar
        },
      ),
    );
  }

  Widget _buildCard({required String title, required String content, bool showArrow = false}) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            if (showArrow)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () {
                    // Acción para ver más detalles
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}