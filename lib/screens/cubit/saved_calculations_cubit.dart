import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/calculation_record.dart';
import '../../data/db_provider.dart';

abstract class SavedCalculationsState {}

class SavedCalculationsInitial extends SavedCalculationsState {}

class SavedCalculationsLoading extends SavedCalculationsState {}

class SavedCalculationsLoaded extends SavedCalculationsState {
  SavedCalculationsLoaded(this.records);

  final List<CalculationRecord> records;
}

class SavedCalculationsError extends SavedCalculationsState {}

class SavedCalculationsCubit extends Cubit<SavedCalculationsState> {
  SavedCalculationsCubit({DBProvider? dbProvider})
    : _dbProvider = dbProvider ?? DBProvider.instance,
      super(SavedCalculationsInitial());

  final DBProvider _dbProvider;

  Future<void> loadCalculations() async {
    emit(SavedCalculationsLoading());
    try {
      final records = await _dbProvider.getAllCalculations();
      emit(SavedCalculationsLoaded(records));
    } catch (_) {
      emit(SavedCalculationsError());
    }
  }
}
