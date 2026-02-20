# Tiendita

A Flutter package for interacting with the [Fake Store API](https://fakestoreapi.com). Provides a clean, type-safe interface for fetching products and managing shopping carts with built-in caching and comprehensive error handling.

## Features

- **Products API**: Fetch all products, single product, categories, and filter by category
- **Cart API**: Full CRUD operations for shopping carts
- **Type-safe error handling**: Uses sealed `Result<T>` type with pattern matching
- **Built-in caching**: In-memory caching with manual refresh support
- **Custom exceptions**: Rich exception hierarchy for different error scenarios
- **Testable architecture**: Dependency injection throughout for easy mocking

## Getting Started

### Prerequisites

- Flutter SDK >= 3.18.0
- Dart SDK >= 3.11.0

### Installation

Add `tiendita` to your `pubspec.yaml`:

```yaml
dependencies:
  tiendita:
    path: ../tiendita  # For local development
    # Or from pub.dev when published:
    # tiendita: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Import the package

```dart
import 'package:tiendita/tiendita.dart';
```

### Fetching Products

```dart
// Create a repository instance
final productRepository = ProductRepository();

// Fetch all products
final result = await productRepository.getProducts();

switch (result) {
  case Ok(:final value):
    print('Got ${value.length} products');
    for (final product in value) {
      print('${product.title}: \$${product.price}');
    }
  case Error(:final error):
    print('Error: $error');
}
```

### Fetching a Single Product

```dart
final result = await productRepository.getProduct(1);

switch (result) {
  case Ok(:final value):
    print('Product: ${value.title}');
    print('Price: \$${value.price}');
    print('Rating: ${value.rating.rate}/5 (${value.rating.count} reviews)');
  case Error(:final error):
    print('Error: $error');
}
```

### Working with Categories

```dart
// Get all categories
final categoriesResult = await productRepository.getCategories();

switch (categoriesResult) {
  case Ok(:final value):
    print('Categories: ${value.join(", ")}');
  case Error(:final error):
    print('Error: $error');
}

// Filter products by category
final electronicsResult = await productRepository.getProductsByCategory('electronics');
```

### Managing Carts

```dart
final cartRepository = CartRepository();

// Get a user's carts
final cartsResult = await cartRepository.getUserCarts(1);

// Add a new cart
final newCartResult = await cartRepository.addCart(
  userId: 1,
  products: [
    CartProduct(productId: 1, quantity: 2),
    CartProduct(productId: 5, quantity: 1),
  ],
);

// Update a cart
final updateResult = await cartRepository.updateCart(
  cartId: 1,
  userId: 1,
  products: [
    CartProduct(productId: 1, quantity: 3),
  ],
);

// Delete a cart
final deleteResult = await cartRepository.deleteCart(1);
```

### Using Pagination and Sorting

```dart
// Get first 5 products, sorted descending
final result = await productRepository.getProducts(
  limit: 5,
  sort: 'desc',
);

// Get carts within a date range
final cartsResult = await cartRepository.getCarts(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 12, 31),
  limit: 10,
);
```

### Cache Management

```dart
// Force refresh to bypass cache
final freshResult = await productRepository.getProducts(forceRefresh: true);

// Clear all cached data
productRepository.clearCache();
cartRepository.clearCache();
```

### Error Handling

The package uses a sealed `Result<T>` type for type-safe error handling:

```dart
final result = await productRepository.getProduct(999);

switch (result) {
  case Ok(:final value):
    // Handle success
    displayProduct(value);
  case Error(:final error):
    // Handle specific error types
    if (error is NotFoundException) {
      print('Product not found');
    } else if (error is NetworkException) {
      print('Network error: ${error.message}');
    } else if (error is ServerException) {
      print('Server error: ${error.message}');
    } else {
      print('Unknown error: $error');
    }
}
```

### Available Exception Types

| Exception | Description |
|-----------|-------------|
| `TienditaException` | Base exception class |
| `NetworkException` | Connection timeouts, no internet |
| `ServerException` | HTTP error responses (5xx) |
| `ParseException` | JSON parsing failures |
| `NotFoundException` | Resource not found (404) |
| `AuthException` | Authentication failures (401) |

## API Reference

### ProductRepository

| Method | Description | Returns |
|--------|-------------|---------|
| `getProducts({limit, sort, forceRefresh})` | Get all products | `Result<List<Product>>` |
| `getProduct(id, {forceRefresh})` | Get single product | `Result<Product>` |
| `getCategories({forceRefresh})` | Get all categories | `Result<List<String>>` |
| `getProductsByCategory(category)` | Get products by category | `Result<List<Product>>` |
| `clearCache()` | Clear cached data | `void` |

### CartRepository

| Method | Description | Returns |
|--------|-------------|---------|
| `getCarts({limit, sort, startDate, endDate})` | Get all carts | `Result<List<Cart>>` |
| `getCart(id, {forceRefresh})` | Get single cart | `Result<Cart>` |
| `getUserCarts(userId, {forceRefresh})` | Get user's carts | `Result<List<Cart>>` |
| `addCart({userId, products})` | Create new cart | `Result<Cart>` |
| `updateCart({cartId, userId, products})` | Update cart | `Result<Cart>` |
| `deleteCart(cartId)` | Delete cart | `Result<void>` |
| `clearCache()` | Clear cached data | `void` |

### Models

#### Product

```dart
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;
}

class Rating {
  final double rate;
  final int count;
}
```

#### Cart

```dart
class Cart {
  final int id;
  final int userId;
  final DateTime date;
  final List<CartProduct> products;
}

class CartProduct {
  final int productId;
  final int quantity;
}
```

## Running the Example App

The package includes a complete example app demonstrating all features:

```bash
cd example
flutter pub get
flutter run
```

The example app showcases:
- Product listing with grid view
- Category filtering with chips
- Pull-to-refresh functionality
- Product detail view with full information
- MVVM architecture with `ChangeNotifier`
- Error handling with retry functionality

### Example App Screenshots

The example app displays:
1. **Product List**: Grid of products with images, titles, prices, and ratings
2. **Category Filter**: Horizontal scrollable chips to filter by category
3. **Product Detail**: Full product information with image, description, and add-to-cart button

## Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Architecture

```
lib/
├── tiendita.dart              # Public API exports
└── src/
    ├── core/
    │   ├── result.dart        # Result<T> sealed class
    │   └── exceptions.dart    # Custom exception hierarchy
    └── data/
        ├── models/
        │   ├── product.dart   # Product & Rating models
        │   └── cart.dart      # Cart & CartProduct models
        ├── services/
        │   └── fake_store_api_service.dart  # HTTP client
        └── repositories/
            ├── product_repository.dart      # Product data layer
            └── cart_repository.dart         # Cart data layer
```

## Dependencies

- [dio](https://pub.dev/packages/dio) ^5.4.0 - HTTP client

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
