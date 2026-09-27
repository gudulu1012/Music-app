/// Base class for application-specific exceptions.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException($code): $message';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError});
}

class PlayerException extends AppException {
  const PlayerException(super.message, {super.code, super.originalError});
}

class DownloadException extends AppException {
  const DownloadException(super.message, {super.code, super.originalError});
}
