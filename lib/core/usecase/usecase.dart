// lib/core/usecases/usecase.dart

import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';

/// Abstract base class for Use Cases.
///
/// [Type] is the type of the output of the Use Case.
/// [Params] is the type of the input parameters for the Use Case.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Represents a Use Case that doesn't require any input parameters.
class NoParams {
  @override
  List<Object?> get props => []; // Use Equatable or override hashCode/== if needed for comparison
}
