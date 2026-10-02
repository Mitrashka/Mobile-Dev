import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Долгих Дмитрий Андреевич, вариант 5'),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  bool _agreement = false;
  String? _agreementError;
  final _massController = TextEditingController();
  final _radiusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const Text(
              'Масса небесного тела:',
              style: TextStyle(fontSize: 20.0),
            ),
            TextFormField(
              controller: _massController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return 'Пожалуйста введите массу';
                if (double.tryParse(value) == null) return 'Пожалуйста введите число';
              },
            ),
            const Text(
              'Радиус небесного тела:',
              style: TextStyle(fontSize: 20.0),
            ),
            TextFormField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return 'Пожалуйста введите радиус';
                if (double.tryParse(value) == null) return 'Пожалуйста введите число';
              },
            ),
            CheckboxListTile(
              value: _agreement,
              title: new Text('Я ознакомился с документом "Согласие на обработку персональных данных" и даю согласие на обработку моих персональных данных в соответствии с требованиями "Федерального закона О персональных данных № 152-ФЗ"'),
              onChanged: (bool? value) => setState(() {
                _agreement = value!;
                _agreementError = null;
              }),
            ),
            if (_agreementError != null) Text(_agreementError!, style: TextStyle(color: Colors.red, fontSize: 12.0)),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                final formValid = _formKey.currentState!.validate();
                if (!_agreement) {
                  setState(() {
                    _agreementError = 'Пожалуйста дайте ваше согласие';
                  });
                }
                if (formValid && _agreement) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondScreen(
                        mass: double.parse(_massController.text),
                        radius: double.parse(_radiusController.text),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Проверить'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  final double mass;
  final double radius;
  SecondScreen({required this.mass, required this.radius});

  @override
  Widget build(BuildContext context) {
    final v = sqrt(6.674e-11 * mass / radius);
    return Scaffold(
      appBar: AppBar(title: Text('Результат')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Масса: $mass кг', style: TextStyle(fontSize: 18)),
            Text('Радиус: $radius м', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Первая космическая скорость:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('v = $v м/с', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Назад')),
          ],
        ),
      ),
    );
  }
}