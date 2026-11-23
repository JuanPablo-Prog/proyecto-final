import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/firebase/email_auth.dart';
import 'package:flutter_application_1/firebase/social_auth.dart';

/// (Se llama SessionProvider para no chocar con `AuthProvider` de firebase_auth.)
/// Usa EmailAuth y SocialAuth (carpeta firebase/) para hablar con Firebase Auth.
/// Autenticación: correo/contraseña + Google + GitHub, verificación de correo,
/// recuperación de contraseña y foto de perfil (solo editable con correo).
class SessionProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmailAuth _email = EmailAuth();
  final SocialAuth _social = SocialAuth();
  StreamSubscription<User?>? _sub;

  // Foto de perfil de cuentas por correo: se guarda reducida (base64) en
  // Realtime Database (users/{uid}/photoB64), sin necesidad de Firebase Storage.
  StreamSubscription<DatabaseEvent>? _photoSub;
  String? _photoUid;
  Uint8List? photoBytes;

  User? _user;
  bool initialized = false;
  bool busy = false;

  // Reenvío de correo con enfriamiento para evitar abusos.
  int resendCooldown = 0;
  Timer? _timer;

  SessionProvider() {
    _sub = _auth.userChanges().listen((u) {
      _user = u;
      initialized = true;
      _bindPhoto(u?.uid);
      if (u != null) _syncProfile(u);
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String get displayName => _user?.displayName?.trim().isNotEmpty == true
      ? _user!.displayName!
      : (_user?.email?.split('@').first ?? 'Viajero');
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;

  List<String> get providerIds =>
      _user?.providerData.map((p) => p.providerId).toList() ?? [];
  bool get isPasswordUser => providerIds.contains('password');

  /// Solo las cuentas de correo exigen verificación previa al acceso.
  bool get needsVerification => isPasswordUser && !(_user?.emailVerified ?? false);

  /// Regla del proyecto: solo cuentas por correo pueden editar su foto.
  bool get canEditPhoto => isPasswordUser;

  String providerLabel() {
    if (providerIds.contains('google.com')) return 'Google';
    if (providerIds.contains('github.com')) return 'GitHub';
    return 'Correo y contraseña';
  }

  // ---------------------------------------------------------------- acciones
  /// Marca `busy` mientras corre la acción; devuelve null (ok) o el mensaje de error.
  Future<String?> _run(Future<String?> Function() action) async {
    busy = true;
    notifyListeners();
    try {
      return await action();
    } catch (_) {
      return 'Ocurrió un error inesperado. Intenta de nuevo.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String?> signIn(String email, String password) =>
      _run(() => _email.m_loginUser(user: email, pass: password));

  Future<String?> register(String name, String email, String password) => _run(() async {
        final err = await _email.m_creaUsuario(name: name, user: email, pass: password);
        if (err == null) {
          _user = _auth.currentUser;
          _startCooldown();
        }
        return err;
      });

  Future<String?> signInWithGoogle() => _run(_social.m_loginGoogle);
  Future<String?> signInWithGithub() => _run(_social.m_loginGithub);

  Future<String?> sendPasswordReset(String email) =>
      _run(() => _email.m_recuperaPass(email));

  Future<String?> resendVerification() async {
    if (resendCooldown > 0) return 'Espera $resendCooldown s para reenviar';
    return _run(() async {
      final err = await _email.m_reenviaVerificacion();
      if (err == null) _startCooldown();
      return err;
    });
  }

  /// Vuelve a consultar el estado del usuario (¿ya verificó su correo?).
  Future<bool> refreshVerification() async {
    _user = await _email.m_recargaUsuario();
    notifyListeners();
    return !needsVerification;
  }

  Future<void> signOut() => _auth.signOut();

  // ------------------------------------------------------------ foto perfil
  Future<String?> updatePhoto(Uint8List bytes) async {
    if (!canEditPhoto) return 'Tu foto proviene de ${providerLabel()} y no se puede editar aquí.';
    final u = _auth.currentUser;
    if (u == null) return 'Sesión no válida';
    if (bytes.length > 150 * 1024) return 'La imagen es muy pesada. Elige otra.';
    return _run(() async {
      await FirebaseDatabase.instance
          .ref('users/${u.uid}/photoB64')
          .set(base64Encode(bytes));
      return null; // el stream de _bindPhoto actualiza el avatar en toda la app
    });
  }

  void _bindPhoto(String? uid) {
    if (uid == _photoUid) return;
    _photoUid = uid;
    _photoSub?.cancel();
    photoBytes = null;
    if (uid == null) return;
    _photoSub = FirebaseDatabase.instance.ref('users/$uid/photoB64').onValue.listen((e) {
      final v = e.snapshot.value;
      try {
        photoBytes = (v is String && v.isNotEmpty) ? base64Decode(v) : null;
      } catch (_) {
        photoBytes = null;
      }
      notifyListeners();
    }, onError: (_) {});
  }

  // ---------------------------------------------------------------- helpers
  void _startCooldown() {
    resendCooldown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      resendCooldown--;
      if (resendCooldown <= 0) t.cancel();
      notifyListeners();
    });
  }

  Future<void> _syncProfile(User u) async {
    try {
      await FirebaseDatabase.instance.ref('users/${u.uid}').update({
        'name': u.displayName ?? '',
        'email': u.email ?? '',
        'photoUrl': u.photoURL ?? '',
        'lastLogin': ServerValue.timestamp,
      });
    } catch (_) {/* sin conexión: se ignora */}
  }

  @override
  void dispose() {
    _sub?.cancel();
    _photoSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
