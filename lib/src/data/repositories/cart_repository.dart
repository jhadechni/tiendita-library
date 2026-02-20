import '../../core/exceptions.dart';
import '../../core/result.dart';
import '../models/cart.dart';
import '../services/fake_store_api_service.dart';

/// Repository for managing cart data.
///
/// Acts as the single source of truth for cart-related data.
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
/// final repository = CartRepository();
///
/// // Fetch user's carts
/// final result = await repository.getUserCarts(1);
///
/// switch (result) {
///   case Ok(:final value):
///     for (final cart in value) {
///       print('Cart ${cart.id}: ${cart.products.length} items');
///     }
///   case Error(:final error):
///     print('Error: $error');
/// }
/// ```
///
/// ## Caching Strategy
///
/// The repository implements in-memory caching:
/// - **Cart cache**: Stores carts by ID
/// - **User carts cache**: Stores cart lists by user ID
///
/// Cache is automatically invalidated on mutations (add, update, delete).
/// Use `forceRefresh: true` to bypass cache, or `clearCache()` to reset.
class CartRepository {
  /// Creates a new [CartRepository] instance.
  ///
  /// Optionally accepts a custom [FakeStoreApiService] for testing.
  CartRepository({
    FakeStoreApiService? apiService,
  }) : _apiService = apiService ?? FakeStoreApiService();

  final FakeStoreApiService _apiService;

  // Simple in-memory cache
  final Map<int, Cart> _cartCache = {};
  final Map<int, List<Cart>> _userCartsCache = {};

  /// Gets all carts.
  ///
  /// ## Parameters
  /// - [limit]: Maximum number of carts to return
  /// - [sort]: Sort order - `'asc'` or `'desc'`
  /// - [startDate]: Filter carts created on or after this date
  /// - [endDate]: Filter carts created on or before this date
  ///
  /// ## Example
  /// ```dart
  /// // Get carts from a date range
  /// final result = await repository.getCarts(
  ///   startDate: DateTime(2020, 1, 1),
  ///   endDate: DateTime(2020, 12, 31),
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with cart list on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<List<Cart>>> getCarts({
    int? limit,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final carts = await _apiService.getCarts(
        limit: limit,
        sort: sort,
        startDate: startDate,
        endDate: endDate,
      );

      for (final cart in carts) {
        _cartCache[cart.id] = cart;
      }

      return Result.ok(carts);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Gets a single cart by ID.
  ///
  /// Returns cached data if available, otherwise fetches from API.
  ///
  /// ## Parameters
  /// - [id]: The cart ID to fetch
  /// - [forceRefresh]: Set to `true` to bypass cache
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.getCart(1);
  ///
  /// switch (result) {
  ///   case Ok(:final value):
  ///     print('${value.products.length} items in cart');
  ///   case Error(:final error):
  ///     print('Cart not found');
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with the cart on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<Cart>> getCart(int id, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cartCache.containsKey(id)) {
        return Result.ok(_cartCache[id]!);
      }

      final cart = await _apiService.getCart(id);
      _cartCache[id] = cart;

      return Result.ok(cart);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Gets all carts for a specific user.
  ///
  /// Returns cached data if available, otherwise fetches from API.
  ///
  /// ## Parameters
  /// - [userId]: The user ID whose carts to fetch
  /// - [forceRefresh]: Set to `true` to bypass cache
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.getUserCarts(1);
  ///
  /// switch (result) {
  ///   case Ok(:final value):
  ///     print('User has ${value.length} carts');
  ///   case Error(:final error):
  ///     print('Error: $error');
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with cart list on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<List<Cart>>> getUserCarts(
    int userId, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _userCartsCache.containsKey(userId)) {
        return Result.ok(_userCartsCache[userId]!);
      }

      final carts = await _apiService.getUserCarts(userId);
      _userCartsCache[userId] = carts;

      for (final cart in carts) {
        _cartCache[cart.id] = cart;
      }

      return Result.ok(carts);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Adds a new cart.
  ///
  /// **Note**: The Fake Store API simulates creation but doesn't persist data.
  ///
  /// ## Parameters
  /// - [userId]: ID of the user who owns the cart
  /// - [products]: List of [CartProduct] items to add
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.addCart(
  ///   userId: 1,
  ///   products: [
  ///     CartProduct(productId: 1, quantity: 2),
  ///     CartProduct(productId: 5, quantity: 1),
  ///   ],
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the created cart on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<Cart>> addCart({
    required int userId,
    required List<CartProduct> products,
  }) async {
    try {
      final cart = await _apiService.addCart(
        userId: userId,
        products: products,
      );

      _cartCache[cart.id] = cart;
      _userCartsCache.remove(userId); // Invalidate user carts cache

      return Result.ok(cart);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Updates an existing cart (full replacement).
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [cartId]: ID of the cart to update
  /// - [userId]: User ID for the cart
  /// - [products]: New list of [CartProduct] items
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.updateCart(
  ///   cartId: 1,
  ///   userId: 1,
  ///   products: [CartProduct(productId: 3, quantity: 5)],
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the updated cart on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<Cart>> updateCart({
    required int cartId,
    required int userId,
    required List<CartProduct> products,
  }) async {
    try {
      final cart = await _apiService.updateCart(
        cartId: cartId,
        userId: userId,
        products: products,
      );

      _cartCache[cartId] = cart;
      _userCartsCache.remove(userId); // Invalidate user carts cache

      return Result.ok(cart);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Deletes a cart.
  ///
  /// **Note**: The Fake Store API simulates deletion but doesn't persist data.
  ///
  /// ## Parameters
  /// - [cartId]: ID of the cart to delete
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.deleteCart(1);
  ///
  /// switch (result) {
  ///   case Ok():
  ///     print('Cart deleted');
  ///   case Error(:final error):
  ///     print('Delete failed: $error');
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with `null` on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<void>> deleteCart(int cartId) async {
    try {
      await _apiService.deleteCart(cartId);

      final cart = _cartCache.remove(cartId);
      if (cart != null) {
        _userCartsCache.remove(cart.userId);
      }

      return Result.ok(null);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Partially updates an existing cart.
  ///
  /// Only updates the fields that are provided (non-null).
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [cartId]: ID of the cart to update
  /// - [userId]: New user ID (optional)
  /// - [products]: New products list (optional)
  ///
  /// ## Example
  /// ```dart
  /// // Only update the products
  /// final result = await repository.patchCart(
  ///   cartId: 1,
  ///   products: [CartProduct(productId: 2, quantity: 3)],
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the updated cart on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<Cart>> patchCart({
    required int cartId,
    int? userId,
    List<CartProduct>? products,
  }) async {
    try {
      // Invalidate user carts cache for both old and new user
      final existingCart = _cartCache[cartId];
      if (existingCart != null) {
        _userCartsCache.remove(existingCart.userId);
      }
      if (userId != null) {
        _userCartsCache.remove(userId);
      }

      final cart = await _apiService.patchCart(
        cartId: cartId,
        userId: userId,
        products: products,
      );

      _cartCache[cartId] = cart;

      return Result.ok(cart);
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
    _cartCache.clear();
    _userCartsCache.clear();
  }
}
