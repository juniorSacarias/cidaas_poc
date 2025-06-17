// lib/protected_resource/protected_resource_injector.dart

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// Updated import path:
import 'package:cidaas_poc/protected_resource/data/datasources/protected_resource_remote_datasource.dart';
// No need for separate protected_resource_remote_datasource_impl.dart import now.

import 'package:cidaas_poc/protected_resource/data/repositories/protected_resource_repository_impl.dart';
import 'package:cidaas_poc/protected_resource/domain/repositories/protected_resource_repository.dart';
import 'package:cidaas_poc/protected_resource/domain/usecases/get_protected_resources.dart';
import 'package:cidaas_poc/protected_resource/presentation/cubit/protected_resource_cubit.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';

final sl = GetIt.instance;

Future<void> initProtectedResourceFeature() async {
  // === Presentation Layer (Cubits) ===
  sl.registerFactory<ProtectedResourceCubit>(
    () => ProtectedResourceCubit(
      getProtectedResourceUseCase: sl<GetProtectedResource>(),
    ),
  );

  // === Domain Layer (Use Cases) ===
  sl.registerLazySingleton<GetProtectedResource>(
    () => GetProtectedResource(
      protectedResourceRepository: sl<ProtectedResourceRepository>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // === Data Layer (Repositories & Data Sources) ===
  sl.registerLazySingleton<ProtectedResourceRepository>(
    () => ProtectedResourceRepositoryImpl(
      remoteDataSource: sl<ProtectedResourceRemoteDataSourceImpl>(),
    ),
  );
  // Register the abstract type with its concrete implementation
  sl.registerLazySingleton<ProtectedResourceRemoteDataSourceImpl>(
    () => ProtectedResourceRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // External dependencies (like Dio) should be registered in a more central injector.
}
