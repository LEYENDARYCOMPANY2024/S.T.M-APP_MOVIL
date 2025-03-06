import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../services/token_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int? userId;
  
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }
  
  Future<void> _loadUserId() async {
    final id = await TokenService.getUserId();
    if (mounted) {
      setState(() {
        userId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await viewModel.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // Acción para el perfil de usuario
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Información de Usuario"),
                  content: Text("ID de Usuario: ${userId ?? 'Cargando...'}"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cerrar"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              title: "Información de Usuario",
              content: "ID de Usuario: ${userId ?? 'Cargando...'}",
            ),
            const SizedBox(height: 20),
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