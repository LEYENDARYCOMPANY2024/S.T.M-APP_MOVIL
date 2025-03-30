import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';

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
              : RefreshIndicator(
                  onRefresh: () => homeViewModel.recargarDatos(),
                  color: Colors.blue[900],
                  child: _buildContentView(homeViewModel),
                ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Historial Clinico"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Ejercicios"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamed('/inicio');
          } else if (index == 1) {
            Navigator.of(context).pushNamed('/historial-clinico');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/ejercicios');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/chat');
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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

  Widget _buildProgresoCard(HomeViewModel viewModel) {
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
                Icon(Icons.trending_up, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  "Progreso",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (viewModel.graficasSesiones?.isEmpty ?? true)
              Center(
                child: Text(
                  "No hay datos de progreso disponibles",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              Column(
                children: [
                  _buildGraficaSesion(
                    "Sesión más reciente",
                    viewModel.graficasSesiones![0],
                  ),
                  SizedBox(height: 20),
                  if (viewModel.graficasSesiones!.length > 1)
                    _buildGraficaSesion(
                      "Sesión anterior",
                      viewModel.graficasSesiones![1],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficaSesion(String titulo, Map<String, dynamic> sesion) {
    final fechaSesion = DateTime.parse(sesion['fecha']);
    final esAntigua = sesion['es_antigua'] as bool;
    final notaEvolutiva = sesion['nota_evolutiva'] as String?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '(${_formatearFecha(fechaSesion)})',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.description, color: Colors.white70),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nota Evolutiva',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.white70),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Fecha: ${_formatearFecha(fechaSesion)}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              constraints: BoxConstraints(maxHeight: 300),
                              child: SingleChildScrollView(
                                child: Text(
                                  notaEvolutiva ?? 'No hay nota evolutiva disponible',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cerrar',
                                  style: TextStyle(
                                    color: Colors.blue[300],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        if (esAntigua)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '⚠️ Sesión antigua',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
        SizedBox(height: 10),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue[900]!.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: sesion['datos_graficas'] == null
              ? Center(
                  child: Text(
                    "No existen gráficas para esta sesión",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: _buildLineChart(sesion['datos_graficas']),
                ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              color: Colors.blue[300],
            ),
            SizedBox(width: 8),
            Text(
              'Pierna Izquierda',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(width: 20),
            Container(
              width: 12,
              height: 12,
              color: Colors.green[300],
            ),
            SizedBox(width: 8),
            Text(
              'Pierna Derecha',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    final List<String> meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]}';
  }

  Widget _buildLineChart(Map<String, dynamic> datos) {
    final datosIzquierda = (datos['izquierda'] as List<dynamic>)
        .map((e) => FlSpot(
              e['timestamp'].toDouble(),
              e['value'].toDouble(),
            ))
        .toList();

    final datosDerecha = (datos['derecha'] as List<dynamic>)
        .map((e) => FlSpot(
              e['timestamp'].toDouble(),
              e['value'].toDouble(),
            ))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          if (datosIzquierda.isNotEmpty)
            LineChartBarData(
              spots: datosIzquierda,
              isCurved: true,
              color: Colors.blue[300],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          if (datosDerecha.isNotEmpty)
            LineChartBarData(
              spots: datosDerecha,
              isCurved: true,
              color: Colors.green[300],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(enabled: true),
      ),
    );
  }
}
