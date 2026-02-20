import 'package:flutter_test/flutter_test.dart';
import 'package:tiendita/tiendita.dart';

void main() {
  group('Tiendita Package', () {
    test('exports Product model', () {
      const product = Product(
        id: 1,
        title: 'Test',
        price: 10.0,
        description: 'Desc',
        category: 'test',
        image: 'url',
        rating: Rating(rate: 4.0, count: 10),
      );

      expect(product, isA<Product>());
    });

    test('exports Cart model', () {
      final cart = Cart(
        id: 1,
        userId: 1,
        date: DateTime.now(),
        products: const [],
      );

      expect(cart, isA<Cart>());
    });

    test('exports Result type', () {
      final ok = Result.ok(42);
      final error = Result<int>.error(Exception('test'));

      expect(ok, isA<Ok<int>>());
      expect(error, isA<Error<int>>());
    });

    test('exports exceptions', () {
      const network = NetworkException('test');
      const server = ServerException('test', statusCode: 500);
      const notFound = NotFoundException('test');

      expect(network, isA<TienditaException>());
      expect(server, isA<TienditaException>());
      expect(notFound, isA<TienditaException>());
    });

    test('exports ProductRepository', () {
      final repo = ProductRepository();

      expect(repo, isA<ProductRepository>());
    });

    test('exports CartRepository', () {
      final repo = CartRepository();

      expect(repo, isA<CartRepository>());
    });

    test('exports FakeStoreApiService', () {
      final service = FakeStoreApiService();

      expect(service, isA<FakeStoreApiService>());
    });
  });
}
