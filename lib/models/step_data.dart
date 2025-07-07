class StepData {
  final DateTime date;
  final int steps;
  final double calories;
  final double distance;
  final Duration activeTime;
  final bool goalAchieved;
  final int? id;

  StepData({
    required this.date,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.activeTime,
    required this.goalAchieved,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'activeTimeMinutes': activeTime.inMinutes,
      'goalAchieved': goalAchieved ? 1 : 0,
    };
  }

  factory StepData.fromMap(Map<String, dynamic> map) {
    return StepData(
      id: map['id']?.toInt(),
      date: DateTime.parse(map['date']),
      steps: map['steps']?.toInt() ?? 0,
      calories: map['calories']?.toDouble() ?? 0.0,
      distance: map['distance']?.toDouble() ?? 0.0,
      activeTime: Duration(minutes: map['activeTimeMinutes']?.toInt() ?? 0),
      goalAchieved: (map['goalAchieved'] ?? 0) == 1,
    );
  }

  StepData copyWith({
    DateTime? date,
    int? steps,
    double? calories,
    double? distance,
    Duration? activeTime,
    bool? goalAchieved,
    int? id,
  }) {
    return StepData(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      distance: distance ?? this.distance,
      activeTime: activeTime ?? this.activeTime,
      goalAchieved: goalAchieved ?? this.goalAchieved,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return 'StepData(id: $id, date: $date, steps: $steps, calories: $calories, distance: $distance, activeTime: $activeTime, goalAchieved: $goalAchieved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StepData &&
        other.date == date &&
        other.steps == steps &&
        other.calories == calories &&
        other.distance == distance &&
        other.activeTime == activeTime &&
        other.goalAchieved == goalAchieved &&
        other.id == id;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        steps.hashCode ^
        calories.hashCode ^
        distance.hashCode ^
        activeTime.hashCode ^
        goalAchieved.hashCode ^
        id.hashCode;
  }
}
