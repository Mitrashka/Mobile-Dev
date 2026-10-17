import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'main_screen_state.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  MainScreenCubit() : super(MainScreenInitial());

  static const double _gravitationalConstant = 6.674e-11;

  void calculateVelocity({required double mass, required double radius}) {
    final velocity = sqrt(_gravitationalConstant * mass / radius);
    emit(MainScreenCalculated(mass: mass, radius: radius, velocity: velocity));
  }
}
