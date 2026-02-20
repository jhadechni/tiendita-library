import 'package:flutter_test/flutter_test.dart';
import 'package:tiendita/tiendita.dart';

void main() {
  group('Result', () {
    group('Ok', () {
      test('Result.ok creates Ok instance', () {
        final result = Result.ok(42);

        expect(result, isA<Ok<int>>());
        expect(result.asOk.value, 42);
      });

      test('Ok contains correct value', () {
        const ok = Ok('test value');

        expect(ok.value, 'test value');
      });

      test('toString returns readable format', () {
        const ok = Ok(123);

        expect(ok.toString(), 'Result<int>.ok(123)');
      });

      test('asOk returns itself', () {
        final result = Result.ok('hello');

        expect(result.asOk, isA<Ok<String>>());
        expect(result.asOk.value, 'hello');
      });
    });

    group('Error', () {
      test('Result.error creates Error instance', () {
        final exception = Exception('test error');
        final result = Result<int>.error(exception);

        expect(result, isA<Error<int>>());
        expect(result.asError.error, exception);
      });

      test('Error contains correct exception', () {
        final exception = Exception('failed');
        final error = Error<String>(exception);

        expect(error.error, exception);
      });

      test('toString returns readable format', () {
        final exception = Exception('something went wrong');
        final error = Error<int>(exception);

        expect(error.toString(), contains('Result<int>.error'));
        expect(error.toString(), contains('something went wrong'));
      });

      test('asError returns itself', () {
        final exception = Exception('error');
        final result = Result<int>.error(exception);

        expect(result.asError, isA<Error<int>>());
        expect(result.asError.error, exception);
      });
    });

    group('pattern matching', () {
      test('switch on Ok works correctly', () {
        final result = Result.ok(100);
        String output = '';

        switch (result) {
          case Ok(:final value):
            output = 'Value: $value';
          case Error(:final error):
            output = 'Error: $error';
        }

        expect(output, 'Value: 100');
      });

      test('switch on Error works correctly', () {
        final result = Result<int>.error(Exception('failed'));
        String output = '';

        switch (result) {
          case Ok(:final value):
            output = 'Value: $value';
          case Error(:final error):
            output = 'Error: $error';
        }

        expect(output, contains('Error:'));
        expect(output, contains('failed'));
      });
    });
  });
}
