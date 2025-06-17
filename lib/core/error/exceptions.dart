class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic innerException;
  final StackTrace? stackTrace;

  const ServerException({
    this.message = 'Server error.',
    this.statusCode,
    this.innerException,
    this.stackTrace,
  });

  @override
  String toString() {
    String output = 'ServerException: $message';
    if (statusCode != null) {
      output += ' (Status: $statusCode)';
    }
    if (innerException != null) {
      output += '\n  Inner Exception: $innerException';
    }
    return output;
  }
}

class CacheException implements Exception {
  final String message;
  final dynamic innerException;
  final StackTrace? stackTrace;

  const CacheException({
    this.message = 'Cache error.',
    this.innerException,
    this.stackTrace,
  });

  @override
  String toString() {
    String output = 'CacheException: $message';
    if (innerException != null) {
      output += '\n  Inner Exception: $innerException';
    }
    return output;
  }
}

class AuthException implements Exception {
  final String message;
  final dynamic innerException;
  final StackTrace? stackTrace;
  final String? errorCode;
  final String? errorDescription;

  const AuthException({
    this.message = 'Authentication error.',
    this.innerException,
    this.stackTrace,
    this.errorCode,
    this.errorDescription,
  });

  @override
  String toString() {
    String output = 'AuthException: $message';
    if (errorCode != null) {
      output += ' (Code: $errorCode)';
    }
    if (errorDescription != null) {
      output += ' (Description: $errorDescription)';
    }
    if (innerException != null) {
      output += '\n  Inner Exception: $innerException';
    }
    return output;
  }
}

class NetworkException implements Exception {
  final String message;
  final dynamic innerException;
  final StackTrace? stackTrace;

  const NetworkException({
    this.message = 'Network error. Please check your Internet connection.',
    this.innerException,
    this.stackTrace,
  });

  @override
  String toString() {
    String output = 'NetworkException: $message';
    if (innerException != null) {
      output += '\n  Inner Exception: $innerException';
    }
    return output;
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic innerException;
  final StackTrace? stackTrace;
  final dynamic responseData;

  const ApiException({
    this.message = 'API error.',
    this.statusCode,
    this.innerException,
    this.stackTrace,
    this.responseData,
  });

  @override
  String toString() {
    String output = 'ApiException: $message';
    if (statusCode != null) {
      output += ' (Status: $statusCode)';
    }
    if (responseData != null) {
      output += ' (Response Data: $responseData)';
    }
    if (innerException != null) {
      output += '\n  Inner Exception: $innerException';
    }
    return output;
  }
}
