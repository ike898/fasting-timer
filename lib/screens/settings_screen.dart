import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Notifications section
        Text('Notifications', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Fast Complete'),
                subtitle: const Text('Notify when your fast goal is reached'),
                value: true,
                onChanged: (_) {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Eating Window'),
                subtitle: const Text('Remind before eating window closes'),
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Premium section
        Text('Premium', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (isPremium)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 32),
                  const SizedBox(width: 16),
                  Text('Premium Active',
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.green)),
                ],
              ),
            ),
          )
        else
        Card(
          child: InkWell(
            onTap: () => _showPremiumSheet(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upgrade to Premium',
                            style: theme.textTheme.titleSmall),
                        Text('No ads, custom presets, CSV export',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('\$2.99',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Data section
        Text('Data', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Export CSV'),
                subtitle: const Text('Premium feature'),
                trailing: const Icon(Icons.lock, size: 16),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                title: Text('Reset All Data',
                    style: TextStyle(color: theme.colorScheme.error)),
                onTap: () => _showResetDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // About section
        Text('About', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.star_rate),
                title: const Text('Rate App'),
                onTap: () {},
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('Version'),
                trailing: Text('1.0.0'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPremiumSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 48),
            const SizedBox(height: 16),
            Text('Go Premium', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            const _PremiumFeature(text: 'No ads, ever'),
            const _PremiumFeature(text: 'Unlimited custom presets'),
            const _PremiumFeature(text: 'Detailed statistics'),
            const _PremiumFeature(text: 'CSV export'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(purchaseServiceProvider).buyPremium();
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Buy — \$2.99'),
            ),
            const SizedBox(height: 8),
            Text('One-time purchase. Pay once, keep forever.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            TextButton(
              onPressed: () {
                ref.read(purchaseServiceProvider).restorePurchases();
              },
              child: const Text('Restore Purchase'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
            'This will permanently delete all fasting records. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  final String text;
  const _PremiumFeature({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
