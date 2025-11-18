import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/settings.dart';
import '../../repositories/settings_repository.dart';

/// Use case for updating application settings
class UpdateSettings {
  final SettingsRepository repository;

  UpdateSettings(this.repository);

  Future<Either<Failure, void>> call(AppSettings settings) async {
    // Validate settings
    if (!_isValidLanguage(settings.language)) {
      return Left(ValidationFailure(message: 'Invalid language code'));
    }

    if (!_isValidTheme(settings.theme)) {
      return Left(ValidationFailure(message: 'Invalid theme'));
    }

    if (!_isValidDateFormat(settings.dateFormat)) {
      return Left(ValidationFailure(message: 'Invalid date format'));
    }

    if (settings.autoBackupIntervalDays < 1) {
      return Left(
        ValidationFailure(message: 'Auto backup interval must be at least 1 day'),
      );
    }

    return repository.updateSettings(settings);
  }

  bool _isValidLanguage(String language) {
    return ['en', 'hi'].contains(language);
  }

  bool _isValidTheme(String theme) {
    return ['light', 'dark', 'system'].contains(theme);
  }

  bool _isValidDateFormat(String format) {
    return [
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'yyyy-MM-dd',
    ].contains(format);
  }
}
