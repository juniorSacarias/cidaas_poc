import 'package:cidaas_poc/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cidaas_poc/auth/data/repositories/auth_repository_impl.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';
import 'package:cidaas_poc/auth/domain/usecases/refresh_user_session.dart';
import 'package:cidaas_poc/auth/domain/usecases/sign_in_with_cidaas.dart';
import 'package:cidaas_poc/auth/domain/usecases/sign_out_with_cidaas.dart';
import 'package:cidaas_poc/auth/presentation/cubit/auth_cubit.dart';
import 'package:cidaas_poc/core/di/injection_container.dart';
import 'package:cidaas_poc/core/platform/secure_local_storage.dart';
import 'package:cidaas_poc/core/platform/secure_local_storage_impl.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void initAuthFeature() {
  sl.registerFactory(
    () => AuthCubit(
      signInWithCidaasUseCase: sl(),
      signOutWithCidaasUseCase: sl(),
      refreshUserSessionUseCase: sl(),
    ),
  );

  // Data Layer

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<SecureLocalStorage>(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // External (Infrastructure)
  sl.registerLazySingleton(() => FlutterAppAuth());
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<SecureLocalStorage>(
    () => SecureLocalStorageImpl(sl()),
  );

  // Domain Layer

  sl.registerLazySingleton(() => SignInWithCidaas(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => RefreshUserSession(sl()));
}
