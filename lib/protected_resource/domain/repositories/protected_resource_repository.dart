import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/protected_resource/domain/entities/protected_resource.dart';

abstract class ProtectedResourceRepository {
  Future<Either<Failure, ProtectedResource>> getProtectedResource(
    String accessToken,
  );
}
