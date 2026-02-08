import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/General/Providers/clubs_provided.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/MyAthletes/Page/my_athletes_page.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  final bool isCoachView;
  final bool formEditable;

  const UserProfile({super.key, required this.isCoachView, required this.formEditable});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController disciplineOtherController = TextEditingController();
  bool showsearch = false;
  String? searchPrase;
  Future<void>? _fetchDataFuture;
  //bool formEditable = false;
  Map<String, dynamic>? selectedClub;
  late bool formEditable = widget.formEditable;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoadingImage = false;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    _fetchDataFuture = _fetchData(appUserProvider, internalStatusProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(AppUserProvider appUserProvider, InternalStatusProvider internalStatusProvider) async {
    final userUIDToShow = internalStatusProvider.userUIDToShow;

    // Load user data
    await appUserProvider.getUserProfileToShow(userUIDToShow);

    final userProfileToShow = appUserProvider.userProfileToShow;

    userProfileToShow['name'] == null ? firstNameController.text = '' : firstNameController.text = userProfileToShow['name'];
    userProfileToShow['surname'] == null ? lastNameController.text = '' : lastNameController.text = userProfileToShow['surname'];
    userProfileToShow['email'] == null ? emailController.text = '' : emailController.text = userProfileToShow['email'];
    userProfileToShow['dateOfBirth'] == null ? dateOfBirthController.text = '' : dateOfBirthController.text = userProfileToShow['dateOfBirth'];
    userProfileToShow['athleteDisciplines'] == null || userProfileToShow['athleteDisciplines']['otherDiscipline'] == null
        ? disciplineOtherController.text = ''
        : disciplineOtherController.text = userProfileToShow['athleteDisciplines']['otherDiscipline'];
  }

  //----------------------------------------------------
  // Dispose controllers
  @override
  void dispose() {
    dateOfBirthController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    disciplineOtherController.dispose();
    super.dispose();
  }

  //----------------------------------------------------
  // Workout Days Widget
  Widget _workoutDaysWidget(Map<String, dynamic> userProfileToShow) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final workoutTypes = internalStatusProvider.workoutTypes;

    // Initialize workoutDays if missing
    if (userProfileToShow['workoutDays'] == null) {
      userProfileToShow['workoutDays'] = {
        'mondayBool': false,
        'mondayPreference': null,
        'tuesdayBool': false,
        'tuesdayPreference': null,
        'wednesdayBool': false,
        'wednesdayPreference': null,
        'thursdayBool': false,
        'thursdayPreference': null,
        'fridayBool': false,
        'fridayPreference': null,
        'saturdayBool': false,
        'saturdayPreference': null,
        'sundayBool': false,
        'sundayPreference': null,
      };
    }

    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.calendar_today, color: localAppTheme['anchorColors']['primaryColor']),
          SizedBox(width: 10.0),
          header1(header: 'Workout Days:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ],
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0)),
          ),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tickBox(
                    label: 'Monday',
                    value: userProfileToShow['workoutDays']['mondayBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        userProfileToShow['workoutDays']['mondayBool'] = newValue ?? false;
                        userProfileToShow['workoutDays']['mondayPreference'] = null;
                      });
                    },
                    context: context,
                  ),
                  Visibility(
                    visible: userProfileToShow['workoutDays']['mondayBool'] ?? false,
                    child: SizedBox(
                      width: 200,
                      child: SearchableDropdown(
                        labelText: 'Workout Preference:',
                        hint: 'Select Preference',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: workoutTypes,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'workoutTypeID',
                        displayField: 'workoutType',
                        onChanged: (value) {
                          userProfileToShow['workoutDays']['mondayPreference'] = value?['workoutTypeID'];
                        },
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                        isEnabled: true,
                        initialValue: userProfileToShow['workoutDays']['mondayPreference'],
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a workout preference';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tickBox(
                    label: 'Tuesday',
                    value: userProfileToShow['workoutDays']['tuesdayBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        userProfileToShow['workoutDays']['tuesdayBool'] = newValue ?? false;
                        userProfileToShow['workoutDays']['tuesdayPreference'] = null;
                      });
                    },
                    context: context,
                  ),
                  Visibility(
                    visible: userProfileToShow['workoutDays']['tuesdayBool'] ?? false,
                    child: SizedBox(
                      width: 200,
                      child: SearchableDropdown(
                        labelText: 'Workout Preference:',
                        hint: 'Select Preference',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: workoutTypes,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'workoutTypeID',
                        displayField: 'workoutType',
                        onChanged: (value) {
                          userProfileToShow['workoutDays']['tuesdayPreference'] = value?['workoutTypeID'];
                        },
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                        isEnabled: true,
                        initialValue: userProfileToShow['workoutDays']['tuesdayPreference'],
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a workout preference';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tickBox(
                    label: 'Wednesday',
                    value: userProfileToShow['workoutDays']['wednesdayBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        userProfileToShow['workoutDays']['wednesdayBool'] = newValue ?? false;
                        userProfileToShow['workoutDays']['wednesdayPreference'] = null;
                      });
                    },
                    context: context,
                  ),
                  Visibility(
                    visible: userProfileToShow['workoutDays']['wednesdayBool'] ?? false,
                    child: SizedBox(
                      width: 200,
                      child: SearchableDropdown(
                        labelText: 'Workout Preference:',
                        hint: 'Select Preference',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: workoutTypes,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'workoutTypeID',
                        displayField: 'workoutType',
                        onChanged: (value) {
                          userProfileToShow['workoutDays']['wednesdayPreference'] = value?['workoutTypeID'];
                        },
                        isEnabled: true,
                        initialValue: userProfileToShow['workoutDays']['wednesdayPreference'],
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a workout preference';
                          }
                          return null;
                        },
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tickBox(
                    label: 'Thursday',
                    value: userProfileToShow['workoutDays']['thursdayBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        userProfileToShow['workoutDays']['thursdayBool'] = newValue ?? false;
                        userProfileToShow['workoutDays']['thursdayPreference'] = null;
                      });
                    },
                    context: context,
                  ),
                  Visibility(
                    visible: userProfileToShow['workoutDays']['thursdayBool'] ?? false,
                    child: SizedBox(
                      width: 200,
                      child: SearchableDropdown(
                        labelText: 'Workout Preference:',
                        hint: 'Select Preference',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: workoutTypes,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'workoutTypeID',
                        displayField: 'workoutType',
                        onChanged: (value) {
                          userProfileToShow['workoutDays']['thursdayPreference'] = value?['workoutTypeID'];
                        },
                        isEnabled: true,
                        initialValue: userProfileToShow['workoutDays']['thursdayPreference'],
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a workout preference';
                          }
                          return null;
                        },
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tickBox(
                    label: 'Friday',
                    value: userProfileToShow['workoutDays']['fridayBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        userProfileToShow['workoutDays']['fridayBool'] = newValue ?? false;
                        userProfileToShow['workoutDays']['fridayPreference'] = null;
                      });
                    },
                    context: context,
                  ),
                  Visibility(
                    visible: userProfileToShow['workoutDays']['fridayBool'] ?? false,
                    child: SizedBox(
                      width: 200,
                      child: SearchableDropdown(
                        labelText: 'Workout Preference:',
                        hint: 'Select Preference',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: workoutTypes,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'workoutTypeID',
                        displayField: 'workoutType',
                        onChanged: (value) {
                          userProfileToShow['workoutDays']['fridayPreference'] = value?['workoutTypeID'];
                        },
                        isEnabled: true,
                        initialValue: userProfileToShow['workoutDays']['fridayPreference'],
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a workout preference';
                          }
                          return null;
                        },
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tickBox(
                    label: 'Saturday',
                    value: userProfileToShow['workoutDays']['saturdayBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        userProfileToShow['workoutDays']['saturdayBool'] = newValue ?? false;
                        userProfileToShow['workoutDays']['saturdayPreference'] = null;
                      });
                    },
                    context: context,
                  ),
                  Visibility(
                    visible: userProfileToShow['workoutDays']['saturdayBool'] ?? false,
                    child: SizedBox(
                      width: 200,
                      child: SearchableDropdown(
                        labelText: 'Workout Preference:',
                        hint: 'Select Preference',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: workoutTypes,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'workoutTypeID',
                        displayField: 'workoutType',
                        onChanged: (value) {
                          userProfileToShow['workoutDays']['saturdayPreference'] = value?['workoutTypeID'];
                        },
                        isEnabled: true,
                        initialValue: userProfileToShow['workoutDays']['saturdayPreference'],
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a workout preference';
                          }
                          return null;
                        },
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tickBox(
                    label: 'Sunday',
                    value: userProfileToShow['workoutDays']['sundayBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        userProfileToShow['workoutDays']['sundayBool'] = newValue ?? false;
                        userProfileToShow['workoutDays']['sundayPreference'] = null;
                      });
                    },
                    context: context,
                  ),
                  Visibility(
                    visible: userProfileToShow['workoutDays']['sundayBool'] ?? false,
                    child: SizedBox(
                      width: 200,
                      child: SearchableDropdown(
                        labelText: 'Workout Preference:',
                        hint: 'Select Preference',
                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                        searchBoxVisable: false,
                        dropDownList: workoutTypes,
                        header: '',
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        idField: 'workoutTypeID',
                        displayField: 'workoutType',
                        onChanged: (value) {
                          userProfileToShow['workoutDays']['sundayPreference'] = value?['workoutTypeID'];
                        },
                        isEnabled: true,
                        initialValue: userProfileToShow['workoutDays']['sundayPreference'],
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a workout preference';
                          }
                          return null;
                        },
                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ],
    );
  }

  //----------------------------------------------------
  // Disciplines Widget
  Widget _disciplinesWidget(Map<String, dynamic> userProfileToShow) {
    final localAppTheme = ResponsiveTheme(context).theme;

    // Initialize athleteDisciplines if missing
    if (userProfileToShow['athleteDisciplines'] == null) {
      userProfileToShow['athleteDisciplines'] = {
        'runningBool': false,
        'ultraRunningBool': false,
        'cyclingBool': false,
        'swimmingBool': false,
        'triathlonBool': false,
        'otherBool': false,
        'otherDiscipline': '',
      };
    }

    return ExpansionTile(
      collapsedShape: Border(
        top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
        bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.fitness_center, color: localAppTheme['anchorColors']['primaryColor']),
          SizedBox(width: 10.0),
          header1(header: 'Disciplines:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ],
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0)),
          ),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              tickBox(
                label: 'Running',
                value: userProfileToShow['athleteDisciplines']['runningBool'] ?? false,
                enabled: formEditable,
                onChanged: (bool? newValue) {
                  setState(() {
                    userProfileToShow['athleteDisciplines']['runningBool'] = newValue ?? false;
                  });
                },
                context: context,
              ),
              SizedBox(height: 10.0),
              tickBox(
                label: 'Ultra Running',
                value: userProfileToShow['athleteDisciplines']['ultraRunningBool'] ?? false,
                enabled: formEditable,
                onChanged: (bool? newValue) {
                  setState(() {
                    userProfileToShow['athleteDisciplines']['ultraRunningBool'] = newValue ?? false;
                  });
                },
                context: context,
              ),
              SizedBox(height: 10.0),
              tickBox(
                label: 'Cycling',
                value: userProfileToShow['athleteDisciplines']['cyclingBool'] ?? false,
                enabled: formEditable,
                onChanged: (bool? newValue) {
                  setState(() {
                    userProfileToShow['athleteDisciplines']['cyclingBool'] = newValue ?? false;
                  });
                },
                context: context,
              ),
              SizedBox(height: 10.0),
              tickBox(
                label: 'Swimming',
                value: userProfileToShow['athleteDisciplines']['swimmingBool'] ?? false,
                enabled: formEditable,
                onChanged: (bool? newValue) {
                  setState(() {
                    userProfileToShow['athleteDisciplines']['swimmingBool'] = newValue ?? false;
                  });
                },
                context: context,
              ),
              SizedBox(height: 10.0),
              tickBox(
                label: 'Triathlon',
                value: userProfileToShow['athleteDisciplines']['triathlonBool'] ?? false,
                enabled: formEditable,
                onChanged: (bool? newValue) {
                  setState(() {
                    userProfileToShow['athleteDisciplines']['triathlonBool'] = newValue ?? false;
                  });
                },
                context: context,
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  tickBox(
                    label: 'Other',
                    value: userProfileToShow['athleteDisciplines']['otherBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        userProfileToShow['athleteDisciplines']['otherBool'] = newValue ?? false;
                      });
                    },
                    context: context,
                  ),
                  SizedBox(width: 20.0),
                  Visibility(
                    visible: userProfileToShow['athleteDisciplines']['otherBool'] ?? false,
                    child: Expanded(
                      child: FormInputField(
                        label: 'Please specify:',
                        errorMessage: 'Please enter your discipline',
                        isMultiline: false,
                        isPassword: false,
                        prefixIcon: null,
                        suffixIcon: null,
                        showLabel: true,
                        controller: disciplineOtherController,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ],
    );
  }

  //----------------------------------------------------
  // Clubs Widget
  Widget _clubsWidget(Map<String, dynamic> userProfileToShow) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return ExpansionTile(
      collapsedShape: Border(
        top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
        bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.group, color: localAppTheme['anchorColors']['primaryColor']),
              SizedBox(width: 10.0),
              header1(header: 'Clubs:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
            ],
          ),
          Visibility(
            visible: formEditable,
            child: iconButton(
              label: null,
              backgroundColor: null,
              iconColor: localAppTheme['anchorColors']['primaryColor'],
              icon: Icons.add,
              size: 30,
              toolTip: 'ADD CLUB',
              onPressed: () {
                _showClubSelectionPopupDialog(context);
              },
              context: context,
            ),
          ),
        ],
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0)),
          ),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              userProfileToShow['clubs'] != null && (userProfileToShow['clubs'] as List).isNotEmpty
                  ? Column(
                      children: List<Widget>.generate((userProfileToShow['clubs'] as List).length, (index) {
                        final club = userProfileToShow['clubs'][index];
                        return ListTile(
                          title: body(header: club['clubName'], color: localAppTheme['anchorColors']['primaryColor'], context: context),
                          trailing: formEditable
                              ? iconButton(
                                  label: null,
                                  backgroundColor: null,
                                  iconColor: localAppTheme['anchorColors']['primaryColor'],
                                  icon: Icons.delete,
                                  size: 30,
                                  toolTip: 'REMOVE CLUB',
                                  onPressed: () {
                                    setState(() {
                                      userProfileToShow['clubs'].removeAt(index);
                                    });
                                  },
                                  context: context,
                                )
                              : null,
                        );
                      }),
                    )
                  : Container(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ],
    );
  }

  //----------------------------------------------------
  // Profile picture selection widget
  Future<void> _selectProfilePicture(String uid) async {
    // Use FilePicker specifically for Web stability
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['jpg'],
    );

    if (result != null && result.files.first.bytes != null) {
      final Uint8List fileBytes = result.files.first.bytes!;
      final String fileName = result.files.first.name;

      try {
        final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
        await appUserProvider.updateUserProfileImage(uid, fileBytes, fileName);
      } catch (e) {
        rethrow;
      }
    }
  }

  //----------------------------------------------------
  // My Profile Widget
  Widget _myProfileWidget(Map<String, dynamic> userProfileToShow) {
    final localAppTheme = ResponsiveTheme(context).theme;
    return ExpansionTile(
      initiallyExpanded: true,
      collapsedShape: Border(
        top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
        bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.person, color: localAppTheme['anchorColors']['primaryColor']),
          SizedBox(width: 10.0),
          header1(header: 'Details:', context: context, color: localAppTheme['anchorColors']['primaryColor'])
        ],
      ),
      children: [
        Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0)),
            ),
            child: Column(
              children: [
                SizedBox(height: 20.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          FormInputField(
                            label: 'First Name:',
                            errorMessage: 'Please enter your first name',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            controller: firstNameController,
                            enabled: formEditable,
                            onChanged: (value) {
                              userProfileToShow['name'] = firstNameController.text;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0),
                          FormInputField(
                            label: 'Last Name:',
                            errorMessage: 'Please enter your last name',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            controller: lastNameController,
                            enabled: formEditable,
                            onChanged: (value) {
                              userProfileToShow['surname'] = lastNameController.text;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0),
                          FormInputField(
                            label: 'Email Name:',
                            errorMessage: 'Please enter your first name',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            enabled: false,
                            controller: emailController,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Stack(
                        children: [
                        Container(
                          width: 100,
                          height: 164,
                          decoration: BoxDecoration(
                          border: Border.all(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: isLoadingImage
                            ? Center(child: CircularProgressIndicator(color: localAppTheme['anchorColors']['primaryColor']))
                            : userProfileToShow['profileImageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: Image.network(
                                  userProfileToShow['profileImageUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset('images/PlaceholderUserImage.png', fit: BoxFit.cover);
                                  },
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: Image.asset(
                                  'images/PlaceholderUserImage.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset('images/PlaceholderUserImage.png', fit: BoxFit.cover);
                                  },
                                ),
                              ),
                      ),
                        Visibility(
                          visible: !widget.isCoachView,
                          child: Positioned(
                            bottom: 5,
                            left: 5,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                              color: localAppTheme['anchorColors']['primaryColor'],
                              shape: BoxShape.circle,
                              ),
                              child: IconButton(
                              onPressed: () async {
                                try {
                                  setState(() {
                                    isLoadingImage = true;
                                  });
                                  await _selectProfilePicture(userProfileToShow['uid']);
                                } catch (e) {
                                  showGeneralPopupDialog(context, 'Error', 'An error occurred while selecting your profile picture. Please try again.');
                                }
                                setState(() {
                                  isLoadingImage = false;
                                });
                              }, 
                              icon: Icon(
                                size: 20,
                                Icons.photo, 
                                color: localAppTheme['anchorColors']['secondaryColor'],
                              ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 10.0),
                DatePicker(
                  buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                  label: 'Date of Birth:',
                  buttonVisibility: true,
                  initialDate: null,
                  enabled: formEditable,
                  firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
                  lastDate: DateTime.now(),
                  validator: (date) {
                    if (date == null) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                  controller: dateOfBirthController,
                  onChanged: (selectedDate) {
                    userProfileToShow['dateOfBirth'] = dateOfBirthController.text;
                  },
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
      ],
    );
  }

  //----------------------------------------------------
  // Club Selection Popup Dialog
  Future<void> _showClubSelectionPopupDialog(BuildContext context) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
    final clubs = clubsProvider.clubs;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final userProfile = appUserProvider.userProfileToShow;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
          title: header1(header: 'Select Club:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          content: SingleChildScrollView(
            child: SearchableDropdown(
              labelText: 'Search Clubs:',
              hint: 'Select Club',
              dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
              searchBoxVisable: true,
              dropDownList: clubs!,
              header: '',
              iconColor: localAppTheme['anchorColors']['primaryColor'],
              idField: 'clubId',
              displayField: 'clubName',
              onChanged: (value) {
                selectedClub = value;
              },
              isEnabled: true,
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
                      selectedClub = null;
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
                      if (selectedClub != null) {
                        if (userProfile['clubs'] == null) {
                          userProfile['clubs'] = [];
                        }
                        setState(() {
                          userProfile['clubs'].add(selectedClub);
                        });
                      }
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
  Widget _buildMobileUserProfile() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final userProfileToShow = appUserProvider.userProfileToShow;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(
          context: context,
          automaticallyImplyLeading: true,
          onPressed: () {
            if (widget.isCoachView) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyAthletesPage()));
              return;
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    pageHeaderImage(
                    imagePath: 'images/Profile.png', 
                    context: context, 
                    toolTip: '', 
                    userProfileToShow: userProfileToShow, 
                    pageTitle: 'PROFILE',
                    isCoachView: widget.isCoachView,
                    buttonVisibility: false,
                  ),
                  _myProfileWidget(userProfileToShow),
                  _disciplinesWidget(userProfileToShow),
                  _workoutDaysWidget(userProfileToShow),
                  _clubsWidget(userProfileToShow),
                  SizedBox(height: 20.0),
                  Visibility(
                    visible: !widget.isCoachView,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: elevatedButton(
                        label: 'SAVE CHANGES',
                        onPressed: () async {
                          final formState = _formKey.currentState;
                          if (formState != null && formState.validate()) {
                            try {
                              await appUserProvider.updateUserRecord(userProfileToShow);
                              showGeneralPopupDialog(context, 'Success!', 'Your profile has been updated successfully.');
                            } catch (e) {
                              showGeneralPopupDialog(context, 'Error', 'An error occurred while updating your profile. Please try again.');
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
  Widget _buildDesktopUserProfile() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackUserProfile() {
    return Scaffold(body: const Center(child: Text('Landing Page - Fallback Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Build Method
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
            return _buildMobileUserProfile();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopUserProfile();
          } else {
            return _buildFallbackUserProfile();
          }
        }
      },
    );
  }
}
