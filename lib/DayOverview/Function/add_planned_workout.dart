import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
//import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Workouts/Functions/mobile_list_of_workouts.dart';
import 'package:provider/provider.dart';

class AddPlannedWorkout extends StatefulWidget {
  final DateTime selectedDate;
  final String athleteUID;

  const AddPlannedWorkout({super.key, required this.selectedDate, required this.athleteUID});

  @override
  State<AddPlannedWorkout> createState() => _AddPlannedWorkoutState();
}

class _AddPlannedWorkoutState extends State<AddPlannedWorkout> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(
      appUserProvider, 
      workoutsProvider
    );
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(
    AppUserProvider appUserProvider, 
    WorkoutsProvider workoutsProvider
    ) async {
    final coachUID = appUserProvider.appUser['uid'];
    await workoutsProvider.fetchWorkoutsForCoach(coachUID);
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
          return AlertDialog(
            backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
            title: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.8,
                    padding: const EdgeInsets.all(10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: MobileListOfWorkouts(fromDayOverview: true, selectedDate: widget.selectedDate, athleteUID: widget.athleteUID),
                  ),
                  SizedBox(height: 10),
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
          );
        }
      },
    );
  }
}