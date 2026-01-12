import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/Home/Providers/clubsprovided.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  final bool isCoachView;

  const UserProfile({super.key, required this.isCoachView});

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
  bool formEditable = false;
  Map<String, dynamic>? selectedClub;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);

    _fetchDataFuture = _fetchData(appUserProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(AppUserProvider appUserProvider) async {
    final appUser = appUserProvider.appUser;

    appUser['name'] == null ? firstNameController.text = '' : firstNameController.text = appUser['name'];
    appUser['surname'] == null ? lastNameController.text = '' : lastNameController.text = appUser['surname'];
    appUser['email'] == null ? emailController.text = '' : emailController.text = appUser['email'];
    appUser['dateOfBirth'] == null ? dateOfBirthController.text = '' : dateOfBirthController.text = appUser['dateOfBirth'];
    appUser['athleteDisciplines']['otherDiscipline'] == null
        ? disciplineOtherController.text = ''
        : disciplineOtherController.text = appUser['athleteDisciplines']['otherDiscipline'];
  }

  //----------------------------------------------------
  //Reset controllers
  Future<void> _resetControllers(AppUserProvider appUserProvider) async {
    // Refresh user data from deep store first, then read the provider value
    await appUserProvider.refreshDeepStore();
    final appUser = appUserProvider.appUser;

    firstNameController.text = appUser['name'] ?? '';
    lastNameController.text = appUser['surname'] ?? '';
    emailController.text = appUser['email'] ?? '';
    dateOfBirthController.text = appUser['dateOfBirth'] ?? '';
    disciplineOtherController.text = appUser['athleteDisciplines']['otherDiscipline'] ?? '';
  }

  //----------------------------------------------------
  // Club Selection Popup Dialog
  Future<void> _showClubSelectionPopupDialog(BuildContext context) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
    final clubs = clubsProvider.Clubs;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final userProfile = appUserProvider.appUser;

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
    final appUser = appUserProvider.appUser;
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
                    if (widget.isCoachView) {
                      Navigator.of(context).pop();
                      return;
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => HomePage()
                          ),
                        );
                    }
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header1(header: 'Profile:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                  SizedBox(height: 20.0),
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
                      appUser['name'] = firstNameController.text;
                    },
                  ),
                  SizedBox(height: 10.0),
                  FormInputField(
                    label: 'Last Name:',
                    errorMessage: 'Please enter your first name',
                    isMultiline: false,
                    isPassword: false,
                    prefixIcon: null,
                    suffixIcon: null,
                    showLabel: true,
                    controller: lastNameController,
                    enabled: formEditable,
                    onChanged: (value) {
                      appUser['surname'] = lastNameController.text;
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
                      appUser['dateOfBirth'] = dateOfBirthController.text;
                    },
                  ),
                  SizedBox(height: 20.0),
                  header1(header: 'Disciplines:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                  SizedBox(height: 20.0),
                  tickBox(
                    label: 'Running',
                    value: appUser['athleteDisciplines']['runningBool'],
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        appUser['athleteDisciplines']['runningBool'] = newValue ?? false;
                      });
                    },
                    context: context,
                  ),
                  tickBox(
                    label: 'Ultra Running',
                    value: appUser['athleteDisciplines']['ultraRunningBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        appUser['athleteDisciplines']['ultraRunningBool'] = newValue ?? false;
                      });
                    },
                    context: context,
                  ),
                  SizedBox(height: 10.0),
                  tickBox(
                    label: 'Cycling',
                    value: appUser['athleteDisciplines']['cyclingBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        appUser['athleteDisciplines']['cyclingBool'] = newValue ?? false;
                      });
                    },
                    context: context,
                  ),
                  SizedBox(height: 10.0),
                  tickBox(
                    label: 'Swimming',
                    value: appUser['athleteDisciplines']['swimmingBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        appUser['athleteDisciplines']['swimmingBool'] = newValue ?? false;
                      });
                    },
                    context: context,
                  ),
                  SizedBox(height: 10.0),
                  tickBox(
                    label: 'Triathlon',
                    value: appUser['athleteDisciplines']['triathlonBool'] ?? false,
                    enabled: formEditable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        appUser['athleteDisciplines']['triathlonBool'] = newValue ?? false;
                      });
                    },
                    context: context,
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      tickBox(
                        label: 'Other',
                        value: appUser['athleteDisciplines']['otherBool'] ?? false,
                        enabled: formEditable,
                        onChanged: (bool? newValue) {
                          setState(() {
                            appUser['athleteDisciplines']['otherBool'] = newValue ?? false;
                          });
                        },
                        context: context,
                      ),
                      SizedBox(width: 20.0),
                      Visibility(
                        visible: appUser['athleteDisciplines']['otherBool'] ?? false,
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
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        header1(header: 'Clubs:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
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
                  ),
                  SizedBox(height: 10.0),
                  appUser['clubs'] != null && (appUser['clubs'] as List).isNotEmpty
                      ? Column(
                          children: List<Widget>.generate((appUser['clubs'] as List).length, (index) {
                            final club = appUser['clubs'][index];
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
                                          appUser['clubs'].removeAt(index);
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
                  Visibility(
                    visible: !formEditable && !widget.isCoachView,
                    child: elevatedButton(
                      label: 'EDIT PROFILE',
                      onPressed: () {
                        setState(() {
                          formEditable = true;
                        });
                      },
                      backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                      labelColor: localAppTheme['anchorColors']['secondaryColor'],
                      leadingIcon: null,
                      trailingIcon: null,
                      context: context,
                    ),
                  ),
                  Visibility(
                    visible: formEditable,
                    child: Row(
                      children: [
                        Expanded(
                          child: elevatedButton(
                            label: 'CANCEL',
                            onPressed: () async {
                              await _resetControllers(appUserProvider);
                              setState(() {
                                formEditable = false;
                              });
                            },
                            backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                            labelColor: localAppTheme['anchorColors']['secondaryColor'],
                            leadingIcon: null,
                            trailingIcon: null,
                            context: context,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: elevatedButton(
                            label: 'SAVE CHANGES',
                            onPressed: () async {
                              try {
                                await appUserProvider.updateUserRecord(appUser);
                                showGeneralPopupDialog(context, 'Success!', 'Your profile has been updated successfully.');
                                setState(() {
                                  formEditable = false;
                                });
                              } catch (e) {
                                showGeneralPopupDialog(context, 'Error', 'An error occurred while updating your profile. Please try again.');
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
