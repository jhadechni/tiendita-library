import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiendita/tiendita.dart';

class MockFakeStoreApiService extends Mock implements FakeStoreApiService {}

void main() {
  late MockFakeStoreApiService mockApiService;
  late CartRepository repository;

  final testCarts = [
    Cart(
      id: 1,
      userId: 1,
      date: DateTime(2024, 1, 15),
      products: const [
        CartProduct(productId: 1, quantity: 2),
        CartProduct(productId: 3, quantity: 1),
      ],
    ),
    Cart(
      id: 2,
      userId: 2,
      date: DateTime(2024, 2, 20),
      products: const [
        CartProduct(productId: 5, quantity: 3),
      ],
    ),
  ];

  setUp(() {
    mockApiService = MockFakeStoreApiService();
    repository = CartRepository(apiService: mockApiService);
  });

  setUpAll(() {
    registerFallbackValue(<CartProduct>[]);
  });

  group('getCarts', () {
    test('returns Ok with carts on success', () async {
      when(() => mockApiService.getCarts(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => testCarts);

      final result = await repository.getCarts();

      expect(result, isA<Ok<List<Cart>>>());
      expect(result.asOk.value.length, 2);
    });

    test('returns Error on failure', () async {
      when(() => mockApiService.getCarts(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(const ServerException('Server error', statusCode: 500));

      final result = await repository.getCarts();

      expect(result, isA<Error<List<Cart>>>());
    });
  });

  group('getCart', () {
    test('returns Ok with cart on success', () async {
      when(() => mockApiService.getCart(1))
          .thenAnswer((_) async => testCarts[0]);

      final result = await repository.getCart(1);

      expect(result, isA<Ok<Cart>>());
      expect(result.asOk.value.id, 1);
    });

    test('caches cart after fetch', () async {
      when(() => mockApiService.getCart(1))
          .thenAnswer((_) async => testCarts[0]);

      await repository.getCart(1);
      await repository.getCart(1);

      verify(() => mockApiService.getCart(1)).called(1);
    });

    test('bypasses cache with forceRefresh', () async {
      when(() => mockApiService.getCart(1))
          .thenAnswer((_) async => testCarts[0]);

      await repository.getCart(1);
      await repository.getCart(1, forceRefresh: true);

      verify(() => mockApiService.getCart(1)).called(2);
    });
  });

  group('getUserCarts', () {
    test('returns Ok with user carts', () async {
      when(() => mockApiService.getUserCarts(1))
          .thenAnswer((_) async => [testCarts[0]]);

      final result = await repository.getUserCarts(1);

      expect(result, isA<Ok<List<Cart>>>());
      expect(result.asOk.value.length, 1);
    });

    test('caches user carts', () async {
      when(() => mockApiService.getUserCarts(1))
          .thenAnswer((_) async => [testCarts[0]]);

      await repository.getUserCarts(1);
      await repository.getUserCarts(1);

      verify(() => mockApiService.getUserCarts(1)).called(1);
    });
  });

  group('addCart', () {
    test('returns Ok with created cart', () async {
      final newCart = Cart(
        id: 3,
        userId: 1,
        date: DateTime.now(),
        products: const [CartProduct(productId: 1, quantity: 1)],
      );

      when(() => mockApiService.addCart(
            userId: 1,
            products: any(named: 'products'),
          )).thenAnswer((_) async => newCart);

      final result = await repository.addCart(
        userId: 1,
        products: const [CartProduct(productId: 1, quantity: 1)],
      );

      expect(result, isA<Ok<Cart>>());
      expect(result.asOk.value.id, 3);
    });

    test('invalidates user carts cache after add', () async {
      when(() => mockApiService.getUserCarts(1))
          .thenAnswer((_) async => [testCarts[0]]);

      final newCart = Cart(
        id: 3,
        userId: 1,
        date: DateTime.now(),
        products: const [CartProduct(productId: 1, quantity: 1)],
      );

      when(() => mockApiService.addCart(
            userId: 1,
            products: any(named: 'products'),
          )).thenAnswer((_) async => newCart);

      await repository.getUserCarts(1);
      await repository.addCart(
        userId: 1,
        products: const [CartProduct(productId: 1, quantity: 1)],
      );
      await repository.getUserCarts(1);

      verify(() => mockApiService.getUserCarts(1)).called(2);
    });
  });

  group('updateCart', () {
    test('returns Ok with updated cart', () async {
      final updatedCart = Cart(
        id: 1,
        userId: 1,
        date: DateTime.now(),
        products: const [CartProduct(productId: 1, quantity: 5)],
      );

      when(() => mockApiService.updateCart(
            cartId: 1,
            userId: 1,
            products: any(named: 'products'),
          )).thenAnswer((_) async => updatedCart);

      final result = await repository.updateCart(
        cartId: 1,
        userId: 1,
        products: const [CartProduct(productId: 1, quantity: 5)],
      );

      expect(result, isA<Ok<Cart>>());
      expect(result.asOk.value.products[0].quantity, 5);
    });
  });

  group('deleteCart', () {
    test('returns Ok on successful delete', () async {
      when(() => mockApiService.getCart(1))
          .thenAnswer((_) async => testCarts[0]);
      when(() => mockApiService.deleteCart(1))
          .thenAnswer((_) async {});

      // First cache the cart
      await repository.getCart(1);

      final result = await repository.deleteCart(1);

      expect(result, isA<Ok<void>>());
    });

    test('returns Error on failure', () async {
      when(() => mockApiService.deleteCart(999))
          .thenThrow(const NotFoundException('Cart not found'));

      final result = await repository.deleteCart(999);

      expect(result, isA<Error<void>>());
      expect(result.asError.error, isA<NotFoundException>());
    });
  });

  group('patchCart', () {
    test('returns Ok with patched cart', () async {
      final patchedCart = Cart(
        id: 1,
        userId: 1,
        date: DateTime(2024, 1, 15),
        products: const [CartProduct(productId: 10, quantity: 5)],
      );

      when(() => mockApiService.patchCart(
            cartId: 1,
            userId: null,
            products: any(named: 'products'),
          )).thenAnswer((_) async => patchedCart);

      final result = await repository.patchCart(
        cartId: 1,
        products: const [CartProduct(productId: 10, quantity: 5)],
      );

      expect(result, isA<Ok<Cart>>());
      expect(result.asOk.value.products[0].productId, 10);
      expect(result.asOk.value.products[0].quantity, 5);
    });

    test('invalidates user carts cache for existing cart user', () async {
      when(() => mockApiService.getCart(1))
          .thenAnswer((_) async => testCarts[0]);
      when(() => mockApiService.getUserCarts(1))
          .thenAnswer((_) async => [testCarts[0]]);

      final patchedCart = Cart(
        id: 1,
        userId: 1,
        date: DateTime(2024, 1, 15),
        products: const [CartProduct(productId: 10, quantity: 5)],
      );

      when(() => mockApiService.patchCart(
            cartId: 1,
            userId: any(named: 'userId'),
            products: any(named: 'products'),
          )).thenAnswer((_) async => patchedCart);

      // Cache the cart and user carts
      await repository.getCart(1);
      await repository.getUserCarts(1);

      // Patch the cart
      await repository.patchCart(
        cartId: 1,
        products: const [CartProduct(productId: 10, quantity: 5)],
      );

      // Should fetch user carts again
      await repository.getUserCarts(1);

      verify(() => mockApiService.getUserCarts(1)).called(2);
    });

    test('invalidates cache for new userId when changing user', () async {
      when(() => mockApiService.getUserCarts(1))
          .thenAnswer((_) async => [testCarts[0]]);
      when(() => mockApiService.getUserCarts(2))
          .thenAnswer((_) async => [testCarts[1]]);

      final patchedCart = Cart(
        id: 1,
        userId: 2,
        date: DateTime(2024, 1, 15),
        products: const [CartProduct(productId: 1, quantity: 2)],
      );

      when(() => mockApiService.patchCart(
            cartId: 1,
            userId: 2,
            products: any(named: 'products'),
          )).thenAnswer((_) async => patchedCart);

      // Cache user carts for user 2
      await repository.getUserCarts(2);

      // Patch cart to change user from 1 to 2
      await repository.patchCart(
        cartId: 1,
        userId: 2,
      );

      // Should fetch user 2 carts again
      await repository.getUserCarts(2);

      verify(() => mockApiService.getUserCarts(2)).called(2);
    });

    test('returns Error on failure', () async {
      when(() => mockApiService.patchCart(
            cartId: any(named: 'cartId'),
            userId: any(named: 'userId'),
            products: any(named: 'products'),
          )).thenThrow(const NotFoundException('Cart not found'));

      final result = await repository.patchCart(
        cartId: 999,
        products: const [CartProduct(productId: 1, quantity: 1)],
      );

      expect(result, isA<Error<Cart>>());
      expect(result.asError.error, isA<NotFoundException>());
    });
  });

  group('clearCache', () {
    test('clears all cached data', () async {
      when(() => mockApiService.getCart(1))
          .thenAnswer((_) async => testCarts[0]);
      when(() => mockApiService.getUserCarts(1))
          .thenAnswer((_) async => [testCarts[0]]);

      await repository.getCart(1);
      await repository.getUserCarts(1);

      repository.clearCache();

      await repository.getCart(1);
      await repository.getUserCarts(1);

      verify(() => mockApiService.getCart(1)).called(2);
      verify(() => mockApiService.getUserCarts(1)).called(2);
    });
  });
}
