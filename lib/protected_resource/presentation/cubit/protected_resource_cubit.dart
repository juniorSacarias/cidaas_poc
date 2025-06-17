import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/core/usecase/usecase.dart';
import 'package:cidaas_poc/protected_resource/domain/entities/protected_resource.dart';
import 'package:cidaas_poc/protected_resource/domain/usecases/get_protected_resources.dart';

part 'protected_resource_state.dart';

class ProtectedResourceCubit extends Cubit<ProtectedResourceState> {
  final GetProtectedResource getProtectedResourceUseCase;

  ProtectedResourceCubit({required this.getProtectedResourceUseCase})
    : super(ProtectedResourceInitial());

  Future<void> getResource() async {
    emit(ProtectedResourceLoading());

    final result = await getProtectedResourceUseCase(NoParams());

    result.fold(
      (failure) => emit(ProtectedResourceError(_mapFailureToMessage(failure))),
      (resource) => emit(ProtectedResourceLoaded(resource)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error accessing protected resource.';
      case NetworkFailure _:
        return 'Network error accessing protected resource. Check your connection.';
      case AuthFailure _:
        return 'Authentication required or invalid token for protected resource.';
      case CacheFailure _:
        return 'Local data error accessing protected resource.';
      default:
        return 'An unexpected error occurred: ${failure.message}';
    }
  }
}
