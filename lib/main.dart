import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Лабораторная работа, вариант 5'),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Wrap(
            spacing: 10.0,
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                color: Colors.indigo,
                child: Text('ФИО: Долгих Дмитрий Андреевич',
                style: TextStyle(
                  fontSize: 24
                )),
              ),
              Container(
                padding: EdgeInsets.all(9.0),
                color: const Color.fromARGB(255, 181, 63, 142),
                child: Text('Группа: ИСТУ-23',
                style: TextStyle(
                  fontSize: 24
                )),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                color: const Color.fromARGB(255, 243, 84, 44),
                child: Text('Год рождения: 2005',
                style: TextStyle(
                  fontSize: 24
                )),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                color: const Color.fromARGB(255, 1, 9, 49),
                child: Text('Контейнер',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ))
              )
            ],
          )
          // Здесь будут ваши виджеты
        ],
      ),
    );
  }
}