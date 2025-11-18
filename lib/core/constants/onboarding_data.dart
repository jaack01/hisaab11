import '../../domain/entities/onboarding.dart';

/// Onboarding pages data
class OnboardingData {
  OnboardingData._();

  static List<OnboardingPage> get pages => [
        const OnboardingPage(
          title: 'Welcome to Hisaab',
          subtitle: 'Manage your business accounts easily',
          imagePath: 'assets/images/onboarding_1.png',
          pageIndex: 0,
        ),
        const OnboardingPage(
          title: 'Track Customers & Transactions',
          subtitle: 'Keep track of who owes you and who you owe',
          imagePath: 'assets/images/onboarding_2.png',
          pageIndex: 1,
        ),
        const OnboardingPage(
          title: 'Generate Reports',
          subtitle: 'Get detailed business insights with professional reports',
          imagePath: 'assets/images/onboarding_3.png',
          pageIndex: 2,
        ),
        const OnboardingPage(
          title: 'Create Invoices',
          subtitle: 'Professional invoices for your business',
          imagePath: 'assets/images/onboarding_4.png',
          pageIndex: 3,
        ),
      ];
}

/// Setup wizard steps data
class SetupWizardData {
  SetupWizardData._();

  static List<SetupWizardStep> get steps => [
        const SetupWizardStep(
          title: 'Business Name',
          description: "What's your business name?",
          stepIndex: 0,
        ),
        const SetupWizardStep(
          title: 'Business Details',
          description: 'Add your business contact information',
          stepIndex: 1,
        ),
        const SetupWizardStep(
          title: 'Complete',
          description: "You're all set to start managing your business!",
          stepIndex: 2,
        ),
      ];
}
