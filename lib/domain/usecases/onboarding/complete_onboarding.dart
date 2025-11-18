import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/onboarding_repository.dart';

/// Use case for completing onboarding
class CompleteOnboarding {
  final OnboardingRepository repository;

  CompleteOnboarding(this.repository);

  Future<Either<Failure, void>> call() async {
    return repository.completeOnboarding();
  }
}
