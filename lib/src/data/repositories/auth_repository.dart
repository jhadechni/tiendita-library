import '../../core/exceptions.dart';
import '../../core/result.dart';
import '../models/auth.dart';
import '../services/fake_store_api_service.dart';

/// Repository for managing authentication.
///
/// Handles user authentication and token management.
///
/// ## Architecture
///
/// This repository follows the Repository pattern from clean architecture:
/// - **Manages** authentication state (token storage)
/// - **Returns** [Result] types for type-safe error handling
/// - **Abstracts** the login API from business logic
///
/// ## Usage
///
/// ```dart
/// final repository = AuthRepository();
///
/// // Login
/// final result = await repository.login(
///   username: 'johnd',
///   password: 'm38rmF\$',
/// );
///
/// switch (result) {
///   case Ok(:final value):
///     print('Token: ${value.token}');
///     print('Is authenticated: ${repository.isAuthenticated}');
///   case Error(:final error):
///     print('Login failed: $error');
/// }
///
/// // Check authentication status
/// if (repository.isAuthenticated) {
///   final token = repository.currentToken;
///   // Use token for authenticated requests
/// }
///
/// // Logout
/// repository.logout();
/// ```
///
/// ## Token Management
///
/// The repository caches the authentication token after successful login.
/// Use [currentToken] to retrieve it and [isAuthenticated] to check status.
/// Call [logout] or [clearCache] to clear the token.
///
/// ## Test Credentials
///
/// Available test users from the Fake Store API:
/// - username: `johnd`, password: `m38rmF$`
/// - username: `mor_2314`, password: `83r5^_`
class AuthRepository {
  /// Creates a new [AuthRepository] instance.
  ///
  /// Optionally accepts a custom [FakeStoreApiService] for testing.
  AuthRepository({
    FakeStoreApiService? apiService,
  }) : _apiService = apiService ?? FakeStoreApiService();

  final FakeStoreApiService _apiService;

  // Cached authentication token
  String? _cachedToken;

  /// Gets the current cached token.
  ///
  /// Returns `null` if not authenticated.
  String? get currentToken => _cachedToken;

  /// Checks if user is authenticated.
  ///
  /// Returns `true` if a token is cached, `false` otherwise.
  bool get isAuthenticated => _cachedToken != null;

  /// Authenticates a user with username and password.
  ///
  /// On success, caches the token for later retrieval via [currentToken].
  ///
  /// ## Parameters
  /// - [username]: The user's username
  /// - [password]: The user's password
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.login(
  ///   username: 'johnd',
  ///   password: 'm38rmF\$',
  /// );
  ///
  /// switch (result) {
  ///   case Ok(:final value):
  ///     print('Logged in! Token: ${value.token}');
  ///   case Error(:final error):
  ///     if (error is AuthException) {
  ///       print('Invalid credentials');
  ///     } else {
  ///       print('Login error: $error');
  ///     }
  /// }
  /// ```
  ///
  /// Returns [Result.ok] with [LoginResponse] containing the JWT token.
  /// Returns [Result.error] with [AuthException] if credentials are invalid.
  /// Returns [Result.error] with [TienditaException] on other failures.
  Future<Result<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        username: username,
        password: password,
      );

      _cachedToken = response.token;

      return Result.ok(response);
    } on TienditaException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(TienditaException(e.toString()));
    }
  }

  /// Logs out the current user by clearing the cached token.
  ///
  /// After calling this, [isAuthenticated] returns `false` and
  /// [currentToken] returns `null`.
  ///
  /// ## Example
  /// ```dart
  /// repository.logout();
  /// print(repository.isAuthenticated); // false
  /// ```
  void logout() {
    _cachedToken = null;
  }

  /// Clears all cached authentication data.
  ///
  /// Equivalent to [logout].
  void clearCache() {
    _cachedToken = null;
  }
}
