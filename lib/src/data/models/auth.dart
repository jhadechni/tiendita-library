/// Login response containing the authentication token.
///
/// Returned by the `/auth/login` endpoint upon successful authentication.
///
/// ## Example
/// ```dart
/// final response = await authRepository.login(
///   username: 'johnd',
///   password: 'm38rmF\$',
/// );
///
/// switch (response) {
///   case Ok(:final value):
///     print('Token: ${value.token}');
///   case Error(:final error):
///     print('Login failed: $error');
/// }
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
/// }
/// ```
///
/// ## Token Usage
/// The token is a JWT (JSON Web Token) that can be used for:
/// - Authenticating subsequent API requests
/// - Identifying the logged-in user
///
/// **Note**: The Fake Store API doesn't actually validate tokens
/// on subsequent requests - it's for demo/learning purposes only.
class LoginResponse {
  /// Creates a new [LoginResponse] instance.
  ///
  /// - [token]: The JWT authentication token
  const LoginResponse({
    required this.token,
  });

  /// Creates a [LoginResponse] from JSON data.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
    );
  }

  /// The JWT authentication token.
  ///
  /// This token can be decoded to extract user information
  /// or passed in request headers for authentication.
  final String token;

  /// Converts this response to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }

  @override
  String toString() {
    final preview = token.length > 20 ? '${token.substring(0, 20)}...' : token;
    return 'LoginResponse(token: $preview)';
  }
}
