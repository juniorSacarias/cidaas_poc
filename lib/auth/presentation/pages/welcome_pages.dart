import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cidaas_poc/auth/domain/entities/user.dart';
import 'package:cidaas_poc/auth/presentation/cubit/auth_cubit.dart';
import 'package:cidaas_poc/auth/presentation/pages/auth_pages.dart';

class WelcomePage extends StatelessWidget {
  final User user;

  const WelcomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully!')),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout Error: ${state.message}')),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello, ${user.name}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'You have successfully logged in.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  context.go(
                    '/protected-resource',
                  ); // Navegar al recurso protegido
                },
                child: const Text('Go to Protected Resource'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthCubit>().signOut(user.idToken);
                  context.go('/');
                },
                child: const Text('Log Out'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<AuthCubit>()
                      .refreshSession(); // Llama al método de refresco
                },
                child: const Text('Refresh Session (for testing)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
