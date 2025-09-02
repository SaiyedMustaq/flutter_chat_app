class AppException implements Exception {
  final String message;
  final int statusCode;

  AppException(this.message, this.statusCode);

  @override
  String toString() => 'AppException: $message (Status: $statusCode)';
}

class NetworkException extends AppException {
  NetworkException(super.message, super.statusCode);
}

class DioException extends AppException {
  DioException(super.message, super.statusCode);
}

class NotFoundException extends AppException {
  NotFoundException(super.message, super.statusCode);
}

class ServerException extends AppException {
  ServerException(super.message, super.statusCode);
}
