import 'package:flutter_test/flutter_test.dart';
import 'package:tiendita/tiendita.dart';

void main() {
  group('TienditaException', () {
    test('creates with message', () {
      const exception = TienditaException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.statusCode, isNull);
    });

    test('creates with message and statusCode', () {
      const exception = TienditaException('Server error', statusCode: 500);

      expect(exception.message, 'Server error');
      expect(exception.statusCode, 500);
    });

    test('toString returns formatted message', () {
      const exception = TienditaException('Error', statusCode: 400);

      expect(exception.toString(), contains('TienditaException'));
      expect(exception.toString(), contains('Error'));
      expect(exception.toString(), contains('400'));
    });
  });

  group('NetworkException', () {
    test('is a TienditaException', () {
      const exception = NetworkException('No internet');

      expect(exception, isA<TienditaException>());
    });

    test('stores message and statusCode', () {
      const exception = NetworkException('Timeout', statusCode: 408);

      expect(exception.message, 'Timeout');
      expect(exception.statusCode, 408);
    });
  });

  group('ServerException', () {
    test('is a TienditaException', () {
      const exception = ServerException('Internal error', statusCode: 500);

      expect(exception, isA<TienditaException>());
      expect(exception.statusCode, 500);
    });
  });

  group('ParseException', () {
    test('is a TienditaException', () {
      const exception = ParseException('Invalid JSON');

      expect(exception, isA<TienditaException>());
    });

    test('has null statusCode', () {
      const exception = ParseException('Parse failed');

      expect(exception.statusCode, isNull);
    });
  });

  group('NotFoundException', () {
    test('is a TienditaException', () {
      const exception = NotFoundException('Product not found');

      expect(exception, isA<TienditaException>());
    });

    test('has statusCode 404', () {
      const exception = NotFoundException('Not found');

      expect(exception.statusCode, 404);
    });
  });

  group('AuthException', () {
    test('is a TienditaException', () {
      const exception = AuthException('Unauthorized');

      expect(exception, isA<TienditaException>());
    });

    test('has statusCode 401', () {
      const exception = AuthException('Invalid token');

      expect(exception.statusCode, 401);
    });
  });
}
