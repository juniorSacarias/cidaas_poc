// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cidaas_poc/core/di/injection_container.dart' as di;
import 'package:cidaas_poc/auth/presentation/cubit/auth_cubit.dart';
import 'package:cidaas_poc/auth/presentation/pages/auth_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env.development");

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appName = dotenv.env['APP_NAME'] ?? 'Cidaas Auth PoC (Dev)';
    final currentEnvironment = dotenv.env['ENVIRONMENT'] ?? 'development';

    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: currentEnvironment == 'development'
              ? Colors.blue.shade700
              : currentEnvironment == 'staging'
              ? Colors.orange.shade700
              : Colors.blue,
        ),
      ),
      home: BlocProvider(
        create: (context) => di.sl<AuthCubit>(),
        child: const LoginPage(),
      ),
    );
  }
}
