import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../requests/weather_api.dart';
import 'cubit/weather_cubit.dart';
import 'weather_screen.dart';

class WeatherScreenProvider extends StatelessWidget {
  const WeatherScreenProvider({super.key, this.api});

  final WeatherApi? api;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherCubit(api: api)..loadHistory(),
      child: const WeatherScreen(),
    );
  }
}
