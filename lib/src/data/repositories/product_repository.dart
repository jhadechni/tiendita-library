import '../../core/exceptions.dart';
import '../../core/result.dart';
import '../models/product.dart';
import '../services/fake_store_api_service.dart';

/// Repository for managing product data.
///
/// Acts as the single source of truth for product-related data.
/// Handles caching, error handling, and data aggregation.
///
/// ## Architecture
///
/// This repository follows the Repository pattern from clean architecture:
/// - **Abstracts** data source implementation from business logic
/// - **Caches** data in memory for performance
/// - **Returns** [Result] types for type-safe error handling
///
/// ## Usage
///
/// ```dart
/// final repository = ProductRepository();
///
/// // Fetch all products
/// final result = await repository.getProducts();
///
/// switch (result) {
///   case Ok(:final value):
///     for (final product in value) {
///       print(product.title);
///     }
///   case Error(:final error):
///     print('Error: $error');
/// }
/// ```
///
/// ## Caching Strategy
///
/// The repository implements in-memory caching:
/// - **List cache**: Stores the full product list
/// - **Individual cache**: Stores products by ID
/// - **Category cache**: Stores category list
///
/// Use `forceRefresh: true` to bypass cache, or `clearCache()` to reset.
class ProductRepository {
  /// Creates a new [ProductRepository] instance.
  ///
  /// Optionally accepts a custom [FakeStoreApiService] for testing.
  ProductRepository({
    FakeStoreApiService? apiService,
  }) : _apiService = apiService ?? FakeStoreApiService();

  final FakeStoreApiService _apiService;

  // Simple in-memory cache
  List<Product>? _cachedProducts;
  List<String>? _cachedCategories;
  final Map<int, Product> _productCache = {};

