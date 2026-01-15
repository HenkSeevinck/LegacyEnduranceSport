import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class GoalsPage extends StatefulWidget {
  final bool isCoachView;
  const GoalsPage({super.key, required this.isCoachView});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  Future<void>? _fetchDataFuture;
  bool isLoading = false;
  TextEditingController dateController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    titleController.dispose();
    distanceController.dispose();
    durationController.dispose();
    super.dispose();
  }

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
    await appUserProvider.getUserProfileToShow(userUIDToShow);
  }

  //----------------------------------------------------
  // Update text controllers with current data
  void _updateTextControllers(Map<String, dynamic>? goal) {
    // Avoid updating controllers after the State object is disposed.
    if (!mounted) return;

    // If no goal provided, clear controllers.
    if (goal == null) {
      dateController.text = '';
      titleController.text = '';
      distanceController.text = '';
      durationController.text = '';
      return;
    }

    final dynamic goalDate = goal['date'];
    if (goalDate == null) {
      dateController.text = '';
    } else if (goalDate is Timestamp) {
      dateController.text = DateFormat.yMd().format(goalDate.toDate());
    } else if (goalDate is DateTime) {
      dateController.text = DateFormat.yMd().format(goalDate);
    } else if (goalDate is String) {
      final parsed = DateTime.tryParse(goalDate);
      if (parsed != null) {
        dateController.text = DateFormat.yMd().format(parsed);
      } else {
        dateController.text = '';
      }
    } else {
      dateController.text = '';
    }

    titleController.text = (goal['title'] ?? '').toString();
    distanceController.text = (goal['distance'] ?? '').toString();
    durationController.text = (goal['duration'] ?? '').toString();
  }

  //----------------------------------------------------
  // Parse various stored date representations into a DateTime
  DateTime? _parseToDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  //----------------------------------------------------
  // Delete goal from user profile by matching title (to avoid index/order mismatches)
  Future<void> _deleteGoal(Map<String, dynamic> goalItem) async {
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final currentGoals = List<dynamic>.from(appUserProvider.appUser['goals'] ?? <dynamic>[]);

    final String uuidToRemove = (goalItem['uuid'] ?? '').toString();
    if (uuidToRemove.isEmpty) return;

    final int removeIndex = currentGoals.indexWhere((g) => (g is Map) && ((g['uuid'] ?? '').toString() == uuidToRemove));
    if (removeIndex == -1) return;

    currentGoals.removeAt(removeIndex);

    await appUserProvider.updateUserRecord({
      'uid': appUserProvider.appUser['uid'],
      'goals': currentGoals,
    });

    // Refresh the profile shown in the UI so it reflects the updated goals.
    await appUserProvider.getUserProfileToShow(appUserProvider.appUser['uid']);
  }

  //----------------------------------------------------
  // Athlete Selection Popup Dialog
  Future<void> _showCreateGoalPopupDialog(BuildContext context, Map<String, dynamic>? goal, int? index) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final eventTypes = internalStatusProvider.eventTypes;
    final events = eventsProvider.events ?? <Map<String, dynamic>>[];
    // Local form key and a working copy of the goal so edits don't mutate the
    // original until the user submits.
    final formKey = GlobalKey<FormState>();
    bool showEventDropdown = false;
    Map<String, dynamic> draftGoal = goal != null
        ? Map<String, dynamic>.from(goal)
        : {'title': null, 'date': null, 'type': null, 'distance': null, 'duration': 'hh:mm:ss'};
    _updateTextControllers(draftGoal);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
          title: header1(header: 'Create a Goal:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setStateDialog) {
                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: goal == null,
                        child: elevatedButton(
                          label: 'Use an event',
                          onPressed: () {
                            setStateDialog(() {
                              showEventDropdown = !showEventDropdown;
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
                        visible: showEventDropdown,
                        child: Column(
                          children: [
                            SizedBox(height: 10.0),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                                color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1),
                              ),
                              child: SearchableDropdown(
                                labelText: 'Search Events:',
                                hint: 'Select Event',
                                dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                                searchBoxVisable: true,
                                backgroundColor: Colors.transparent,
                                dropDownList: events,
                                header: '',
                                iconColor: localAppTheme['anchorColors']['primaryColor'],
                                idField: 'eventID',
                                displayField: 'name',
                                onChanged: (value) {
                                  // Not working yet will need to incorporate text editing controllers :-(
                                  setStateDialog(() {
                                    _updateTextControllers(
                                      draftGoal = {
                                        'title': value?['name'],
                                        'date': value?['eventDate'],
                                        'type': value?['type'],
                                        'distance': value?['distance'],
                                        'duration': 'hh:mm:ss',
                                      },
                                    );
                                    showEventDropdown = !showEventDropdown;
                                  });
                                },
                                isEnabled: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
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
                        //initialValue: draftGoal['title'],
                        onChanged: (value) {
                          draftGoal['title'] = value;
                        },
                        controller: titleController,
                      ),
                      SizedBox(height: 10.0),
                      DatePicker(
                        buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                        label: 'Date:',
                        buttonVisibility: true,
                        enabled: true,
                        initialDate: (() {
                          final dateVal = draftGoal['date'];
                          if (dateVal == null) return null;
                          if (dateVal is Timestamp) return dateVal.toDate();
                          if (dateVal is DateTime) return dateVal;
                          return null;
                        })(),
                        validator: (date) {
                          if (date == null) {
                            return 'Please select a valid date.';
                          }
                          return null;
                        },
                        controller: dateController,
                        onChanged: (value) {
                          draftGoal['date'] = value;
                          dateController.text = DateFormat.yMd().format(value);
                        },
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
                          setStateDialog(() {
                            draftGoal['type'] = value?['id'];
                          });
                        },
                        isEnabled: true,
                        initialValue: draftGoal['type'],
                        validator: (value) {
                          if ((value == null || value.isEmpty) && draftGoal['type'] == null) {
                            return 'Please select a valid event type.';
                          }
                          return null;
                        },
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
                        onChanged: (value) {
                          draftGoal['distance'] = int.tryParse(value) ?? 0;
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
                        onChanged: (value) {
                          draftGoal['duration'] = value;
                        },
                        controller: durationController,
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
                      goal = null;
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
                      if (formKey.currentState == null) return;
                      if (!formKey.currentState!.validate()) return;

                        try {
                        setState(() {
                          isLoading = true;
                        });

                        // Create a copy of the current goals list to avoid in-place mutation issues
                        final List<dynamic> currentGoals = List<dynamic>.from(appUserProvider.appUser['goals'] ?? <dynamic>[]);

                        if (goal == null) {
                          // Add a deep copy of the draftGoal so later edits don't mutate the saved entry
                          draftGoal['uuid'] = const Uuid().v4();
                          currentGoals.add(Map<String, dynamic>.from(draftGoal));
                        } else {
                          // If editing, replace the existing goal at the provided index when possible
                          if (index != null && index >= 0 && index < currentGoals.length) {
                            final existing = Map<String, dynamic>.from(currentGoals[index] ?? <String, dynamic>{});
                            existing.addAll(draftGoal);
                            currentGoals[index] = existing;
                          } else {
                            // fallback: try to merge into the first matching entry by title/date
                            bool merged = false;
                            for (int i = 0; i < currentGoals.length; i++) {
                              final item = currentGoals[i] as Map<String, dynamic>;
                              if ((item['title'] ?? '') == (goal?['title'] ?? '') && (item['date'] ?? '') == (goal?['date'] ?? '')) {
                                final mergedItem = Map<String, dynamic>.from(item);
                                mergedItem.addAll(draftGoal);
                                currentGoals[i] = mergedItem;
                                merged = true;
                                break;
                              }
                            }
                            if (!merged) {
                              currentGoals.add(Map<String, dynamic>.from(draftGoal));
                            }
                          }
                        }

                        await appUserProvider.updateUserRecord({
                          'uid': appUserProvider.appUser['uid'],
                          'goals': currentGoals,
                        });

                        // Refresh the profile shown in the UI so it reflects the updated goals.
                        await appUserProvider.getUserProfileToShow(appUserProvider.appUser['uid']);

                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pop();
                        showGeneralPopupDialog(context, 'Success!', 'Goal saved successfully.');
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pop();
                        showGeneralPopupDialog(context, 'Error!', 'Failed to save goal.');
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
    final userProfileToShow = appUserProvider.userProfileToShow;
    // Safely handle when there are no goals saved yet.
    final rawGoals = userProfileToShow['goals'] ?? <dynamic>[];
    final goals = rawGoals.where((goal) {
      final eventDate = _parseToDate(goal['date']);
      return eventDate != null && eventDate.isAfter(DateTime.now());
    }).toList();

    // Sort earliest -> latest
    goals?.sort((a, b) {
      final da = _parseToDate(a['date']);
      final db = _parseToDate(b['date']);
      if (da == null && db == null) return 0;
      if (da == null) return 1; // put nulls last
      if (db == null) return -1;
      return da.compareTo(db);
    });

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
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        !widget.isCoachView
                            ? header1(header: 'My Goals:', context: context, color: localAppTheme['anchorColors']['primaryColor'])
                            : header1(
                                header: '${userProfileToShow['name'] ?? 'XXX'}\'s Goals:',
                                context: context,
                                color: localAppTheme['anchorColors']['primaryColor'],
                              ),
                        Visibility(
                          visible: !widget.isCoachView,
                          child: iconButton(
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
                                eventDateStr = DateFormat.yMMMMd().format(rawDate.toDate());
                              } else if (rawDate is DateTime) {
                                eventDateStr = DateFormat.yMMMMd().format(rawDate);
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
                                                header:
                                                    eventTypes.where((type) => type['id'] == goal['type']).map((type) => type['eventType']).first ??
                                                    'No Type Provided',
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
                                      Container(
                                        width: 75,
                                        padding: const EdgeInsets.only(left: 10.0),
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
                                              onPressed: () async{
                                                try {
                                                 await _deleteGoal(goal);
                                                  showGeneralPopupDialog(context, 'Success!', 'Goal deleted successfully.');
                                                } catch (e) {
                                                  showGeneralPopupDialog(context, 'Error!', 'Failed to delete goal.');
                                                }
                                              },
                                            ),
                                          ],  
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
