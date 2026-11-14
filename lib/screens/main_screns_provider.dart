import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../requests/dog_api.dart';
import 'cubit/main_screen_cubit.dart';
import 'man_screen.dart';

class MainScreenProvider extends StatelessWidget {
  const MainScreenProvider({super.key, this.dogApi});

  final DogApi? dogApi;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainScreenCubit>(
      create: (_) => MainScreenCubit(),
      child: MainScreen(dogApi: dogApi),
    );
  }
}
