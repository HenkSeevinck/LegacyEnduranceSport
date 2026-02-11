import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/DayOverview/Page/daily_overview.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

/// WeekDaysTable
/// - shows 7 days for a current week (Mon-Sun by default)
/// - has back / forward controls to move weeks
/// - reports selected day via `onDaySelected`
class WeekDaysTable extends StatefulWidget {
  final String athleteUID;
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDaySelected;
  final double minTileHeight;
  final String navPath;

  const WeekDaysTable({
    super.key, 
    required this.athleteUID, 
    required this.navPath, 
    this.initialDate, 
    this.onDaySelected, 
    this.minTileHeight = 64
  });

  @override
  State<WeekDaysTable> createState() => _WeekDaysTableState();
}

class _WeekDaysTableState extends State<WeekDaysTable> {
  late DateTime _weekStart;
  DateTime? _selectedDate;
  Future<void>? _fetchDataFuture;
  late List<dynamic> _athleteWorkouts; // Store athlete-specific data

  //----------------------------------------------------
  // Initialize state
  @override
  void initState() {
    super.initState();
    _athleteWorkouts = []; // Initialize empty
    //final now = widget.initialDate ?? DateTime.now();
    //_weekStart = _startOfWeek(now);
    //_selectedDate = now;

    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    _fetchDataFuture = _fetchData(eventsProvider, workoutsProvider, appUserProvider, internalStatusProvider);
  }

  //----------------------------------------------------
  // Fetch data for the week
  Future<void> _fetchData(EventsProvider eventsProvider, WorkoutsProvider workoutsProvider, AppUserProvider appUserProvider, InternalStatusProvider internalStatusProvider) async {
    appUserProvider.appUser;
    
    _weekStart = _startOfWeek(internalStatusProvider.weekStartDate ?? widget.initialDate ?? DateTime.now());
    _selectedDate = internalStatusProvider.selectedDate ?? widget.initialDate ?? DateTime.now();

    await eventsProvider.fetchEventsBetweenDates(_weekStart, _weekStart.add(const Duration(days: 6)));
    await workoutsProvider.fetchLoadedWorkoutsBetweenDates(widget.athleteUID, _weekStart, _weekStart.add(const Duration(days: 6)));
    
    // Copy to local state immediately
    setState(() {
      _athleteWorkouts = List.from(workoutsProvider.workoutsBetweenDates);
    });
    
    await appUserProvider.fetchUserGoalsBetweenDates(_weekStart, _weekStart.add(const Duration(days: 6)));
  }

  //----------------------------------------------------
  // Get start of week (Monday)
  DateTime _startOfWeek(DateTime d) {
    // treat Monday as start of week
    final weekday = d.weekday; // Mon = 1
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
  }

  //----------------------------------------------------
  // Move to previous week
  void _prevWeek() async {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final athleteUID = widget.athleteUID;
    
    _weekStart = _weekStart.subtract(const Duration(days: 7));
    await internalStatusProvider.setWeekStartDate(_weekStart);
    setState(() {
      _fetchDataFuture = _fetchData(eventsProvider, workoutsProvider, appUserProvider, internalStatusProvider);
    });
    await eventsProvider.fetchEventsBetweenDates(_weekStart, _weekStart.add(const Duration(days: 6)));
    await workoutsProvider.fetchLoadedWorkoutsBetweenDates(
      athleteUID,
      _weekStart,
      _weekStart.add(const Duration(days: 6)),
    );
    
    // Copy athlete workouts to local state
    setState(() {
      _athleteWorkouts = List.from(workoutsProvider.workoutsBetweenDates);
    });
    
    await appUserProvider.fetchUserGoalsBetweenDates(
      _weekStart,
      _weekStart.add(const Duration(days: 6)),
    );
  }

  //----------------------------------------------------
  // Move to next week
  void _nextWeek() async {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final athleteUID = widget.athleteUID;
    
    _weekStart = _weekStart.add(const Duration(days: 7));
    await internalStatusProvider.setWeekStartDate(_weekStart);
    setState(() {
      _fetchDataFuture = _fetchData(eventsProvider, workoutsProvider, appUserProvider, internalStatusProvider);
    });
    await eventsProvider.fetchEventsBetweenDates(_weekStart, _weekStart.add(const Duration(days: 6)));
    await workoutsProvider.fetchLoadedWorkoutsBetweenDates(
      athleteUID,
      _weekStart,
      _weekStart.add(const Duration(days: 6)),
    );

    // Copy athlete workouts to local state
    setState(() {
      _athleteWorkouts = List.from(workoutsProvider.workoutsBetweenDates);
    });

    await appUserProvider.fetchUserGoalsBetweenDates(
      _weekStart,
      _weekStart.add(const Duration(days: 6)),
    );
  }

