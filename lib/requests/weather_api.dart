import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_reading.dart';

class WeatherApi {
  WeatherApi({
    http.Client? client,
    String apiKey = const String.fromEnvironment('OPENWEATHERMAP_API_KEY'),
  }) : _client = client ?? http.Client(),
       _apiKey = apiKey.trim();

  static const _host = 'api.openweathermap.org';
  final http.Client _client;
  final String _apiKey;

  bool get hasApiKey => _apiKey.isNotEmpty;

  Future<WeatherReading> fetchCurrentWeather(String query) async {
    if (!hasApiKey) {
      throw const WeatherApiException(
        'Укажите ключ OpenWeatherMap при запуске',
      );
    }
    try {
      final places = await _get('/geo/1.0/direct', {'q': query, 'limit': '1'});
      if (places is! List) throw const FormatException();
      if (places.isEmpty) {
        throw const WeatherApiException('Город не найден');
      }
      final place = places.first;
      if (place is! Map<String, dynamic>) throw const FormatException();
      final latitude = place['lat'];
      final longitude = place['lon'];
      if (latitude is! num || longitude is! num) throw const FormatException();

      final response = await _get('/data/2.5/weather', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'units': 'metric',
        'lang': 'ru',
      });
      if (response is! Map<String, dynamic>) throw const FormatException();

      final localNames = place['local_names'];
      final russianName = localNames is Map ? localNames['ru'] : null;
      final name = russianName ?? place['name'] ?? response['name'] ?? query;
      final country = place['country'];
      final city = country is String && country.isNotEmpty
          ? '$name, $country'
          : name.toString();
      return WeatherReading.fromApi(response, city);
    } on FormatException {
      throw const WeatherApiException(
        'OpenWeatherMap вернул некорректные данные',
      );
    } on TimeoutException {
      throw const WeatherApiException(
        'Превышено время ожидания ответа сервера',
      );
    } on http.ClientException {
      throw const WeatherApiException(
        'Не удалось подключиться к OpenWeatherMap',
      );
    }
  }

  Future<Object?> _get(String path, Map<String, String> parameters) async {
    final uri = Uri.https(_host, path, {...parameters, 'appid': _apiKey});
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    switch (response.statusCode) {
      case 200:
        return jsonDecode(utf8.decode(response.bodyBytes));
      case 401:
        throw const WeatherApiException(
          'Ключ OpenWeatherMap недействителен или ещё не активирован',
        );
      case 404:
        throw const WeatherApiException('Нет данных о погоде для этого города');
      case 429:
        throw const WeatherApiException(
          'Превышен лимит запросов OpenWeatherMap',
        );
      default:
        throw WeatherApiException(
          'Не удалось загрузить погоду (HTTP ${response.statusCode})',
        );
    }
  }

  void close() => _client.close();
}

class WeatherApiException implements Exception {
  const WeatherApiException(this.message);

  final String message;
}
