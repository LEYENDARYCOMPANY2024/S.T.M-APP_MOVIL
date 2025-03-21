import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    final homeViewModel = Provider.of<HomeViewModel>(context);

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
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/perfil');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => homeViewModel.recargarDatos(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await loginViewModel.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: homeViewModel.isLoading
          ? _buildLoadingView()
          : homeViewModel.errorMessage != null
              ? _buildErrorView(homeViewModel.errorMessage!)
              : _buildContentView(homeViewModel),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Historial Clinico"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Ejercicios"),
        ],
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/ejercicios');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[300],
        child: Icon(Icons.event_note, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pushNamed('/sesion');
        },
      ),
    );
  }

  // Vista de carga
  Widget _buildLoadingView() {
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
  Widget _buildErrorView(String errorMessage) {
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
              onPressed: () => Provider.of<HomeViewModel>(context, listen: false).recargarDatos(),
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
  Widget _buildContentView(HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTerapeutaCard(viewModel),
            const SizedBox(height: 20),
            _buildProximaSesionCard(viewModel),
            const SizedBox(height: 20),
            _buildProgresoCard(viewModel),
          ],
        ),
      ),
    );
  }

  // Tarjeta de información del terapeuta
  Widget _buildTerapeutaCard(HomeViewModel viewModel) {
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
            // Verificamos si el paciente está inactivo
            viewModel.paciente != null && viewModel.paciente!.estadoPaciente == 'inactivo'
              ? Text(
                  "Sin terapeuta",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                )
              : viewModel.terapeuta != null
                  ? _buildTerapeutaInfo(viewModel.terapeuta!)
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
  Widget _buildTerapeutaInfo(terapeuta) {
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
  Widget _buildProximaSesionCard(HomeViewModel viewModel) {
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
            // Verificar si el paciente está inactivo
            viewModel.paciente != null && viewModel.paciente!.estadoPaciente == 'inactivo'
              ? Text(
                  "Estás inactivo, no tienes sesiones",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                )
              : viewModel.proximaSesion != null
                  ? _buildSessionInfo(viewModel)
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
  Widget _buildSessionInfo(HomeViewModel viewModel) {
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
  Widget _buildProgresoCard(HomeViewModel viewModel) {
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
}
