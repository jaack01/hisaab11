import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/onboarding.dart';
import '../../repositories/onboarding_repository.dart';

/// Use case for getting onboarding state
class GetOnboardingState {
  final OnboardingRepository repository;

  GetOnboardingState(this.repository);

  Future<Either<Failure, OnboardingState>> call() async {
    return repository.getOnboardingState();
  }
}
