import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/weather_reading.dart';
import 'cubit/weather_cubit.dart';
import 'developer_screen.dart';
import 'main_screns_provider.dart';
import 'temperature_screen_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _city = TextEditingController();

  void _search() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<WeatherCubit>().search(_city.text);
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _openForecast(int? cityId) async {
    final uri = Uri.https(
      'openweathermap.org',
      cityId == null ? '/' : '/city/$cityId',
    );
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Show the same message if the platform rejects the launch.
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось открыть сайт прогноза')),
    );
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasApiKey = context.read<WeatherCubit>().hasApiKey;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода'),
        actions: [
          IconButton(
            tooltip: 'О разработчике',
            icon: const Icon(Icons.person_outline),
            onPressed: () => _openScreen(const DeveloperScreen()),
          ),
          PopupMenuButton<void>(
            tooltip: 'Меню',
            itemBuilder: (_) => [
              PopupMenuItem<void>(
                onTap: () => _openScreen(const MainScreenProvider()),
                child: const Text('Вернуться назад'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            final current = state.current;
            final message = state.message;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.history.length + 1,
              itemBuilder: (context, index) {
                if (index > 0) {
                  return _WeatherCard(
                    reading: state.history[index - 1],
                    showDate: true,
                  );
                }
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _city,
                        enabled: hasApiKey && !state.isBusy,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          labelText: 'Город',
                          hintText: 'Например, Чита',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Введите город'
                            : null,
                        onFieldSubmitted: (_) => _search(),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: state.isBusy || !hasApiKey ? null : _search,
                        child: const Text('Узнать погоду'),
                      ),
                      if (!hasApiKey)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Для загрузки погоды укажите ключ OpenWeatherMap при запуске.',
                          ),
                        ),
                      if (state.isBusy)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                      if (message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      if (current != null) ...[
                        const SizedBox(height: 12),
                        _WeatherCard(reading: current),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _openForecast(current?.cityId),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Открыть сайт прогноза'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openScreen(const TemperatureScreenProvider()),
                        icon: const Icon(Icons.thermostat),
                        label: const Text('Конвертер температур'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'История запросов',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (state.history.isEmpty && !state.isBusy)
                        const Text('Сохранённых запросов пока нет'),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.reading, this.showDate = false});

  final WeatherReading reading;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final temperature = reading.temperature
        .toStringAsFixed(1)
        .replaceAll('.', ',');
    final requestDate = reading.requestedAt.toLocal().toString().substring(
      0,
      16,
    );
    return Card(
      child: ListTile(
        leading: const Icon(Icons.thermostat),
        title: Text('${reading.city} · $temperature °C'),
        subtitle: Text(
          showDate
              ? '${reading.description}\n$requestDate'
              : reading.description,
        ),
        isThreeLine: showDate,
      ),
    );
  }
}
