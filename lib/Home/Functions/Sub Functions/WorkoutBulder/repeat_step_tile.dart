import 'package:flutter/material.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workout_models.dart';

class RepeatStepTile extends StatelessWidget {
  final RepeatStep step;
  final int stepNumber;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RepeatStepTile({super.key, required this.step, required this.stepNumber, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: Colors.orange.shade50,
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text('$stepNumber. Repeat Block')),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
              onPressed: onEdit,
              tooltip: 'Edit Repeat Block',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Delete Repeat Block',
            ),
          ],
        ),
        subtitle: Text('${step.repeats} times'),
        trailing: const Icon(Icons.repeat),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(step.steps.length, (index) {
          final subStep = step.steps[index];
          return ListTile(contentPadding: const EdgeInsets.only(left: 16), dense: true, leading: Text('${stepNumber}.${index + 1}'), title: Text(subStep.stepType), subtitle: Text('${subStep.durationValue} @ ${subStep.intensityTargetValue} ${subStep.intensityTargetType}'));
        }),
      ),
    );
  }
}
