import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/temperature_cubit.dart';
import 'temperature_screen.dart';

class TemperatureScreenProvider extends StatelessWidget {
  const TemperatureScreenProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TemperatureCubit()..loadHistory(),
      child: const TemperatureScreen(),
    );
  }
}
