import 'package:firebase_auth/firebase_auth.dart';

/// Autenticación por correo (mismo estilo que tu EmailAuth, métodos m_...).
/// En lugar de tragarse el error, devuelve `null` si todo salió bien o un
/// mensaje en español para mostrar en pantalla.
class EmailAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> m_creaUsuario(
      {required String name, required String user, required String pass}) async {
    try {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
          email: user.trim(), password: pass);
      await credentials.user!.updateDisplayName(name.trim());
      await credentials.user!.sendEmailVerification();
      await credentials.user!.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return mensaje(e);
    } catch (_) {
      return 'Ocurrió un error inesperado.';
    }
  }

  /// Inicia sesión. La verificación del correo se exige en RootGate
  /// (VerifyEmailScreen), no aquí.
  Future<String?> m_loginUser({required String user, required String pass}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: user.trim(), password: pass);
      return null;
    } on FirebaseAuthException catch (e) {
      return mensaje(e);
    } catch (_) {
      return 'Ocurrió un error inesperado.';
    }
  }

  Future<String?> m_reenviaVerificacion() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return mensaje(e);
    }
  }

  Future<String?> m_recuperaPass(String correo) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: correo.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return mensaje(e);
    }
  }

  Future<User?> m_recargaUsuario() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser;
  }

  static String mensaje(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese correo usando otro método.';
      case 'canceled':
      case 'popup-closed-by-user':
      case 'web-context-canceled':
        return 'Inicio de sesión cancelado.';
      default:
        return e.message ?? 'Error de autenticación.';
    }
  }
}
