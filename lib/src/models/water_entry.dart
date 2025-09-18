class WaterEntry {
  final DateTime at;
  final int ml;
  WaterEntry({required this.at, required this.ml});

  Map<String, dynamic> toJson() => {'at': at.toIso8601String(), 'ml': ml};

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(at: DateTime.parse(json['at'] as String), ml: json['ml'] as int);
  }
}
