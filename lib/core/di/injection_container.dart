import 'package:cidaas_poc/auth/auth_feature_injector.dart' as auth_di;
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  auth_di.initAuthFeature();
}
