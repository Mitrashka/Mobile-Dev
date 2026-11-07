import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/calculation_record.dart';
import '../../data/db_provider.dart';
import 'main_screen_state.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  MainScreenCubit({DBProvider? dbProvider})
    : _dbProvider = dbProvider ?? DBProvider.instance,
      super(MainScreenInitial());

  final DBProvider _dbProvider;

  static const double _gravitationalConstant = 6.674e-11;

  Future<void> calculateVelocity({
    required double mass,
    required double radius,
  }) async {
    final velocity = sqrt(_gravitationalConstant * mass / radius);
    await _dbProvider.insertCalculation(
      CalculationRecord(
        mass: mass,
        radius: radius,
        velocity: velocity,
        createdAt: DateTime.now(),
      ),
    );
    emit(MainScreenCalculated(mass: mass, radius: radius, velocity: velocity));
  }
}
