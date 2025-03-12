class Paciente {
  final int id;
  final String nombre;
  final String primerApellido;
  final String? segundoApellido;
  final int edad;
  final String codigo;
  final String genero;
  final String? estadoCivil;
  final String? escolaridad;
  final String ocupacion;
  final String nombreUsuario;
  final String contrasena;
  final String estadoPaciente;
  final String correoElectronico;  // Nuevo atributo

  Paciente({
    required this.id,
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.edad,
    required this.codigo,
    required this.genero,
    this.estadoCivil,
    this.escolaridad,
    required this.ocupacion,
    required this.nombreUsuario,
    required this.contrasena,
    required this.estadoPaciente,
    required this.correoElectronico,  // Inicializa el nuevo atributo
  });

  // 🔹 Método para actualizar solo los valores modificados sin perder los demás datos
  Paciente copyWith({
    String? nombreUsuario,
    String? correoElectronico,
  }) {
    return Paciente(
      id: id,
      nombre: nombre,
      primerApellido: primerApellido,
      segundoApellido: segundoApellido,
      edad: edad,
      codigo: codigo,
      genero: genero,
      estadoCivil: estadoCivil,
      escolaridad: escolaridad,
      ocupacion: ocupacion,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      contrasena: contrasena,
      estadoPaciente: estadoPaciente,
      correoElectronico: correoElectronico ?? this.correoElectronico,
    );
  }

  // Convertir un mapa (de Supabase) a un objeto Paciente
  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id_paciente'] ?? 0,
      nombre: map['nombre'] ?? '',
      primerApellido: map['primer_apellido'] ?? '',
      segundoApellido: map['segundo_apellido'],
      edad: map['edad'] ?? 0,
      codigo: map['codigo'] ?? '',
      genero: map['genero'] ?? '',
      estadoCivil: map['estado_civil'],
      escolaridad: map['escolaridad'],
      ocupacion: map['ocupacion'] ?? '',
      nombreUsuario: map['nombre_usuario_p'] ?? '',
      contrasena: map['contrasena_p'] ?? '',
      estadoPaciente: map['estado_paciente'] ?? '',
      correoElectronico: map['correo_electronico_p'] ?? '',  // Recuperar el correo electrónico del mapa
    );
  }

  // Convertir un objeto Paciente a un mapa (para futuras inserciones o actualizaciones)
  Map<String, dynamic> toMap() {
    return {
      'id_paciente': id,
      'nombre': nombre,
      'primer_apellido': primerApellido,
      'segundo_apellido': segundoApellido,
      'edad': edad,
      'codigo': codigo,
      'genero': genero,
      'estado_civil': estadoCivil,
      'escolaridad': escolaridad,
      'ocupacion': ocupacion,
      'nombre_usuario_p': nombreUsuario,
      'contrasena_p': contrasena,
      'estado_paciente': estadoPaciente,
      'correo_electronico_p': correoElectronico,  // Agregar el correo electrónico al mapa
    };
  }
}
