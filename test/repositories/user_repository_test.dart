import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiendita/tiendita.dart';

class MockFakeStoreApiService extends Mock implements FakeStoreApiService {}

void main() {
  late MockFakeStoreApiService mockApiService;
  late UserRepository repository;

  const testAddress = Address(
    city: 'kilcoole',
    street: 'new road',
    number: 7682,
    zipcode: '12926-3874',
    geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
  );

  const testName = Name(firstname: 'john', lastname: 'doe');

  const testUsers = [
    User(
      id: 1,
      email: 'john@gmail.com',
      username: 'johnd',
      password: 'm38rmF\$',
      name: testName,
      address: testAddress,
      phone: '1-570-236-7033',
    ),
    User(
      id: 2,
      email: 'jane@gmail.com',
      username: 'janed',
      password: 'password123',
      name: Name(firstname: 'jane', lastname: 'doe'),
      address: testAddress,
      phone: '1-570-236-7034',
    ),
  ];

  setUp(() {
    mockApiService = MockFakeStoreApiService();
    repository = UserRepository(apiService: mockApiService);
  });

  setUpAll(() {
    registerFallbackValue(testName);
    registerFallbackValue(testAddress);
  });

  group('getUsers', () {
    test('returns Ok with users on success', () async {
      when(() => mockApiService.getUsers(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => testUsers);

      final result = await repository.getUsers();

      expect(result, isA<Ok<List<User>>>());
      expect(result.asOk.value, testUsers);
      verify(() => mockApiService.getUsers()).called(1);
    });

    test('returns Error on TienditaException', () async {
      when(() => mockApiService.getUsers(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenThrow(const NetworkException('No connection'));

      final result = await repository.getUsers();

      expect(result, isA<Error<List<User>>>());
      expect(result.asError.error, isA<NetworkException>());
    });

    test('caches users after first fetch', () async {
      when(() => mockApiService.getUsers(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => testUsers);

      await repository.getUsers();
      await repository.getUsers();

      verify(() => mockApiService.getUsers()).called(1);
    });

    test('bypasses cache with forceRefresh', () async {
      when(() => mockApiService.getUsers(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => testUsers);

      await repository.getUsers();
      await repository.getUsers(forceRefresh: true);

      verify(() => mockApiService.getUsers()).called(2);
    });

    test('passes limit and sort parameters', () async {
      when(() => mockApiService.getUsers(limit: 5, sort: 'desc'))
          .thenAnswer((_) async => testUsers);

      await repository.getUsers(limit: 5, sort: 'desc');

      verify(() => mockApiService.getUsers(limit: 5, sort: 'desc')).called(1);
    });

    test('does not cache when limit or sort is specified', () async {
      when(() => mockApiService.getUsers(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => testUsers);

      await repository.getUsers(limit: 5);
      await repository.getUsers(limit: 5);

      verify(() => mockApiService.getUsers(limit: 5)).called(2);
    });
  });

  group('getUser', () {
    test('returns Ok with user on success', () async {
      when(() => mockApiService.getUser(1))
          .thenAnswer((_) async => testUsers[0]);

      final result = await repository.getUser(1);

      expect(result, isA<Ok<User>>());
      expect(result.asOk.value.id, 1);
    });

    test('returns Error on NotFoundException', () async {
      when(() => mockApiService.getUser(999))
          .thenThrow(const NotFoundException('User not found'));

      final result = await repository.getUser(999);

      expect(result, isA<Error<User>>());
      expect(result.asError.error, isA<NotFoundException>());
    });

    test('caches individual users', () async {
      when(() => mockApiService.getUser(1))
          .thenAnswer((_) async => testUsers[0]);

      await repository.getUser(1);
      await repository.getUser(1);

      verify(() => mockApiService.getUser(1)).called(1);
    });

    test('bypasses cache with forceRefresh', () async {
      when(() => mockApiService.getUser(1))
          .thenAnswer((_) async => testUsers[0]);

      await repository.getUser(1);
      await repository.getUser(1, forceRefresh: true);

      verify(() => mockApiService.getUser(1)).called(2);
    });
  });

  group('addUser', () {
    test('returns Ok with created user', () async {
      const newUser = User(
        id: 11,
        email: 'new@example.com',
        username: 'newuser',
        password: 'secret',
        name: testName,
        address: testAddress,
        phone: '555-1234',
      );

      when(() => mockApiService.addUser(
            email: 'new@example.com',
            username: 'newuser',
            password: 'secret',
            name: any(named: 'name'),
            address: any(named: 'address'),
            phone: '555-1234',
          )).thenAnswer((_) async => newUser);

      final result = await repository.addUser(
        email: 'new@example.com',
        username: 'newuser',
        password: 'secret',
        name: testName,
        address: testAddress,
        phone: '555-1234',
      );

      expect(result, isA<Ok<User>>());
      expect(result.asOk.value.id, 11);
    });

    test('invalidates list cache after add', () async {
      when(() => mockApiService.getUsers(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => testUsers);

      const newUser = User(
        id: 11,
        email: 'new@example.com',
        username: 'newuser',
        password: 'secret',
        name: testName,
        address: testAddress,
        phone: '555-1234',
      );

      when(() => mockApiService.addUser(
            email: any(named: 'email'),
            username: any(named: 'username'),
            password: any(named: 'password'),
            name: any(named: 'name'),
            address: any(named: 'address'),
            phone: any(named: 'phone'),
          )).thenAnswer((_) async => newUser);

      await repository.getUsers();
      await repository.addUser(
        email: 'new@example.com',
        username: 'newuser',
        password: 'secret',
        name: testName,
        address: testAddress,
        phone: '555-1234',
      );
      await repository.getUsers();

      verify(() => mockApiService.getUsers()).called(2);
    });
  });

  group('updateUser', () {
    test('returns Ok with updated user', () async {
      const updatedUser = User(
        id: 1,
        email: 'updated@example.com',
        username: 'johnd',
        password: 'newpassword',
        name: testName,
        address: testAddress,
        phone: '555-9999',
      );

      when(() => mockApiService.updateUser(
            userId: 1,
            email: 'updated@example.com',
            username: 'johnd',
            password: 'newpassword',
            name: any(named: 'name'),
            address: any(named: 'address'),
            phone: '555-9999',
          )).thenAnswer((_) async => updatedUser);

      final result = await repository.updateUser(
        userId: 1,
        email: 'updated@example.com',
        username: 'johnd',
        password: 'newpassword',
        name: testName,
        address: testAddress,
        phone: '555-9999',
      );

      expect(result, isA<Ok<User>>());
      expect(result.asOk.value.email, 'updated@example.com');
    });

    test('updates cache after update', () async {
      const updatedUser = User(
        id: 1,
        email: 'updated@example.com',
        username: 'johnd',
        password: 'newpassword',
        name: testName,
        address: testAddress,
        phone: '555-9999',
      );

      when(() => mockApiService.getUser(1))
          .thenAnswer((_) async => testUsers[0]);
      when(() => mockApiService.updateUser(
            userId: 1,
            email: any(named: 'email'),
            username: any(named: 'username'),
            password: any(named: 'password'),
            name: any(named: 'name'),
            address: any(named: 'address'),
            phone: any(named: 'phone'),
          )).thenAnswer((_) async => updatedUser);

      await repository.getUser(1);
      await repository.updateUser(
        userId: 1,
        email: 'updated@example.com',
        username: 'johnd',
        password: 'newpassword',
        name: testName,
        address: testAddress,
        phone: '555-9999',
      );

      // Should return cached updated user
      final result = await repository.getUser(1);

      expect(result.asOk.value.email, 'updated@example.com');
      verify(() => mockApiService.getUser(1)).called(1);
    });
  });

  group('patchUser', () {
    test('returns Ok with patched user', () async {
      const patchedUser = User(
        id: 1,
        email: 'patched@example.com',
        username: 'johnd',
        password: 'm38rmF\$',
        name: testName,
        address: testAddress,
        phone: '1-570-236-7033',
      );

      when(() => mockApiService.patchUser(
            userId: 1,
            email: 'patched@example.com',
            username: null,
            password: null,
            name: null,
            address: null,
            phone: null,
          )).thenAnswer((_) async => patchedUser);

      final result = await repository.patchUser(
        userId: 1,
        email: 'patched@example.com',
      );

      expect(result, isA<Ok<User>>());
      expect(result.asOk.value.email, 'patched@example.com');
    });
  });

  group('deleteUser', () {
    test('returns Ok on successful delete', () async {
      when(() => mockApiService.deleteUser(1)).thenAnswer((_) async {});

      final result = await repository.deleteUser(1);

      expect(result, isA<Ok<void>>());
    });

    test('removes user from cache after delete', () async {
      when(() => mockApiService.getUser(1))
          .thenAnswer((_) async => testUsers[0]);
      when(() => mockApiService.deleteUser(1)).thenAnswer((_) async {});

      await repository.getUser(1);
      await repository.deleteUser(1);
      await repository.getUser(1);

      verify(() => mockApiService.getUser(1)).called(2);
    });
  });

  group('clearCache', () {
    test('clears list cache', () async {
      when(() => mockApiService.getUsers(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => testUsers);

      await repository.getUsers();

      repository.clearCache();

      await repository.getUsers();

      verify(() => mockApiService.getUsers()).called(2);
    });

    test('clears individual user cache', () async {
      when(() => mockApiService.getUser(1))
          .thenAnswer((_) async => testUsers[0]);

      await repository.getUser(1);

      repository.clearCache();

      await repository.getUser(1);

      verify(() => mockApiService.getUser(1)).called(2);
    });
  });
}
