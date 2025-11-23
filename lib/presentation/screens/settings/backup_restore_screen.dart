import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart' as app_date;

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _autoBackupEnabled = true;
  String _backupInterval = 'daily';
  bool _isCreatingBackup = false;

  // Mock backup history - will be replaced with actual implementation
  final List<BackupInfo> _backupHistory = [
    BackupInfo(
      id: '1',
      fileName: 'backup_2025_11_23_14_30.db',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
      size: 2.5,
      isAutomatic: true,
    ),
    BackupInfo(
      id: '2',
      fileName: 'backup_2025_11_22_10_15.db',
      timestamp: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
      size: 2.3,
      isAutomatic: true,
    ),
    BackupInfo(
      id: '3',
      fileName: 'backup_manual_2025_11_20.db',
      timestamp: DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch ~/ 1000,
      size: 2.1,
      isAutomatic: false,
    ),
  ];

  Future<void> _createManualBackup() async {
    setState(() => _isCreatingBackup = true);

    // TODO: Implement actual backup creation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isCreatingBackup = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to restore this backup? This will replace all current data.',
            ),
            const SizedBox(height: 16),
            Text('Backup: ${backup.fileName}'),
            Text('Created: ${app_date.AppDateUtils.formatDate(backup.timestamp)}'),
            Text('Size: ${backup.size.toStringAsFixed(2)} MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement actual restore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restore feature coming soon!'),
        ),
      );
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Are you sure you want to delete ${backup.fileName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement actual deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup deleted successfully'),
        ),
      );
    }
  }

  void _showBackupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Backups'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backup Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Manual backups: Create backups anytime'),
              Text('• Automatic backups: Scheduled backups based on interval'),
              Text('• Restore: Restore data from any backup'),
              Text('• Cloud sync: Upload backups to cloud (coming soon)'),
              SizedBox(height: 16),
              Text(
                'What is backed up:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• All customers and contacts'),
              Text('• All transactions (credit/debit)'),
              Text('• All invoices and items'),
              Text('• All expenses and reminders'),
              Text('• Business settings'),
              SizedBox(height: 16),
              Text(
                'Storage Location:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Backups are stored locally on your device in the app\'s private storage.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showBackupInfo,
            tooltip: 'About Backups',
          ),
        ],
      ),
      body: ListView(
        children: [
          // Manual Backup Section
          _buildSectionHeader('Manual Backup'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.backup,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Backup Now',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manually backup all your data',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isCreatingBackup ? null : _createManualBackup,
                      icon: _isCreatingBackup
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.backup),
                      label: Text(_isCreatingBackup ? 'Creating Backup...' : 'Create Backup'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Automatic Backup Settings
          _buildSectionHeader('Automatic Backup'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  value: _autoBackupEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoBackupEnabled = value;
                    });
                    // TODO: Save to settings
                  },
                  title: const Text('Enable Auto-Backup'),
                  subtitle: const Text('Automatically backup data at regular intervals'),
                  secondary: const Icon(Icons.schedule),
                ),
                if (_autoBackupEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text('Backup Interval'),
                    subtitle: Text(_formatInterval(_backupInterval)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showIntervalPicker(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Backup History
          _buildSectionHeader('Backup History'),
          if (_backupHistory.isEmpty)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text('No backups found'),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first backup to get started',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._backupHistory.map((backup) => _buildBackupCard(backup)),

          const SizedBox(height: 16),

          // Storage Info
          _buildSectionHeader('Storage Information'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Backups:'),
                      Text(
                        '${_backupHistory.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Size:'),
                      Text(
                        '${_calculateTotalSize().toStringAsFixed(2)} MB',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Last Backup:'),
                      Text(
                        _backupHistory.isNotEmpty
                            ? app_date.AppDateUtils.formatDate(_backupHistory.first.timestamp)
                            : 'Never',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cloud Backup (Coming Soon)
          _buildSectionHeader('Cloud Backup'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.cloud_upload,
                color: Colors.grey.shade400,
              ),
              title: const Text('Cloud Sync'),
              subtitle: const Text('Coming soon! Upload backups to Google Drive'),
              trailing: Chip(
                label: const Text(
                  'Coming Soon',
                  style: TextStyle(fontSize: 11),
                ),
                backgroundColor: Colors.orange.shade100,
                labelStyle: const TextStyle(color: Colors.orange),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildBackupCard(BackupInfo backup) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backup.isAutomatic ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            backup.isAutomatic ? Icons.schedule : Icons.backup,
            color: backup.isAutomatic ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(
          backup.fileName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(app_date.AppDateUtils.formatDate(backup.timestamp)),
            const SizedBox(height: 2),
            Row(
              children: [
                Text('${backup.size.toStringAsFixed(2)} MB'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: backup.isAutomatic
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    backup.isAutomatic ? 'Auto' : 'Manual',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: backup.isAutomatic ? Colors.blue : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Restore'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'restore':
                _restoreBackup(backup);
                break;
              case 'share':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon!')),
                );
                break;
              case 'delete':
                _deleteBackup(backup);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showIntervalPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.looks_one),
              title: const Text('Daily'),
              trailing: _backupInterval == 'daily' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _backupInterval = 'daily');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_week),
              title: const Text('Weekly'),
              trailing: _backupInterval == 'weekly' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _backupInterval = 'weekly');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Monthly'),
              trailing: _backupInterval == 'monthly' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _backupInterval = 'monthly');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatInterval(String interval) {
    switch (interval) {
      case 'daily':
        return 'Every day';
      case 'weekly':
        return 'Every week';
      case 'monthly':
        return 'Every month';
      default:
        return interval;
    }
  }

  double _calculateTotalSize() {
    return _backupHistory.fold(0.0, (sum, backup) => sum + backup.size);
  }
}

class BackupInfo {
  final String id;
  final String fileName;
  final int timestamp;
  final double size; // Size in MB
  final bool isAutomatic;

  BackupInfo({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.size,
    required this.isAutomatic,
  });
}
