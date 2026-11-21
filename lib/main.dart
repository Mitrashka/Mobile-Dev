import 'package:flutter/material.dart';

import 'requests/weather_api.dart';
import 'screens/weather_screen_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.weatherApi});

  final WeatherApi? weatherApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: WeatherScreenProvider(api: weatherApi));
  }
}
