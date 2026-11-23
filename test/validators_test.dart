import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/components/validators.dart';

void main() {
  test('Luhn valida tarjetas de prueba', () {
    expect(Validators.luhn('4242 4242 4242 4242'), isTrue);
    expect(Validators.luhn('4242 4242 4242 4243'), isFalse);
  });

  test('correo y contraseña', () {
    expect(Validators.email('a@b.com'), isNull);
    expect(Validators.email('mal'), isNotNull);
    expect(Validators.password('abc12345'), isNull);
    expect(Validators.password('corta1'), isNotNull);
  });

  test('vencimiento', () {
    expect(Validators.expiry('01/20'), 'Tarjeta vencida');
    expect(Validators.expiry('13/30'), 'Mes inválido');
    expect(Validators.expiry('12/99'), isNull);
  });
}
