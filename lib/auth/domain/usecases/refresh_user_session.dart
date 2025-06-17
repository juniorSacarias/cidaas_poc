// lib/auth/domain/usecases/refresh_user_session.dart

import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/core/usecase/usecase.dart';
import 'package:cidaas_poc/auth/domain/entities/user.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';

class RefreshUserSession implements UseCase<User, NoParams> {
  final AuthRepository repository;

  RefreshUserSession(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    // Primero, intenta obtener el refresh token guardado
    final refreshTokenResult = await repository.getRefreshToken();

    return await refreshTokenResult.fold(
      (failure) => Left(failure), // Si falla obtener el token, propaga el fallo
      (refreshToken) async {
        if (refreshToken == null) {
          return Left(AuthFailure('No refresh token found in cache.'));
        }
        // Si hay refresh token, úsalo para refrescar la sesión
        return await repository.refreshUserSession(refreshToken);
      },
    );
  }
}
