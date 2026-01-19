import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CompleteWorkoutPopup extends StatefulWidget {
  Map<String, dynamic>? workoutData;
  String workoutStatus; // 'completed' or 'new'
  Map<String, dynamic>? loadedWorkout;


  CompleteWorkoutPopup({
    super.key, 
    required this.workoutData, 
    required this.workoutStatus, 
    required this.loadedWorkout,
    });

  @override
  State<CompleteWorkoutPopup> createState() => _CompleteWorkoutPopupState();
}

class _CompleteWorkoutPopupState extends State<CompleteWorkoutPopup> {
  String? uploadType;
  bool inputData = true;
  TextEditingController durationController = TextEditingController();
  TextEditingController distanceController = TextEditingController();

  //--------------------------------------------------------------
  // Dispose
  @override
  void dispose() {
    durationController.dispose();
    distanceController.dispose();
    super.dispose();
  }

  //--------------------------------------------------------------
  // Init State
  @override
  void initState() {
    super.initState();
    durationController.text = widget.workoutData?['completedworkoutData']?['duration'] ?? '';
    distanceController.text = widget.workoutData?['completedworkoutData']?['distance'] ?? '';
  }

  //--------------------------------------------------------------
  // Function to complete a workout
  Future<void> _completeWorkout() async {
    final loadedWorkout = widget.loadedWorkout;
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final workoutData = widget.workoutData;
    final completedworkoutData = workoutData!['completedworkoutData'];

    loadedWorkout!['completedworkoutData'] = completedworkoutData;
    try {
      setState(() {
        workoutsProvider.addCompletedWorkoutData(loadedWorkout['loadedWorkoutUID'], completedworkoutData);
      });
      Navigator.of(context).pop();
    } catch (e) {
      showGeneralPopupDialog(context, 'Error', 'Error submitting completed workout: $e');
    }
  }

  //--------------------------------------------------------------
  // Function to create a new loaded workout record
  Future<void> _createNewWorkout() async {
    final loadedWorkout = widget.loadedWorkout;
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final workoutData = widget.workoutData;
    final completedworkoutData = workoutData!['completedworkoutData'];

    loadedWorkout!['completedworkoutData'] = completedworkoutData;
    try {
      await workoutsProvider.createLoadedWorkoutRecord(loadedWorkout);
      setState(() {});
      Navigator.of(context).pop();
    } catch (e) {
      showGeneralPopupDialog(context, 'Error', 'Error submitting completed workout: $e');
    }
  }

  //--------------------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final workoutTypes = internalStatusProvider.workoutTypes;
    final workoutData = widget.workoutData;
    final workoutStatus = widget.workoutStatus;
    final completedworkoutData = workoutData!['completedworkoutData'];

    //print(workoutData);
    //print(workoutStatus);
    //print(loadedWorkout);

