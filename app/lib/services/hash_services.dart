import 'package:bcrypt/bcrypt.dart';

class HashService {
  // Generar un hash de la contraseña
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  // Verificar contraseña hasheada
  static bool verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }
}
