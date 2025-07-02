import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/WorkoutBulder/workout_models.dart';
import 'package:provider/provider.dart';

class AddStepDialog extends StatefulWidget {
  final WorkoutStep? initialStep;
  const AddStepDialog({super.key, this.initialStep});

  @override
  State<AddStepDialog> createState() => _AddStepDialogState();
}

class _AddStepDialogState extends State<AddStepDialog> {
  final _formKey = GlobalKey<FormState>();
  bool get isEditing => widget.initialStep != null;

  // Form values
  String? _selectedStepType;
  String? _selectedDurationType;
  String? _selectedIntensityTargetType;
  final _durationController = TextEditingController();
  final _intensityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _selectedStepType = widget.initialStep!.stepType;
      _selectedDurationType = widget.initialStep!.durationType;
      _selectedIntensityTargetType = widget.initialStep!.intensityTargetType;
      _durationController.text = widget.initialStep!.durationValue;
      _intensityController.text = widget.initialStep!.intensityTargetValue;
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _intensityController.dispose();
    super.dispose();
  }

  void _saveStep() {
    if (_formKey.currentState!.validate()) {
      final newStep = WorkoutStep(stepType: _selectedStepType!, durationType: _selectedDurationType!, durationValue: _durationController.text, intensityTargetType: _selectedIntensityTargetType!, intensityTargetValue: _intensityController.text);
      Navigator.of(context).pop(newStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InternalStatusProvider>(context, listen: false);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Workout Step' : 'Add Workout Step'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Details
              Text('Details', style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<String>(
                value: _selectedStepType,
                hint: const Text('Select Step Type'),
                items: provider.mesoBlocks.map((block) => DropdownMenuItem<String>(value: block['mesoBlock'] as String, child: Text(block['mesoBlock'].toString()))).toList(),
                onChanged: (value) => setState(() => _selectedStepType = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Duration
              Text('Duration', style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<String>(
                value: _selectedDurationType,
                hint: const Text('Select Duration Type'),
                items: provider.durationTypes.map((type) => DropdownMenuItem<String>(value: type['durationType'] as String, child: Text(type['durationType'].toString()))).toList(),
                onChanged: (value) => setState(() => _selectedDurationType = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              if (_selectedDurationType != null) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _durationController,
                  decoration: InputDecoration(labelText: provider.durationTypes.firstWhere((e) => e['durationType'] == _selectedDurationType)['value']),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
              ],
              const SizedBox(height: 20),

              // Intensity Target
              Text('Intensity Target', style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<String>(
                value: _selectedIntensityTargetType,
                hint: const Text('Select Intensity Type'),
                items: provider.intensityTargetTypes.map((type) => DropdownMenuItem<String>(value: type['intensityTargetType'] as String, child: Text(type['intensityTargetType'].toString()))).toList(),
                onChanged: (value) => setState(() => _selectedIntensityTargetType = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              if (_selectedIntensityTargetType != null) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _intensityController,
                  decoration: InputDecoration(labelText: provider.intensityTargetTypes.firstWhere((e) => e['intensityTargetType'] == _selectedIntensityTargetType)['value']),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveStep, child: Text(isEditing ? 'Save Changes' : 'Add Step')),
      ],
    );
  }
}
