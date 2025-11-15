import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    String message = 'Database operation failed',
    int? code,
  }) : super(message: message, code: code);
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Network connection failed',
    int? code,
  }) : super(message: message, code: code);
}

/// Server related failures
class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Server error occurred',
    int? code,
  }) : super(message: message, code: code);
}

/// Validation related failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    String message = 'Validation failed',
    this.fieldErrors,
    int? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Authentication related failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    String message = 'Authentication failed',
    int? code,
  }) : super(message: message, code: code);
}

/// Authorization related failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    String message = 'Access denied',
    int? code,
  }) : super(message: message, code: code);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Resource not found',
    int? code,
  }) : super(message: message, code: code);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Cache operation failed',
    int? code,
  }) : super(message: message, code: code);
}

/// File operation related failures
class FileFailure extends Failure {
  const FileFailure({
    String message = 'File operation failed',
    int? code,
  }) : super(message: message, code: code);
}

/// Permission related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'Permission denied',
    int? code,
  }) : super(message: message, code: code);
}

/// Unexpected/Unknown failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    String message = 'An unexpected error occurred',
    int? code,
  }) : super(message: message, code: code);
}

/// Business logic failures
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}
