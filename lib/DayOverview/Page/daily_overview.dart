import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/DayOverview/Function/add_planned_workout.dart';
import 'package:legacyendurancesport/DayOverview/Function/complete_workout_popup.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/image_verification_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/Goals/Functions/add_goal_popup.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/MyAthletes/Page/my_athletes_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class DailyOverview extends StatefulWidget {
  String navPath;
  DateTime selectedDate;
  String athleteUID;
  bool isCoachView;

  DailyOverview({super.key, required this.selectedDate, required this.navPath, required this.athleteUID, required this.isCoachView});

  @override
  State<DailyOverview> createState() => _DailyOverviewState();
}

class _DailyOverviewState extends State<DailyOverview> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // Open URL function
  Future<void> _openUrl(String rawUrl) async {
    try {
      final urlString = (rawUrl.isEmpty) ? 'https://www.google.com' : rawUrl;
      final uri = Uri.parse(urlString.startsWith('http') ? urlString : 'https://$urlString');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // ignore errors for now
    }
  }

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    // Initialize the data fetching future
    _fetchDataFuture = _fetchData();
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData() async {
    // Fetch necessary data from providers
  }

  //----------------------------------------------------
  // Athlete Selection Popup Dialog
  Future<void> _showCreateGoalPopupDialog(BuildContext context, Map<String, dynamic>? goal, int? index) async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AddGoalPopup(context: context, goal: goal, index: index);
      },
    );
  }

  //----------------------------------------------------
  // Button to mark workout complete
  Future<void> _markWorkoutComplete(loadedWorkout) async {
    Map<String, dynamic> completedworkoutData = {};
    Map<String, dynamic> workoutData = {};
    if (loadedWorkout['workout'] != null) {
      completedworkoutData['duration'] = loadedWorkout['workout']?['duration'];
      completedworkoutData['distance'] = loadedWorkout['workout']?['distance'];
      completedworkoutData['type'] = loadedWorkout['workout']?['type'];
      workoutData['completedworkoutData'] = completedworkoutData;
      workoutData['LoadedWorkoutID'] = loadedWorkout['LoadedWorkoutID'];
      showDialog(
        context: context,
        builder: (context) => CompleteWorkoutPopup(workoutData: workoutData, workoutStatus: 'completed', loadedWorkout: loadedWorkout),
      );
    }
  }

  //----------------------------------------------------
  // Add Planned Workout Popup Dialog
  Future<void> _showAddPlannedWorkoutPopupDialog() async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AddPlannedWorkout(selectedDate: widget.selectedDate, athleteUID: widget.athleteUID);
      },
    );
  }

  //----------------------------------------------------
  // Button to create new workout
  Future<void> _logAnotherWorkout() async {
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;

    // Create empty workout data for new entry
    Map<String, dynamic> emptyWorkoutData = {};
    Map<String, dynamic> emptyCompletedworkoutData = {};
    emptyCompletedworkoutData['duration'] = 'hh:mm:ss';
    emptyCompletedworkoutData['distance'] = '00.00';
    emptyCompletedworkoutData['type'] = null;
    emptyWorkoutData['completedworkoutData'] = emptyCompletedworkoutData;
    emptyWorkoutData['LoadedWorkoutID'] = null;

    // Create empty loaded workout for new entry
    Map<String, dynamic>? emptyLoadedWorkout = {};
    emptyLoadedWorkout['workout'] = null;
    emptyLoadedWorkout['athleteUID'] = appUser['uid'];
    emptyLoadedWorkout['workoutDate'] = Timestamp.fromDate(widget.selectedDate);

    showDialog(
      context: context,
      builder: (context) => CompleteWorkoutPopup(
        workoutData: emptyWorkoutData, 
        workoutStatus: 'new', 
        loadedWorkout: emptyLoadedWorkout, 
      ),
    );
  }

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileDailyOverview() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: true);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: true);
    final imageVerificationProvider = Provider.of<ImageVerificationProvider>(context, listen: true);
    final todaysGoals = appUserProvider.todaysGoals;
    final todaysEvents = eventsProvider.todaysEvents;
    final todaysWorkouts = workoutsProvider.todaysWorkouts;
    final focusBlocks = internalStatusProvider.focusBlocks;
    final workoutTypes = internalStatusProvider.workoutTypes;
    final eventTypes = internalStatusProvider.eventTypes;
    final appUser = appUserProvider.appUser;
    final isCoachView = widget.isCoachView;

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
                    widget.navPath == 'HomePage'
                        ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()))
                        : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyAthletesPage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageHeaderImage(
                  imagePath: 'images/DailyView.png',
                  context: context,
                  toolTip: '',
                  userProfileToShow: {},
                  pageTitle: 'DAY\'S OVERVIEW',
                  isCoachView: false,
                  buttonVisibility: false,
                ),
                SizedBox(height: 10.0),
                header1(header: 'Day\'s Workouts:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),
                todaysWorkouts.isEmpty
                    ? Center(
                        child: body(header: 'No Workouts Assigned.', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      )
                    : Column(
                        children: List<Widget>.generate(todaysWorkouts.length, (index) {
                          final loadedWorkout = todaysWorkouts[index];

                          return SizedBox(
                            width: double.infinity,
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              collapsedShape: Border(
                                top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == 0 ? 1.0 : 0.0),
                                bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                              ),
                              showTrailingIcon: false,
                              title: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 10.0),
                                          SizedBox(
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                header2(
                                                  header: loadedWorkout['workout']?['name'] ?? 'UNSCHEDULED WORKOUT',
                                                  color: localAppTheme['anchorColors']['primaryColor'],
                                                  context: context,
                                                ),
                                                loadedWorkout['completedworkoutData'] != null
                                                ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                                                : isCoachView
                                                ? iconButton(
                                                    label: null, 
                                                    backgroundColor: null, 
                                                    iconColor: localAppTheme['anchorColors']['primaryColor'], 
                                                    icon: Icons.delete, 
                                                    size: 20, 
                                                    toolTip: 'REMOVE WORKOUT', 
                                                    context: context, 
                                                    onPressed: () async {    
                                                      try{
                                                        await workoutsProvider.deleteLoadedWorkoutRecord(loadedWorkout['loadedWorkoutUID']);
                                                      } catch(e){
                                                        snackbar(context: context, header: 'Error deleting workout. Please try again.');
                                                      }
                                                      
                                                    },
                                                  )
                                                : SizedBox.shrink(),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10.0),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    header3(
                                                      header: loadedWorkout['workout'] != null ? 'PLANNED:' : 'UNSCHEDULED',
                                                      context: context, color: 
                                                      localAppTheme['anchorColors']['primaryColor'],
                                                    ),
                                                    SizedBox(height: 10.0),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          loadedWorkout['workout'] != null
                                                          ? workoutTypes.firstWhere(
                                                            (type) => type['workoutTypeID'] == loadedWorkout['workout']?['type'],
                                                            orElse: () => {'icon': Icons.fitness_center},
                                                          )['icon'] ?? Icons.fitness_center
                                                          : workoutTypes.firstWhere(
                                                            (type) => type['workoutTypeID'] == loadedWorkout['completedworkoutData']?['type'],
                                                            orElse: () => {'icon': Icons.fitness_center},
                                                          )['icon'] ?? Icons.fitness_center,
                                                          color: localAppTheme['anchorColors']['primaryColor'],
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 20.0),
                                                        body(
                                                          header: loadedWorkout['workout'] != null 
                                                          ? workoutTypes.firstWhere(
                                                              (type) => type['workoutTypeID'] == loadedWorkout['workout']?['type'],
                                                              orElse: () => {'workoutType': '-'}
                                                            )['workoutType'] ?? '-'
                                                          : workoutTypes.firstWhere(
                                                                (type) => type['workoutTypeID'] == loadedWorkout['completedworkoutData']?['type'],
                                                                orElse: () => {'workoutType': '-'}
                                                              )['workoutType'] ?? '-',
                                                          color: localAppTheme['anchorColors']['primaryColor'],
                                                          context: context,
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible: loadedWorkout['workout'] != null,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(height: 10.0),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.fitness_center, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                              SizedBox(width: 20.0),
                                                              body(
                                                                header:
                                                                  focusBlocks.firstWhere(
                                                                    (type) => type['blockTypeID'] == loadedWorkout['workout']?['block'],
                                                                    orElse: () => {'blockType': '-'},
                                                                  )['blockType'] ?? '-',
                                                                color: localAppTheme['anchorColors']['primaryColor'],
                                                                context: context,
                                                              ),
                                                            ],
                                                          ),
                                                          Visibility(
                                                            visible: loadedWorkout['workout']?['distance'] != '00.00',
                                                            child: Column(
                                                              children: [
                                                                SizedBox(height: 10.0),
                                                                Row(
                                                                  children: [
                                                                    Icon(Icons.straighten, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                                    SizedBox(width: 20.0),
                                                                    body(
                                                                      header: loadedWorkout['workout']?['distance'] == null ? '-' : '${loadedWorkout['workout']?['distance']?.toString()} km',
                                                                      color: localAppTheme['anchorColors']['primaryColor'],
                                                                      context: context,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible: loadedWorkout['workout']?['duration'] != 'hh:mm:ss',
                                                            child: Column(
                                                              children: [
                                                                SizedBox(height: 10.0),
                                                                Row(
                                                                  children: [
                                                                    Icon(Icons.timer, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                                    SizedBox(width: 20.0),
                                                                    body(
                                                                      header: loadedWorkout['workout']?['duration']?.toString() ?? '-',
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
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    header3(header: 'COMPLETED:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                                    SizedBox(height: 10.0),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.timer, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                        SizedBox(width: 20.0),
                                                        body(
                                                          header: loadedWorkout['completedworkoutData']?['duration'] ?? '-',
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
                                                          header: loadedWorkout['completedworkoutData']?['distance'] ?? '-',
                                                          color: localAppTheme['anchorColors']['primaryColor'],
                                                          context: context,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10.0),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.sick_outlined, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                        SizedBox(width: 20.0),
                                                        body(
                                                          header: loadedWorkout['completedworkoutData']?['perceivedEffort']?.toString() ?? '-',
                                                          color: localAppTheme['anchorColors']['primaryColor'],
                                                          context: context,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10.0),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.sentiment_satisfied, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                        SizedBox(width: 20.0),
                                                        body(
                                                          header: loadedWorkout['completedworkoutData']?['feeling']?.toString() ?? '-',
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
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: loadedWorkout['completedworkoutData'] == null && widget.navPath == 'HomePage',
                                      child: Container(
                                        padding: EdgeInsets.only(left: 15.0),
                                        height: 180,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          border: Border(left: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                                        ),
                                        child: iconButton(
                                          label: null,
                                          backgroundColor: null,
                                          iconColor: localAppTheme['anchorColors']['primaryColor'],
                                          icon: Icons.check_circle,
                                          size: 30,
                                          toolTip: 'Complete Workout',
                                          context: context,
                                          onPressed: () {
                                            _markWorkoutComplete(loadedWorkout);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                        header: loadedWorkout['workout']?['description'] ?? 'No Description Available.',
                                        context: context,
                                        color: localAppTheme['anchorColors']['primaryColor'],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                const SizedBox(height: 10),
                Visibility(
                  visible: widget.navPath == 'HomePage',
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: elevatedButton(
                      label: 'Log another Workout',
                      onPressed: () {
                        _logAnotherWorkout();
                        imageVerificationProvider.clearWorkoutResult();
                      },
                      backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                      labelColor: localAppTheme['anchorColors']['secondaryColor'],
                      leadingIcon: null,
                      trailingIcon: null,
                      context: context,
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.navPath != 'HomePage' && widget.selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 1))),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: elevatedButton(
                      label: 'Add a Planned Workout',
                      onPressed: () {
                        _showAddPlannedWorkoutPopupDialog();
                      },
                      backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                      labelColor: localAppTheme['anchorColors']['secondaryColor'],
                      leadingIcon: null,
                      trailingIcon: null,
                      context: context,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                header1(header: 'Day\'s Goals:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),
                todaysGoals.isEmpty
                    ? Center(
                        child: body(header: 'No Goals Assigned.', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      )
                    : Column(
                        children: List<Widget>.generate(todaysGoals.length, (index) {
                          final goal = todaysGoals[index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == 0 ? 1.0 : 0.0),
                                bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    header2(header: goal['title'] ?? 'Unnamed Goal', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(
                                          workoutTypes.firstWhere((type) => type['workoutTypeID'] == goal['type'])['icon'] ?? Icons.fitness_center,
                                          color: localAppTheme['anchorColors']['primaryColor'],
                                          size: 20,
                                        ),
                                        SizedBox(width: 20.0),
                                        body(
                                          header: workoutTypes.firstWhere((type) => type['workoutTypeID'] == goal['type'])['workoutType'] ?? 'Unknown',
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
                                          header: '${goal['distance']?.toString()} km',
                                          color: localAppTheme['anchorColors']['primaryColor'],
                                          context: context,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(Icons.timer, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                        SizedBox(width: 20.0),
                                        body(header: '${goal['duration']?.toString()}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                const SizedBox(height: 10),
                Visibility(
                  visible: widget.navPath == 'HomePage' && widget.selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 1))),
                  child: elevatedButton(
                    label: 'Add New Goal',
                    onPressed: () {
                      _showCreateGoalPopupDialog(context, null, null);
                    },
                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                    leadingIcon: null,
                    trailingIcon: null,
                    context: context,
                  ),
                ),
                const SizedBox(height: 20),
                header1(header: 'Day\'s Events:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),
                todaysEvents!.isEmpty
                    ? Center(
                        child: body(header: 'No Events Assigned.', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      )
                    : Column(
                        children: List<Widget>.generate(todaysEvents.length, (index) {
                          final event = todaysEvents[index];
                          final attendees = event['attendees'] as List?;
                          final hasRSVPed = attendees != null && (attendees).contains(appUser['uid']);

                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == 0 ? 1.0 : 0.0),
                                bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                              ),
                            ),
                            width: double.infinity,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        header2(header: event['name'] ?? 'Unnamed Event', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Icon(Icons.terrain, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                            SizedBox(width: 20.0),
                                            body(header: event['terrain'], color: localAppTheme['anchorColors']['primaryColor'], context: context),
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Icon(Icons.flag_outlined, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                            SizedBox(width: 20.0),
                                            body(
                                              header: eventTypes.firstWhere((type) => type['id'] == event['type'])['eventType'] ?? 'Unknown',
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
                                              header: '${event['distance'].toString()} km',
                                              color: localAppTheme['anchorColors']['primaryColor'],
                                              context: context,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Icon(Icons.link, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                            SizedBox(width: 20.0),
                                            InkWell(
                                              onTap: () => _openUrl(event['link']?.toString() ?? 'www.google.com'),
                                              child: body(
                                                header: event['link']?.toString() ?? 'www.google.com',
                                                color: localAppTheme['anchorColors']['primaryColor'],
                                                context: context,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    imageButtonWithHeader(
                                      width: 75, 
                                      height: 130, 
                                      onPressed: () async{
                                        try{
                                        // Update RSVP status
                                        List<dynamic> updatedAttendees = List<dynamic>.from(event['attendees'] ?? <dynamic>[]);
                                        if (!hasRSVPed) {
                                          await eventsProvider.updateEvent(event['eventID'], {
                                            'attendees': FieldValue.arrayUnion(appUser['uid'] != null ? [appUser['uid']] : []),
                                          });
                                          updatedAttendees.add(appUser['uid']);
                                        } else {
                                          await eventsProvider.updateEvent(event['eventID'], {
                                            'attendees': FieldValue.arrayRemove(appUser['uid'] != null ? [appUser['uid']] : []),
                                          });
                                          updatedAttendees.remove(appUser['uid']);
                                        }
                                        } catch (e) {
                                          showGeneralPopupDialog(context, 'Error', 'An error occurred while updating your RSVP. Please try again later.');
                                        }
                                      },
                                      toolTip: 'RSVP', 
                                      imagePath: hasRSVPed ? 'images/RSVPed.png' : 'images/RSVP.png', 
                                      context: context, 
                                      headerText: 'RSVP'
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopDailyOverview() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackDailyOverview() {
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
            return _buildMobileDailyOverview();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopDailyOverview();
          } else {
            return _buildFallbackDailyOverview();
          }
        }
      },
    );
  }
}
