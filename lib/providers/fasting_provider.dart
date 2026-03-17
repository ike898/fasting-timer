import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/fast_record.dart';

int _counter = 0;
String _generateId() =>
    '${DateTime.now().millisecondsSinceEpoch}_${++_counter}';

// Active fast state
final activeFastProvider =
    StateNotifierProvider<ActiveFastNotifier, FastRecord?>(
        (ref) => ActiveFastNotifier(ref));

class ActiveFastNotifier extends StateNotifier<FastRecord?> {
  final Ref _ref;

  ActiveFastNotifier(this._ref) : super(null) {
    _loadActive();
  }

  Future<void> _loadActive() async {
    final records = await _ref.read(fastHistoryProvider.future);
    final active = records.where((r) => r.isActive).firstOrNull;
    state = active;
  }

  Future<void> startFast(int targetHours) async {
    final record = FastRecord(
      id: _generateId(),
      startTime: DateTime.now(),
      targetHours: targetHours,
    );
    state = record;
    await _ref.read(fastHistoryProvider.notifier).add(record);
  }

  Future<void> endFast({String? note}) async {
    if (state == null) return;
    final now = DateTime.now();
    final completed = state!.progress >= 1.0;
    final ended = state!.copyWith(
      endTime: now,
      note: note,
      wasCompleted: completed,
    );
    state = null;
    await _ref.read(fastHistoryProvider.notifier).updateRecord(ended);
  }
}

// History
final fastHistoryProvider =
    AsyncNotifierProvider<FastHistoryNotifier, List<FastRecord>>(
        FastHistoryNotifier.new);

class FastHistoryNotifier extends AsyncNotifier<List<FastRecord>> {
  @override
  Future<List<FastRecord>> build() => _load();

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/fasts.json');
  }

  Future<List<FastRecord>> _load() async {
    final file = await _file;
    if (!await file.exists()) return [];
    final json = jsonDecode(await file.readAsString()) as List;
    final records =
        json.map((e) => FastRecord.fromJson(e as Map<String, dynamic>)).toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<void> _save(List<FastRecord> records) async {
    final file = await _file;
    await file.writeAsString(
        jsonEncode(records.map((r) => r.toJson()).toList()));
  }

  Future<void> add(FastRecord record) async {
    final current = [...?state.value, record];
    state = AsyncData(current);
    await _save(current);
  }

  Future<void> updateRecord(FastRecord updated) async {
    final current =
        state.value?.map((r) => r.id == updated.id ? updated : r).toList() ??
            [];
    state = AsyncData(current);
    await _save(current);
  }

  Future<void> delete(String id) async {
    final current = state.value?.where((r) => r.id != id).toList() ?? [];
    state = AsyncData(current);
    await _save(current);
  }
}

// Computed stats
final currentStreakProvider = Provider<int>((ref) {
  final history = ref.watch(fastHistoryProvider).value ?? [];
  final completed =
      history.where((r) => r.wasCompleted && !r.isActive).toList();
  if (completed.isEmpty) return 0;

  completed.sort((a, b) => b.startTime.compareTo(a.startTime));
  int streak = 0;
  var checkDate = DateTime.now();

  for (final record in completed) {
    final recordDate = DateTime(
        record.startTime.year, record.startTime.month, record.startTime.day);
    final check =
        DateTime(checkDate.year, checkDate.month, checkDate.day);
    final diff = check.difference(recordDate).inDays;

    if (diff <= 1) {
      streak++;
      checkDate = record.startTime;
    } else {
      break;
    }
  }
  return streak;
});
