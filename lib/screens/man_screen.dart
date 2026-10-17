import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/main_screen_cubit.dart';
import 'cubit/main_screen_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _formKey = GlobalKey<FormState>();
  final _massController = TextEditingController();
  final _radiusController = TextEditingController();
  bool _agreement = false;
  String? _agreementError;

  @override
  void dispose() {
    _massController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  double? _parseNumber(String? value) => double.tryParse((value ?? '').trim());

  String? _validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, введите $fieldName';
    }

    final number = _parseNumber(value);
    if (number == null || !number.isFinite) {
      return 'Пожалуйста, введите число';
    }
    if (number <= 0) {
      return '$fieldName должно быть больше нуля';
    }
    return null;
  }

  void _calculate() {
    final formIsValid = _formKey.currentState!.validate();
    setState(() {
      _agreementError = _agreement ? null : 'Пожалуйста, дайте согласие';
    });

    if (!formIsValid || !_agreement) return;

    context.read<MainScreenCubit>().calculateVelocity(
      mass: _parseNumber(_massController.text)!,
      radius: _parseNumber(_radiusController.text)!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Долгих Дмитрий Андреевич, вариант 5')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _massController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Масса небесного тела, кг',
                  ),
                  validator: (value) => _validatePositiveNumber(value, 'массу'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _radiusController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Радиус небесного тела, м',
                  ),
                  validator: (value) =>
                      _validatePositiveNumber(value, 'радиус'),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _agreement,
                  title: const Text(
                    'Я ознакомился с документом «Согласие на обработку '
                    'персональных данных» и даю согласие на обработку моих '
                    'персональных данных в соответствии с требованиями '
                    'Федерального закона № 152-ФЗ «О персональных данных».',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _agreement = value ?? false;
                      _agreementError = null;
                    });
                  },
                ),
                if (_agreementError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      _agreementError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('Рассчитать'),
                ),
                const SizedBox(height: 24),
                BlocBuilder<MainScreenCubit, MainScreenState>(
                  builder: (context, state) {
                    if (state is! MainScreenCalculated) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Масса: ${state.mass} кг'),
                            Text('Радиус: ${state.radius} м'),
                            const SizedBox(height: 12),
                            const Text(
                              'Первая космическая скорость:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'v = ${state.velocity.toStringAsPrecision(6)} м/с',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
