import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/core/usecase/usecase.dart';
import 'package:cidaas_poc/protected_resource/domain/entities/protected_resource.dart';
import 'package:cidaas_poc/protected_resource/domain/repositories/protected_resource_repository.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';

class GetProtectedResource implements UseCase<ProtectedResource, NoParams> {
  final ProtectedResourceRepository protectedResourceRepository;
  final AuthRepository authRepository;

  GetProtectedResource({
    required this.protectedResourceRepository,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, ProtectedResource>> call(NoParams params) async {
    final userResult = await authRepository.getCachedUser();
    debugPrint('>>> DEBUG: Resultado de getCachedUser: $userResult');
    return await userResult.fold((failure) => Left(failure), (user) async {
      if (user == null) {
        return Left(
          AuthFailure('No authenticated user or access token found.'),
        );
      }

      return await protectedResourceRepository.getProtectedResource(
        user.accessToken,
      );
    });
  }
}
