import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/onboarding.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// Implementation of OnboardingRepository using SharedPreferences
class OnboardingRepositoryImpl implements OnboardingRepository {
  static const String _keyCompletedOnboarding = 'onboarding_completed';
  static const String _keyCompletedSetup = 'setup_completed';
  static const String _keyCurrentOnboardingPage = 'onboarding_current_page';
  static const String _keyCurrentSetupStep = 'setup_current_step';

  @override
  Future<Either<Failure, OnboardingState>> getOnboardingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final state = OnboardingState(
        hasCompletedOnboarding: prefs.getBool(_keyCompletedOnboarding) ?? false,
        hasCompletedSetup: prefs.getBool(_keyCompletedSetup) ?? false,
        currentOnboardingPage: prefs.getInt(_keyCurrentOnboardingPage) ?? 0,
        currentSetupStep: prefs.getInt(_keyCurrentSetupStep) ?? 0,
      );

      return Right(state);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOnboardingState(
    OnboardingState state,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        _keyCompletedOnboarding,
        state.hasCompletedOnboarding,
      );
      await prefs.setBool(
        _keyCompletedSetup,
        state.hasCompletedSetup,
      );
      await prefs.setInt(
        _keyCurrentOnboardingPage,
        state.currentOnboardingPage,
      );
      await prefs.setInt(
        _keyCurrentSetupStep,
        state.currentSetupStep,
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyCompletedOnboarding, true);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyCompletedSetup, true);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCompletedOnboarding);
      await prefs.remove(_keyCompletedSetup);
      await prefs.remove(_keyCurrentOnboardingPage);
      await prefs.remove(_keyCurrentSetupStep);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
