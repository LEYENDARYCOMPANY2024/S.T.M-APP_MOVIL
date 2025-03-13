import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sesiones_viewmodels.dart';
import '../models/terapeuta.dart';
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
                hintText: "Buscar terapeuta...",
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
                    : viewModel.terapeutas.isEmpty
                        ? _buildEmptyView()
                        : _buildTerapeutasListView(viewModel),
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

  // Vista vacía
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, color: Colors.white, size: 60),
          SizedBox(height: 20),
          Text(
            Provider.of<SesionesViewModel>(context).searchQuery.isEmpty
                ? "No tienes sesiones registradas con ningún terapeuta"
                : "No se encontraron terapeutas con ese nombre",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // Lista de terapeutas con sus sesiones
  Widget _buildTerapeutasListView(SesionesViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.terapeutas.length,
      itemBuilder: (context, index) {
        final terapeuta = viewModel.terapeutas[index];
        return _buildTerapeutaCard(viewModel, terapeuta);
      },
    );
  }

  // Tarjeta de terapeuta con expansión para sesiones
  Widget _buildTerapeutaCard(SesionesViewModel viewModel, Terapeuta terapeuta) {
    // Verificar si hay sesiones para este terapeuta
    List<Sesion> sesiones = viewModel.sesionesPorTerapeuta[terapeuta.id] ?? [];
    
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.grey[800],
        backgroundColor: Colors.grey[800],
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[300],
              radius: 25,
              child: Text(
                terapeuta.nombre.substring(0, 1) + terapeuta.primerApellido.substring(0, 1),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terapeuta.nombreCompleto,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  Text(
                    terapeuta.correo,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          sesiones.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "No hay sesiones registradas con este terapeuta",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: sesiones.length,
                  itemBuilder: (context, index) {
                    final sesion = sesiones[index];
                    return _buildSesionTile(sesion);
                  },
                ),
        ],
      ),
    );
  }

  // Tile para cada sesión dentro de la tarjeta de terapeuta
  Widget _buildSesionTile(Sesion sesion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sesión: ${sesion.descripcion}",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  "Fecha: ${sesion.fechaFormateada} - Hora: ${sesion.horaFormateada}",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.visibility, color: Colors.white70),
            onPressed: () {
              // Acción para ver detalles de la sesión
            },
          ),
        ],
      ),
    );
  }
}