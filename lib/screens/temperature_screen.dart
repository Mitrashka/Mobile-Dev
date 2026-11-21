import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/temperature_conversion.dart';
import 'cubit/temperature_cubit.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _input = TextEditingController();
  var _direction = TemperatureDirection.celsiusToFahrenheit;

  double? _parse(String input) =>
      double.tryParse(input.trim().replaceAll(',', '.'));

  void _convert() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<TemperatureCubit>().convert(_parse(_input.text)!, _direction);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Конвертер температур')),
      body: SafeArea(
        child: BlocBuilder<TemperatureCubit, TemperatureState>(
          builder: (context, state) {
            final message = state.message;
            final unsaved = state.unsaved;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.history.length + 1,
              itemBuilder: (context, index) {
                if (index > 0) {
                  final conversion = state.history[index - 1];
                  return Card(
                    child: ListTile(
                      title: Text(conversion.label),
                      subtitle: Text(
                        conversion.createdAt.toLocal().toString().substring(
                          0,
                          16,
                        ),
                      ),
                    ),
                  );
                }
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<TemperatureDirection>(
                        segments: [
                          for (final direction in TemperatureDirection.values)
                            ButtonSegment(
                              value: direction,
                              label: Text(direction.label),
                            ),
                        ],
                        selected: {_direction},
                        onSelectionChanged: state.isBusy
                            ? null
                            : (selection) =>
                                  setState(() => _direction = selection.single),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _input,
                        enabled: !state.isBusy,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Температура, ${_direction.fromUnit}',
                        ),
                        validator: (value) {
                          final temperature = _parse(value ?? '');
                          return temperature == null || !temperature.isFinite
                              ? 'Введите число'
                              : null;
                        },
                        onFieldSubmitted: (_) => _convert(),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: state.isBusy ? null : _convert,
                        child: const Text('Перевести'),
                      ),
                      if (state.isBusy) const LinearProgressIndicator(),
                      if (unsaved != null) ListTile(title: Text(unsaved.label)),
                      if (message != null)
                        Text(
                          message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        'История расчётов',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (state.history.isEmpty && !state.isBusy)
                        const Text('Сохранённых расчётов пока нет'),
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
