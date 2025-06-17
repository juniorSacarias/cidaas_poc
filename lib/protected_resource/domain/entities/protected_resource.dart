import 'package:equatable/equatable.dart';

class ProtectedResource extends Equatable {
  final String data;

  const ProtectedResource({required this.data});

  @override
  List<Object?> get props => [data];
}
