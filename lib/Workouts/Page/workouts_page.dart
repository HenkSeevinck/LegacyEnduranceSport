import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/ai_provider.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';

class Workouts extends StatefulWidget {
  const Workouts({super.key});

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  Future<void>? _fetchDataFuture;
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController workoutDateController = TextEditingController();

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(workoutsProvider, appUserProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(WorkoutsProvider workoutsProvider, AppUserProvider appUserProvider) async {
    final appUser = appUserProvider.appUser;
    await workoutsProvider.fetchWorkoutsForCoach(appUser['uid']);
    await appUserProvider.getCoachAthletes(appUser['uid']);
  }

  //----------------------------------------------------
  // Dispose controllers
  @override
  void dispose() {
    workoutNameController.dispose();
    durationController.dispose();
    distanceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  //----------------------------------------------------
  // Update text controllers with current data
  void _updateTextControllers(Map<String, dynamic>? workout) {
    // Avoid updating controllers after the State object is disposed.
    if (!mounted) return;
    if (workout == null) {
      workoutNameController.text = '';
      durationController.text = '';
      distanceController.text = '';
      descriptionController.text = '';
      return;
    }

    workoutNameController.text = (workout['name'] ?? '').toString();
    durationController.text = (workout['duration'] ?? '').toString();
    distanceController.text = (workout['distance'] ?? '').toString();
    descriptionController.text = (workout['description'] ?? '').toString();
    workoutDateController.text = ''.toString();
  }
    
  //----------------------------------------------------
  // Add Workout Context Menus and Dialogs Here
  _showCreateWorkoutPopupDialog(BuildContext context, Map<String, dynamic>? workout, int? index) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final aiProvider = Provider.of<AiProvider>(context, listen: false);
    final focusBlocks = internalStatusProvider.focusBlocks;
    final workoutTypes = internalStatusProvider.workoutTypes;
    final formKey = GlobalKey<FormState>();
    Map<String, dynamic> draftWorkout = workout != null
        ? Map<String, dynamic>.from(workout)
        : {'name': null, 'block': null, 'type': null, 'distance': '00.00', 'duration': 'hh:mm:ss', 'description': null};
    _updateTextControllers(draftWorkout);
    // Toggle selection state for Duration vs Distance
    List<bool> isSelected = [true, false];
    final List<Widget> toggleWorkoutBasis = [Text('Duration'), Text('Distance')];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: header1(
            header: workout == null ? 'New Workout:' : 'Edit Workout:', 
            context: context, 
            color: localAppTheme['anchorColors']['primaryColor'],
          ),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setStateDialog) {
                // assign the builder's setState to the outer reference
                //setStateDialogRef = setStateDialog;
                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchableDropdown(
                        labelText: 'Search Workout Type',
                        hint: 'Workout Type:',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: workoutTypes,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'workoutTypeID',
                        displayField: 'workoutType',
                        onChanged: (value) {
                          setStateDialog(() {
                            draftWorkout['type'] = value?['workoutTypeID'];
                          });
                        },
                        isEnabled: true,
                        initialValue: draftWorkout['type'],
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a workout type';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      SearchableDropdown(
                        labelText: 'Search Focus Block',
                        hint: 'Focus Block:',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: focusBlocks,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'blockTypeID',
                        displayField: 'blockType',
                        onChanged: (value) {
                          setStateDialog(() {
                            draftWorkout['block'] = value?['blockTypeID'];
                          });
                        },
                        isEnabled: true,
                        initialValue: draftWorkout['block'],
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a focus block';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: ToggleButtons(
                          color: localAppTheme['anchorColors']['primaryColor'],
                          selectedColor: localAppTheme['anchorColors']['secondaryColor'],
                          fillColor: localAppTheme['anchorColors']['primaryColor'],
                          borderColor: localAppTheme['anchorColors']['primaryColor'],
                          constraints: BoxConstraints(minHeight: 40.0, minWidth: (MediaQuery.of(context).size.width - 200) / 2),
                          borderRadius: BorderRadius.circular(8.0),
                          isSelected: isSelected,
                          onPressed: (int index) {
                            setStateDialog(() {
                              for (int i = 0; i < isSelected.length; i++) {
                                isSelected[i] = i == index;
                              }
                            });
                          },
                          children: toggleWorkoutBasis,
                        ),
                      ),
                      Visibility(
                        visible: isSelected[0],
                        child: Column(
                          children: [
                            SizedBox(height: 10.0),
                            FormInputField(
                              label: 'Duration:',
                              errorMessage: 'Please enter a duration',
                              isMultiline: false,
                              isPassword: false,
                              prefixIcon: null,
                              suffixIcon: null,
                              showLabel: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid goal duration (hh:mm:ss).';
                                }
                                final pattern = RegExp(r'^\d{2}:[0-5]\d:[0-5]\d$');
                                if (!pattern.hasMatch(value)) {
                                  return 'Please enter duration in hh:mm:ss format (e.g. 01:30:00).';
                                }
                                return null;
                              },
                              controller: durationController,
                              onChanged: (value) {
                                setStateDialog(() {
                                  draftWorkout['duration'] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: isSelected[1],
                        child: Column(
                          children: [
                            SizedBox(height: 10.0),
                            FormInputField(
                              label: 'Distance:',
                              errorMessage: 'Please enter a distance',
                              isMultiline: false,
                              isPassword: false,
                              prefixIcon: null,
                              suffixIcon: null,
                              showLabel: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a workout name';
                                }
                                return null;
                              },
                              controller: distanceController,
                              onChanged: (value) {
                                setStateDialog(() {
                                  draftWorkout['distance'] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      body(
                        header: 'Provide a brief overview of the phases of the workout:\n\nPhases:\nWarmup\nCooldown\nEndurance\nSteady State\nTempo\nInterval\nTaper\n\nExample:\nWarmup: 10 min\nEndurance: 20 min\nCooldown: 10 min', 
                        color: localAppTheme['anchorColors']['primaryColor'], 
                        context: context
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
                            child: FormInputField(
                              label: 'Description:',
                              errorMessage: 'Please enter a description',
                              isMultiline: true,
                              isPassword: false,
                              prefixIcon: null,
                              suffixIcon: null,
                              showLabel: true,
                              onChanged: (value) {
                                setStateDialog(() {
                                  draftWorkout['description'] = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                              controller: descriptionController,
                            ),
                          ),
                          iconButton(
                            label: null, 
                            backgroundColor: null, 
                            iconColor: localAppTheme['anchorColors']['primaryColor'], 
                            icon: Icons.smart_toy, 
                            size: 30, 
                            toolTip: 'Generate Description with AI', 
                            context: context, 
                            onPressed: () async {
                              try {
                                final suggestion = await aiProvider.getWorkoutDescriptionSuggestion(
                                  descriptionController.text,
                                  draftWorkout,
                                  workoutTypes.firstWhere((type) => type['workoutTypeID'] == draftWorkout['type'])['workoutType'] ?? '',
                                  focusBlocks.firstWhere((type) => type['blockTypeID'] == draftWorkout['block'])['blockType'] ?? '',
                                );
                                setStateDialog(() {
                                  descriptionController.text = suggestion;
                                  draftWorkout['description'] = suggestion;
                                });
                              } catch (e) {
                                setStateDialog(() {
                                  descriptionController.text = 'Error generating suggestion';
                                  draftWorkout['description'] = descriptionController.text;
                                });
                              }
                            }
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: elevatedButton(
                    label: 'CANCEL',
                    onPressed: () {
                      workout = null;
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
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          var blockType = focusBlocks.firstWhere((type) => type['blockTypeID'] == draftWorkout['block']);
                          var workoutType = workoutTypes.firstWhere((type) => type['workoutTypeID'] == draftWorkout['type']);

                          draftWorkout['coachUID'] = appUser['uid'];
                          final displayValue = (draftWorkout['duration'] != null && draftWorkout['duration'] != '' && draftWorkout['duration'] != 'hh:mm:ss')
                            ? draftWorkout['duration']
                            : ((draftWorkout['distance'] != null && draftWorkout['distance'] != '' && draftWorkout['distance'] != '00.00') ? '${draftWorkout['distance']} km' : '');
                          draftWorkout['name'] = "${blockType['blockType'].toString().toUpperCase()} - ${workoutType['workoutType'].toString().toUpperCase()}${displayValue.isNotEmpty ? " - $displayValue" : ''}";
                          
                          if (workout == null) {
                            // Create new workout
                            await workoutsProvider.createWorkoutRecord(draftWorkout);
                            setState(() {});
                            workout = null;
                            Navigator.of(context).pop();
                            showGeneralPopupDialog(context, 'Success', 'Workout created successfully!');
                            setState(() {});
                          } else {
                            // Update existing workout
                            await workoutsProvider.updateWorkoutRecord(draftWorkout);
                            workout = null;
                            Navigator.of(context).pop();
                            showGeneralPopupDialog(context, 'Success', 'Workout updated successfully!');
                          }
                        } catch (e) {
                          Navigator.of(context).pop();
                          showGeneralPopupDialog(context, 'Error', 'An error occurred while creating the workout: $e');
                        }
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
          ],
        );
      },
    );
  }

  //----------------------------------------------------
  // Show athelete assignment dialog
  _showAssignAthletesPopupDialog(BuildContext context, Map<String, dynamic> workout) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    final athletesByCoach = appUserProvider.athletesByCoach;
    List<Map<String, dynamic>>? assignedAthletes;
    Map<String, dynamic> todaysWorkout = {};

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: header1(
            header: 'Assign Workout:', 
            context: context, 
            color: localAppTheme['anchorColors']['primaryColor'],
            ),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setStateDialog) {
                // assign the builder's setState to the outer reference
                //setStateDialogRef = setStateDialog;
                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DatePicker(
                        buttonLabelColor: localAppTheme['anchorColors']['primaryColor'], 
                        label: 'Select Date:', 
                        buttonVisibility: true,
                        enabled: true,
                        initialDate: DateTime.now(), 
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a date';
                          }
                          return null;
                        }, 
                        controller: workoutDateController,
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: List<Widget>.generate(athletesByCoach.length, (index) {
                          final athlete = athletesByCoach[index];
                          return ExpansionTile(
                            collapsedShape: Border(
                                top: BorderSide(
                                  color: localAppTheme['anchorColors']['primaryColor'], 
                                  width: index == 0 ? 1.0 : 0.0
                                  ),
                                bottom: BorderSide(
                                  color: localAppTheme['anchorColors']['primaryColor'], 
                                  width: 1.0
                                  ),
                              ),
                            //showTrailingIcon: false,
                            title: body(
                                header: '${athlete['name']} ${athlete['surname']}',
                                color: localAppTheme['anchorColors']['primaryColor'],
                                context: context,
                              ),
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 10.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    todaysWorkout.isEmpty 
                                    ? SizedBox(
                                      width: (MediaQuery.of(context).size.width - 200)* 0.8,
                                      child: Center(
                                          child: body(
                                            header: 'No workout assigned to this athlete yet.', 
                                            color: localAppTheme['anchorColors']['primaryColor'], 
                                            context: context
                                          ),
                                      ),
                                    )
                                    : SizedBox(), // Placeholder for future workout display
                                    SizedBox(height: 10.0),
                                    CheckboxListTile(
                                    checkColor: localAppTheme['anchorColors']['secondaryColor'],
                                    activeColor: localAppTheme['anchorColors']['primaryColor'],
                                    title: body(
                                      header: 'Assign Workout',
                                      color: localAppTheme['anchorColors']['primaryColor'],
                                      context: context,
                                    ),
                                                                
                                    value: assignedAthletes != null && assignedAthletes!.any((athleteMap) => athleteMap['uid'] == athlete['uid']),
                                    onChanged: (bool? value) {
                                      setStateDialog(() {
                                        if (value == true) {
                                          assignedAthletes ??= [];
                                          assignedAthletes?.add(athlete);
                                        } else {
                                          assignedAthletes?.removeWhere((athleteMap) => athleteMap['uid'] == athlete['uid']);
                                        }
                                      });
                                    },
                                                                ),
                                  ],
                                ),
                              ),
                            ],
                            onExpansionChanged: (value) {
                              setStateDialog(() {});
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: elevatedButton(
                    label: 'CANCEL',
                    onPressed: () {
                      assignedAthletes = [];
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
                    onPressed: () async {
                      assignedAthletes = [];
                      Navigator.of(context).pop();
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
          ],
        );
      },
    );
  }

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileWorkouts() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: true);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final focusBlocks = internalStatusProvider.focusBlocks;
    final workoutTypes = internalStatusProvider.workoutTypes;
    final allWorkouts = workoutsProvider.allWorkouts;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SafeArea(
          top: true,
          child: Stack(
            children: [
              Center(child: Image.asset('images/Legacy-Endurance-Logo.png', height: 70, width: 70, fit: BoxFit.contain)),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: iconButton(
                  label: null,
                  backgroundColor: null,
                  iconColor: localAppTheme['anchorColors']['primaryColor'],
                  icon: Icons.arrow_back,
                  size: 30,
                  toolTip: 'BACK',
                  context: context,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        header1(header: 'My Workouts:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                        iconButton(
                          label: null,
                          backgroundColor: null,
                          iconColor: localAppTheme['anchorColors']['primaryColor'],
                          icon: Icons.add,
                          size: 30,
                          toolTip: 'ADD GOAL',
                          onPressed: () {
                            _showCreateWorkoutPopupDialog(context, null, null);
                          },
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  allWorkouts.isNotEmpty
                      ? Column(
                          children: List<Widget>.generate(allWorkouts.length, (index) {
                            final workout = allWorkouts[index];

                            return ExpansionTile(
                              collapsedShape: Border(
                                top: BorderSide(
                                  color: localAppTheme['anchorColors']['primaryColor'], 
                                  width: index == 0 ? 1.0 : 0.0
                                  ),
                                bottom: BorderSide(
                                  color: localAppTheme['anchorColors']['primaryColor'], 
                                  width: 1.0
                                  ),
                              ),
                              showTrailingIcon: false,
                              title: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10.0),
                                    SizedBox(
                                      width: double.infinity,
                                      child: header2(
                                        header: workout['name'] ?? 'Unnamed Workout',
                                        color: localAppTheme['anchorColors']['primaryColor'],
                                        context: context,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  workoutTypes.firstWhere((type) => type['type'] == workout['workoutTypeID'])['icon'] ?? Icons.fitness_center,
                                                  color: localAppTheme['anchorColors']['primaryColor'],
                                                  size: 20,
                                                ),
                                                SizedBox(width: 20.0),
                                                body(
                                                  header: workoutTypes.firstWhere((type) => type['type'] == workout['workoutTypeID'])['workoutType'] ?? 'Unknown',
                                                  color: localAppTheme['anchorColors']['primaryColor'],
                                                  context: context,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10.0),
                                            Row(
                                              children: [
                                                Icon(Icons.fitness_center, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                SizedBox(width: 20.0),
                                                body(
                                                  header: focusBlocks.firstWhere((type) => type['blockTypeID'] == workout['block'])['blockType'] ?? 'Unknown',
                                                  color: localAppTheme['anchorColors']['primaryColor'],
                                                  context: context,
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible: workout['distance'] != '00.00',
                                              child: Column(
                                                children: [
                                                  SizedBox(height: 10.0),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.straighten, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                      SizedBox(width: 20.0),
                                                      body(
                                                        header: '${workout['distance'].toString()} km',
                                                        color: localAppTheme['anchorColors']['primaryColor'],
                                                        context: context,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Visibility(
                                              visible: workout['duration'] != 'hh:mm:ss',
                                              child: Column(
                                                children: [
                                                  SizedBox(height: 10.0),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.timer, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                      SizedBox(width: 20.0),
                                                      body(
                                                        header: workout['duration'].toString(),
                                                        color: localAppTheme['anchorColors']['primaryColor'],
                                                        context: context,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 75,
                                          height: 75,
                                          padding: const EdgeInsets.only(left: 10.0),
                                          decoration: BoxDecoration(
                                            border: Border(left: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                                          ),
                                          child: iconButton(
                                                label: null,
                                                backgroundColor: null,
                                                iconColor: localAppTheme['anchorColors']['primaryColor'],
                                                icon: Icons.group_outlined,
                                                size: 30,
                                                toolTip: 'Assign Athletes',
                                                context: context,
                                                onPressed: () {
                                                  _showAssignAthletesPopupDialog(context, workout);
                                                },
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                  ],
                                ),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      header3(header: 'Description:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                      SizedBox(height: 5.0),
                                      body(
                                        header: workout['description'] ?? 'No description provided.',
                                        color: localAppTheme['anchorColors']['primaryColor'],
                                        context: context,
                                      ),
                                      SizedBox(height: 10.0),
                                      Center(
                                        child: elevatedButton(
                                          label: 'EDIT WORKOUT',
                                          onPressed: () {
                                            _showCreateWorkoutPopupDialog(context, workout, index);
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
                          }),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopWorkouts() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackWorkouts() {
    return Scaffold(body: const Center(child: Text('Landing Page - Fallback Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Build method with FutureBuilder
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        final localAppTheme = ResponsiveTheme(context).theme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          );
        } else {
          final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
          final platform = internalStatusProvider.platform;

          if (platform == 'MobileWeb' || platform == 'Mobile') {
            return _buildMobileWorkouts();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopWorkouts();
          } else {
            return _buildFallbackWorkouts();
          }
        }
      },
    );
  }
}
