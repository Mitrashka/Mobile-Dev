import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/saved_calculations_cubit.dart';
import 'saved_calculations_screen.dart';

class SavedCalculationsScreenProvider extends StatelessWidget {
  const SavedCalculationsScreenProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SavedCalculationsCubit>(
      create: (_) => SavedCalculationsCubit()..loadCalculations(),
      child: const SavedCalculationsScreen(),
    );
  }
}
