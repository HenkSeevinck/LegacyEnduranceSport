import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
//import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
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

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchData();
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData() async {
    //Add fetch functions from Providers you want to fetch data from here
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
  }

  //----------------------------------------------------
  // Add Workout Context Menus and Dialogs Here
  _showCreateWorkoutPopupDialog(BuildContext context, Map<String, dynamic>? workout, int? index) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
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
          title: Text(workout == null ? 'New Workout:' : 'Edit Workout:', style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'])),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setStateDialog) {
                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormInputField(
                        label: 'Workout Name:',
                        errorMessage: 'Please enter a workout name',
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
                        controller: workoutNameController,
                      ),
                      SizedBox(height: 10.0),
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
                            draftWorkout['type'] = value;
                          });
                        },
                        isEnabled: true,
                        initialValue: draftWorkout['type'],
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
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
                            draftWorkout['block'] = value;
                          });
                        },
                        isEnabled: true,
                        initialValue: draftWorkout['block'],
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
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
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      FormInputField(
                        label: 'Description:',
                        errorMessage: 'Please enter a description',
                        isMultiline: true,
                        isPassword: false,
                        prefixIcon: null,
                        suffixIcon: null,
                        showLabel: true,
                        onChanged: (value) {
                          setStateDialog(() {});
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
    //final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    //final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    //final appUser = appUserProvider.appUser;

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
