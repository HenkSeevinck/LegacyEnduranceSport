import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/ai_provider.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

import 'mobile_assign_workouts.dart';

class MobileListOfWorkouts extends StatefulWidget {
  final bool fromDayOverview;
  final DateTime? selectedDate;
  final String? athleteUID;

  const MobileListOfWorkouts({super.key, required this.fromDayOverview, this.selectedDate, this.athleteUID});

  @override
  State<MobileListOfWorkouts> createState() => _MobileListOfWorkoutsState();
}

class _MobileListOfWorkoutsState extends State<MobileListOfWorkouts> {
  Future<void>? _fetchDataFuture;
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController workoutDateController = TextEditingController();
  TextEditingController breakdownController = TextEditingController();
  int? block;
  int? type;



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
      breakdownController.text = '';
      return;
    }

    workoutNameController.text = (workout['name'] ?? '').toString();
    durationController.text = (workout['duration'] ?? '').toString();
    distanceController.text = (workout['distance'] ?? '').toString();
    descriptionController.text = (workout['description'] ?? '').toString();
    breakdownController.text = (workout['breakdown'] ?? '').toString();
    //workoutDateController.text = ''.toString();
  }

  //----------------------------------------------------
  // Add Workout Context Menus and Dialogs Here
  Future<dynamic> _showCreateWorkoutPopupDialog(BuildContext context, Map<String, dynamic>? workout, int? index) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final aiProvider = Provider.of<AiProvider>(context, listen: false);
    final focusBlocks = internalStatusProvider.focusBlocks;
    final workoutTypes = internalStatusProvider.workoutTypes;
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    Map<String, dynamic> draftWorkout = workout != null
        ? Map<String, dynamic>.from(workout)
        : {'name': null, 'block': null, 'type': null, 'distance': '00.00', 'duration': 'hh:mm:ss', 'breakdown': null, 'description': null};
    _updateTextControllers(draftWorkout);
    // Toggle selection state for Duration vs Distance
    bool durationSelected = draftWorkout['duration'] != null && draftWorkout['duration'].toString().isNotEmpty && draftWorkout['duration'] != 'hh:mm:ss';
    bool distanceSelected = draftWorkout['distance'] != null && draftWorkout['distance'].toString().isNotEmpty && draftWorkout['distance'] != '00.00';
    // Ensure exactly one is selected by default; prefer duration if both present
    if (!durationSelected && !distanceSelected) {
      durationSelected = true;
    } else if (durationSelected && distanceSelected) {
      distanceSelected = false;
    }
    List<bool> isSelected = [durationSelected, distanceSelected];
    final List<Widget> toggleWorkoutBasis = [Text('Duration'), Text('Distance')];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
          title: header1(header: workout == null ? 'New Workout:' : 'Edit Workout:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) setStateDialog) {
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
                          header:
                              'Provide a brief overview of the phases of the workout:\n\nPhases:\nWarmup, Cooldown, Endurance, Steady State, Tempo, Interval, Taper\n\nExample:\nWarmup: 10 min\nEndurance: 20 min\nCooldown: 10 min',
                          color: localAppTheme['anchorColors']['primaryColor'],
                          context: context,
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: FormInputField(
                                label: 'Workout Breakdown:',
                                errorMessage: 'Please enter a breakdown',
                                isMultiline: true,
                                isPassword: false,
                                prefixIcon: null,
                                suffixIcon: null,
                                showLabel: true,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    draftWorkout['breakdown'] = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a breakdown';
                                  }
                                  return null;
                                },
                                controller: breakdownController,
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
                                setStateDialog(() {
                                  isLoading = true;
                                });
                                try {
                                  final suggestion = await aiProvider.getWorkoutDescriptionSuggestion(
                                    breakdownController.text,
                                    draftWorkout,
                                    workoutTypes.firstWhere((type) => type['workoutTypeID'] == draftWorkout['type'])['workoutType'] ?? '',
                                    focusBlocks.firstWhere((type) => type['blockTypeID'] == draftWorkout['block'])['blockType'] ?? '',
                                  );
                                  setStateDialog(() {
                                    descriptionController.text = suggestion;
                                    draftWorkout['description'] = suggestion;
                                    isLoading = false;
                                  });
                                } catch (e) {
                                  setStateDialog(() {
                                    isLoading = false;
                                    descriptionController.text = 'Error generating suggestion';
                                    draftWorkout['description'] = descriptionController.text;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        isLoading
                            ? Center(child: CircularProgressIndicator(color: localAppTheme['anchorColors']['primaryColor']))
                            : FormInputField(
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
                      ],
                    ),
                  );
                },
              ),
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
                              : ((draftWorkout['distance'] != null && draftWorkout['distance'] != '' && draftWorkout['distance'] != '00.00')
                                    ? '${draftWorkout['distance']} km'
                                    : '');
                          draftWorkout['name'] =
                              "${blockType['blockType'].toString().toUpperCase()} - ${workoutType['workoutType'].toString().toUpperCase()}${displayValue.isNotEmpty ? " - $displayValue" : ''}";

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
  Future<dynamic> _showAssignAthletesPopupDialog(BuildContext context, Map<String, dynamic> workout) async {
    final localAppTheme = ResponsiveTheme(context).theme;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
          title: header1(header: 'Assign Workout:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
          content: MobileAssignWorkouts(workout: workout),
        );
      },
    );
  }

  //------------------------------------------------------------------------------
  // Shared Grid Builder for Athlete and Coach Sections
  Widget _buildSectionGrid({
    required BuildContext context,
    required List<Map<String, dynamic>> options,
    required String columnName,
    required bool fromDayOverview,
    required int crossAxisCount,
    required String idColumnName,
    required int? selectedId,
    required ValueChanged<int> onItemSelected,
  }) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return GridView.builder(
      padding: const EdgeInsets.all(12.0), // Add overall padding to the grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,          // Keep the 2-column layout
        childAspectRatio: !fromDayOverview ? 4 : 3,      // A fixed aspect ratio for more uniform cards
        crossAxisSpacing: !fromDayOverview ? 5.0 : 2.0,     // Spacing between columns
        mainAxisSpacing: !fromDayOverview ? 5.0 : 2.0,      // Spacing between rows
      ),
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        final item = options[index];
        final int itemId = item[idColumnName] as int;
        final bool isSelected = itemId == selectedId;

        return elevatedButton(
            label: item[columnName],
            onPressed: (){
              onItemSelected(itemId);
            },
            backgroundColor: isSelected ? localAppTheme['anchorColors']['secondaryColor'] : localAppTheme['anchorColors']['primaryColor'],
            labelColor: isSelected ? localAppTheme['anchorColors']['primaryColor'] : localAppTheme['anchorColors']['secondaryColor'],
            leadingIcon: null,
            trailingIcon: null,
            size: !fromDayOverview ? 12 : 6,
            context: context
        );
      },
    );
  }

  //----------------------------------------------------
  // Mobile Layout
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
          final localAppTheme = ResponsiveTheme(context).theme;
          final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: true);
          final focusBlocks = internalStatusProvider.focusBlocks;
          final workoutTypes = internalStatusProvider.workoutTypes;
          //final allWorkouts = workoutsProvider.allWorkouts;
          final allWorkouts = workoutsProvider.allWorkouts.where((workout) => workout['type'] == type && workout['block'] == block).toList();
          final fromDayOverview = widget.fromDayOverview;
          final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
          final appUser = appUserProvider.appUser;

          return SingleChildScrollView(
            child: Column(
              children: [
                pageHeaderImage(
                  imagePath: 'images/Workouts.png', 
                  context: context, 
                  toolTip: 'ADD WORKOUT', 
                  userProfileToShow: {}, 
                  pageTitle: 'MY WORKOUTS',
                  isCoachView: false,
                  buttonVisibility: !fromDayOverview,
                  showCreateGoalPopupDialog: () {
                    _showCreateWorkoutPopupDialog(context, null, null);
                  },
                ),
                Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: localAppTheme['anchorColors']['primaryColor'],
                                width: allWorkouts.isEmpty ? 1.0 : 0.0,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    !fromDayOverview
                                    ? header2(
                                        header: "WORKOUT TYPE:",
                                        context: context,
                                        color: localAppTheme['anchorColors']['primaryColor']
                                      )
                                    : customHeader(
                                        header: "WORKOUT TYPE:",
                                        context: context,
                                        color: localAppTheme['anchorColors']['primaryColor'],
                                        size: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    SizedBox(
                                      height: 200,
                                      child: _buildSectionGrid(
                                        crossAxisCount: 1,
                                        context: context,
                                        options: workoutTypes,
                                        columnName: 'workoutType',
                                        fromDayOverview: fromDayOverview,
                                        idColumnName: 'workoutTypeID',
                                        selectedId: type,
                                        onItemSelected: (id) {
                                          setState(() {
                                            type = id;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    !fromDayOverview
                                    ? header2(
                                        header: "BLOCK TYPE:",
                                        context: context,
                                        color: localAppTheme['anchorColors']['primaryColor']
                                      )
                                    : customHeader(
                                        header: "BLOCK TYPE:",
                                        context: context,
                                        color: localAppTheme['anchorColors']['primaryColor'],
                                        size: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    SizedBox(
                                      height: 200,
                                      child: _buildSectionGrid(
                                        crossAxisCount: 1,
                                        context: context,
                                        options: focusBlocks,
                                        columnName: 'blockType',
                                        fromDayOverview: fromDayOverview,
                                        idColumnName: 'blockTypeID',
                                        selectedId: block,
                                        onItemSelected: (id) {
                                          setState(() {
                                            block = id;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                            children: List<Widget>.generate(allWorkouts.length, (index) {
                              final workout = allWorkouts[index];

                              return ExpansionTile(
                                collapsedShape: Border(
                                  top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == 0 ? 1.0 : 0.0),
                                  bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                ),
                                showTrailingIcon: false,
                                tilePadding: EdgeInsets.all(0),
                                title: Column(
                                  children: [
                                    SizedBox(height: 10.0),
                                    !fromDayOverview
                                        ? SizedBox(
                                            width: double.infinity,
                                            child: header2(
                                              header: workout['name'] ?? 'Unnamed Workout',
                                              color: localAppTheme['anchorColors']['primaryColor'],
                                              context: context,
                                            ),
                                          )
                                        : SizedBox(
                                            width: double.infinity,
                                            child: header3(
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
                                                  workoutTypes.firstWhere((type) => type['workoutTypeID'] == workout['type'])['icon'] ?? Icons.fitness_center,
                                                  color: localAppTheme['anchorColors']['primaryColor'],
                                                  size: 20,
                                                ),
                                                SizedBox(width: 20.0),
                                                body(
                                                  header: workoutTypes.firstWhere((type) => type['workoutTypeID'] == workout['type'])['workoutType'] ?? 'Unknown',
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
                                        !fromDayOverview
                                          ? imageButtonWithHeader(
                                              width: 75,
                                              height: 100,
                                              onPressed: () {
                                                _showAssignAthletesPopupDialog(context, workout);
                                              },
                                              toolTip: 'ASSIGN TO ATHLETE',
                                              imagePath: 'images/Athletes.png',
                                              context: context,
                                              headerText: 'ASSIGN',
                                            )
                                          : imageButtonWithHeader(
                                              width: 75,
                                              height: 100,
                                              onPressed: () async{
                                                Map<String, dynamic> workoutToLoad = {
                                                  'athleteUID': widget.athleteUID,
                                                  'coachUID': appUser['uid'],
                                                  'workout': {
                                                    'workoutUID': workout['id'],
                                                  },
                                                  'workoutDate': Timestamp.fromDate(widget.selectedDate ?? DateTime.now()),
                                                };
                                              try{
                                                await workoutsProvider.createLoadedWorkoutRecord(workoutToLoad, workout);
                                                Navigator.of(context).pop();
                                                } catch(e){
                                                  Navigator.of(context).pop();
                                                  showGeneralPopupDialog(context, 'Error', 'Failed to assign workout to athlete. Please try again.');
                                                }
                                              },
                                              toolTip: 'ASSIGN TO ATHLETE',
                                              imagePath: 'images/Athletes.png',
                                              context: context,
                                              headerText: 'ASSIGN',
                                            )
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                  ],
                                ),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        header3(header: 'Workout Breakdown:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                        SizedBox(height: 5.0),
                                        body(
                                          header: workout['breakdown'] ?? 'No breakdown provided.',
                                          color: localAppTheme['anchorColors']['primaryColor'],
                                          context: context,
                                        ),
                                        SizedBox(height: 10.0),
                                        header3(header: 'Description:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                        SizedBox(height: 5.0),
                                        body(
                                          header: workout['description'] ?? 'No description provided.',
                                          color: localAppTheme['anchorColors']['primaryColor'],
                                          context: context,
                                        ),
                                        Visibility(
                                          visible: !fromDayOverview,
                                          child: Column(
                                            children: [
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
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                      ],
                    )
              ],
            ),
          );
        }
      },
    );
  }
}
