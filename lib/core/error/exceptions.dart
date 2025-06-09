// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Error del servidor.',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Error de caché.'});

  @override
  String toString() => 'CacheException: $message';
}

// Nueva o actualizada excepción de autenticación
class AuthException implements Exception {
  final String message;

  const AuthException({this.message = 'Error de autenticación.'});

  @override
  String toString() => 'AuthException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Error de red. Verifique su conexión a Internet.',
  });

  @override
  String toString() => 'NetworkException: $message';
}
