import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legacyendurancesport/General/Providers/image_verification_provider.dart';
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

  CompleteWorkoutPopup({super.key, required this.workoutData, required this.workoutStatus, required this.loadedWorkout});

  @override
  State<CompleteWorkoutPopup> createState() => _CompleteWorkoutPopupState();
}

class _CompleteWorkoutPopupState extends State<CompleteWorkoutPopup> {
  String? uploadType;
  bool inputData = true;
  TextEditingController durationController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  Uint8List? imageData;
  bool _pickerOpen = false;
  bool isVerifyingImage = false;
  Map<String, dynamic> completedworkoutData = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    completedworkoutData = widget.workoutData?['completedworkoutData'] ?? {};

    durationController.text = completedworkoutData['duration'] ?? '';
    distanceController.text = completedworkoutData['distance'] ?? '';
  }

  //--------------------------------------------------------------
  // Reset Text Controllers
  Future<void> _resetTextControllers() async {
    final imageVerificationProvider = Provider.of<ImageVerificationProvider>(context, listen: false);
    final workoutResult = imageVerificationProvider.workoutResult;

    completedworkoutData = workoutResult;

    durationController.text = completedworkoutData['duration'] ?? '';
    distanceController.text = completedworkoutData['distance'] ?? '';
  }

  //--------------------------------------------------------------
  // Function to complete a workout
  Future<void> _completeWorkout() async {
    final loadedWorkout = widget.loadedWorkout;
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    //final workoutData = widget.workoutData;
    //final completedworkoutData = workoutData!['completedworkoutData'];

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
    //final workoutData = widget.workoutData;
    //final completedworkoutData = workoutData!['completedworkoutData'];

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
  // Manual Entry Widget Build
  Widget _buildManualEntryWidget() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final imageVerificationProvider = Provider.of<ImageVerificationProvider>(context, listen: true);
    final workoutResult = imageVerificationProvider.workoutResult;
    final workoutTypes = internalStatusProvider.workoutTypes;
    // final workoutData = widget.workoutData;
    final workoutStatus = widget.workoutStatus;
    // final completedworkoutData = workoutData!['completedworkoutData'];

    if (workoutResult.isNotEmpty) {
      _resetTextControllers();
      setState(() {
        isVerifyingImage = false;
      });
    }

    return isVerifyingImage
        ? Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: Column(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter workout type';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a workout type';
                      }
                      return null;
                    },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter duration';
                    }
                    if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$').hasMatch(value)) {
                      return 'Please use format hh:mm:ss';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter distance';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (!RegExp(r'^\d+\.\d{2}$').hasMatch(value)) {
                      return 'Please use format 0.00';
                    }
                    if (double.parse(value) == 0.0) {
                      return 'Distance cannot be 0.00';
                    }
                    return null;
                  },
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
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: (completedworkoutData['perceivedEffort'] ?? 0).toString(),
                        activeColor: localAppTheme['anchorColors']['primaryColor'],
                        thumbColor: localAppTheme['anchorColors']['primaryColor'],
                      ),
                      SizedBox(height: 10),
                      body(header: 'How did you feel:\n1: Very Weak\n10: Very Strong', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                      Slider(
                        value: (completedworkoutData['feeling'] ?? 0).toDouble(),
                        onChanged: !inputData
                            ? (double value) {
                                setState(() {
                                  completedworkoutData['feeling'] = value;
                                });
                              }
                            : null,
                        min: 0,
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
            ),
          );
  }

  //-------------------------------------------------------------
  // Helper that opens the mobile browser camera via a hidden file input
  Future<void> _openCameraAndStore() async {
    if (_pickerOpen) return;
    _pickerOpen = true;

    try {
      final ImagePicker picker = ImagePicker();
      // Setting source to camera triggers the 'capture' attribute on web
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 10, preferredCameraDevice: CameraDevice.rear);

      if (image != null) {
        final bytes = await image.readAsBytes();
        final provider = Provider.of<ImageVerificationProvider>(context, listen: false);

        setState(() {
          isVerifyingImage = true;
        });

        await provider.verifyImage(bytes);

        if (mounted) {
          setState(() {
            imageData = bytes;
          });
        }
      }
    } catch (e) {
      showGeneralPopupDialog(context, 'Error', 'Error accessing camera: $e');
    } finally {
      _pickerOpen = false;
    }
  }

  //-------------------------------------------------------------
  // Helper that opens the file picker for the user to select an image
  Future<void> _openFilePickerAndStore() async {
    if (_pickerOpen) return;
    _pickerOpen = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 10);

      if (image != null) {
        final bytes = await image.readAsBytes();
        final provider = Provider.of<ImageVerificationProvider>(context, listen: false);

        setState(() {
          isVerifyingImage = true;
        });

        await provider.verifyImage(bytes);

        if (mounted) {
          setState(() {
            imageData = bytes;
          });
        }
      }
    } catch (e) {
      showGeneralPopupDialog(context, 'Error', 'Error accessing file picker: $e');
    } finally {
      _pickerOpen = false;
    }
  }

  //--------------------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final workoutStatus = widget.workoutStatus;
    final imageVerificationProvider = Provider.of<ImageVerificationProvider>(context, listen: true);
    final workoutResult = imageVerificationProvider.workoutResult;

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
                ? _buildManualEntryWidget()
                : uploadType == 'camera'
                ? _buildManualEntryWidget()
                : uploadType == 'filePicker'
                ? _buildManualEntryWidget()
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
                icon: Icons.camera_alt,
                size: 30,
                toolTip: 'Take Photo',
                context: context,
                onPressed: () {
                  setState(() {
                    uploadType = 'camera';
                  });
                  _openCameraAndStore();
                },
              ),
              iconButton(
                label: null,
                backgroundColor: null,
                iconColor: localAppTheme['anchorColors']['primaryColor'],
                icon: Icons.image,
                size: 30,
                toolTip: 'Upload image',
                context: context,
                onPressed: () {
                  setState(() {
                    uploadType = 'filePicker';
                  });
                  _openFilePickerAndStore();
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
              Visibility(
                visible: workoutResult.isNotEmpty || uploadType == 'manual',
                child: Expanded(
                  child: elevatedButton(
                    label: 'SUBMIT',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          inputData = false;
                        });
                      } else {
                        return;
                      }
                    },
                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                    leadingIcon: null,
                    trailingIcon: null,
                    context: context,
                  ),
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
