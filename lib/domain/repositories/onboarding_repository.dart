import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/onboarding.dart';

/// Repository for managing onboarding state
abstract class OnboardingRepository {
  /// Get current onboarding state
  Future<Either<Failure, OnboardingState>> getOnboardingState();

  /// Update onboarding state
  Future<Either<Failure, void>> updateOnboardingState(OnboardingState state);

  /// Mark onboarding as completed
  Future<Either<Failure, void>> completeOnboarding();

  /// Mark setup wizard as completed
  Future<Either<Failure, void>> completeSetup();

  /// Reset onboarding (for testing)
  Future<Either<Failure, void>> resetOnboarding();
}
