import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/auth/domain/entities/user.dart';
import 'package:cidaas_poc/auth/domain/usecases/sign_in_with_cidaas.dart';
import 'package:cidaas_poc/auth/domain/usecases/sign_out_with_cidaas.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInWithCidaas signInWithCidaasUseCase;
  final SignOut signOutWithCidaasUseCase;

  AuthCubit({
    required this.signInWithCidaasUseCase,
    required this.signOutWithCidaasUseCase,
  }) : super(AuthInitial());

  Future<void> signIn() async {
    emit(AuthLoading());
    final result = await signInWithCidaasUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> signOut(String? idToken) async {
    emit(AuthLoading());

    if (idToken == null) {
      debugPrint(
        '>>> DEBUG: AuthCubit: No ID Token available for signOutCidaas.',
      );
      emit(AuthFailure('No ID Token available for logout.'));
      return;
    }

    final result = await signOutWithCidaasUseCase(idToken);
    result.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
      (_) => emit(AuthLoggedOut()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure _:
        return (failure as AuthFailure).message;
      case ServerFailure _:
        return 'Server issues. Please try again later.';
      case NetworkFailure _:
        return 'No Internet connection. Please check your network.';
      case CacheFailure _:
        return 'Local data error.';
      default:
        return 'An unexpected error occurred. ${failure.message}';
    }
  }
}
