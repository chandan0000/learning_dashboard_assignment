sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on our side']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Could not access local data']);
}

final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([
    super.message = 'Incorrect email or password',
  ]);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found']);
}
