import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cidaas_poc/core/di/injection_container.dart' as di;
import 'package:cidaas_poc/auth/presentation/cubit/auth_cubit.dart';
import 'package:cidaas_poc/auth/presentation/pages/auth_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cidaas Auth PoC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => di.sl<AuthCubit>(),
        child: const LoginPage(),
      ),
    );
  }
}
