/// Validadores de formularios (correo, contraseña y tarjeta).
class Validators {
  static String? required(String? v, [String label = 'Este campo']) =>
      (v == null || v.trim().isEmpty) ? '$label es obligatorio' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    final ok = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(v.trim());
    return ok ? null : 'Correo no válido';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[0-9]').hasMatch(v) || !RegExp(r'[A-Za-z]').hasMatch(v)) {
      return 'Usa letras y números';
    }
    return null;
  }

  // ---------- Tarjeta ----------
  static String digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  static bool luhn(String number) {
    final d = digits(number);
    if (d.length < 13) return false;
    var sum = 0;
    var alt = false;
    for (var i = d.length - 1; i >= 0; i--) {
      var n = int.parse(d[i]);
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  static String? cardNumber(String? v) {
    final d = digits(v ?? '');
    if (d.isEmpty) return 'Ingresa el número de tarjeta';
    if (d.length < 15 || d.length > 16) return 'Número incompleto';
    return luhn(d) ? null : 'Número de tarjeta inválido';
  }

  static String? expiry(String? v) {
    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(v ?? '');
    if (m == null) return 'Formato MM/AA';
    final month = int.parse(m.group(1)!);
    final year = 2000 + int.parse(m.group(2)!);
    if (month < 1 || month > 12) return 'Mes inválido';
    final now = DateTime.now();
    final lastDay = DateTime(year, month + 1, 0, 23, 59);
    if (lastDay.isBefore(now)) return 'Tarjeta vencida';
    return null;
  }

  static String? cvv(String? v, {int length = 3}) {
    final d = digits(v ?? '');
    return d.length == length ? null : 'CVV de $length dígitos';
  }
}
