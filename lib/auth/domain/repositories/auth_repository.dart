import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithCidaas();
  Future<Either<Failure, User>> refreshUserSession(String refreshToken);
  Future<Either<Failure, void>> signOut(String idToken);
  Future<Either<Failure, String?>> getRefreshToken();
  Future<Either<Failure, User?>> getCachedUser();
}
