import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/add_step_dialog.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workout_models.dart';

class AddRepeatDialog extends StatefulWidget {
  final RepeatStep? initialStep;
  const AddRepeatDialog({super.key, this.initialStep});

  @override
  State<AddRepeatDialog> createState() => _AddRepeatDialogState();
}

class _AddRepeatDialogState extends State<AddRepeatDialog> {
  final List<WorkoutStep> _subSteps = [];
  final _repeatsController = TextEditingController(text: '1');
  bool get isEditing => widget.initialStep != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _subSteps.addAll(widget.initialStep!.steps);
      _repeatsController.text = widget.initialStep!.repeats.toString();
    }
  }

  @override
  void dispose() {
    _repeatsController.dispose();
    super.dispose();
  }

  void _saveRepeatStep() {
    if (_subSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one sub-step.')));
      return;
    }
    final repeats = int.tryParse(_repeatsController.text) ?? 1;
    final newRepeatStep = RepeatStep(steps: _subSteps, repeats: repeats);
    Navigator.of(context).pop(newRepeatStep);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Repeat Block' : 'Add Repeat Block'),
      content: SizedBox(
        width: 500, // Set a width for the dialog
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Repeats count
            TextFormField(
              controller: _repeatsController,
              decoration: const InputDecoration(labelText: 'Number of Repeats'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            // Sub-steps list
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _subSteps.length,
                itemBuilder: (context, index) {
                  final step = _subSteps[index];
                  return Card(
                    child: ListTile(
                      title: Text('${index + 1}. ${step.stepType}'),
                      subtitle: Text('${step.durationValue} @ ${step.intensityTargetValue}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                            tooltip: 'Edit Sub-Step',
                            onPressed: () async {
                              final editedSubStep = await showDialog<WorkoutStep>(
                                context: context,
                                builder: (_) => AddStepDialog(initialStep: step),
                              );
                              if (editedSubStep != null) {
                                setState(() {
                                  _subSteps[index] = editedSubStep;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            tooltip: 'Delete Sub-Step',
                            onPressed: () => setState(() => _subSteps.removeAt(index)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Add sub-step button
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Sub-Step'),
              onPressed: () async {
                final newSubStep = await showDialog<WorkoutStep>(context: context, builder: (_) => const AddStepDialog(initialStep: null));
                if (newSubStep != null) {
                  setState(() => _subSteps.add(newSubStep));
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveRepeatStep, child: Text(isEditing ? 'Save Changes' : 'Add Repeat Block')),
      ],
    );
  }
}
