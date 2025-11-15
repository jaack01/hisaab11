/// Base exception class
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    String message = 'Database operation failed',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    String message = 'Network connection failed',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Server related exceptions
class ServerException extends AppException {
  const ServerException({
    String message = 'Server error occurred',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    String message = 'Validation failed',
    this.fieldErrors,
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Authentication related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException({
    String message = 'Authentication failed',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Authorization related exceptions
class AuthorizationException extends AppException {
  const AuthorizationException({
    String message = 'Access denied',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Resource not found',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException({
    String message = 'Cache operation failed',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// File operation related exceptions
class FileException extends AppException {
  const FileException({
    String message = 'File operation failed',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException({
    String message = 'Permission denied',
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Business logic exceptions
class BusinessLogicException extends AppException {
  const BusinessLogicException({
    required String message,
    int? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
