import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sesiones_viewmodels.dart';
import '../models/sesion.dart';

class SesionesView extends StatefulWidget {
  const SesionesView({Key? key}) : super(key: key);

  @override
  _SesionesViewState createState() => _SesionesViewState();
}

class _SesionesViewState extends State<SesionesView> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Cargar los datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SesionesViewModel>(context, listen: false).cargarTerapeutas();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SesionesViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text(
          "Mis Sesiones",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar sesión...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.blue[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                viewModel.buscarTerapeuta(value);
              },
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: viewModel.isLoading
                ? _buildLoadingView()
                : viewModel.errorMessage != null
                    ? _buildErrorView(viewModel.errorMessage!)
                    : _buildAllSesionesListView(viewModel),
          ),
        ],
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
            "Cargando sesiones...",
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
              onPressed: () => Provider.of<SesionesViewModel>(context, listen: false).recargarDatos(),
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

  // Lista de todas las sesiones
  Widget _buildAllSesionesListView(SesionesViewModel viewModel) {
    // Crear una lista plana de todas las sesiones
    List<Sesion> todasLasSesiones = [];
    Map<int, String> terapeutasNombres = {};
    
    // Recopilar todas las sesiones de todos los terapeutas
    viewModel.terapeutas.forEach((terapeuta) {
      final sesiones = viewModel.sesionesPorTerapeuta[terapeuta.id] ?? [];
      
      // Almacenar el nombre del terapeuta para mostrarlo con cada sesión
      terapeutasNombres[terapeuta.id] = terapeuta.nombreCompleto;
      
      // Agregar las sesiones a la lista plana
      todasLasSesiones.addAll(sesiones);
    });

    // No hacemos sort aquí ya que no conocemos el formato exacto de la fecha
    // Idealmente, las sesiones ya vendrían ordenadas desde el back-end
    
    if (todasLasSesiones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, color: Colors.white, size: 60),
            SizedBox(height: 20),
            Text(
              viewModel.searchQuery.isEmpty
                  ? "No tienes sesiones registradas"
                  : "No se encontraron sesiones con esa búsqueda",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: todasLasSesiones.length,
      itemBuilder: (context, index) {
        final sesion = todasLasSesiones[index];
        return _buildSesionCard(sesion);
      },
    );
  }

  // Tarjeta para cada sesión
  Widget _buildSesionCard(Sesion sesion) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sesion.descripcion,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Fecha: ${sesion.fechaFormateada}",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Hora: ${sesion.horaFormateada}",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Terapeuta: ${sesion.nombreTerapeuta}",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.visibility, color: Colors.white70, size: 28),
              onPressed: () {
                // Este botón se usará más adelante para detalle_sesion
              },
            ),
          ],
        ),
      ),
    );
  }
}