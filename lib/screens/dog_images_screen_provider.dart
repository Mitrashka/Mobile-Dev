import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../requests/dog_api.dart';
import 'cubit/dog_images_cubit.dart';
import 'dog_images_screen.dart';

class DogImagesScreenProvider extends StatelessWidget {
  const DogImagesScreenProvider({super.key, this.api});

  final DogApi? api;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DogImagesCubit>(
      create: (_) => DogImagesCubit(api: api)..loadDogs(),
      child: const DogImagesScreen(),
    );
  }
}
