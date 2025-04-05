import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
          if (homeViewModel.paciente?.correoElectronico.isEmpty ?? true)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, color: Colors.white),
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildContentView(homeViewModel),
                        if (homeViewModel.paciente?.correoElectronico.isEmpty ?? true)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Completa tu perfil",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          ),
                      ],
                    ),
                  ),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto de perfil o avatar
              terapeuta.fotoPerfil != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        terapeuta.fotoPerfil!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(terapeuta),
                      ),
                    )
                  : _buildAvatarFallback(terapeuta),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terapeuta.nombreCompleto,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Terapeuta',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: Colors.white24, height: 32),
          // Información de contacto
          _buildInfoRow(Icons.email_outlined, 'Correo', terapeuta.correo),
          if (terapeuta.direccionCompleta.isNotEmpty) ...[
            SizedBox(height: 12),
            _buildInfoRow(Icons.location_on_outlined, 'Dirección', terapeuta.direccionCompleta),
          ],
          SizedBox(height: 16),
          // Botón de cédula
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Aquí iría la funcionalidad del botón de cédula
              },
              icon: Icon(Icons.badge_outlined, color: Colors.blue[900]),
              label: Text(
                'Ver Cédula Profesional',
                style: TextStyle(color: Colors.blue[900]),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(terapeuta) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.blue[300],
      child: Text(
        terapeuta.nombre.substring(0, 1) + terapeuta.primerApellido.substring(0, 1),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
                      "No tienes sesiones programadas próximamente",
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
                viewModel.proximaSesion!['descripcion'] ?? 'Sesión sin descripción',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 5),
              Text(
                "Fecha: ${viewModel.proximaSesion!['fecha']}",
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
              SizedBox(height: 5),
              Text(
                "Hora: ${_formatearHora(viewModel.proximaSesion!['hora'])}",
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
              if (viewModel.terapeuta != null) ...[
                SizedBox(height: 5),
                Text(
                  "Terapeuta: ${viewModel.terapeuta!.nombreCompleto}",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatearHora(String? hora) {
    if (hora == null) return 'Pendiente';
    try {
      final DateTime horaDateTime = DateTime.parse('2000-01-01 $hora');
      return DateFormat('hh:mm a').format(horaDateTime);
    } catch (e) {
      return hora;
    }
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
            // Verificamos si el paciente está inactivo
            if (viewModel.paciente?.estadoPaciente == 'inactivo')
              Center(
                child: Text(
                  "Estás inactivo, no hay gráficas disponibles",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else if (viewModel.graficasSesiones?.isEmpty ?? true)
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
    return LayoutBuilder(
      builder: (context, constraints) {
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
                        '(${_formatearFecha(DateTime.parse(sesion['fecha']))})',
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
                                  'Fecha: ${_formatearFecha(DateTime.parse(sesion['fecha']))}',
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
                                      sesion['nota_evolutiva'] ?? 'No hay nota evolutiva disponible',
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
            SizedBox(height: 10),
            FutureBuilder<Widget>(
              future: Future.delayed(
                Duration(milliseconds: 100),
                () => _buildGrafica(sesion['datos_graficas'], constraints.maxWidth),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[900]!.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  );
                }
                return snapshot.data!;
              },
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
      },
    );
  }

  Widget _buildGrafica(Map<String, dynamic>? datos, double width) {
    if (datos == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue[900]!.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "No existen gráficas para esta sesión",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: _buildLineChart(datos),
      ),
    );
  }

  Widget _buildLineChart(Map<String, dynamic> datos) {
    // Optimizamos el procesamiento de datos
    List<FlSpot> procesarDatos(List<dynamic> datos) {
      if (datos.isEmpty) return [];
      
      // Reducimos la cantidad de puntos
      const maxPuntos = 30; // Reducimos aún más los puntos
      if (datos.length > maxPuntos) {
        final paso = datos.length ~/ maxPuntos;
        return List.generate(maxPuntos, (index) {
          final punto = datos[index * paso];
          return FlSpot(
            index.toDouble(), // Simplificamos el eje X
            punto['value'].toDouble(),
          );
        });
      }
      
      return List.generate(datos.length, (index) {
        final punto = datos[index];
        return FlSpot(
          index.toDouble(), // Simplificamos el eje X
          punto['value'].toDouble(),
        );
      });
    }

    final datosIzquierda = procesarDatos(datos['izquierda'] as List<dynamic>? ?? []);
    final datosDerecha = procesarDatos(datos['derecha'] as List<dynamic>? ?? []);

    // Encontrar los valores máximos y mínimos para ajustar la escala
    double minY = 0;
    double maxY = 0;
    
    void actualizarLimites(List<FlSpot> spots) {
      for (var spot in spots) {
        if (spot.y < minY) minY = spot.y;
        if (spot.y > maxY) maxY = spot.y;
      }
    }
    
    actualizarLimites(datosIzquierda);
    actualizarLimites(datosDerecha);

    // Añadir un margen del 10% arriba y abajo
    final margen = (maxY - minY) * 0.1;
    minY = minY - margen;
    maxY = maxY + margen;

    // Si no hay datos o los valores son iguales, establecer límites por defecto
    if (minY == maxY) {
      minY = -0.5;
      maxY = 0.5;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 5, // Ajustamos el intervalo basado en el rango
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxY - minY) / 5,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.white30),
            left: BorderSide(color: Colors.white30),
          ),
        ),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          if (datosIzquierda.isNotEmpty)
            LineChartBarData(
              spots: datosIzquierda,
              isCurved: true,
              color: Colors.blue[300],
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue[300]!.withOpacity(0.1),
              ),
            ),
          if (datosDerecha.isNotEmpty)
            LineChartBarData(
              spots: datosDerecha,
              isCurved: true,
              color: Colors.green[300],
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green[300]!.withOpacity(0.1),
              ),
            ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final List<String> meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]}';
  }
}
