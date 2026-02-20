import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiendita/tiendita.dart';

class MockFakeStoreApiService extends Mock implements FakeStoreApiService {}

void main() {
  late MockFakeStoreApiService mockApiService;
  late ProductRepository repository;

  const testProducts = [
    Product(
      id: 1,
      title: 'Product 1',
      price: 10.0,
      description: 'Description 1',
      category: 'electronics',
      image: 'https://example.com/1.jpg',
      rating: Rating(rate: 4.5, count: 100),
    ),
    Product(
      id: 2,
      title: 'Product 2',
      price: 20.0,
      description: 'Description 2',
      category: 'clothing',
      image: 'https://example.com/2.jpg',
      rating: Rating(rate: 3.8, count: 50),
    ),
  ];

  const testCategories = ['electronics', 'clothing', 'jewelery'];

  setUp(() {
    mockApiService = MockFakeStoreApiService();
    repository = ProductRepository(apiService: mockApiService);
  });

  group('getProducts', () {
    test('returns Ok with products on success', () async {
      when(() => mockApiService.getProducts(limit: any(named: 'limit'), sort: any(named: 'sort')))
          .thenAnswer((_) async => testProducts);

      final result = await repository.getProducts();

      expect(result, isA<Ok<List<Product>>>());
      expect(result.asOk.value, testProducts);
      verify(() => mockApiService.getProducts()).called(1);
    });

    test('returns Error on TienditaException', () async {
      when(() => mockApiService.getProducts(limit: any(named: 'limit'), sort: any(named: 'sort')))
          .thenThrow(const NetworkException('No connection'));

      final result = await repository.getProducts();

      expect(result, isA<Error<List<Product>>>());
      expect(result.asError.error, isA<NetworkException>());
    });

    test('caches products after first fetch', () async {
      when(() => mockApiService.getProducts(limit: any(named: 'limit'), sort: any(named: 'sort')))
          .thenAnswer((_) async => testProducts);

      await repository.getProducts();
      await repository.getProducts();

      verify(() => mockApiService.getProducts()).called(1);
    });

    test('bypasses cache with forceRefresh', () async {
      when(() => mockApiService.getProducts(limit: any(named: 'limit'), sort: any(named: 'sort')))
          .thenAnswer((_) async => testProducts);

      await repository.getProducts();
      await repository.getProducts(forceRefresh: true);

      verify(() => mockApiService.getProducts()).called(2);
    });

    test('passes limit and sort parameters', () async {
      when(() => mockApiService.getProducts(limit: 5, sort: 'desc'))
          .thenAnswer((_) async => testProducts);

      await repository.getProducts(limit: 5, sort: 'desc');

      verify(() => mockApiService.getProducts(limit: 5, sort: 'desc')).called(1);
    });
  });

  group('getProduct', () {
    test('returns Ok with product on success', () async {
      when(() => mockApiService.getProduct(1))
          .thenAnswer((_) async => testProducts[0]);

      final result = await repository.getProduct(1);

      expect(result, isA<Ok<Product>>());
      expect(result.asOk.value.id, 1);
    });

    test('returns Error on NotFoundException', () async {
      when(() => mockApiService.getProduct(999))
          .thenThrow(const NotFoundException('Product not found'));

      final result = await repository.getProduct(999);

      expect(result, isA<Error<Product>>());
      expect(result.asError.error, isA<NotFoundException>());
    });

    test('caches individual products', () async {
      when(() => mockApiService.getProduct(1))
          .thenAnswer((_) async => testProducts[0]);

      await repository.getProduct(1);
      await repository.getProduct(1);

      verify(() => mockApiService.getProduct(1)).called(1);
    });
  });

  group('getCategories', () {
    test('returns Ok with categories on success', () async {
      when(() => mockApiService.getCategories())
          .thenAnswer((_) async => testCategories);

      final result = await repository.getCategories();

      expect(result, isA<Ok<List<String>>>());
      expect(result.asOk.value, testCategories);
    });

    test('caches categories', () async {
      when(() => mockApiService.getCategories())
          .thenAnswer((_) async => testCategories);

      await repository.getCategories();
      await repository.getCategories();

      verify(() => mockApiService.getCategories()).called(1);
    });
  });

  group('getProductsByCategory', () {
    test('returns filtered products', () async {
      when(() => mockApiService.getProductsByCategory('electronics'))
          .thenAnswer((_) async => [testProducts[0]]);

      final result = await repository.getProductsByCategory('electronics');

      expect(result, isA<Ok<List<Product>>>());
      expect(result.asOk.value.length, 1);
      expect(result.asOk.value[0].category, 'electronics');
    });
  });

  group('addProduct', () {
    test('returns Ok with created product', () async {
      const newProduct = Product(
        id: 21,
        title: 'New Product',
        price: 29.99,
        description: 'A new product',
        category: 'electronics',
        image: 'https://example.com/new.jpg',
        rating: Rating(rate: 0.0, count: 0),
      );

      when(() => mockApiService.addProduct(
            title: 'New Product',
            price: 29.99,
            description: 'A new product',
            category: 'electronics',
            image: 'https://example.com/new.jpg',
          )).thenAnswer((_) async => newProduct);

      final result = await repository.addProduct(
        title: 'New Product',
        price: 29.99,
        description: 'A new product',
        category: 'electronics',
        image: 'https://example.com/new.jpg',
      );

      expect(result, isA<Ok<Product>>());
      expect(result.asOk.value.id, 21);
      expect(result.asOk.value.title, 'New Product');
    });

    test('invalidates list cache after add', () async {
      when(() => mockApiService.getProducts(
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => testProducts);

      const newProduct = Product(
        id: 21,
        title: 'New Product',
        price: 29.99,
        description: 'A new product',
        category: 'electronics',
        image: 'https://example.com/new.jpg',
        rating: Rating(rate: 0.0, count: 0),
      );

      when(() => mockApiService.addProduct(
            title: any(named: 'title'),
            price: any(named: 'price'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            image: any(named: 'image'),
          )).thenAnswer((_) async => newProduct);

      await repository.getProducts();
      await repository.addProduct(
        title: 'New Product',
        price: 29.99,
        description: 'A new product',
        category: 'electronics',
        image: 'https://example.com/new.jpg',
      );
      await repository.getProducts();

      verify(() => mockApiService.getProducts()).called(2);
    });

    test('returns Error on failure', () async {
      when(() => mockApiService.addProduct(
            title: any(named: 'title'),
            price: any(named: 'price'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            image: any(named: 'image'),
          )).thenThrow(const ServerException('Server error', statusCode: 500));

      final result = await repository.addProduct(
        title: 'New Product',
        price: 29.99,
        description: 'A new product',
        category: 'electronics',
        image: 'https://example.com/new.jpg',
      );

      expect(result, isA<Error<Product>>());
      expect(result.asError.error, isA<ServerException>());
    });
  });

  group('updateProduct', () {
    test('returns Ok with updated product', () async {
      const updatedProduct = Product(
        id: 1,
        title: 'Updated Product',
        price: 39.99,
        description: 'Updated description',
        category: 'electronics',
        image: 'https://example.com/updated.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );

      when(() => mockApiService.updateProduct(
            productId: 1,
            title: 'Updated Product',
            price: 39.99,
            description: 'Updated description',
            category: 'electronics',
            image: 'https://example.com/updated.jpg',
          )).thenAnswer((_) async => updatedProduct);

      final result = await repository.updateProduct(
        productId: 1,
        title: 'Updated Product',
        price: 39.99,
        description: 'Updated description',
        category: 'electronics',
        image: 'https://example.com/updated.jpg',
      );

      expect(result, isA<Ok<Product>>());
      expect(result.asOk.value.title, 'Updated Product');
      expect(result.asOk.value.price, 39.99);
    });

    test('updates cache after update', () async {
      const updatedProduct = Product(
        id: 1,
        title: 'Updated Product',
        price: 39.99,
        description: 'Updated description',
        category: 'electronics',
        image: 'https://example.com/updated.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );

      when(() => mockApiService.getProduct(1))
          .thenAnswer((_) async => testProducts[0]);
      when(() => mockApiService.updateProduct(
            productId: 1,
            title: any(named: 'title'),
            price: any(named: 'price'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            image: any(named: 'image'),
          )).thenAnswer((_) async => updatedProduct);

      await repository.getProduct(1);
      await repository.updateProduct(
        productId: 1,
        title: 'Updated Product',
        price: 39.99,
        description: 'Updated description',
        category: 'electronics',
        image: 'https://example.com/updated.jpg',
      );

      final result = await repository.getProduct(1);

      expect(result.asOk.value.title, 'Updated Product');
      verify(() => mockApiService.getProduct(1)).called(1);
    });
  });

  group('patchProduct', () {
    test('returns Ok with patched product', () async {
      const patchedProduct = Product(
        id: 1,
        title: 'Product 1',
        price: 49.99,
        description: 'Description 1',
        category: 'electronics',
        image: 'https://example.com/1.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );

      when(() => mockApiService.patchProduct(
            productId: 1,
            title: null,
            price: 49.99,
            description: null,
            category: null,
            image: null,
          )).thenAnswer((_) async => patchedProduct);

      final result = await repository.patchProduct(
        productId: 1,
        price: 49.99,
      );

      expect(result, isA<Ok<Product>>());
      expect(result.asOk.value.price, 49.99);
    });

    test('returns Error on failure', () async {
      when(() => mockApiService.patchProduct(
            productId: any(named: 'productId'),
            title: any(named: 'title'),
            price: any(named: 'price'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            image: any(named: 'image'),
          )).thenThrow(const NotFoundException('Product not found'));

      final result = await repository.patchProduct(
        productId: 999,
        price: 49.99,
      );

      expect(result, isA<Error<Product>>());
      expect(result.asError.error, isA<NotFoundException>());
    });
  });

  group('deleteProduct', () {
    test('returns Ok on successful delete', () async {
      when(() => mockApiService.deleteProduct(1)).thenAnswer((_) async {});

      final result = await repository.deleteProduct(1);

      expect(result, isA<Ok<void>>());
    });

    test('removes product from cache after delete', () async {
      when(() => mockApiService.getProduct(1))
          .thenAnswer((_) async => testProducts[0]);
      when(() => mockApiService.deleteProduct(1)).thenAnswer((_) async {});

      await repository.getProduct(1);
      await repository.deleteProduct(1);
      await repository.getProduct(1);

      verify(() => mockApiService.getProduct(1)).called(2);
    });

    test('returns Error on failure', () async {
      when(() => mockApiService.deleteProduct(999))
          .thenThrow(const NotFoundException('Product not found'));

      final result = await repository.deleteProduct(999);

      expect(result, isA<Error<void>>());
      expect(result.asError.error, isA<NotFoundException>());
    });
  });

  group('clearCache', () {
    test('clears all cached data', () async {
      when(() => mockApiService.getProducts(limit: any(named: 'limit'), sort: any(named: 'sort')))
          .thenAnswer((_) async => testProducts);
      when(() => mockApiService.getCategories())
          .thenAnswer((_) async => testCategories);

      await repository.getProducts();
      await repository.getCategories();

      repository.clearCache();

      await repository.getProducts();
      await repository.getCategories();

      verify(() => mockApiService.getProducts()).called(2);
      verify(() => mockApiService.getCategories()).called(2);
    });
  });
}
