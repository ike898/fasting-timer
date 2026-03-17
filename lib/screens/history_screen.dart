import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fasting_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(fastHistoryProvider);
    final theme = Theme.of(context);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) {
        final completed = records.where((r) => !r.isActive).toList();
        if (completed.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('No fasting history yet',
                    style: theme.textTheme.bodyLarge),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completed.length,
          itemBuilder: (context, index) {
            final record = completed[index];
            final hours = record.elapsed.inHours;
            final minutes = record.elapsed.inMinutes.remainder(60);

            return Card(
              child: ListTile(
                leading: Icon(
                  record.wasCompleted
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: record.wasCompleted ? Colors.green : Colors.orange,
                ),
                title: Text('${hours}h ${minutes}m'),
                subtitle: Text(
                    '${record.targetHours}:${24 - record.targetHours} — ${_formatDate(record.startTime)}'),
                trailing: record.note != null
                    ? const Icon(Icons.note, size: 16)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
