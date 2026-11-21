enum TemperatureDirection {
  celsiusToFahrenheit('°C', '°F'),
  fahrenheitToCelsius('°F', '°C');

  const TemperatureDirection(this.fromUnit, this.toUnit);

  final String fromUnit;
  final String toUnit;

  String get label => '$fromUnit → $toUnit';

  double convert(double value) => switch (this) {
    celsiusToFahrenheit => value * 1.8 + 32,
    fahrenheitToCelsius => (value - 32) / 1.8,
  };
}

class TemperatureConversion {
  const TemperatureConversion({
    required this.input,
    required this.result,
    required this.direction,
    required this.createdAt,
  });

  final double input;
  final double result;
  final TemperatureDirection direction;
  final DateTime createdAt;

  String get label =>
      '${_format(input)} ${direction.fromUnit} = '
      '${_format(result)} ${direction.toUnit}';

  static String _format(double value) {
    if (value.abs() >= 1e21 || (value != 0 && value.abs() < 0.005)) {
      return value.toStringAsPrecision(3).replaceAll('.', ',');
    }
    if (value == 0) return '0';
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '')
        .replaceAll('.', ',');
  }

  factory TemperatureConversion.fromJson(Map<String, dynamic> json) =>
      TemperatureConversion(
        input: (json['input'] as num).toDouble(),
        result: (json['result'] as num).toDouble(),
        direction: TemperatureDirection.values.byName(
          json['direction'] as String,
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, Object?> toJson() => {
    'input': input,
    'result': result,
    'direction': direction.name,
    'created_at': createdAt.toIso8601String(),
  };
}
