abstract class DogImagesState {}

class DogImagesInitial extends DogImagesState {}

class DogImagesLoading extends DogImagesState {}

class DogImagesLoaded extends DogImagesState {
  DogImagesLoaded({required this.imageUrls});

  final List<String> imageUrls;
}

class DogImagesError extends DogImagesState {
  DogImagesError({required this.message});

  final String message;
}
