import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  Future<void>? _fetchDataFuture;
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    //Add Providers you want to fetch data from here
    _fetchDataFuture = _fetchData();
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData() async {
    //Add fetch functions from Providers you want to fetch data from here
  }

  //----------------------------------------------------
  // Set Controlles
  Future<void> _setControllers() async {
    titleController.text = '';
    distanceController.text = '';
    dateController.text = '';
    durationController.text = 'hh:mm:ss';
  }

  //----------------------------------------------------
  // Dispose controllers
  @override
  void dispose() {
    titleController.dispose();
    distanceController.dispose();
    dateController.dispose();
    durationController.dispose();
    super.dispose();
  }

  //----------------------------------------------------
  // Athlete Selection Popup Dialog
  Future<void> _showCreateGoalPopupDialog(BuildContext context, Map<String, dynamic>? goal, int? index) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    //final allUsers = appUserProvider.allUsers;
    final eventTypes = internalStatusProvider.eventTypes;
    Map<String, dynamic>? selectedAthlete;
    await _setControllers();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
          title: header1(header: 'Create a Goal:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormInputField(
                  label: 'Title:',
                  errorMessage: 'Please enter a valid goal title.',
                  isMultiline: false,
                  isPassword: false,
                  prefixIcon: null,
                  suffixIcon: null,
                  showLabel: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid goal title.';
                    }
                    return null;
                  },
                  controller: titleController,
                ),
                SizedBox(height: 10.0),
                DatePicker(
                  buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                  label: 'Date:',
                  buttonVisibility: true,
                  initialDate: null,
                  validator: (date) {
                    if (date == null) {
                      return 'Please select a valid date.';
                    }
                    return null;
                  },
                  controller: dateController,
                ),
                SizedBox(height: 10.0),
                SearchableDropdown(
                  labelText: 'Type:',
                  hint: 'Event Type',
                  dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                  searchBoxVisable: false,
                  dropDownList: eventTypes,
                  header: '',
                  iconColor: localAppTheme['anchorColors']['primaryColor'],
                  idField: 'id',
                  displayField: 'eventType',
                  onChanged: (value) {
                    setState(() {
                      //selectedAthlete = value;
                    });
                  },
                  isEnabled: true,
                ),
                SizedBox(height: 10.0),
                FormInputField(
                  label: 'Distance:',
                  errorMessage: 'Please enter a valid goal distance (integer).',
                  isMultiline: false,
                  isPassword: false,
                  prefixIcon: null,
                  suffixIcon: null,
                  showLabel: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid goal distance.';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer distance.';
                    }
                    return null;
                  },
                  controller: distanceController,
                ),
                SizedBox(height: 10.0),
                FormInputField(
                  label: 'Duration:',
                  errorMessage: 'Please enter a valid goal duration.',
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
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: elevatedButton(
                    label: 'CANCEL',
                    onPressed: () {
                      selectedAthlete = null;
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
                      if (selectedAthlete != null) {
                        try {
                          setState(() {
                            isLoading = true;
                          });
                          await appUserProvider.addAthleteToCoach(appUser['coachDocID'], selectedAthlete!['uid'], selectedAthlete!['email']);
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop();
                          showGeneralPopupDialog(context, 'Success!', 'Athlete added successfully.');
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop();
                          showGeneralPopupDialog(context, 'Error!', 'Failed to add athlete.');
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
  // Mobile Layout
  Widget _buildMobileGoalsPage() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final eventTypes = internalStatusProvider.eventTypes;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    //final goals = appUserProvider.appUser['goals'];
    final goals = appUserProvider.appUser['goals'].where((goal) {
      final eventDate = goal['date'];
      if (eventDate is Timestamp) {
        return eventDate.toDate().isAfter(DateTime.now());
      } else if (eventDate is DateTime) {
        return eventDate.isAfter(DateTime.now());
      }
      return false;
    }).toList();

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
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      header1(header: 'My Goals:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      iconButton(
                        label: null,
                        backgroundColor: null,
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        icon: Icons.add,
                        size: 30,
                        toolTip: 'ADD GOAL',
                        onPressed: () {
                          _showCreateGoalPopupDialog(context, null, null);
                        },
                        context: context,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                goals != null && goals.isNotEmpty
                    ? Column(
                        children: List<Widget>.generate(goals.length, (index) {
                          final itemCount = goals.length;
                          final goal = goals[index];
                          String eventDateStr = 'No Date Provided';
                          final rawDate = goal['date'];
                          if (rawDate != null) {
                            if (rawDate is Timestamp) {
                              eventDateStr = DateFormat.yMMMMd().add_jm().format(rawDate.toDate());
                            } else if (rawDate is DateTime) {
                              eventDateStr = DateFormat.yMMMMd().add_jm().format(rawDate);
                            } else {
                              eventDateStr = rawDate.toString();
                            }
                          }
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == (itemCount - 1) ? 1.0 : 0.0),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              children: [
                                SizedBox(height: 10.0),
                                SizedBox(
                                  width: double.infinity,
                                  child: header2(
                                    header: goal['title'] ?? 'Unnamed Goal',
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
                                            Icon(Icons.event, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                            SizedBox(width: 20.0),
                                            body(header: eventDateStr, color: localAppTheme['anchorColors']['primaryColor'], context: context),
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Icon(Icons.flag_outlined, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                            SizedBox(width: 20.0),
                                            body(
                                              header: eventTypes.where((type) => type['id'] == goal['type']).map((type) => type['eventType']).first ?? 'No Type Provided',
                                              color: localAppTheme['anchorColors']['primaryColor'],
                                              context: context,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Icon(Icons.straighten, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                            SizedBox(width: 20.0),
                                            body(
                                              header: '${goal['distance'].toString()} km',
                                              color: localAppTheme['anchorColors']['primaryColor'],
                                              context: context,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Icon(Icons.timer_outlined, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                            SizedBox(width: 20.0),
                                            body(header: goal['duration'].toString(), color: localAppTheme['anchorColors']['primaryColor'], context: context),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 20.0),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(left: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                                        ),
                                        child: Column(
                                          children: [
                                            iconButton(
                                              label: null,
                                              backgroundColor: null,
                                              iconColor: localAppTheme['anchorColors']['primaryColor'],
                                              icon: Icons.edit_outlined,
                                              size: 30,
                                              toolTip: 'Edit Goal',
                                              context: context,
                                              onPressed: () {
                                                _showCreateGoalPopupDialog(context, goal, index);
                                              },
                                            ),
                                            SizedBox(height: 10.0),
                                            iconButton(
                                              label: null,
                                              backgroundColor: null,
                                              iconColor: localAppTheme['anchorColors']['primaryColor'],
                                              icon: Icons.delete_outlined,
                                              size: 30,
                                              toolTip: 'Remove Goal',
                                              context: context,
                                              onPressed: () {
                                                // Remove action
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                              ],
                            ),
                          );
                        }),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopGoalsPage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackGoalsPage() {
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
            return _buildMobileGoalsPage();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopGoalsPage();
          } else {
            return _buildFallbackGoalsPage();
          }
        }
      },
    );
  }
}
