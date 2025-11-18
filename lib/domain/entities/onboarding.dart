import 'package:equatable/equatable.dart';

/// Onboarding page entity
class OnboardingPage extends Equatable {
  final String title;
  final String subtitle;
  final String imagePath;
  final int pageIndex;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.pageIndex,
  });

  @override
  List<Object?> get props => [title, subtitle, imagePath, pageIndex];
}

/// Business setup wizard step
class SetupWizardStep extends Equatable {
  final String title;
  final String description;
  final int stepIndex;
  final bool isCompleted;

  const SetupWizardStep({
    required this.title,
    required this.description,
    required this.stepIndex,
    this.isCompleted = false,
  });

  SetupWizardStep copyWith({
    String? title,
    String? description,
    int? stepIndex,
    bool? isCompleted,
  }) {
    return SetupWizardStep(
      title: title ?? this.title,
      description: description ?? this.description,
      stepIndex: stepIndex ?? this.stepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [title, description, stepIndex, isCompleted];
}

/// App onboarding state
class OnboardingState extends Equatable {
  final bool hasCompletedOnboarding;
  final bool hasCompletedSetup;
  final int currentOnboardingPage;
  final int currentSetupStep;

  const OnboardingState({
    this.hasCompletedOnboarding = false,
    this.hasCompletedSetup = false,
    this.currentOnboardingPage = 0,
    this.currentSetupStep = 0,
  });

  OnboardingState copyWith({
    bool? hasCompletedOnboarding,
    bool? hasCompletedSetup,
    int? currentOnboardingPage,
    int? currentSetupStep,
  }) {
    return OnboardingState(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      currentOnboardingPage:
          currentOnboardingPage ?? this.currentOnboardingPage,
      currentSetupStep: currentSetupStep ?? this.currentSetupStep,
    );
  }

  @override
  List<Object?> get props => [
        hasCompletedOnboarding,
        hasCompletedSetup,
        currentOnboardingPage,
        currentSetupStep,
      ];
}
