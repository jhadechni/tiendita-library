# Changelog

All notable changes to this project will be documented in this file.

## 0.0.1

Initial release of the Tiendita package.

### Features

- **Product API Support**
  - Fetch all products with optional pagination and sorting
  - Fetch single product by ID
  - Get all product categories
  - Filter products by category

- **Cart API Support**
  - Full CRUD operations for shopping carts
  - Get all carts with date range filtering
  - Get carts by user ID
  - Add, update, and delete carts

- **Core Utilities**
  - `Result<T>` sealed class for type-safe error handling
  - Pattern matching support with `Ok` and `Error` subclasses
  - Custom exception hierarchy:
    - `TienditaException` (base)
    - `NetworkException`
    - `ServerException`
    - `ParseException`
    - `NotFoundException`
    - `AuthException`

- **Data Models**
  - `Product` with `Rating` for product data
  - `Cart` with `CartProduct` for cart data
  - JSON serialization support

- **Repository Layer**
  - `ProductRepository` with in-memory caching
  - `CartRepository` with in-memory caching
  - Cache invalidation and force refresh support

- **Example App**
  - Complete Flutter app demonstrating package usage
  - MVVM architecture with `ChangeNotifier`
  - Product listing with grid view
  - Category filtering
  - Product detail view
  - Error handling with retry
