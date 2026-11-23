import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/firebase/email_auth.dart';

/// Inicio de sesión con Google y GitHub (proveedores nativos de Firebase Auth).
class SocialAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> m_loginGoogle() => _login(GoogleAuthProvider());
  Future<String?> m_loginGithub() => _login(GithubAuthProvider());

  Future<String?> _login(AuthProvider provider) async {
    try {
      if (kIsWeb) {
        await _firebaseAuth.signInWithPopup(provider);
      } else {
        await _firebaseAuth.signInWithProvider(provider);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return EmailAuth.mensaje(e);
    } catch (_) {
      return 'Ocurrió un error inesperado.';
    }
  }
}
