/// Base class for all step types in a workout.
abstract class WorkoutStepBase {}

class WorkoutStep extends WorkoutStepBase {
  final String stepType; // e.g., 'RECOVERY', 'ENDURANCE'
  final String durationType;
  final String durationValue;
  final String intensityTargetType;
  final String intensityTargetValue;

  WorkoutStep({required this.stepType, required this.durationType, required this.durationValue, required this.intensityTargetType, required this.intensityTargetValue});
}

/// Represents a block of steps that are repeated a number of times.
class RepeatStep extends WorkoutStepBase {
  final int repeats;
  final List<WorkoutStep> steps; // The steps to be repeated

  RepeatStep({required this.repeats, required this.steps});
}

class Workout {
  String name;
  final String type;
  final List<WorkoutStepBase> steps; // Can contain WorkoutStep or RepeatStep

  Workout({required this.name, required this.type, required this.steps});
}
