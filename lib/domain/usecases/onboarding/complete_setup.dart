import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/onboarding_repository.dart';

/// Use case for completing setup wizard
class CompleteSetup {
  final OnboardingRepository repository;

  CompleteSetup(this.repository);

  Future<Either<Failure, void>> call() async {
    return repository.completeSetup();
  }
}