  /// Gets all products.
  ///
  /// Returns cached data if available, otherwise fetches from API.
  ///
  /// ## Parameters
  /// - [limit]: Maximum number of products to return
  /// - [sort]: Sort order - `'asc'` or `'desc'`
  /// - [forceRefresh]: Set to `true` to bypass cache
  ///
  /// ## Example
  /// ```dart
  /// // Get first 10 products
  /// final result = await repository.getProducts(limit: 10);
  ///
  /// // Force refresh from API
  /// final fresh = await repository.getProducts(forceRefresh: true);
  /// ```
  ///
  /// Returns [Result.ok] with products list on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<List<Product>>> getProducts({
    int? limit,
    String? sort,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh &&
          _cachedProducts != null &&
          limit == null &&
          sort == null) {
        return Result.ok(_cachedProducts!);
      }

      final products = await _apiService.getProducts(limit: limit, sort: sort);

      if (limit == null && sort == null) {
        _cachedProducts = products;
        for (final product in products) {
          _productCache[product.id] = product;
        }
      }

      return Result.ok(products);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Gets a single product by ID.
  ///
  /// Returns cached data if available, otherwise fetches from API.
  ///
  /// ## Parameters
  /// - [id]: The product ID to fetch
  /// - [forceRefresh]: Set to `true` to bypass cache
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.getProduct(1);
  ///
  /// switch (result) {
  ///   case Ok(:final value):
  ///     print(value.title);
  ///   case Error(:final error):
  ///     print('Product not found');
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with the product on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<Product>> getProduct(int id, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _productCache.containsKey(id)) {
        return Result.ok(_productCache[id]!);
      }

      final product = await _apiService.getProduct(id);
      _productCache[id] = product;

      return Result.ok(product);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Gets all product categories.
  ///
  /// Returns cached data if available, otherwise fetches from API.
  ///
  /// ## Parameters
  /// - [forceRefresh]: Set to `true` to bypass cache
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.getCategories();
  ///
  /// switch (result) {
  ///   case Ok(:final value):
  ///     // ["electronics", "jewelery", "men's clothing", "women's clothing"]
  ///     print(value);
  ///   case Error(:final error):
  ///     print('Error: $error');
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with category list on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<List<String>>> getCategories({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedCategories != null) {
        return Result.ok(_cachedCategories!);
      }

      final categories = await _apiService.getCategories();
      _cachedCategories = categories;

      return Result.ok(categories);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Gets products filtered by category.
  ///
  /// ## Parameters
  /// - [category]: The category name (e.g., "electronics")
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.getProductsByCategory('electronics');
  /// ```
  ///
  /// Returns [Result.ok] with filtered products on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<List<Product>>> getProductsByCategory(String category) async {
    try {
      final products = await _apiService.getProductsByCategory(category);
      return Result.ok(products);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Adds a new product.
  ///
  /// **Note**: The Fake Store API simulates creation but doesn't persist data.
  ///
  /// ## Parameters
  /// - [title]: Product title/name
  /// - [price]: Product price
  /// - [description]: Product description
  /// - [category]: Product category
  /// - [image]: URL to product image
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.addProduct(
  ///   title: 'New Product',
  ///   price: 29.99,
  ///   description: 'A great product',
  ///   category: 'electronics',
  ///   image: 'https://example.com/image.jpg',
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the created product on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<Product>> addProduct({
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
  }) async {
    try {
      final product = await _apiService.addProduct(
        title: title,
        price: price,
        description: description,
        category: category,
        image: image,
      );

      _productCache[product.id] = product;
      _cachedProducts = null; // Invalidate list cache

      return Result.ok(product);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Updates an existing product (full replacement).
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [productId]: ID of the product to update
  /// - [title]: New product title
  /// - [price]: New product price
  /// - [description]: New product description
  /// - [category]: New product category
  /// - [image]: New product image URL
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.updateProduct(
  ///   productId: 1,
  ///   title: 'Updated Title',
  ///   price: 39.99,
  ///   description: 'Updated description',
  ///   category: 'electronics',
  ///   image: 'https://example.com/new-image.jpg',
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the updated product on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<Product>> updateProduct({
    required int productId,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
  }) async {
    try {
      final product = await _apiService.updateProduct(
        productId: productId,
        title: title,
        price: price,
        description: description,
        category: category,
        image: image,
      );

      _productCache[productId] = product;
      _cachedProducts = null; // Invalidate list cache

      return Result.ok(product);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Partially updates an existing product.
  ///
  /// Only updates the fields that are provided (non-null).
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [productId]: ID of the product to update
  /// - [title]: New title (optional)
  /// - [price]: New price (optional)
  /// - [description]: New description (optional)
  /// - [category]: New category (optional)
  /// - [image]: New image URL (optional)
  ///
  /// ## Example
  /// ```dart
  /// // Only update the price
  /// final result = await repository.patchProduct(
  ///   productId: 1,
  ///   price: 49.99,
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the updated product on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<Product>> patchProduct({
    required int productId,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
  }) async {
    try {
      final product = await _apiService.patchProduct(
        productId: productId,
        title: title,
        price: price,
        description: description,
        category: category,
        image: image,
      );

      _productCache[productId] = product;
      _cachedProducts = null; // Invalidate list cache

      return Result.ok(product);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Deletes a product.
  ///
  /// **Note**: The Fake Store API simulates deletion but doesn't persist data.
  ///
  /// ## Parameters
  /// - [productId]: ID of the product to delete
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.deleteProduct(1);
  ///
  /// switch (result) {
  ///   case Ok():
  ///     print('Product deleted');
  ///   case Error(:final error):
  ///     print('Delete failed: $error');
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with `null` on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<void>> deleteProduct(int productId) async {
    try {
      await _apiService.deleteProduct(productId);

      _productCache.remove(productId);
      _cachedProducts = null; // Invalidate list cache

      return Result.ok(null);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Clears all cached data.
  ///
  /// Call this to force fresh data on the next request.
  void clearCache() {
    _cachedProducts = null;
    _cachedCategories = null;
    _productCache.clear();
  }
}
