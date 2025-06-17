import 'dart:async';

import 'package:cidaas_poc/auth/domain/entities/user.dart';
import 'package:cidaas_poc/auth/presentation/cubit/auth_cubit.dart';
import 'package:cidaas_poc/auth/presentation/pages/auth_pages.dart';
import 'package:cidaas_poc/auth/presentation/pages/welcome_pages.dart';
import 'package:cidaas_poc/protected_resource/presentation/cubit/protected_resource_cubit.dart';
import 'package:cidaas_poc/protected_resource/presentation/pages/protected_resource_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) {
        final User user = state.extra as User;
        return CustomTransitionPage(
          key: state.pageKey,
          child: WelcomePage(user: user),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tweenOffset = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            );
            final tweenOpacity = Tween<double>(begin: 0, end: 1);

            return SlideTransition(
              position: animation.drive(tweenOffset),
              child: FadeTransition(
                opacity: animation.drive(tweenOpacity),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/protected-resource',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => GetIt.instance<ProtectedResourceCubit>(),
          child: const ProtectedResourcePage(),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Error al navegar: ${state.error}')),
  ),
  redirect: (BuildContext context, GoRouterState state) {
    final authCubit = context.read<AuthCubit>();
    final bool loggedIn = authCubit.state is AuthSuccess;

    final bool goingToLogin = state.fullPath == '/';
    if (goingToLogin && loggedIn) {
      return '/welcome';
    }

    final bool goingToProtectedResource =
        state.fullPath == '/protected-resource';
    if (goingToProtectedResource && !loggedIn) {
      return '/';
    }

    final bool goingToWelcome = state.fullPath == '/welcome';
    if (goingToWelcome && !loggedIn) {
      return '/';
    }
    return null;
  },
);
