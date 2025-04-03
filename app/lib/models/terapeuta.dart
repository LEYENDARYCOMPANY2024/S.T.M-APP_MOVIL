import 'dart:typed_data';

class Terapeuta {
  final int id;
  final String nombreUsuario;
  final String nombre;
  final String primerApellido;
  final String? segundoApellido;
  final String correo;
  final String? codigoPostal;
  final String? calle;
  final String? colonia;
  final String? numExt;
  final String? numInt;
  final String? fotoPerfil;
  final Uint8List? documentoCedula;

  Terapeuta({
    required this.id,
    required this.nombreUsuario,
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.correo,
    this.codigoPostal,
    this.calle,
    this.colonia,
    this.numExt,
    this.numInt,
    this.fotoPerfil,
    this.documentoCedula,
  });

  // Convertir un mapa (de Supabase) a un objeto Terapeuta
  factory Terapeuta.fromMap(Map<String, dynamic> map) {
    return Terapeuta(
      id: map['id_terapeuta'] ?? 0,
      nombreUsuario: map['nombre_usuario'] ?? '',
      nombre: map['nombre'] ?? '',
      primerApellido: map['primer_apellido'] ?? '',
      segundoApellido: map['segundo_apellido'],
      correo: map['correo'] ?? '',
      codigoPostal: map['codigo_postal'],
      calle: map['calle'],
      colonia: map['colonia'],
      numExt: map['num_ext'],
      numInt: map['num_int'],
      fotoPerfil: map['foto_perfil'],
      documentoCedula: map['documento_cedula'],
    );
  }

  // Nombre completo del terapeuta
  String get nombreCompleto {
    return segundoApellido != null && segundoApellido!.isNotEmpty
        ? '$nombre $primerApellido $segundoApellido'
        : '$nombre $primerApellido';
  }

  String get direccionCompleta {
    List<String> partesDireccion = [];
    if (calle != null) partesDireccion.add(calle!);
    if (numExt != null) partesDireccion.add("No. $numExt");
    if (numInt != null) partesDireccion.add("Int. $numInt");
    if (colonia != null) partesDireccion.add(colonia!);
    if (codigoPostal != null) partesDireccion.add("C.P. $codigoPostal");
    
    return partesDireccion.join(', ');
  }
}