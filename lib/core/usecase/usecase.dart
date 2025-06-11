import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  List<Object?> get props => [];
}
