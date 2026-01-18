import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';

class DailyOverview extends StatefulWidget {
  DateTime selectedDate;

  DailyOverview({super.key, required this.selectedDate});

  @override
  State<DailyOverview> createState() => _DailyOverviewState();
}

class _DailyOverviewState extends State<DailyOverview> {
  Future<void>? _fetchDataFuture;
  bool isLoading = true;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(appUserProvider, eventsProvider, workoutsProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(AppUserProvider appUserProvider, EventsProvider eventsProvider, WorkoutsProvider workoutsProvider) async {
    await appUserProvider.filterTodaysGoals(widget.selectedDate);
    await eventsProvider.filterTodaysEvents(widget.selectedDate);
    await workoutsProvider.filterTodaysWorkouts(widget.selectedDate);
    setState(() {
      isLoading = false;
    });
  }

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileDailyOverview() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final eventsProvider = Provider.of<EventsProvider>(context, listen: true);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: true);
    final todaysGoals = appUserProvider.todaysGoals;
    final todaysEvents = eventsProvider.todaysEvents;
    final todaysWorkouts = workoutsProvider.todaysWorkouts;
    final focusBlocks = internalStatusProvider.focusBlocks;
    final workoutTypes = internalStatusProvider.workoutTypes;
    final allWorkouts = workoutsProvider.allWorkouts;

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
                header1(
                  header: 'Daily Overview - ${widget.selectedDate.toIso8601String().split('T').first}',
                  context: context,
                  color: localAppTheme['anchorColors']['primaryColor'],
                ),
                const SizedBox(height: 20),
                header2(header: 'Today\'s Workouts:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),
                todaysWorkouts.isEmpty
                    ? Center(
                        child: body(header: 'No Workouts Assigned for Today.', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      )
                    : Column(
                        children: List<Widget>.generate(todaysWorkouts.length, (index) {
                          final itemCount = todaysWorkouts.length;
                          final workout = todaysWorkouts[index];
            
                          return SizedBox(
                            width: double.infinity,
                            child: ExpansionTile(
                              collapsedShape: Border(
                                top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == 0 ? 1.0 : 0.0),
                                bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                              ),
                              showTrailingIcon: false,
                              title: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10.0),
                                    SizedBox(
                                      width: double.infinity,
                                      child: header3(
                                        header: workout['workout']['name'] ?? 'Unnamed Workout',
                                        color: localAppTheme['anchorColors']['primaryColor'],
                                        context: context,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(
                                          workoutTypes.firstWhere((type) => type['type'] == workout['workout']['workoutTypeID'])['icon'] ?? Icons.fitness_center,
                                          color: localAppTheme['anchorColors']['primaryColor'],
                                          size: 20,
                                        ),
                                        SizedBox(width: 20.0),
                                        body(
                                          header:
                                              workoutTypes.firstWhere((type) => type['type'] == workout['workout']['workoutTypeID'])['workoutType'] ?? 'Unknown',
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
                                          header: focusBlocks.firstWhere((type) => type['blockTypeID'] == workout['workout']['block'])['blockType'] ?? 'Unknown',
                                          color: localAppTheme['anchorColors']['primaryColor'],
                                          context: context,
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible: workout['workout']['distance'] != '00.00',
                                      child: Column(
                                        children: [
                                          SizedBox(height: 10.0),
                                          Row(
                                            children: [
                                              Icon(Icons.straighten, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                              SizedBox(width: 20.0),
                                              body(
                                                header: '${workout['workout']['distance'].toString()} km',
                                                color: localAppTheme['anchorColors']['primaryColor'],
                                                context: context,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: workout['workout']['duration'] != 'hh:mm:ss',
                                      child: Column(
                                        children: [
                                          SizedBox(height: 10.0),
                                          Row(
                                            children: [
                                              Icon(Icons.timer, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                              SizedBox(width: 20.0),
                                              body(
                                                header: workout['workout']['duration'].toString(),
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
                                        header: workout['workout']['description'] ?? 'No Description Available.',
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
                const SizedBox(height: 20),
                header2(header: 'Today\'s Goals:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),
                todaysGoals.isEmpty
                    ? Center(
                        child: body(header: 'No Goals Assigned for Today.', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      )
                    : Column(
                        children: List<Widget>.generate(todaysGoals.length, (index) {
                          final itemCount = todaysGoals.length;
                          final goal = todaysGoals[index];
            
                          return SizedBox(
                            width: double.infinity,
                            child: header3(header: goal['title'] ?? 'Unnamed Goal', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          );
                        }),
                      ),
                const SizedBox(height: 20),
                header2(header: 'Today\'s Events:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),
                todaysEvents!.isEmpty
                    ? Center(
                        child: body(header: 'No Events Assigned for Today.', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      )
                    : Column(
                        children: List<Widget>.generate(todaysEvents.length, (index) {
                          final itemCount = todaysEvents.length;
                          final event = todaysEvents[index];
            
                          return SizedBox(
                            width: double.infinity,
                            child: header3(header: event['name'] ?? 'Unnamed Event', context: context, color: localAppTheme['anchorColors']['primaryColor']),
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

        if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
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
