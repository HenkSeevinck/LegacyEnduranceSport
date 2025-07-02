import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/add_repeat_dialog.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/repeat_step_tile.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/add_step_dialog.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workout_step_tile.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workout_models.dart';
import 'package:provider/provider.dart';

class WorkoutEditor extends StatefulWidget {
  final Workout? workout;
  final Function(String) onCreateNew;

  const WorkoutEditor({super.key, this.workout, required this.onCreateNew});

  @override
  State<WorkoutEditor> createState() => _WorkoutEditorState();
}

class _WorkoutEditorState extends State<WorkoutEditor> {
  late TextEditingController _workoutNameController;

  @override
  void initState() {
    super.initState();
    _workoutNameController = TextEditingController(text: widget.workout?.name ?? '');
    _workoutNameController.addListener(() {
      if (widget.workout != null && mounted) {
        widget.workout!.name = _workoutNameController.text;
      }
    });
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final localAppTheme = ResponsiveTheme(context).theme;

    if (widget.workout == null) {
      return _buildTypeSelection();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          TextFormField(
            controller: _workoutNameController,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
          const SizedBox(height: 24),

          // --- STEP LIST ---
          Expanded(
            child: ListView.builder(
              itemCount: widget.workout!.steps.length,
              itemBuilder: (context, index) {
                final step = widget.workout!.steps[index];
                if (step is WorkoutStep) {
                  return WorkoutStepTile(
                    step: step,
                    stepNumber: index + 1,
                    onEdit: () async {
                      final editedStep = await showDialog<WorkoutStep>(
                        context: context,
                        builder: (_) => AddStepDialog(initialStep: step),
                      );
                      if (editedStep != null) {
                        setState(() {
                          widget.workout!.steps[index] = editedStep;
                        });
                      }
                    },
                    onDelete: () => _showDeleteConfirmation(index),
                  );
                } else if (step is RepeatStep) {
                  return RepeatStepTile(
                    step: step,
                    stepNumber: index + 1,
                    onEdit: () async {
                      final editedStep = await showDialog<RepeatStep>(
                        context: context,
                        builder: (_) => AddRepeatDialog(initialStep: step),
                      );
                      if (editedStep != null) {
                        setState(() {
                          widget.workout!.steps[index] = editedStep;
                        });
                      }
                    },
                    onDelete: () => _showDeleteConfirmation(index),
                  );
                }
                // Placeholder for other step types like 'Repeat'
                return const SizedBox.shrink();
              },
            ),
          ),

          // --- ACTION BUTTONS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              elevatedButton(
                label: 'Add Step',
                onPressed: () async {
                  final newStep = await showDialog<WorkoutStep>(context: context, builder: (BuildContext context) => const AddStepDialog());
                  if (newStep != null) {
                    setState(() {
                      widget.workout!.steps.add(newStep);
                    });
                  }
                },
                context: context,
                backgroundColor: Colors.blue,
                labelColor: Colors.white,
                leadingIcon: Icons.add,
                trailingIcon: null,
              ),
              const SizedBox(width: 10),
              elevatedButton(
                label: 'Add Repeat',
                onPressed: () async {
                  final newRepeatStep = await showDialog<RepeatStep>(context: context, builder: (BuildContext context) => const AddRepeatDialog());
                  if (newRepeatStep != null) {
                    setState(() {
                      widget.workout!.steps.add(newRepeatStep);
                    });
                  }
                },
                context: context,
                backgroundColor: Colors.orange,
                labelColor: Colors.white,
                leadingIcon: Icons.repeat,
                trailingIcon: null,
              ),
              const Spacer(),
              elevatedButton(
                label: 'Save Workout',
                onPressed: () {
                  // In a real app, this would call a provider to save to a database.
                  // For now, we'll just print the workout details to the console.
                  print('--- Saving Workout ---');
                  print('Name: ${widget.workout!.name}');
                  print('Type: ${widget.workout!.type}');
                  print('Steps: ${widget.workout!.steps.length}');
                  for (var i = 0; i < widget.workout!.steps.length; i++) {
                    final step = widget.workout!.steps[i];
                    if (step is WorkoutStep) {
                      print('  Step ${i + 1}: ${step.stepType}, ${step.durationValue}, ${step.intensityTargetValue}');
                    } else if (step is RepeatStep) {
                      print('  Repeat Block ${i + 1} (x${step.repeats}):');
                      for (var j = 0; j < step.steps.length; j++) {
                        print('    - ${step.steps[j].stepType}, ${step.steps[j].durationValue}, ${step.steps[j].intensityTargetValue}');
                      }
                    }
                  }
                  print('----------------------');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.workout!.name} saved! (simulated)')));
                },
                context: context,
                backgroundColor: Colors.green,
                labelColor: Colors.white,
                leadingIcon: Icons.save,
                trailingIcon: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to remove this step?'),
        actions: [
          TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                widget.workout!.steps.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          body(header: 'Create a new workout', context: context, color: Colors.black),
          const SizedBox(height: 20),
          body(header: 'First, select the workout type:', context: context, color: Colors.black),
          const SizedBox(height: 20),
          Consumer<InternalStatusProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: provider.workoutTypes.map((workoutType) {
                  final String type = workoutType['workoutType'];
                  final IconData icon = workoutType['icon'];
                  final Color color = workoutType['color'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: elevatedButton(label: type.toUpperCase(), onPressed: () => widget.onCreateNew(type), context: context, backgroundColor: color, labelColor: Colors.white, leadingIcon: icon, trailingIcon: null),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
