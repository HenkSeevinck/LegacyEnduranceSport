import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/DayOverview/Page/daily_overview.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
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

  const WeekDaysTable({super.key, required this.athleteUID, required this.navPath, this.initialDate, this.onDaySelected, this.minTileHeight = 64});
  @override
  State<WeekDaysTable> createState() => _WeekDaysTableState();
}

class _WeekDaysTableState extends State<WeekDaysTable> {
  late DateTime _weekStart; // Monday of the current week
  DateTime? _selectedDate;
  Future<void>? _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    _weekStart = _startOfWeek(now);
    _selectedDate = now;

    //Add Providers you want to fetch data from here
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);

    _fetchDataFuture = _fetchData(eventsProvider, workoutsProvider, appUserProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(EventsProvider eventsProvider, WorkoutsProvider workoutsProvider, AppUserProvider appUserProvider) async {
    appUserProvider.appUser;
    await eventsProvider.fetchEventsBetweenDates(_weekStart, _weekStart.add(const Duration(days: 6)));
    await workoutsProvider.fetchLoadedWorkoutsBetweenDates(widget.athleteUID, _weekStart, _weekStart.add(const Duration(days: 6)));
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
    final athleteUID = widget.athleteUID;
    
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
    await eventsProvider.fetchEventsBetweenDates(_weekStart, _weekStart.add(const Duration(days: 6)));
    await workoutsProvider.fetchLoadedWorkoutsBetweenDates(
      athleteUID,
      _weekStart,
      _weekStart.add(const Duration(days: 6)),
    );
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
    final athleteUID = widget.athleteUID;
    
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
    await eventsProvider.fetchEventsBetweenDates(_weekStart, _weekStart.add(const Duration(days: 6)));
    await workoutsProvider.fetchLoadedWorkoutsBetweenDates(
      athleteUID,
      _weekStart,
      _weekStart.add(const Duration(days: 6)),
    );
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

    await appUserProvider.filterTodaysGoals(d);
    await eventsProvider.filterTodaysEvents(d);
    await workoutsProvider.filterTodaysWorkouts(d);

    setState(() {
      _selectedDate = d;
    });
    widget.onDaySelected?.call(d);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DailyOverview(selectedDate: d, navPath: widget.navPath),
      ),
    );
  }

  //----------------------------------------------------
  // Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  //----------------------------------------------------
  // Build Widget
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        final weekDays = List<DateTime>.generate(7, (i) => _weekStart.add(Duration(days: i)));
        final weekLabel = '${DateFormat.yMMMd().format(weekDays.first)} - ${DateFormat.yMMMd().format(weekDays.last)}';
        final localAppTheme = ResponsiveTheme(context).theme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
              width: double.infinity,
              height: 150,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator())
                )
              );
        } else if (snapshot.hasError) {
          return Center(
            child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          );
        } else {
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
            
                    return SizedBox(
                      height: effectiveHeight,
                      child: Row(
                        children: weekDays.map((d) {
                          final eventsProvider = Provider.of<EventsProvider>(context, listen: true);
                          final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: true);
                          final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
                          final eventsBetweenDates = eventsProvider.eventsBetweenDates;
                          final workoutsBetweenDates = workoutsProvider.workoutsBetweenDates;
                          final goalsBetweenDates = appUserProvider.goalsBetweenDates;
                          final isSelected = _selectedDate != null && _isSameDay(_selectedDate!, d);
                          final isToday = _isSameDay(DateTime.now(), d);
                          final primary = localAppTheme['anchorColors']['primaryColor'];
                          final secondary = localAppTheme['anchorColors']['primaryColor'];
                          
                          bool hasEvent = eventsBetweenDates!.any((event) {
                            final eventDate = event['eventDate']?.toDate();
                            return eventDate != null && _isSameDay(eventDate, d);
                          });
                          
                          bool hasSchedulledWorkout = workoutsBetweenDates.any((workout) {
                            final workoutDate = workout['workoutDate']?.toDate();
                            return workoutDate != null && workout['workout'] != null && _isSameDay(workoutDate, d);
                          });

                          bool hasCompletedSchedulledWorkout = workoutsBetweenDates.any((workout) {
                            final workoutDate = workout['workoutDate']?.toDate();
                            return workoutDate != null && workout['workout'] != null && workout['completedworkoutData'] != null && _isSameDay(workoutDate, d);
                          });
            
                          bool hasUnSchedulledWorkout = workoutsBetweenDates.any((workout) {
                            final workoutDate = workout['workoutDate']?.toDate();
                            return workoutDate != null && workout['workout'] == null && _isSameDay(workoutDate, d);
                          });
            
                          bool hasGoal = goalsBetweenDates.any((goal) {
                            final goalDate = goal['date']?.toDate();
                            return goalDate != null && _isSameDay(goalDate, d);
                          });
            
                          return Expanded(
                            child: Column(
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
                                              Visibility(
                                                visible: hasEvent,
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 1, bottom: 1),
                                                  padding: EdgeInsets.all(1),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: localAppTheme['utilityColorPair1']['color1'],
                                                  ),
                                                  child: Icon(
                                                    Icons.event, 
                                                    size: 15, 
                                                    color: localAppTheme['utilityColorPair1']['color2'],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: hasSchedulledWorkout && !hasCompletedSchedulledWorkout,
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 1, bottom: 1),
                                                  padding: EdgeInsets.all(1),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: localAppTheme['utilityColorPair3']['color1'],
                                                  ),
                                                  child: Icon(
                                                    Icons.fitness_center, 
                                                    size: 15, 
                                                    color: localAppTheme['utilityColorPair3']['color2'],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: hasCompletedSchedulledWorkout,
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 1, bottom: 1),
                                                  padding: EdgeInsets.all(1),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: localAppTheme['utilityColorPair1']['color1'],
                                                  ),
                                                  child: Icon(
                                                    Icons.fitness_center, 
                                                    size: 15, 
                                                    color: localAppTheme['utilityColorPair1']['color2'],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: hasUnSchedulledWorkout,
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 1, bottom: 1),
                                                  padding: EdgeInsets.all(1),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: localAppTheme['utilityColorPair2']['color1'],
                                                  ),
                                                  child: Icon(
                                                    Icons.fitness_center_outlined, 
                                                    size: 15, 
                                                    color: localAppTheme['utilityColorPair2']['color2'],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: hasGoal,
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 1, bottom: 1),
                                                  padding: EdgeInsets.all(1),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: localAppTheme['utilityColorPair4']['color1'],
                                                  ),
                                                  child: Icon(
                                                    Icons.flag_outlined, 
                                                    size: 15, 
                                                    color: localAppTheme['utilityColorPair4']['color2']
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
