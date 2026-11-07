import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/saved_calculations_cubit.dart';

class SavedCalculationsScreen extends StatelessWidget {
  const SavedCalculationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сохранённые расчёты')),
      body: BlocBuilder<SavedCalculationsCubit, SavedCalculationsState>(
        builder: (context, state) {
          if (state is SavedCalculationsLoading ||
              state is SavedCalculationsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SavedCalculationsError) {
            return const Center(
              child: Text('Не удалось загрузить сохранённые расчёты'),
            );
          }
          if (state is SavedCalculationsLoaded) {
            if (state.records.isEmpty) {
              return const Center(child: Text('Сохранённых расчётов нет'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = state.records[index];
                final date = record.createdAt.toLocal().toString();
                return Card(
                  child: ListTile(
                    title: Text(
                      'Первая космическая скорость: '
                      '${record.velocity.toStringAsPrecision(6)} м/с',
                    ),
                    subtitle: Text(
                      'Масса: ${record.mass} кг\n'
                      'Радиус: ${record.radius} м\n'
                      'Дата: ${date.substring(0, 16)}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
