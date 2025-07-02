import 'package:flutter/material.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workouteditor.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workoutgallery.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workout_models.dart';

class WorkoutBuilder extends StatefulWidget {
  const WorkoutBuilder({super.key});

  @override
  State<WorkoutBuilder> createState() => _WorkoutBuilderState();
}

class _WorkoutBuilderState extends State<WorkoutBuilder> {
  // --- STATE ---
  Workout? _currentWorkout;
  final List<Workout> _savedWorkouts = [
    // Dummy data for the gallery
    Workout(name: "Tempo Run", type: "Run", steps: []),
    Workout(name: "Long Ride", type: "cycle", steps: []),
  ];

  void _createNewWorkout(String type) {
    setState(() {
      _currentWorkout = Workout(name: "New ${type[0].toUpperCase()}${type.substring(1)} Workout", type: type, steps: []);
    });
  }

  void _selectWorkout(Workout workout) {
    setState(() {
      _currentWorkout = workout;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // --- LEFT PANE: WORKOUT GALLERY (33%) ---
        Expanded(
          flex: 1,
          child: WorkoutGallery(
            workouts: _savedWorkouts,
            onSelectWorkout: _selectWorkout,
            onCreateNew: () => setState(() {
              _currentWorkout = null; // Clear current to show type selection
            }),
          ),
        ),
        const VerticalDivider(width: 1),
        // --- RIGHT PANE: WORKOUT BUILDER (66%) ---
        Expanded(
          flex: 2,
          child: WorkoutEditor(
            key: ValueKey(_currentWorkout), // Ensures editor rebuilds when workout changes
            workout: _currentWorkout,
            onCreateNew: _createNewWorkout,
          ),
        ),
      ],
    );
  }
}
