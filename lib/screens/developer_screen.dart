import 'package:flutter/material.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О разработчике')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Card(
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Долгих Дмитрий Андреевич'),
            ),
          ),
        ),
      ),
    );
  }
}