    return AlertDialog(
      backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
      title: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header1(
              header: workoutStatus == 'new' ? 'New Workout:' : 'Complete Workout:',
              color: localAppTheme['anchorColors']['primaryColor'],
              context: context,
            ),
            SizedBox(height: 20),
            uploadType == null
                ? body(header: 'Select how you want to complete the workout:', context: context, color: localAppTheme['anchorColors']['primaryColor'])
                : uploadType == 'manual'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: workoutStatus == 'completed',
                        child: FormInputField(
                          label: 'Workout Type:',
                          errorMessage: 'Please enter workout type',
                          isMultiline: false,
                          isPassword: false,
                          prefixIcon: null,
                          suffixIcon: null,
                          showLabel: true,
                          enabled: false,
                          initialValue: completedworkoutData['type'] != null
                              ? workoutTypes.where((type) => type['workoutTypeID'] == completedworkoutData['type']).first['workoutType']
                              : '',
                        ),
                      ),
                      Visibility(
                        visible: workoutStatus == 'new',
                        child: SearchableDropdown(
                          labelText: '',
                          hint: '',
                          dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                          searchBoxVisable: false,
                          dropDownList: workoutTypes,
                          header: 'Workout Type:',
                          iconColor: localAppTheme['anchorColors']['primaryColor'],
                          idField: 'workoutTypeID',
                          displayField: 'workoutType',
                          onChanged: (value) {
                            setState(() {
                              completedworkoutData['type'] = value?['workoutTypeID'];
                            });
                          },
                          isEnabled: inputData,
                        ),
                      ),
                      SizedBox(height: 10),
                      FormInputField(
                        label: 'Duration:',
                        errorMessage: 'Please enter duration',
                        isMultiline: false,
                        isPassword: false,
                        prefixIcon: null,
                        suffixIcon: null,
                        showLabel: true,
                        enabled: inputData,
                        onChanged: (value) {
                          completedworkoutData['duration'] = value;
                        },
                        controller: durationController,
                      ),
                      SizedBox(height: 10),
                      FormInputField(
                        label: 'Distance:',
                        errorMessage: 'Please enter distance',
                        isMultiline: false,
                        isPassword: false,
                        prefixIcon: null,
                        suffixIcon: null,
                        showLabel: true,
                        enabled: inputData,
                        onChanged: (value) {
                          completedworkoutData['distance'] = value;
                        },
                        controller: distanceController,
                      ),
                      SizedBox(height: 10),
                      Visibility(
                        visible: uploadType != null && inputData != true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            body(header: 'Perceived Effort:\n1: Very Easy\n10: Very Hard', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                            Slider(
                              value: (completedworkoutData['perceivedEffort'] ?? 0).toDouble(),
                              onChanged: !inputData
                                  ? (double value) {
                                      setState(() {
                                        completedworkoutData['perceivedEffort'] = value;
                                      });
                                    }
                                  : null,
                              min: 1,
                              max: 10,
                              divisions: 10,
                              label: (completedworkoutData['perceivedEffort'] ?? 0).toString(),
                              activeColor: localAppTheme['anchorColors']['primaryColor'],
                              thumbColor: localAppTheme['anchorColors']['primaryColor'],
                            ),
                            SizedBox(height: 10),
                            body(
                              header: 'How did you feel:\n1: Very Weak\n10: Very Strong',
                              color: localAppTheme['anchorColors']['primaryColor'],
                              context: context,
                            ),
                            Slider(
                              value: (completedworkoutData['feeling'] ?? 0).toDouble(),
                              onChanged: !inputData
                                  ? (double value) {
                                      setState(() {
                                        completedworkoutData['feeling'] = value;
                                      });
                                    }
                                  : null,
                              min: 1,
                              max: 10,
                              divisions: 10,
                              label: (completedworkoutData['feeling'] ?? 0).toString(),
                              activeColor: localAppTheme['anchorColors']['primaryColor'],
                              thumbColor: localAppTheme['anchorColors']['primaryColor'],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : uploadType == 'camera'
                ? body(header: 'Camera Selected', context: context, color: localAppTheme['anchorColors']['primaryColor'])
                : uploadType == 'upload'
                ? body(header: 'Upload Selected', context: context, color: localAppTheme['anchorColors']['primaryColor'])
                : SizedBox(),
          ],
        ),
      ),
      actions: [
        Visibility(
          visible: uploadType == null && inputData == true,
          child: Row(
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
                  setState(() {
                    uploadType = 'manual';
                  });
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
                  setState(() {
                    uploadType = 'upload';
                  });
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
                  setState(() {
                    uploadType = 'camera';
                  });
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
        ),
        Visibility(
          visible: uploadType != null && inputData == true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: elevatedButton(
                  label: 'CANCEL',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                  labelColor: localAppTheme['anchorColors']['secondaryColor'],
                  leadingIcon: null,
                  trailingIcon: null,
                  context: context,
                ),
              ),
              Expanded(
                child: elevatedButton(
                  label: 'SUBMIT',
                  onPressed: () {
                    setState(() {
                      inputData = false;
                    });
                  },
                  backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                  labelColor: localAppTheme['anchorColors']['secondaryColor'],
                  leadingIcon: null,
                  trailingIcon: null,
                  context: context,
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: uploadType != null && inputData != true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: elevatedButton(
                  label: 'CANCEL',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                  labelColor: localAppTheme['anchorColors']['secondaryColor'],
                  leadingIcon: null,
                  trailingIcon: null,
                  context: context,
                ),
              ),
              Expanded(
                child: elevatedButton(
                  label: 'SUBMIT',
                  onPressed: () {
                    if (widget.workoutStatus == 'new') {
                      _createNewWorkout();
                    } else {
                      _completeWorkout();
                    }
                  },
                  backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                  labelColor: localAppTheme['anchorColors']['secondaryColor'],
                  leadingIcon: null,
                  trailingIcon: null,
                  context: context,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
