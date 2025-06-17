import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:cidaas_poc/core/error/exceptions.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/core/platform/secure_local_storage.dart';
import 'package:cidaas_poc/core/constants/cache_keys.dart';
import 'package:cidaas_poc/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cidaas_poc/auth/domain/entities/user.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureLocalStorage secureLocalStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.secureLocalStorage);

  @override
  Future<Either<Failure, User>> signInWithCidaas() async {
    try {
      final tokenResponse = await remoteDataSource.signInWithCidaas();

      if (tokenResponse.idToken == null) {
        return Left(AuthFailure('Authentication failed: ID token is null.'));
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(
        tokenResponse.idToken!,
      );

      debugPrint('>>> DEBUG: Decoded ID Token: $decodedToken');
      debugPrint('>>> DEBUG: RESPONSE: $tokenResponse');

      final String userEmail = decodedToken['email'] ?? 'No email provided';
      final String userName =
          decodedToken['name'] ??
          decodedToken['given_name'] ??
          'No name provided';
      final String userId = decodedToken['sub'] ?? tokenResponse.accessToken!;

      final user = User(
        id: userId,
        email: userEmail,
        name: userName,
        accessToken: tokenResponse.accessToken!,
        refreshToken: tokenResponse.refreshToken,
        idToken: tokenResponse.idToken,
      );

      await secureLocalStorage.saveToken(cachedAccessToken, user.accessToken);
      if (user.idToken != null) {
        await secureLocalStorage.saveToken(cachedIdToken, user.idToken!);
      }
      if (user.refreshToken != null) {
        await secureLocalStorage.saveToken(
          cachedRefreshToken,
          user.refreshToken!,
        );
      }
      debugPrint('>>> DEBUG: Tokens saved in secure storage.');

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on FormatException catch (e) {
      return Left(AuthFailure('Invalid ID Token format: ${e.message}'));
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

      if (tokenResponse.idToken == null) {
        return Left(AuthFailure('Refresh failed: ID token is null.'));
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(
        tokenResponse.idToken!,
      );
      debugPrint('>>> DEBUG: Decoded ID Token on refresh: $decodedToken');

      final String userEmail = decodedToken['email'] ?? 'No email provided';
      final String userName =
          decodedToken['name'] ??
          decodedToken['given_name'] ??
          'No name provided';
      final String userId = decodedToken['sub'] ?? tokenResponse.accessToken!;

      final user = User(
        id: userId,
        email: userEmail,
        name: userName,
        accessToken: tokenResponse.accessToken!,
        refreshToken: tokenResponse.refreshToken,
        idToken: tokenResponse.idToken,
      );

      // --- ALMACENAR NUEVOS TOKENS DE FORMA SEGURA TRAS EL REFRESH ---
      await secureLocalStorage.saveToken(cachedAccessToken, user.accessToken);
      if (user.idToken != null) {
        await secureLocalStorage.saveToken(cachedIdToken, user.idToken!);
      }
      if (user.refreshToken != null) {
        // El refresh token puede renovarse
        await secureLocalStorage.saveToken(
          cachedRefreshToken,
          user.refreshToken!,
        );
      } else {
        // Si no se devuelve, asegurar que el viejo se elimine si el flujo lo requiere
        await secureLocalStorage.deleteToken(cachedRefreshToken);
      }
      debugPrint('>>> DEBUG: New tokens saved after refresh.');
      // --- FIN ALMACENAMIENTO ---

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on FormatException catch (e) {
      return Left(AuthFailure('Invalid ID Token format: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to refresh session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut(String idToken) async {
    try {
      await remoteDataSource.signOutCidaas(idToken);
      // --- BORRAR TODOS LOS TOKENS AL CERRAR SESIÓN ---
      await secureLocalStorage.deleteAllTokens();
      debugPrint(
        '>>> DEBUG: Todos los tokens eliminados del almacenamiento seguro.',
      );
      // --- FIN BORRADO ---
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

  // --- NUEVOS MÉTODOS PARA OBTENER EL REFRESH TOKEN Y EL USUARIO EN CACHÉ ---
  @override
  Future<Either<Failure, String?>> getRefreshToken() async {
    try {
      final refreshToken = await secureLocalStorage.getToken(
        cachedRefreshToken,
      );
      return refreshToken;
    } catch (e) {
      return Left(
        CacheFailure('Failed to retrieve refresh token: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final idTokenString = await secureLocalStorage.getToken(cachedIdToken);
      final accessTokenString = await secureLocalStorage.getToken(
        cachedAccessToken,
      );
      final refreshTokenString = await secureLocalStorage.getToken(
        cachedRefreshToken,
      );

      if (idTokenString.isLeft() ||
          accessTokenString.isLeft() ||
          refreshTokenString.isLeft()) {
        return Left(CacheFailure('Failed to retrieve tokens from cache.'));
      }

      final idToken = idTokenString.fold((l) => null, (r) => r);
      final accessToken = accessTokenString.fold((l) => null, (r) => r);
      final refreshToken = refreshTokenString.fold((l) => null, (r) => r);

      if (idToken == null || accessToken == null) {
        return const Right(
          null,
        ); // No hay tokens completos, no hay usuario en caché
      }

      // Decodificar el ID Token para obtener los detalles del usuario
      final decodedToken = JwtDecoder.decode(idToken);
      final String userEmail = decodedToken['email'] ?? 'No email provided';
      final String userName =
          decodedToken['name'] ??
          decodedToken['given_name'] ??
          'No name provided';
      final String userId = decodedToken['sub'] ?? accessToken;

      final user = User(
        id: userId,
        email: userEmail,
        name: userName,
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: idToken,
      );
      debugPrint('>>> DEBUG: Usuario restaurado desde caché: ${user.name}');
      return Right(user);
    } on FormatException catch (e) {
      return Left(CacheFailure('Cached ID Token is invalid: ${e.message}'));
    } catch (e) {
      return Left(
        CacheFailure('Failed to retrieve cached user: ${e.toString()}'),
      );
    }
  }

  // --- FIN NUEVOS MÉTODOS ---
}
