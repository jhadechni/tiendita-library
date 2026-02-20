import 'package:flutter_test/flutter_test.dart';
import 'package:tiendita/tiendita.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson creates LoginResponse correctly', () {
      final json = {
        'token':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInVzZXIiOiJqb2huZCIsImlhdCI6MTcxNjAwMDAwMH0.abc123',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.token, startsWith('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'));
    });

    test('toJson returns correct map', () {
      const response = LoginResponse(token: 'test-token-12345');

      final json = response.toJson();

      expect(json['token'], 'test-token-12345');
    });

    test('toString returns truncated token for long tokens', () {
      const response = LoginResponse(
        token:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInVzZXIiOiJqb2huZCIsImlhdCI6MTcxNjAwMDAwMH0.abc123',
      );

      final str = response.toString();

      expect(str, contains('LoginResponse'));
      expect(str, contains('...'));
      expect(str.length, lessThan(100));
    });

    test('toString handles short tokens', () {
      const response = LoginResponse(token: 'short');

      final str = response.toString();

      expect(str, contains('LoginResponse'));
      expect(str, contains('short'));
    });
  });
}
