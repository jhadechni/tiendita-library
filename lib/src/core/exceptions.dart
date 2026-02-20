/// Base exception for Tiendita package
class TienditaException implements Exception {
  const TienditaException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'TienditaException: $message (statusCode: $statusCode)';
}

/// Exception thrown when a network error occurs
class NetworkException extends TienditaException {
  const NetworkException(super.message, {super.statusCode});
}

/// Exception thrown when the server returns an error response
class ServerException extends TienditaException {
  const ServerException(super.message, {super.statusCode});
}

/// Exception thrown when parsing data fails
class ParseException extends TienditaException {
  const ParseException(super.message) : super(statusCode: null);
}

/// Exception thrown when a resource is not found
class NotFoundException extends TienditaException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

/// Exception thrown when authentication fails
class AuthException extends TienditaException {
  const AuthException(super.message) : super(statusCode: 401);
}
