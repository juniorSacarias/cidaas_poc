import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/protected_resource/data/datasources/protected_resource_remote_datasource.dart';
import 'package:cidaas_poc/protected_resource/domain/entities/protected_resource.dart';
import 'package:cidaas_poc/protected_resource/domain/repositories/protected_resource_repository.dart';

class ProtectedResourceRepositoryImpl implements ProtectedResourceRepository {
  final ProtectedResourceRemoteDataSourceImpl remoteDataSource;

  ProtectedResourceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProtectedResource>> getProtectedResource(
    String accessToken,
  ) async {
    final result = await remoteDataSource.getProtectedResource(accessToken);

    return result.fold((failure) => Left(failure), (jsonString) {
      return Right(ProtectedResource(data: jsonString));
    });
  }
}
