
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Statistics/Functions/statistics_window.dart';

// ignore: must_be_immutable
class WeeklyStatistics extends StatefulWidget {
  String athleteUID;
  int workoutTypeID;
  
  WeeklyStatistics({super.key, required this.athleteUID, required this.workoutTypeID});

  @override
  State<WeeklyStatistics> createState() => _WeeklyStatisticsState();
}

class _WeeklyStatisticsState extends State<WeeklyStatistics> {
  late DateTime _weekStart;
  late String athleteUID = widget.athleteUID;
  late int workoutTypeID = widget.workoutTypeID;

  //----------------------------------------------------
  // initState
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = _startOfWeek(now);
  }

  //----------------------------------------------------
  // Update when widget parameters change
  @override
  void didUpdateWidget(covariant WeeklyStatistics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.athleteUID != widget.athleteUID || oldWidget.workoutTypeID != widget.workoutTypeID) {
      setState(() {
        athleteUID = widget.athleteUID;
        workoutTypeID = widget.workoutTypeID;
      });
    }
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
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  //----------------------------------------------------
  // Move to next week
  void _nextWeek() async {  
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }  

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final weekDays = List<DateTime>.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final weekLabel = '${DateFormat.yMMMd().format(weekDays.first)} - ${DateFormat.yMMMd().format(weekDays.last)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header2(header: 'Weekly Statistics:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
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
        SizedBox(height: 10),
        StatisticsWindow(
          startDate: weekDays.first,
          endDate: weekDays.last,
          athleteUID: athleteUID,
          workoutTypeID: workoutTypeID,
        ),
      ],
    );
  }
}