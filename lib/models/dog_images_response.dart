class DogImagesResponse {
  const DogImagesResponse({required this.status, required this.imageUrls});

  final String status;
  final List<String> imageUrls;

  factory DogImagesResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final message = json['message'];

    if (status is! String || message is! List<dynamic>) {
      throw const FormatException('Некорректный ответ Dog CEO API');
    }

    final imageUrls = message.map((item) {
      if (item is! String || item.isEmpty) {
        throw const FormatException('Ответ содержит некорректный URL');
      }
      return item;
    }).toList();

    return DogImagesResponse(status: status, imageUrls: imageUrls);
  }
}
