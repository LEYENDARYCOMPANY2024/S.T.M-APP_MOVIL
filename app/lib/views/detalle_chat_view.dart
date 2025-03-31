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
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.terapeuta.nombreCompleto,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              'Terapeuta',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (viewModel.errorMessage != null) {
              return Center(
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: viewModel.mensajes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Aún no hay mensajes",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "¡Se el primero en escribir!",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: viewModel.mensajes.length,
                          padding: EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final mensaje = viewModel.mensajes[index];
                            return _buildMensaje(mensaje);
                          },
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

  Widget _buildMensaje(Map<String, dynamic> mensaje) {
    final esPaciente = mensaje['remitente'] == 'paciente';
    final fecha = DateTime.parse(mensaje['enviado_en']);
    final horaFormateada = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
    
    return Padding(
      padding: EdgeInsets.only(
        left: esPaciente ? 60 : 8,
        right: esPaciente ? 8 : 60,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: esPaciente ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: esPaciente ? Colors.blue[700] : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: esPaciente ? Radius.circular(15) : Radius.circular(5),
                bottomRight: esPaciente ? Radius.circular(5) : Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensaje['mensaje'],
                  style: TextStyle(
                    color: esPaciente ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              horaFormateada,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputMensaje() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 6,
            color: Colors.black12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _mensajeController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[700],
                shape: BoxShape.circle,
              ),
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