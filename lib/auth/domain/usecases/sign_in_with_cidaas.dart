import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/core/usecase/usecase.dart';
import 'package:cidaas_poc/auth/domain/entities/user.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';

class SignInWithCidaas implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithCidaas(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInWithCidaas();
  }
}
