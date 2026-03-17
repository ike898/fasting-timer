import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fast_record.dart';
import '../providers/fasting_provider.dart';
import '../widgets/progress_ring.dart';
import '../services/interstitial_ad_service.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Timer? _ticker;
  int _selectedPresetIndex = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startFast() {
    final preset = FastingPreset.defaults[_selectedPresetIndex];
    ref.read(activeFastProvider.notifier).startFast(preset.fastHours);
  }

  void _endFast() async {
    await ref.read(activeFastProvider.notifier).endFast();
    InterstitialAdService.showIfReady();
  }

  @override
  Widget build(BuildContext context) {
    final activeFast = ref.watch(activeFastProvider);
    final streak = ref.watch(currentStreakProvider);
    final theme = Theme.of(context);

    if (activeFast != null) {
      return _buildFastingView(activeFast, theme);
    }
    return _buildReadyView(streak, theme);
  }

  Widget _buildReadyView(int streak, ThemeData theme) {
    final preset = FastingPreset.defaults[_selectedPresetIndex];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(preset.name,
              style: theme.textTheme.displayMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${preset.fastHours}h fast / ${preset.eatHours}h eat',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            children: List.generate(FastingPreset.defaults.length, (i) {
              final p = FastingPreset.defaults[i];
              return ChoiceChip(
                label: Text(p.name),
                selected: i == _selectedPresetIndex,
                onSelected: (_) => setState(() => _selectedPresetIndex = i),
              );
            }),
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: _startFast,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Fast'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 56),
              backgroundColor: Colors.green,
            ),
          ),
          if (streak > 0) ...[
            const SizedBox(height: 24),
            Text('Streak: $streak days',
                style: theme.textTheme.titleMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildFastingView(FastRecord fast, ThemeData theme) {
    final isComplete = fast.progress >= 1.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isComplete)
            Text('Complete!',
                style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            width: 240,
            height: 240,
            child: ProgressRing(
              progress: fast.progress,
              elapsed: fast.elapsedFormatted,
              target: '${fast.targetHours}:00',
            ),
          ),
          const SizedBox(height: 16),
          Text('${(fast.progress * 100).toInt()}% complete',
              style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
              'Started: ${_formatTime(fast.startTime)}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: _endFast,
            icon: const Icon(Icons.stop),
            label: Text(isComplete ? 'Finish' : 'End Fast'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 56),
              backgroundColor: isComplete ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
