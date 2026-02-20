import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiendita/tiendita.dart';

class MockFakeStoreApiService extends Mock implements FakeStoreApiService {}

void main() {
  late MockFakeStoreApiService mockApiService;
  late AuthRepository repository;

  const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test-payload.signature';
  const testLoginResponse = LoginResponse(token: testToken);

  setUp(() {
    mockApiService = MockFakeStoreApiService();
    repository = AuthRepository(apiService: mockApiService);
  });

  group('initial state', () {
    test('currentToken is null initially', () {
      expect(repository.currentToken, isNull);
    });

    test('isAuthenticated is false initially', () {
      expect(repository.isAuthenticated, isFalse);
    });
  });

  group('login', () {
    test('returns Ok with LoginResponse on success', () async {
      when(() => mockApiService.login(
            username: 'johnd',
            password: 'm38rmF\$',
          )).thenAnswer((_) async => testLoginResponse);

      final result = await repository.login(
        username: 'johnd',
        password: 'm38rmF\$',
      );

      expect(result, isA<Ok<LoginResponse>>());
      expect(result.asOk.value.token, testToken);
    });

    test('caches token after successful login', () async {
      when(() => mockApiService.login(
            username: 'johnd',
            password: 'm38rmF\$',
          )).thenAnswer((_) async => testLoginResponse);

      await repository.login(
        username: 'johnd',
        password: 'm38rmF\$',
      );

      expect(repository.currentToken, testToken);
      expect(repository.isAuthenticated, isTrue);
    });

    test('returns Error on AuthException', () async {
      when(() => mockApiService.login(
            username: 'invalid',
            password: 'wrong',
          )).thenThrow(const AuthException('Invalid credentials'));

      final result = await repository.login(
        username: 'invalid',
        password: 'wrong',
      );

      expect(result, isA<Error<LoginResponse>>());
      expect(result.asError.error, isA<AuthException>());
    });

    test('does not cache token on failed login', () async {
      when(() => mockApiService.login(
            username: 'invalid',
            password: 'wrong',
          )).thenThrow(const AuthException('Invalid credentials'));

      await repository.login(
        username: 'invalid',
        password: 'wrong',
      );

      expect(repository.currentToken, isNull);
      expect(repository.isAuthenticated, isFalse);
    });

    test('returns Error on NetworkException', () async {
      when(() => mockApiService.login(
            username: 'johnd',
            password: 'm38rmF\$',
          )).thenThrow(const NetworkException('No connection'));

      final result = await repository.login(
        username: 'johnd',
        password: 'm38rmF\$',
      );

      expect(result, isA<Error<LoginResponse>>());
      expect(result.asError.error, isA<NetworkException>());
    });

    test('returns Error on generic exception', () async {
      when(() => mockApiService.login(
            username: 'johnd',
            password: 'm38rmF\$',
          )).thenThrow(Exception('Unknown error'));

      final result = await repository.login(
        username: 'johnd',
        password: 'm38rmF\$',
      );

      expect(result, isA<Error<LoginResponse>>());
      expect(result.asError.error, isA<TienditaException>());
    });
  });

  group('logout', () {
    test('clears cached token', () async {
      when(() => mockApiService.login(
            username: 'johnd',
            password: 'm38rmF\$',
          )).thenAnswer((_) async => testLoginResponse);

      await repository.login(
        username: 'johnd',
        password: 'm38rmF\$',
      );
      expect(repository.isAuthenticated, isTrue);

      repository.logout();

      expect(repository.currentToken, isNull);
      expect(repository.isAuthenticated, isFalse);
    });
  });

  group('clearCache', () {
    test('clears cached token', () async {
      when(() => mockApiService.login(
            username: 'johnd',
            password: 'm38rmF\$',
          )).thenAnswer((_) async => testLoginResponse);

      await repository.login(
        username: 'johnd',
        password: 'm38rmF\$',
      );
      expect(repository.isAuthenticated, isTrue);

      repository.clearCache();

      expect(repository.currentToken, isNull);
      expect(repository.isAuthenticated, isFalse);
    });
  });
}
