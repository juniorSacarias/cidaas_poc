import 'package:cidaas_poc/auth/auth_feature_injector.dart' as auth_di;
import 'package:cidaas_poc/protected_resource/protected_resource_injector.dart'
    as protected_resource_di;
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<Dio>(() => Dio());
  auth_di.initAuthFeature();
  protected_resource_di.initProtectedResourceFeature();
}
