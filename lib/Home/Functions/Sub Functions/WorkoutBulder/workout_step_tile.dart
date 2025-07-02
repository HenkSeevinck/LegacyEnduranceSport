import 'package:flutter/material.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workout_models.dart';

class WorkoutStepTile extends StatelessWidget {
  final WorkoutStep step;
  final int stepNumber;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WorkoutStepTile({super.key, required this.step, required this.stepNumber, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text('$stepNumber. ${step.stepType}')),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
              onPressed: onEdit,
              tooltip: 'Edit Step',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Delete Step',
            ),
          ],
        ),
        subtitle: Text('${step.durationValue} @ ${step.intensityTargetValue} ${step.intensityTargetType}'),
        childrenPadding: const EdgeInsets.all(16.0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildDetailRow('Duration:', '${step.durationValue} (${step.durationType})'), _buildDetailRow('Intensity:', '${step.intensityTargetValue} (${step.intensityTargetType})')],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
