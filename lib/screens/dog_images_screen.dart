import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/dog_images_cubit.dart';
import 'cubit/dog_images_state.dart';

class DogImagesScreen extends StatelessWidget {
  const DogImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Изображения собак')),
      body: SafeArea(
        child: BlocBuilder<DogImagesCubit, DogImagesState>(
          builder: (context, state) {
            if (state is DogImagesLoading || state is DogImagesInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DogImagesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: context.read<DogImagesCubit>().loadDogs,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loadedState = state as DogImagesLoaded;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: loadedState.imageUrls.length,
              itemBuilder: (context, index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Изображение ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: Image.network(
                          loadedState.imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text('Не удалось загрузить изображение'),
                            );
                          },
                        ),
                      ),
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
