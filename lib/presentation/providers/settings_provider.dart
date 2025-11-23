import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/settings.dart';
import '../../domain/usecases/settings/get_settings_usecase.dart';
import '../../domain/usecases/settings/update_language_usecase.dart';
import '../../domain/usecases/settings/update_theme_usecase.dart';
import '../../domain/usecases/settings/update_currency_usecase.dart';
import '../../domain/usecases/settings/toggle_auto_backup_usecase.dart';
import '../../domain/usecases/settings/update_auto_backup_interval_usecase.dart';

/// Settings state
class SettingsState {
  final AppSettings settings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Settings provider
class SettingsNotifier extends StateNotifier<SettingsState> {
  final GetSettingsUseCase _getSettingsUseCase;
  final UpdateLanguageUseCase _updateLanguageUseCase;
  final UpdateThemeUseCase _updateThemeUseCase;
  final UpdateCurrencyUseCase _updateCurrencyUseCase;
  final ToggleAutoBackupUseCase _toggleAutoBackupUseCase;
  final UpdateAutoBackupIntervalUseCase _updateAutoBackupIntervalUseCase;

  SettingsNotifier({
    required GetSettingsUseCase getSettingsUseCase,
    required UpdateLanguageUseCase updateLanguageUseCase,
    required UpdateThemeUseCase updateThemeUseCase,
    required UpdateCurrencyUseCase updateCurrencyUseCase,
    required ToggleAutoBackupUseCase toggleAutoBackupUseCase,
    required UpdateAutoBackupIntervalUseCase updateAutoBackupIntervalUseCase,
    required AppSettings initialSettings,
  })  : _getSettingsUseCase = getSettingsUseCase,
        _updateLanguageUseCase = updateLanguageUseCase,
        _updateThemeUseCase = updateThemeUseCase,
        _updateCurrencyUseCase = updateCurrencyUseCase,
        _toggleAutoBackupUseCase = toggleAutoBackupUseCase,
        _updateAutoBackupIntervalUseCase = updateAutoBackupIntervalUseCase,
        super(SettingsState(settings: initialSettings));

  /// Load settings
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getSettingsUseCase(null);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (settings) => state = state.copyWith(
        isLoading: false,
        settings: settings,
      ),
    );
  }

  /// Update language
  Future<bool> updateLanguage(String language) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateLanguageUseCase(language);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadSettings();
        return true;
      },
    );
  }

  /// Update theme
  Future<bool> updateTheme(String theme) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateThemeUseCase(theme);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadSettings();
        return true;
      },
    );
  }

  /// Update currency
  Future<bool> updateCurrency(String currency) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateCurrencyUseCase(currency);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadSettings();
        return true;
      },
    );
  }

  /// Toggle auto backup
  Future<bool> toggleAutoBackup(bool enabled) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _toggleAutoBackupUseCase(enabled);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadSettings();
        return true;
      },
    );
  }

  /// Update auto backup interval
  Future<bool> updateAutoBackupInterval(int days) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateAutoBackupIntervalUseCase(days);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadSettings();
        return true;
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Quick accessors
  String get currentLanguage => state.settings.language;
  String get currentTheme => state.settings.theme;
  String get currentCurrency => state.settings.currency;
  bool get isAutoBackupEnabled => state.settings.autoBackupEnabled;
  int get autoBackupInterval => state.settings.autoBackupIntervalDays;
  bool get needsBackup => state.settings.needsBackup;
}

// Provider instance (to be configured with dependency injection)
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  throw UnimplementedError('settingsProvider must be overridden with proper dependencies');
});
