import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiendita/tiendita.dart';

import 'package:tiendita_example/features/products/presentation/viewmodels/product_list_viewmodel.dart';
import 'package:tiendita_example/features/products/presentation/views/product_list_view.dart';

class FakeProductRepository extends ProductRepository {
  FakeProductRepository({
    required this.productsResult,
    required this.categoriesResult,
    this.delay = Duration.zero,
  });

  final Result<List<Product>> productsResult;
  final Result<List<String>> categoriesResult;
  final Duration delay;

  @override
  Future<Result<List<Product>>> getProducts({
    int? limit,
    String? sort,
    bool forceRefresh = false,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return productsResult;
  }

  @override
  Future<Result<List<String>>> getCategories({
    bool forceRefresh = false,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return categoriesResult;
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(String category) async {
    return productsResult;
  }

  @override
  void clearCache() {}
}

void main() {
  group('TienditaExampleApp', () {
    testWidgets('App renders with Tiendita title in AppBar', (
      WidgetTester tester,
    ) async {
      final repository = FakeProductRepository(
        productsResult: const Ok<List<Product>>([]),
        categoriesResult: const Ok<List<String>>([]),
      );

      await tester.pumpWidget(
        MaterialApp(home: _TestableProductListView(repository: repository)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tiendita'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      final repository = FakeProductRepository(
        productsResult: const Ok<List<Product>>([]),
        categoriesResult: const Ok<List<String>>([]),
        delay: const Duration(milliseconds: 150),
      );

      await tester.pumpWidget(
        MaterialApp(home: _TestableProductListView(repository: repository)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows products when loaded', (WidgetTester tester) async {
      const testProducts = [
        Product(
          id: 1,
          title: 'Test Product',
          price: 9.99,
          description: 'A test product',
          category: 'electronics',
          image: 'https://example.com/image.jpg',
          rating: Rating(rate: 4.5, count: 100),
        ),
      ];

      final repository = FakeProductRepository(
        productsResult: const Ok(testProducts),
        categoriesResult: const Ok(['electronics']),
      );

      await tester.pumpWidget(
        MaterialApp(home: _TestableProductListView(repository: repository)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
    });

    testWidgets('shows error state when products fail to load', (
      WidgetTester tester,
    ) async {
      final repository = FakeProductRepository(
        productsResult: const Error(NetworkException('No connection')),
        categoriesResult: const Ok<List<String>>([]),
      );

      await tester.pumpWidget(
        MaterialApp(home: _TestableProductListView(repository: repository)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error loading products'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty state when no products', (
      WidgetTester tester,
    ) async {
      final repository = FakeProductRepository(
        productsResult: const Ok<List<Product>>([]),
        categoriesResult: const Ok<List<String>>([]),
      );

      await tester.pumpWidget(
        MaterialApp(home: _TestableProductListView(repository: repository)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No products found'), findsOneWidget);
    });
  });
}

/// A testable version of ProductListView that accepts a mock repository
class _TestableProductListView extends StatefulWidget {
  const _TestableProductListView({required this.repository});

  final ProductRepository repository;

  @override
  State<_TestableProductListView> createState() =>
      _TestableProductListViewState();
}

class _TestableProductListViewState extends State<_TestableProductListView> {
  late final ProductListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductListViewModel(productRepository: widget.repository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProductListView(viewModel: _viewModel);
  }
}
