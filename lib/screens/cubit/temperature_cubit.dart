import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/preference_history.dart';
import '../../models/temperature_conversion.dart';

class TemperatureCubit extends Cubit<TemperatureState> {
  TemperatureCubit() : super(const TemperatureState(isBusy: true));

  final _history = PreferenceHistory<TemperatureConversion>(
    key: 'temperature_conversion_history',
    fromJson: TemperatureConversion.fromJson,
    toJson: (conversion) => conversion.toJson(),
  );

  Future<void> loadHistory() async {
    try {
      final history = await _history.load();
      if (!isClosed) emit(TemperatureState(history: history));
    } catch (_) {
      if (!isClosed) {
        emit(
          const TemperatureState(
            message: 'Не удалось загрузить историю расчётов',
          ),
        );
      }
    }
  }

  Future<void> convert(double input, TemperatureDirection direction) async {
    if (state.isBusy) return;
    final history = state.history;
    final result = direction.convert(input);
    if (!result.isFinite) {
      emit(
        TemperatureState(
          history: history,
          message: 'Результат вне допустимого диапазона',
        ),
      );
      return;
    }

    final conversion = TemperatureConversion(
      input: input,
      result: result,
      direction: direction,
      createdAt: DateTime.now(),
    );
    emit(TemperatureState(history: history, isBusy: true));
    try {
      final updatedHistory = await _history.add(conversion);
      if (!isClosed) emit(TemperatureState(history: updatedHistory));
    } catch (_) {
      if (!isClosed) {
        emit(
          TemperatureState(
            history: history,
            unsaved: conversion,
            message: 'Не удалось сохранить расчёт в истории',
          ),
        );
      }
    }
  }
}

class TemperatureState {
  const TemperatureState({
    this.history = const [],
    this.unsaved,
    this.isBusy = false,
    this.message,
  });

  final List<TemperatureConversion> history;
  final TemperatureConversion? unsaved;
  final bool isBusy;
  final String? message;
}
