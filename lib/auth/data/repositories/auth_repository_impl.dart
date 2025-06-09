import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/exceptions.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cidaas_poc/auth/domain/entities/user.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> signInWithCidaas() async {
    try {
      final authResponse = await remoteDataSource.signInWithCidaas();
      final user = User(
        id: authResponse.accessToken!,
        email: 'user@example.com',
        name: 'John Doe',
        accessToken: authResponse.accessToken!,
        refreshToken: authResponse.refreshToken,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'An unexpected error occurred during sign-in: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> refreshUserSession(String refreshToken) async {
    try {
      final tokenResponse = await remoteDataSource.refreshAuthToken(
        refreshToken,
      );
      final user = User(
        id: tokenResponse.accessToken!,
        email: 'user@example.com',
        name: 'John Doe',
        accessToken: tokenResponse.accessToken!,
        refreshToken: tokenResponse.refreshToken,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to refresh session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    const String dummyIdToken = 'your_current_id_token_here';
    try {
      await remoteDataSource.signOutCidaas(dummyIdToken);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to sign out: ${e.toString()}'));
    }
  }
}
