import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cubit/main_screen_cubit.dart';
import 'cubit/main_screen_state.dart';
import '../requests/dog_api.dart';
import 'dog_images_screen_provider.dart';
import 'saved_calculations_screen_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.dogApi});

  final DogApi? dogApi;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _formKey = GlobalKey<FormState>();
  final _massController = TextEditingController();
  final _radiusController = TextEditingController();
  bool _agreement = false;
  String? _agreementError;
  final _preferences = SharedPreferencesAsync();
  bool _agreementChanged = false;

  @override
  void initState() {
    super.initState();
    _loadAgreement();
  }

  Future<void> _loadAgreement() async {
    final accepted = await _preferences.getBool('personal_data_agreement');
    if (!mounted || _agreementChanged) return;
    setState(() => _agreement = accepted ?? false);
  }

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

  Future<void> _calculate() async {
    final formIsValid = _formKey.currentState!.validate();
    setState(() {
      _agreementError = _agreement ? null : 'Пожалуйста, дайте согласие';
    });

    if (!formIsValid || !_agreement) return;

    await context.read<MainScreenCubit>().calculateVelocity(
      mass: _parseNumber(_massController.text)!,
      radius: _parseNumber(_radiusController.text)!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Долгих Дмитрий Андреевич, вариант 5'),
        actions: [
          IconButton(
            tooltip: 'Сохранённые расчёты',
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SavedCalculationsScreenProvider(),
              ),
            ),
          ),
        ],
      ),
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
                  onChanged: (value) async {
                    _agreementChanged = true;
                    final accepted = value ?? false;
                    setState(() {
                      _agreement = accepted;
                      _agreementError = null;
                    });
                    await _preferences.setBool(
                      'personal_data_agreement',
                      accepted,
                    );
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
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          DogImagesScreenProvider(api: widget.dogApi),
                    ),
                  ),
                  label: const Text('Показать фото собачек'),
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
