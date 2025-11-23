import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/navigation/app_routes.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsProvider);
    final settings = settingsState.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Language Section
          _SectionHeader(title: 'Preferences'),
          _SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _getLanguageName(settings.language),
            onTap: () => _showLanguageDialog(context),
          ),
          _SettingsTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: _getThemeName(settings.theme),
            onTap: () => _showThemeDialog(context),
          ),
          _SettingsTile(
            icon: Icons.currency_rupee,
            title: 'Currency',
            subtitle: settings.currency,
            onTap: () => _showCurrencyDialog(context),
          ),

          const Divider(height: 32),

          // Backup & Data Section
          _SectionHeader(title: 'Backup & Data'),
          _SettingsTile(
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Manage your data backups',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.backupRestore);
            },
          ),
          _SettingsTile(
            icon: Icons.file_download,
            title: 'Export Data',
            subtitle: 'Export to CSV or Excel',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.exportData);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.backup_outlined),
            title: const Text('Auto Backup'),
            subtitle: Text(
              settings.autoBackupEnabled
                  ? 'Every ${settings.autoBackupIntervalDays} days'
                  : 'Disabled',
            ),
            value: settings.autoBackupEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleAutoBackup(value);
            },
          ),

          if (settings.autoBackupEnabled)
            _SettingsTile(
              icon: Icons.schedule,
              title: 'Backup Interval',
              subtitle: '${settings.autoBackupIntervalDays} days',
              onTap: () => _showBackupIntervalDialog(context),
            ),

          const Divider(height: 32),

          // Business Section
          _SectionHeader(title: 'Business'),
          _SettingsTile(
            icon: Icons.business,
            title: 'Business Profile',
            subtitle: 'Manage business information',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.businessProfile);
            },
          ),

          const Divider(height: 32),

          // Help & Support Section
          _SectionHeader(title: 'Help & Support'),
          _SettingsTile(
            icon: Icons.help,
            title: 'Help Center',
            subtitle: 'Get help and support',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement help center
            },
          ),
          _SettingsTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            subtitle: 'Share your thoughts',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Use FeedbackService
            },
          ),
          _SettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version $_appVersion',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.about);
            },
          ),

          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'Hisaab - Digital Khatabook',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Version $_appVersion',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी (Hindi)';
      default:
        return code;
    }
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System Default';
      default:
        return theme;
    }
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final settingsState = ref.read(settingsProvider);
    final currentLanguage = settingsState.settings.language;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('हिंदी (Hindi)'),
              value: 'hi',
              groupValue: currentLanguage,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      await ref.read(settingsProvider.notifier).updateLanguage(selected);
    }
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final settingsState = ref.read(settingsProvider);
    final currentTheme = settingsState.settings.theme;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: currentTheme,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: currentTheme,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('System Default'),
              value: 'system',
              groupValue: currentTheme,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      await ref.read(settingsProvider.notifier).updateTheme(selected);
    }
  }

  Future<void> _showCurrencyDialog(BuildContext context) async {
    final settingsState = ref.read(settingsProvider);
    final currentCurrency = settingsState.settings.currency;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('INR (₹)'),
              value: 'INR',
              groupValue: currentCurrency,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('USD ($)'),
              value: 'USD',
              groupValue: currentCurrency,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('EUR (€)'),
              value: 'EUR',
              groupValue: currentCurrency,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      await ref.read(settingsProvider.notifier).updateCurrency(selected);
    }
  }

  Future<void> _showBackupIntervalDialog(BuildContext context) async {
    final settingsState = ref.read(settingsProvider);
    final currentInterval = settingsState.settings.autoBackupIntervalDays;

    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Daily'),
              value: 1,
              groupValue: currentInterval,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('Every 3 days'),
              value: 3,
              groupValue: currentInterval,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('Weekly'),
              value: 7,
              groupValue: currentInterval,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('Every 2 weeks'),
              value: 14,
              groupValue: currentInterval,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('Monthly'),
              value: 30,
              groupValue: currentInterval,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      await ref.read(settingsProvider.notifier).updateAutoBackupInterval(selected);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
