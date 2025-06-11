import 'package:dartz/dartz.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

      if (authResponse.idToken == null) {
        return Left(AuthFailure('Authentication failed: ID token is null.'));
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(
        authResponse.idToken!,
      );

      final String userEmail = decodedToken['email'] ?? 'No email provided';
      final String userName = decodedToken['given_name'] ?? 'No name provided';
      final String userId =
          decodedToken['sub'] ??
          authResponse.accessToken!; // 'sub' is the subject/user ID

      final user = User(
        id: userId,
        email: userEmail,
        name: userName,
        accessToken: authResponse.accessToken!,
        refreshToken: authResponse.refreshToken,
        idToken: authResponse.idToken,
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
  Future<Either<Failure, void>> signOut(String idToken) async {
    try {
      await remoteDataSource.signOutCidaas(idToken);
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
