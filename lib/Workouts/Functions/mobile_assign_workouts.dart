import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

class MobileAssignWorkouts extends StatefulWidget {
  final Map<String, dynamic> workout;

  const MobileAssignWorkouts({super.key, required this.workout});

  @override
  State<MobileAssignWorkouts> createState() => _MobileAssignWorkoutsState();
}

class _MobileAssignWorkoutsState extends State<MobileAssignWorkouts> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _workoutDateController = TextEditingController();
  List<Map<String, dynamic>>? _assignedAthletes;
  final Map<String, Map<String, dynamic>> _todaysWorkoutByAthlete = {};
  final Map<String, bool> _isLoadingByAthlete = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _workoutDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    final athletesByCoach = appUserProvider.athletesByCoach;

    return _isSubmitting
        ? Center(child: CircularProgressIndicator(color: localAppTheme['anchorColors']['primaryColor']))
        : SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Form(
                key: _formKey,
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
                      controller: _workoutDateController,
                    ),
                    const SizedBox(height: 10.0),
                    header3(header: widget.workout['name'] ?? 'Unnamed Workout', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                    const SizedBox(height: 10.0),
                    body(header: widget.workout['breakdown'] ?? 'No breakdown provided.', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                    const SizedBox(height: 10.0),
                    Column(
                      children: List<Widget>.generate(athletesByCoach.length, (index) {
                        final athlete = athletesByCoach[index];
                        final athleteUid = athlete['uid']?.toString() ?? index.toString();
                        final isLoading = _isLoadingByAthlete[athleteUid] ?? false;
                        final todaysWorkoutLocal = _todaysWorkoutByAthlete[athleteUid] ?? {};

                        return ExpansionTile(
                          collapsedShape: Border(
                            top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == 0 ? 1.0 : 0.0),
                            bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                          ),
                          title: body(
                            header: '${athlete['name']} ${athlete['surname']}',
                            color: localAppTheme['anchorColors']['primaryColor'],
                            context: context,
                          ),
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                              ),
                              child: Column(
                                children: [
                                  if (isLoading)
                                    const Center(child: CircularProgressIndicator())
                                  else if (todaysWorkoutLocal.isEmpty)
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width - 200) * 0.8,
                                      height: 80,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.fitness_center, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                          const SizedBox(height: 10.0),
                                          body(header: 'No workout assigned', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10.0),
                                          SizedBox(
                                            width: double.infinity,
                                            child: header3(
                                              header: 'CURRENTLY ASSIGNED WORKOUT:\n${todaysWorkoutLocal['workout']['name'] ?? 'Unnamed Workout'}',
                                              color: localAppTheme['anchorColors']['primaryColor'],
                                              context: context,
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          body(
                                            header: todaysWorkoutLocal['workout']['breakdown'] ?? 'No breakdown provided.',
                                            color: localAppTheme['anchorColors']['primaryColor'],
                                            context: context,
                                          ),
                                          const SizedBox(height: 10.0),
                                        ],
                                      ),
                                    ),
                                  CheckboxListTile(
                                    tileColor: localAppTheme['anchorColors']['primaryColor'],
                                    checkColor: localAppTheme['anchorColors']['secondaryColor'],
                                    activeColor: localAppTheme['anchorColors']['primaryColor'],
                                    title: body(
                                      header: 'Assign ${widget.workout['name']} to ${athlete['name']} ${athlete['surname']}',
                                      color: localAppTheme['anchorColors']['secondaryColor'],
                                      context: context,
                                    ),
                                    value: _assignedAthletes?.any((a) => a['workoutToLoad']['athleteUID'] == athlete['uid']) ?? false,
                                    onChanged: (bool? value) {
                                      if (_workoutDateController.text.isEmpty) {
                                        showGeneralPopupDialog(context, 'Error', 'Please select a date first.');
                                        return;
                                      }
                                      final workoutDate = Timestamp.fromDate(DateTime.parse(_workoutDateController.text));
                                      final workoutToLoad = {
                                        'athleteUID': athlete['uid'],
                                        'coachUID': appUser['uid'],
                                        'workoutDate': workoutDate,
                                        'workout': {'workoutUID': widget.workout['id']},
                                      };

                                      setState(() {
                                        _assignedAthletes ??= [];
                                        if (value == true) {
                                          _assignedAthletes!.add({
                                            'assignedWorkoutUID': todaysWorkoutLocal.isEmpty ? null : todaysWorkoutLocal['loadedWorkoutUID'],
                                            'workoutToLoad': workoutToLoad,
                                          });
                                        } else {
                                          _assignedAthletes!.removeWhere((a) => a['workoutToLoad']['athleteUID'] == athlete['uid']);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onExpansionChanged: (value) async {
                            if (value && _todaysWorkoutByAthlete[athleteUid] == null) {
                              setState(() => _isLoadingByAthlete[athleteUid] = true);
                              DateTime selectedDate = DateTime.tryParse(_workoutDateController.text) ?? DateTime.now();
                              try {
                                final result = await workoutsProvider.getTodaysLoadedWorkout(athlete['uid'], appUser['uid'], selectedDate);
                                if (mounted) {
                                  setState(() {
                                    _todaysWorkoutByAthlete[athleteUid] = result ?? {};
                                    _isLoadingByAthlete[athleteUid] = false;
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _isLoadingByAthlete[athleteUid] = false);
                                  showGeneralPopupDialog(context, 'Error', '...$e');
                                }
                              }
                            }
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: elevatedButton(
                            label: 'CANCEL',
                            onPressed: () => Navigator.of(context).pop(),
                            backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                            labelColor: localAppTheme['anchorColors']['secondaryColor'],
                            context: context,
                            leadingIcon: null,
                            trailingIcon: null,
                          ),
                        ),
                        Visibility(
                          visible: _assignedAthletes != null && _assignedAthletes!.isNotEmpty,
                          child: Expanded(
                            child: elevatedButton(
                              label: 'SUBMIT',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isSubmitting = true);
                                  try {
                                    await workoutsProvider.loadOrUpdateWorkouts(_assignedAthletes ?? []);
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                      showGeneralPopupDialog(context, 'Success', 'Workout assigned successfully!');
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                      showGeneralPopupDialog(context, 'Error', 'An error occurred while assigning the workout: $e');
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSubmitting = false);
                                    }
                                  }
                                }
                              },
                              backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                              labelColor: localAppTheme['anchorColors']['secondaryColor'],
                              context: context,
                              leadingIcon: null,
                              trailingIcon: null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
