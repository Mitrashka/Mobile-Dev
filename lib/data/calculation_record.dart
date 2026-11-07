class CalculationRecord {
  const CalculationRecord({
    required this.mass,
    required this.radius,
    required this.velocity,
    required this.createdAt,
  });

  final double mass;
  final double radius;
  final double velocity;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
    'mass': mass,
    'radius': radius,
    'velocity': velocity,
    'created_at': createdAt.toIso8601String(),
  };

  factory CalculationRecord.fromMap(Map<String, Object?> map) {
    return CalculationRecord(
      mass: (map['mass'] as num).toDouble(),
      radius: (map['radius'] as num).toDouble(),
      velocity: (map['velocity'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
