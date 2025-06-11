import 'package:dartz/dartz.dart';
import 'package:cidaas_poc/core/error/failures.dart';
import 'package:cidaas_poc/core/usecase/usecase.dart';
import 'package:cidaas_poc/auth/domain/repositories/auth_repository.dart';

class SignOut implements UseCase<void, String> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(String idToken) async {
    return await repository.signOut(idToken);
  }
}
