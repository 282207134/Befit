enum ActivityKind {
  walking('Walking', 'walk', 4.5),
  running('Running', 'running', 9),
  cycling('Cycling', 'bike-bicycle', 18.9);

  const ActivityKind(this.label, this.asset, this.speed);
  final String label;
  final String asset;
  final double speed;
}

class ActivityRecord {
  const ActivityRecord({
    required this.kind,
    required this.seconds,
    required this.distance,
    required this.date,
  });
  final ActivityKind kind;
  final int seconds;
  final double distance;
  final DateTime date;
  int get calories =>
      (seconds / 60 * (kind == ActivityKind.cycling ? 8 : 6)).round();

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'seconds': seconds,
    'distance': distance,
    'date': date.toIso8601String(),
  };

  factory ActivityRecord.fromJson(Map<String, dynamic> json) => ActivityRecord(
    kind: ActivityKind.values.byName(json['kind'] as String),
    seconds: json['seconds'] as int,
    distance: (json['distance'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
  );
}

String clockText(int seconds, {bool hours = false}) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return hours
      ? '${(seconds ~/ 3600).toString().padLeft(2, '0')}:${((seconds ~/ 60) % 60).toString().padLeft(2, '0')}:$rest'
      : '$minutes:$rest';
}

const challengeItems = [
  (id: 'rope', title: 'Battle Rope', image: 'cardio', minutes: 5),
  (id: 'yoga', title: 'Yoga', image: 'yoga', minutes: 10),
  (id: 'cycling', title: 'Cycling', image: 'cycling', minutes: 30),
  (id: 'meditation', title: 'Meditation', image: 'meditation', minutes: 15),
];
