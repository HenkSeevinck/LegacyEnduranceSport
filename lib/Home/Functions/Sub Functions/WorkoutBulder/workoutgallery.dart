import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workout_models.dart';
import 'package:provider/provider.dart';

class WorkoutGallery extends StatelessWidget {
  final List<Workout> workouts;
  final Function(Workout) onSelectWorkout;
  final VoidCallback onCreateNew;

  const WorkoutGallery({super.key, required this.workouts, required this.onSelectWorkout, required this.onCreateNew});

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: body(header: 'Workout Gallery', context: context, color: Colors.black),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 1,
        centerTitle: false,
      ),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          // Find the workout type details from the provider to get the correct icon
          final workoutTypeDetails = internalStatusProvider.workoutTypes.firstWhere(
            (wt) => (wt['workoutType'] as String).toLowerCase() == workout.type.toLowerCase(),
            orElse: () => {'icon': Icons.fitness_center}, // Safe fallback
          );
          final iconData = workoutTypeDetails['icon'] as IconData;

          return ListTile(
            leading: Icon(iconData, color: localAppTheme['anchorColors']['primaryColor']),
            title: body(header: workout.name, context: context, color: Colors.black),
            onTap: () => onSelectWorkout(workout),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreateNew,
        label: body(header: 'New Workout', context: context, color: Colors.black),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
