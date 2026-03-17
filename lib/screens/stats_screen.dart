import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/fasting_provider.dart';
import '../models/fast_record.dart';
import '../widgets/banner_ad_widget.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(fastHistoryProvider);
    final streak = ref.watch(currentStreakProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) {
        final completed = records.where((r) => !r.isActive && r.wasCompleted).toList();
        if (completed.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart, size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Complete your first fast to see stats',
                    style: theme.textTheme.bodyLarge),
              ],
            ),
          );
        }

        final weekRecords = _getWeekRecords(completed);
        final totalHours = completed.fold<double>(
            0, (sum, r) => sum + r.elapsed.inMinutes / 60);
        final avgHours = totalHours / completed.length;
        final longestHours = completed
            .map((r) => r.elapsed.inMinutes / 60)
            .reduce((a, b) => a > b ? a : b);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  _StatCard(
                    label: 'Total',
                    value: '${totalHours.toStringAsFixed(0)}h',
                    icon: Icons.timer,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    label: 'Average',
                    value: '${avgHours.toStringAsFixed(1)}h',
                    icon: Icons.trending_up,
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatCard(
                    label: 'Longest',
                    value: '${longestHours.toStringAsFixed(1)}h',
                    icon: Icons.emoji_events,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    label: 'Streak',
                    value: '$streak days',
                    icon: Icons.local_fire_department,
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly chart
              Text('This Week', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 24,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value.toInt() < days.length) {
                              return Text(days[value.toInt()],
                                  style: const TextStyle(fontSize: 10));
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 20,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value % 8 == 0) {
                              return Text('${value.toInt()}h',
                                  style: const TextStyle(fontSize: 10));
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: List.generate(7, (i) {
                      final hours = weekRecords[i];
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: hours,
                            color: hours > 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            width: 20,
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Completion rate
              Text('Completed: ${completed.length} fasts',
                  style: theme.textTheme.bodyLarge),
            ],
          ),
        );
      },
    ),
        ),
        const BannerAdWidget(),
      ],
    );
  }

  List<double> _getWeekRecords(List<FastRecord> records) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    final result = List.filled(7, 0.0);
    for (final record in records) {
      final dayIndex = record.startTime.difference(weekStart).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        result[dayIndex] += record.elapsed.inMinutes / 60;
      }
    }
    return result;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
