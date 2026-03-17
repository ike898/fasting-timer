class FastRecord {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int targetHours;
  final String? note;
  final bool wasCompleted;
  final DateTime createdAt;

  FastRecord({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.targetHours,
    this.note,
    this.wasCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isActive => endTime == null;

  Duration get elapsed =>
      (endTime ?? DateTime.now()).difference(startTime);

  double get progress =>
      (elapsed.inMinutes / (targetHours * 60)).clamp(0.0, 1.0);

  String get elapsedFormatted {
    final d = elapsed;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  FastRecord copyWith({
    DateTime? endTime,
    String? note,
    bool? wasCompleted,
  }) {
    return FastRecord(
      id: id,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      targetHours: targetHours,
      note: note ?? this.note,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'targetHours': targetHours,
        'note': note,
        'wasCompleted': wasCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FastRecord.fromJson(Map<String, dynamic> json) => FastRecord(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        targetHours: json['targetHours'] as int,
        note: json['note'] as String?,
        wasCompleted: json['wasCompleted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class FastingPreset {
  final String name;
  final int fastHours;
  final int eatHours;

  const FastingPreset({
    required this.name,
    required this.fastHours,
    required this.eatHours,
  });

  static const defaults = [
    FastingPreset(name: '16:8', fastHours: 16, eatHours: 8),
    FastingPreset(name: '18:6', fastHours: 18, eatHours: 6),
    FastingPreset(name: '20:4', fastHours: 20, eatHours: 4),
    FastingPreset(name: 'OMAD', fastHours: 23, eatHours: 1),
    FastingPreset(name: '36h', fastHours: 36, eatHours: 12),
    FastingPreset(name: '48h', fastHours: 48, eatHours: 24),
  ];
}
