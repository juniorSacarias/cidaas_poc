import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/core/platform/secure_local_storage.dart';

class SecureLocalStorageImpl implements SecureLocalStorage {
  final FlutterSecureStorage storage;

  SecureLocalStorageImpl(this.storage);

  @override
  Future<Either<Failure, void>> saveToken(String key, String value) async {
    try {
      await storage.write(key: key, value: value);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Failed to save token to secure storage: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> getToken(String key) async {
    try {
      final value = await storage.read(key: key);
      return Right(value);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to read token from secure storage: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteToken(String key) async {
    try {
      await storage.delete(key: key);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to delete token from secure storage: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllTokens() async {
    try {
      await storage.deleteAll();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to delete all tokens from secure storage: ${e.toString()}',
        ),
      );
    }
  }
}
