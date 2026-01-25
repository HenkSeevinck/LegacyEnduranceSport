import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddGoalPopup extends StatefulWidget {
  final BuildContext context;
  final Map<String, dynamic>? goal;
  final int? index;

 const AddGoalPopup({super.key, 
    required this.context,
    this.goal,
    this.index,
  });

  @override
  State<AddGoalPopup> createState() => _AddGoalPopupState();
}

class _AddGoalPopupState extends State<AddGoalPopup> {
  bool isLoading = false;
  TextEditingController dateController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  
  late final GlobalKey<FormState> formKey;
  late bool showEventDropdown;
  late Map<String, dynamic> draftGoal;

  //----------------------------------------------------
  // Initialize state
  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    showEventDropdown = false;
    
    Map<String, dynamic>? goal = widget.goal;
    draftGoal = goal != null
        ? Map<String, dynamic>.from(goal)
        : {'title': null, 'date': null, 'type': null, 'distance': null, 'duration': 'hh:mm:ss'};
    _updateTextControllers(draftGoal);
  }

  //----------------------------------------------------
  // Dispose controllers
  @override
  void dispose() {
    dateController.dispose();
    titleController.dispose();
    distanceController.dispose();
    durationController.dispose();
    super.dispose();
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


  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final eventTypes = internalStatusProvider.eventTypes;
    final events = eventsProvider.events ?? <Map<String, dynamic>>[];
    Map<String, dynamic>? goal = widget.goal;
    int? index = widget.index;

    return AlertDialog(
          backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
          title: header1(header: 'Create a Goal:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
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
  }
}