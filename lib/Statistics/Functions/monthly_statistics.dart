
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Statistics/Functions/statistics_window.dart';

// ignore: must_be_immutable
class MonthlyStatistics extends StatefulWidget {
  String athleteUID;
  MonthlyStatistics({super.key, required this.athleteUID});

  @override
  State<MonthlyStatistics> createState() => _MonthlyStatisticsState();
}

class _MonthlyStatisticsState extends State<MonthlyStatistics> {
  late DateTime _monthStart;
  late String athleteUID = widget.athleteUID;

  //----------------------------------------------------
  // initState
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthStart = _startOfMonth(now);
  }

  //----------------------------------------------------
  // Get start of month
  DateTime _startOfMonth(DateTime d) {
    return DateTime(d.year, d.month, 1);
  }

  //----------------------------------------------------
  // Move to previous month
  void _prevMonth() async {
    setState(() {
      _monthStart = DateTime(_monthStart.year, _monthStart.month - 1, 1);
    });
  }

  //----------------------------------------------------
  // Move to next month
  void _nextMonth() async {  
    setState(() {
      _monthStart = DateTime(_monthStart.year, _monthStart.month + 1, 1);
    });
  }  

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final monthLabel = DateFormat.yMMM().format(_monthStart);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header2(header: 'Monthly Statistics:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        Row(
          children: [
            IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Center(
                child: body(header: monthLabel, color: localAppTheme['anchorColors']['primaryColor'], context: context),
              ),
            ),
            IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
          ],
        ),
        SizedBox(height: 10),
        StatisticsWindow(
          startDate: _monthStart, 
          endDate: DateTime(_monthStart.year, _monthStart.month + 1, 0), 
          athleteUID: athleteUID,
        )
      ],
    );
  }
}