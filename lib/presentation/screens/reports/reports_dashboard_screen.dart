import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';

class ReportsDashboardScreen extends ConsumerWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ReportCard(
            icon: Icons.receipt_long,
            title: 'Ledger Report',
            description: 'Customer-wise transaction history',
            color: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, Routes.ledgerReport);
            },
          ),
          _ReportCard(
            icon: Icons.today,
            title: 'Daybook',
            description: 'Daily transaction summary',
            color: Colors.green,
            onTap: () {
              Navigator.pushNamed(context, Routes.daybookReport);
            },
          ),
          _ReportCard(
            icon: Icons.trending_up,
            title: 'Profit & Loss',
            description: 'Revenue and expense analysis',
            color: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, Routes.profitLossReport);
            },
          ),
          _ReportCard(
            icon: Icons.account_balance,
            title: 'Balance Sheet',
            description: 'Assets and liabilities',
            color: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, Routes.balanceSheetReport);
            },
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
