import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../requests/dog_api.dart';
import 'dog_images_state.dart';

class DogImagesCubit extends Cubit<DogImagesState> {
  DogImagesCubit({DogApi? api})
    : _api = api ?? DogApi(),
      super(DogImagesInitial());

  final DogApi _api;

  Future<void> loadDogs() async {
    emit(DogImagesLoading());

    try {
      final imageUrls = await _api.fetchDogImageUrls();
      emit(DogImagesLoaded(imageUrls: imageUrls));
    } catch (error) {
      emit(DogImagesError(message: _messageFromError(error)));
    }
  }

  String _messageFromError(Object error) {
    if (error is TimeoutException) {
      return 'Превышено время ожидания ответа сервера';
    }
    if (error is FormatException) {
      return error.message.toString();
    }
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'Произошла непредвиденная ошибка';
  }

  @override
  Future<void> close() {
    _api.close();
    return super.close();
  }
}
