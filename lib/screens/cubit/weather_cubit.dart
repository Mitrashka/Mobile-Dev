import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/preference_history.dart';
import '../../models/weather_reading.dart';
import '../../requests/weather_api.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({WeatherApi? api})
    : _api = api ?? WeatherApi(),
      super(const WeatherState(isBusy: true));

  final WeatherApi _api;
  final _history = PreferenceHistory<WeatherReading>(
    key: 'weather_history',
    fromJson: WeatherReading.fromJson,
    toJson: (reading) => reading.toJson(),
  );

  bool get hasApiKey => _api.hasApiKey;

  Future<void> loadHistory() async {
    try {
      final history = await _history.load();
      if (!isClosed) emit(WeatherState(history: history));
    } catch (_) {
      if (!isClosed) {
        emit(
          const WeatherState(message: 'Не удалось загрузить историю запросов'),
        );
      }
    }
  }

  Future<void> search(String query) async {
    final city = query.trim();
    if (state.isBusy || city.isEmpty) return;
    final previous = state;
    emit(
      WeatherState(
        history: previous.history,
        current: previous.current,
        isBusy: true,
      ),
    );

    WeatherReading reading;
    try {
      reading = await _api.fetchCurrentWeather(city);
    } on WeatherApiException catch (error) {
      _showSearchError(previous, error.message);
      return;
    } catch (_) {
      _showSearchError(previous, 'Не удалось загрузить погоду');
      return;
    }
    if (isClosed) return;

    try {
      final history = await _history.add(reading);
      if (!isClosed) emit(WeatherState(history: history, current: reading));
    } catch (_) {
      if (!isClosed) {
        emit(
          WeatherState(
            history: previous.history,
            current: reading,
            message: 'Не удалось сохранить запрос в истории',
          ),
        );
      }
    }
  }

  void _showSearchError(WeatherState previous, String message) {
    if (!isClosed) {
      emit(
        WeatherState(
          history: previous.history,
          current: previous.current,
          message: message,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _api.close();
    return super.close();
  }
}

class WeatherState {
  const WeatherState({
    this.history = const [],
    this.current,
    this.isBusy = false,
    this.message,
  });

  final List<WeatherReading> history;
  final WeatherReading? current;
  final bool isBusy;
  final String? message;
}
