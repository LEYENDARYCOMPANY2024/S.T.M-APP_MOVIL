import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/detalle_chat_viewmodel.dart';
import '../models/terapeuta.dart';

class DetalleChatView extends StatefulWidget {
  final Terapeuta terapeuta;

  const DetalleChatView({
    Key? key, 
    required this.terapeuta,
  }) : super(key: key);

  @override
  _DetalleChatViewState createState() => _DetalleChatViewState();
}

class _DetalleChatViewState extends State<DetalleChatView> {
  final TextEditingController _mensajeController = TextEditingController();
  late DetalleChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DetalleChatViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.inicializarChat(widget.terapeuta);
    });
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: Text(
          widget.terapeuta.nombreCompleto,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/perfil');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue[700],
        ),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            if (viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "Cargando mensajes...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            
            if (viewModel.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 60),
                      SizedBox(height: 20),
                      Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Conversación",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: viewModel.mensajes.isEmpty
                        ? _buildNoMensajes()
                        : _buildListaMensajes(),
                  ),
                ),
                _buildInputMensaje(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoMensajes() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 60
          ),
          SizedBox(height: 20),
          Text(
            "No hay mensajes aún",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18
            ),
          ),
          SizedBox(height: 10),
          Text(
            "¡Sé el primero en escribir!",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaMensajes() {
    if (viewModel.mensajes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 60
            ),
            SizedBox(height: 20),
            Text(
              "No hay mensajes aún",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              ),
            ),
            SizedBox(height: 10),
            Text(
              "¡Sé el primero en escribir!",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar mensajes por fecha
    Map<String, List<Map<String, dynamic>>> mensajesPorFecha = {};
    for (var mensaje in viewModel.mensajes) {
      final fecha = DateTime.parse(mensaje['enviado_en']);
      final fechaKey = _obtenerFechaFormateada(fecha);
      
      if (!mensajesPorFecha.containsKey(fechaKey)) {
        mensajesPorFecha[fechaKey] = [];
      }
      mensajesPorFecha[fechaKey]!.add(mensaje);
    }

    return ListView.builder(
      itemCount: mensajesPorFecha.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final fecha = mensajesPorFecha.keys.elementAt(index);
        final mensajesDelDia = mensajesPorFecha[fecha]!;
        
        return Column(
          children: [
            _buildFechaSeparador(fecha),
            ...mensajesDelDia.map((mensaje) => _buildMensaje(mensaje)).toList(),
          ],
        );
      },
    );
  }

  String _obtenerFechaFormateada(DateTime fecha) {
    final ahora = DateTime.now();
    final ayer = ahora.subtract(Duration(days: 1));

    if (fecha.year == ahora.year && 
        fecha.month == ahora.month && 
        fecha.day == ahora.day) {
      return "Hoy";
    } else if (fecha.year == ayer.year && 
               fecha.month == ayer.month && 
               fecha.day == ayer.day) {
      return "Ayer";
    } else {
      return "${fecha.day}/${fecha.month}/${fecha.year}";
    }
  }

  Widget _buildFechaSeparador(String fecha) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Colors.white30),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                fecha,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(color: Colors.white30),
          ),
        ],
      ),
    );
  }

  Widget _buildMensaje(Map<String, dynamic> mensaje) {
    final esPaciente = mensaje['remitente'] == 'paciente';
    final fecha = DateTime.parse(mensaje['enviado_en']);
    final horaFormateada = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
    
    // Calcular el ancho máximo para el mensaje
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    
    return Align(
      alignment: esPaciente ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          color: esPaciente ? Colors.blue[300] : Colors.grey[700],
          margin: EdgeInsets.only(
            bottom: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: esPaciente ? Radius.circular(15) : Radius.circular(5),
              bottomRight: esPaciente ? Radius.circular(5) : Radius.circular(15),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: esPaciente ? 40 : 12,
                  top: 8,
                  bottom: 20, // Espacio para la hora
                ),
                child: Text(
                  mensaje['mensaje'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                right: esPaciente ? 40 : 12,
                bottom: 4,
                child: Text(
                  horaFormateada,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ),
              if (esPaciente)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[800],
                            title: Text(
                              '¿Eliminar mensaje?',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              '¿Estás seguro de que quieres eliminar este mensaje?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final eliminado = await viewModel.eliminarMensaje(mensaje['id_mensaje']);
                                  if (!eliminado) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al eliminar el mensaje'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputMensaje() {
    return Container(
      color: Colors.grey[800],
      padding: EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _mensajeController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue[300],
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () async {
                  if (_mensajeController.text.trim().isNotEmpty) {
                    final enviado = await viewModel.enviarMensaje(_mensajeController.text);
                    if (enviado) {
                      _mensajeController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al enviar el mensaje'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 