import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';

// ignore: must_be_immutable
class CompleteWorkoutPopup extends StatefulWidget {
  Map<String, dynamic>? workoutData;
  CompleteWorkoutPopup({super.key, this.workoutData});

  @override
  State<CompleteWorkoutPopup> createState() => _CompleteWorkoutPopupState();
}

class _CompleteWorkoutPopupState extends State<CompleteWorkoutPopup> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final workoutData = widget.workoutData;
    print(workoutData);

    return AlertDialog(
      backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
      title: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header1(
              header: 'Complete Workout:', 
              color: localAppTheme['anchorColors']['primaryColor'], 
              context: context,
            ),
            SizedBox(height: 20),
            body(
              header: 'Select how you want to complete the workout:', 
              context: context, 
              color: localAppTheme['anchorColors']['primaryColor'],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            iconButton(
              label: null,
              backgroundColor: null,
              iconColor: localAppTheme['anchorColors']['primaryColor'],
              icon: Icons.note,
              size: 30,
              toolTip: 'Manual Entry',
              context: context,
              onPressed: () {
                // Handle manual entry action
              },
            ),
            iconButton(
              label: null,
              backgroundColor: null,
              iconColor: localAppTheme['anchorColors']['primaryColor'],
              icon: Icons.upload,
              size: 30,
              toolTip: 'Upload image',
              context: context,
              onPressed: () {
                // Handle manual entry action
              },
            ),
            iconButton(
              label: null,
              backgroundColor: null,
              iconColor: localAppTheme['anchorColors']['primaryColor'],
              icon: Icons.camera,
              size: 30,
              toolTip: 'Take photo',
              context: context,
              onPressed: () {
                // Handle manual entry action
              },
            ),
            iconButton(
              label: null,
              backgroundColor: null,
              iconColor: localAppTheme['anchorColors']['primaryColor'],
              icon: Icons.cancel,
              size: 30,
              toolTip: 'Cancel',
              context: context,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}
