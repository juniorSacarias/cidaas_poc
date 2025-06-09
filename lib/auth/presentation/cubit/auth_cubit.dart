import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/auth/domain/entities/user.dart';
import 'package:cidaas_poc/auth/domain/usecases/sign_in_with_cidaas.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInWithCidaas signInWithCidaasUseCase;

  AuthCubit({required this.signInWithCidaasUseCase}) : super(AuthInitial());

  Future<void> signIn() async {
    emit(AuthLoading());
    final result = await signInWithCidaasUseCase(NoParams());
    result.fold(
      (failure) => emit(
        AuthFailure(_mapFailureToMessage(failure)),
      ), // Aquí se usa el Failure
      (user) => emit(AuthSuccess(user)),
    );
  }

  // Helper para mapear fallos a mensajes de UI
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure _:
        // Mensaje directo del fallo de autenticación
        return (failure as AuthFailure).message;
      case ServerFailure _:
        return 'Problemas con el servidor. Inténtelo más tarde.';
      case NetworkFailure _:
        return 'No hay conexión a Internet. Verifique su red.';
      case CacheFailure _:
        return 'Error de datos locales.';
      default:
        return 'Ocurrió un error inesperado. ${failure.message}';
    }
  }
}