  //----------------------------------------------------
  // Select a date
    Future<void> _selectDate(DateTime d) async {
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    // Filter goals and events from provider
    await appUserProvider.filterTodaysGoals(d);
    await eventsProvider.filterTodaysEvents(d);
    
    // Filter workouts from local _athleteWorkouts list
    await workoutsProvider.filterTodaysWorkoutsFromList(_athleteWorkouts, d);

    setState(() {
      internalStatusProvider.setSelectedDate(d);
      _selectedDate = d;
    });
    widget.onDaySelected?.call(d);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DailyOverview(selectedDate: d, navPath: widget.navPath, athleteUID: widget.athleteUID),
      ),
    );
  }

  //----------------------------------------------------
  // Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  //----------------------------------------------------
  // Build individual day tile
  Widget _buildDayTile(DateTime d, double effectiveHeight, Map localAppTheme, bool isLoading) {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: true);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final eventsBetweenDates = eventsProvider.eventsBetweenDates;
    final goalsBetweenDates = appUserProvider.goalsBetweenDates;
    final isSelected = _selectedDate != null && _isSameDay(_selectedDate!, d);
    final isToday = _isSameDay(DateTime.now(), d);
    final primary = localAppTheme['anchorColors']['primaryColor'];
    final secondary = localAppTheme['anchorColors']['primaryColor'];

    bool hasEvent = !isLoading && eventsBetweenDates!.any((event) {
      final eventDate = event['eventDate']?.toDate();
      return eventDate != null && _isSameDay(eventDate, d);
    });

    bool hasSchedulledWorkout = !isLoading && _athleteWorkouts.any((workout) {
      final workoutDate = workout['workoutDate']?.toDate();
      return workoutDate != null && workout['workout'] != null && _isSameDay(workoutDate, d);
    });

    bool hasCompletedSchedulledWorkout = !isLoading && _athleteWorkouts.any((workout) {
      final workoutDate = workout['workoutDate']?.toDate();
      return workoutDate != null && workout['workout'] != null && workout['completedworkoutData'] != null && _isSameDay(workoutDate, d);
    });

    bool hasUnSchedulledWorkout = !isLoading && _athleteWorkouts.any((workout) {
      final workoutDate = workout['workoutDate']?.toDate();
      return workoutDate != null && workout['workout'] == null && _isSameDay(workoutDate, d);
    });

    bool hasGoal = !isLoading && goalsBetweenDates.any((goal) {
      final goalDate = goal['date']?.toDate();
      return goalDate != null && _isSameDay(goalDate, d);
    });

    return Column(
      children: [
        body(
          header: DateFormat.E().format(d).substring(0, 1),
          color: isSelected ? secondary : (isToday ? primary : localAppTheme['anchorColors']['primaryColor']),
          context: context,
        ),
        SizedBox(height: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _selectDate(d),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2.0),
                  height: effectiveHeight,
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withOpacity(0.12) : (isToday ? secondary.withOpacity(0.10) : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? primary : (isToday ? secondary : primary), width: isSelected ? 2.0 : 1.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      body(
                        header: DateFormat.d().format(d),
                        color: isSelected ? secondary : (isToday ? primary : localAppTheme['anchorColors']['primaryColor']),
                        context: context,
                      ),
                      SizedBox(height: 4),
                      if (isLoading)
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else
                        ... [
                          Visibility(visible: hasEvent, child: _buildIconContainer(localAppTheme, Icons.event, 'utilityColorPair1')),
                          Visibility(visible: hasSchedulledWorkout && !hasCompletedSchedulledWorkout, child: _buildIconContainer(localAppTheme, Icons.fitness_center, 'utilityColorPair3')),
                          Visibility(visible: hasCompletedSchedulledWorkout, child: _buildIconContainer(localAppTheme, Icons.fitness_center, 'utilityColorPair1')),
                          Visibility(visible: hasUnSchedulledWorkout, child: _buildIconContainer(localAppTheme, Icons.fitness_center_outlined, 'utilityColorPair2')),
                          Visibility(visible: hasGoal, child: _buildIconContainer(localAppTheme, Icons.flag_outlined, 'utilityColorPair4')),
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //----------------------------------------------------
  // Build icon container
  Widget _buildIconContainer(Map localAppTheme, IconData icon, String colorPair) {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1),
      padding: EdgeInsets.all(1),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: localAppTheme[colorPair]['color1'],
      ),
      child: Icon(icon, size: 15, color: localAppTheme[colorPair]['color2']),
    );
  }

  //----------------------------------------------------
  // Build Widget
  @override
  Widget build(BuildContext context) {
    final weekDays = List<DateTime>.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final weekLabel = '${DateFormat.yMMMd().format(weekDays.first)} - ${DateFormat.yMMMd().format(weekDays.last)}';
    final localAppTheme = ResponsiveTheme(context).theme;

    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx > 0) {
              _prevWeek();  // Swipe right = previous week
            } else if (details.velocity.pixelsPerSecond.dx < 0) {
              _nextWeek();  // Swipe left = next week
            }
          },
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: _prevWeek, icon: const Icon(Icons.chevron_left)),
                  Expanded(
                    child: Center(
                      child: body(header: weekLabel, color: localAppTheme['anchorColors']['primaryColor'], context: context),
                    ),
                  ),
                  IconButton(onPressed: _nextWeek, icon: const Icon(Icons.chevron_right)),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final tileWidth = (constraints.maxWidth) / 7;
                  final tileHeight = tileWidth * 1.0;
                  final effectiveHeight = (tileHeight < widget.minTileHeight ? widget.minTileHeight : tileHeight) + 75;
                  final isLoading = snapshot.connectionState == ConnectionState.waiting;

                  return SizedBox(
                    height: effectiveHeight,
                    child: Row(
                      children: weekDays.map((d) {
                        return Expanded(
                          child: _buildDayTile(d, effectiveHeight, localAppTheme, isLoading),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
