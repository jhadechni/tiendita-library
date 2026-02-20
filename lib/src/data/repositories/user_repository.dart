import '../../core/exceptions.dart';
import '../../core/result.dart';
import '../models/user.dart';
import '../services/fake_store_api_service.dart';

/// Repository for managing user data.
///
/// Acts as the single source of truth for user-related data.
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
/// final repository = UserRepository();
///
/// // Fetch all users
/// final result = await repository.getUsers();
///
/// switch (result) {
///   case Ok(:final value):
///     for (final user in value) {
///       print('${user.name.firstname} ${user.name.lastname}');
///     }
///   case Error(:final error):
///     print('Error: $error');
/// }
/// ```
///
/// ## Caching Strategy
///
/// The repository implements in-memory caching:
/// - **List cache**: Stores the full user list
/// - **Individual cache**: Stores users by ID
///
/// Cache is automatically invalidated on mutations (add, update, delete).
/// Use `forceRefresh: true` to bypass cache, or `clearCache()` to reset.
class UserRepository {
  /// Creates a new [UserRepository] instance.
  ///
  /// Optionally accepts a custom [FakeStoreApiService] for testing.
  UserRepository({
    FakeStoreApiService? apiService,
  }) : _apiService = apiService ?? FakeStoreApiService();

  final FakeStoreApiService _apiService;

  // Simple in-memory cache
  List<User>? _cachedUsers;
  final Map<int, User> _userCache = {};

  /// Gets all users.
  ///
  /// Returns cached data if available, otherwise fetches from API.
  ///
  /// ## Parameters
  /// - [limit]: Maximum number of users to return
  /// - [sort]: Sort order - `'asc'` or `'desc'`
  /// - [forceRefresh]: Set to `true` to bypass cache
  ///
  /// ## Example
  /// ```dart
  /// // Get first 5 users
  /// final result = await repository.getUsers(limit: 5);
  ///
  /// // Force refresh from API
  /// final fresh = await repository.getUsers(forceRefresh: true);
  /// ```
  ///
  /// Returns [Result.ok] with users list on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<List<User>>> getUsers({
    int? limit,
    String? sort,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh &&
          _cachedUsers != null &&
          limit == null &&
          sort == null) {
        return Result.ok(_cachedUsers!);
      }

      final users = await _apiService.getUsers(limit: limit, sort: sort);

      if (limit == null && sort == null) {
        _cachedUsers = users;
        for (final user in users) {
          _userCache[user.id] = user;
        }
      }

      return Result.ok(users);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Gets a single user by ID.
  ///
  /// Returns cached data if available, otherwise fetches from API.
  ///
  /// ## Parameters
  /// - [id]: The user ID to fetch
  /// - [forceRefresh]: Set to `true` to bypass cache
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.getUser(1);
  ///
  /// switch (result) {
  ///   case Ok(:final value):
  ///     print('${value.name.firstname} ${value.name.lastname}');
  ///   case Error(:final error):
  ///     print('User not found');
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with the user on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<User>> getUser(int id, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _userCache.containsKey(id)) {
        return Result.ok(_userCache[id]!);
      }

      final user = await _apiService.getUser(id);
      _userCache[id] = user;

      return Result.ok(user);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Adds a new user.
  ///
  /// **Note**: The Fake Store API simulates creation but doesn't persist data.
  ///
  /// ## Parameters
  /// - [email]: User's email address
  /// - [username]: User's username
  /// - [password]: User's password
  /// - [name]: User's name (firstname, lastname)
  /// - [address]: User's address information
  /// - [phone]: User's phone number
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.addUser(
  ///   email: 'john@example.com',
  ///   username: 'johnd',
  ///   password: 'secret123',
  ///   name: Name(firstname: 'John', lastname: 'Doe'),
  ///   address: Address(
  ///     city: 'New York',
  ///     street: '5th Avenue',
  ///     number: 123,
  ///     zipcode: '10001',
  ///     geolocation: Geolocation(lat: '40.7128', long: '-74.0060'),
  ///   ),
  ///   phone: '1-555-1234',
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the created user on success.
  /// Returns [Result.error] with [TienditaException] on failure.
  Future<Result<User>> addUser({
    required String email,
    required String username,
    required String password,
    required Name name,
    required Address address,
    required String phone,
  }) async {
    try {
      final user = await _apiService.addUser(
        email: email,
        username: username,
        password: password,
        name: name,
        address: address,
        phone: phone,
      );

      _userCache[user.id] = user;
      _cachedUsers = null; // Invalidate list cache

      return Result.ok(user);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Updates an existing user (full replacement).
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [userId]: ID of the user to update
  /// - [email]: New email address
  /// - [username]: New username
  /// - [password]: New password
  /// - [name]: New name information
  /// - [address]: New address information
  /// - [phone]: New phone number
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.updateUser(
  ///   userId: 1,
  ///   email: 'newemail@example.com',
  ///   username: 'johnd',
  ///   password: 'newpassword',
  ///   name: Name(firstname: 'John', lastname: 'Smith'),
  ///   address: existingAddress,
  ///   phone: '1-555-5678',
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the updated user on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<User>> updateUser({
    required int userId,
    required String email,
    required String username,
    required String password,
    required Name name,
    required Address address,
    required String phone,
  }) async {
    try {
      final user = await _apiService.updateUser(
        userId: userId,
        email: email,
        username: username,
        password: password,
        name: name,
        address: address,
        phone: phone,
      );

      _userCache[userId] = user;
      _cachedUsers = null; // Invalidate list cache

      return Result.ok(user);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Partially updates an existing user.
  ///
  /// Only updates the fields that are provided (non-null).
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [userId]: ID of the user to update
  /// - [email]: New email (optional)
  /// - [username]: New username (optional)
  /// - [password]: New password (optional)
  /// - [name]: New name (optional)
  /// - [address]: New address (optional)
  /// - [phone]: New phone (optional)
  ///
  /// ## Example
  /// ```dart
  /// // Only update the email
  /// final result = await repository.patchUser(
  ///   userId: 1,
  ///   email: 'updated@example.com',
  /// );
  /// ```
  ///
  /// Returns [Result.ok] with the updated user on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<User>> patchUser({
    required int userId,
    String? email,
    String? username,
    String? password,
    Name? name,
    Address? address,
    String? phone,
  }) async {
    try {
      final user = await _apiService.patchUser(
        userId: userId,
        email: email,
        username: username,
        password: password,
        name: name,
        address: address,
        phone: phone,
      );

      _userCache[userId] = user;
      _cachedUsers = null; // Invalidate list cache

      return Result.ok(user);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Deletes a user.
  ///
  /// **Note**: The Fake Store API simulates deletion but doesn't persist data.
  ///
  /// ## Parameters
  /// - [userId]: ID of the user to delete
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.deleteUser(1);
  ///
  /// switch (result) {
  ///   case Ok():
  ///     print('User deleted');
  ///   case Error(:final error):
  ///     print('Delete failed: $error');
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with `null` on success.
  /// Returns [Result.error] with [NotFoundException] if not found.
  Future<Result<void>> deleteUser(int userId) async {
    try {
      await _apiService.deleteUser(userId);

      _userCache.remove(userId);
      _cachedUsers = null; // Invalidate list cache

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
    _cachedUsers = null;
    _userCache.clear();
  }
}
