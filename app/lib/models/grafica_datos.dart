class DatoGrafica {
  final double value;
  final int timestamp;

  DatoGrafica({
    required this.value,
    required this.timestamp,
  });

  factory DatoGrafica.fromMap(Map<String, dynamic> map) {
    return DatoGrafica(
      value: (map['value'] as num).toDouble(),
      timestamp: map['timestamp'] as int,
    );
  }
}

class GraficaDatos {
  final List<DatoGrafica> derecha;
  final List<DatoGrafica> izquierda;
  final DateTime fechaRegistro;

  GraficaDatos({
    required this.derecha,
    required this.izquierda,
    required this.fechaRegistro,
  });

  factory GraficaDatos.fromMap(Map<String, dynamic> map) {
    return GraficaDatos(
      derecha: (map['derecha'] as List<dynamic>)
          .map((e) => DatoGrafica.fromMap(e as Map<String, dynamic>))
          .toList(),
      izquierda: (map['izquierda'] as List<dynamic>)
          .map((e) => DatoGrafica.fromMap(e as Map<String, dynamic>))
          .toList(),
      fechaRegistro: DateTime.parse(map['fecha_registro'] ?? DateTime.now().toString()),
    );
  }
} 