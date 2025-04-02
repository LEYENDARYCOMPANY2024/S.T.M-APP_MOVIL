import 'package:flutter/material.dart';
import '../models/sesion.dart';
import '../viewmodels/detalle_sesion_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
            const SizedBox(height: 24),
            _buildGraficasSection(context),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficasSection(BuildContext context) {
    final viewModel = Provider.of<DetalleSesionViewModel>(context);
    final datosGraficas = viewModel.datosGraficas;

    final graficasData = datosGraficas['graficas'];
    if (graficasData == null) {
      return _buildNoDataCard(
        title: "Análisis de Movimiento",
        message: "No hay datos de movimiento disponibles para esta sesión",
        icon: Icons.analytics,
      );
    }

    final datosDerecha = graficasData['derecha'] as List?;
    final datosIzquierda = graficasData['izquierda'] as List?;

    if (datosDerecha == null || datosIzquierda == null) {
      return _buildNoDataCard(
        title: "Análisis de Movimiento",
        message: "No hay datos de movimiento disponibles para esta sesión",
        icon: Icons.analytics,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                "Análisis de Movimiento",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue[900]!.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _buildLineChart(datosDerecha, datosIzquierda),
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

  Widget _buildLineChart(List datosDerecha, List datosIzquierda) {
    // Optimizamos el procesamiento de datos
    List<FlSpot> procesarDatos(List<dynamic> datos) {
      if (datos.isEmpty) return [];
      
      // Reducimos la cantidad de puntos
      const maxPuntos = 30;
      if (datos.length > maxPuntos) {
        final paso = datos.length ~/ maxPuntos;
        return List.generate(maxPuntos, (index) {
          final punto = datos[index * paso];
          return FlSpot(
            index.toDouble(),
            punto['value'].toDouble(),
          );
        });
      }
      
      return List.generate(datos.length, (index) {
        final punto = datos[index];
        return FlSpot(
          index.toDouble(),
          punto['value'].toDouble(),
        );
      });
    }

    final datosIzq = procesarDatos(datosIzquierda);
    final datosDer = procesarDatos(datosDerecha);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
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
              interval: 0.2,
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
        minY: -0.5,
        maxY: 0.5,
        lineBarsData: [
          if (datosIzq.isNotEmpty)
            LineChartBarData(
              spots: datosIzq,
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
          if (datosDer.isNotEmpty)
            LineChartBarData(
              spots: datosDer,
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

  Widget _buildNoDataCard({
    required String title,
    required String message,
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withOpacity(0.5),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
