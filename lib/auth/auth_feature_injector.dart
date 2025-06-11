import 'package:cidaas_poc/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cidaas_poc/auth/data/repositories/auth_repository_impl.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';
import 'package:cidaas_poc/auth/domain/usecases/sign_in_with_cidaas.dart';
import 'package:cidaas_poc/auth/domain/usecases/sign_out_with_cidaas.dart';
import 'package:cidaas_poc/auth/presentation/cubit/auth_cubit.dart';
import 'package:cidaas_poc/core/di/injection_container.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

void initAuthFeature() {
  sl.registerFactory(
    () => AuthCubit(
      signInWithCidaasUseCase: sl(),
      signOutWithCidaasUseCase: sl(),
    ),
  );

  // Data Layer

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // External (Infrastructure)
  sl.registerLazySingleton(() => FlutterAppAuth());

  // Domain Layer

  sl.registerLazySingleton(() => SignInWithCidaas(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
}
