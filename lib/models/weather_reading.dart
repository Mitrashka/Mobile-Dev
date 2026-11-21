class WeatherReading {
  const WeatherReading({
    required this.city,
    required this.temperature,
    required this.description,
    required this.requestedAt,
    this.cityId,
  });

  final String city;
  final double temperature;
  final String description;
  final DateTime requestedAt;
  final int? cityId;

  factory WeatherReading.fromApi(Map<String, dynamic> json, String city) {
    final main = json['main'];
    final weather = json['weather'];
    final firstCondition = weather is List && weather.isNotEmpty
        ? weather.first
        : null;
    final temperature = main is Map ? main['temp'] : null;
    final description = firstCondition is Map
        ? firstCondition['description']
        : null;
    final id = json['id'];

    if (temperature is! num ||
        !temperature.isFinite ||
        description is! String ||
        description.trim().isEmpty) {
      throw const FormatException();
    }
    return WeatherReading(
      city: city,
      temperature: temperature.toDouble(),
      description: description,
      requestedAt: DateTime.now(),
      cityId: id is int && id > 0 ? id : null,
    );
  }

  factory WeatherReading.fromJson(Map<String, dynamic> json) => WeatherReading(
    city: json['city'] as String,
    temperature: (json['temperature'] as num).toDouble(),
    description: json['description'] as String,
    requestedAt: DateTime.parse(json['requested_at'] as String),
    cityId: json['city_id'] as int?,
  );

  Map<String, Object?> toJson() => {
    'city': city,
    'temperature': temperature,
    'description': description,
    'requested_at': requestedAt.toIso8601String(),
    'city_id': cityId,
  };
}
