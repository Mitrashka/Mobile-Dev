import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dog_images_response.dart';

class DogApi {
  DogApi({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  static const _baseUrl = 'https://dog.ceo/api/breeds/image/random';

  final http.Client _client;
  final Duration requestTimeout;

  Future<List<String>> fetchDogImageUrls({int limit = 10}) async {
    final uri = Uri.parse('$_baseUrl/$limit');
    final response = await _client.get(uri).timeout(requestTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Не удалось загрузить изображения: HTTP ${response.statusCode}',
      );
    }

    late final DogImagesResponse data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException();
      }
      data = DogImagesResponse.fromJson(decoded);
    } on FormatException {
      throw const FormatException('API вернуло некорректный JSON');
    }

    if (data.status != 'success' || data.imageUrls.length != limit) {
      throw const FormatException(
        'API вернуло неполный список изображений собак',
      );
    }

    return data.imageUrls;
  }

  void close() => _client.close();
}
