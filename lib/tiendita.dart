/// A Flutter package for interacting with the Fake Store API.
///
/// This package provides an easy-to-use interface for fetching products
/// and managing carts from the Fake Store API (https://fakestoreapi.com).
///
/// ## Usage
///
/// ```dart
/// import 'package:tiendita/tiendita.dart';
///
/// // Create a repository instance
/// final productRepository = ProductRepository();
///
/// // Fetch all products
/// final result = await productRepository.getProducts();
///
/// switch (result) {
///   case Ok(:final value):
///     print('Got ${value.length} products');
///   case Error(:final error):
///     print('Error: $error');
/// }
/// ```
library;

// Core utilities
export 'src/core/result.dart';
export 'src/core/exceptions.dart';

// Models
export 'src/data/models/auth.dart';
export 'src/data/models/cart.dart';
export 'src/data/models/product.dart';
export 'src/data/models/user.dart';

// Services
export 'src/data/services/fake_store_api_service.dart';

// Repositories
export 'src/data/repositories/auth_repository.dart';
export 'src/data/repositories/cart_repository.dart';
export 'src/data/repositories/product_repository.dart';
export 'src/data/repositories/user_repository.dart';
