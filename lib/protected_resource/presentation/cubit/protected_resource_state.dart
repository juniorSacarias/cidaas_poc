// lib/protected_resource/presentation/cubit/protected_resource_state.dart

part of 'protected_resource_cubit.dart';

@immutable
abstract class ProtectedResourceState extends Equatable {
  const ProtectedResourceState();

  @override
  List<Object?> get props => [];
}

class ProtectedResourceInitial extends ProtectedResourceState {}

class ProtectedResourceLoading extends ProtectedResourceState {}

class ProtectedResourceLoaded extends ProtectedResourceState {
  final ProtectedResource resource;
  const ProtectedResourceLoaded(this.resource);

  @override
  List<Object?> get props => [resource];
}

class ProtectedResourceError extends ProtectedResourceState {
  final String message;
  const ProtectedResourceError(this.message);

  @override
  List<Object?> get props => [message];
}
