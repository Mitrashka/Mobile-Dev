abstract class MainScreenState {}

class MainScreenInitial extends MainScreenState {}

class MainScreenCalculated extends MainScreenState {
  final double mass;
  final double radius;
  final double velocity;

  MainScreenCalculated({
    required this.mass,
    required this.radius,
    required this.velocity,
  });
}
