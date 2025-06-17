import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';

abstract class SecureLocalStorage {
  Future<Either<Failure, void>> saveToken(String key, String value);
  Future<Either<Failure, String?>> getToken(String key);
  Future<Either<Failure, void>> deleteToken(String key);
  Future<Either<Failure, void>> deleteAllTokens();
}
