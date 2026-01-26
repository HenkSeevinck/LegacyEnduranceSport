
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Statistics/Functions/statistics_window.dart';

// ignore: must_be_immutable
class YearlyStatistics extends StatefulWidget {
  String athleteUID;
  YearlyStatistics({super.key, required this.athleteUID});
  
  @override
  State<YearlyStatistics> createState() => _YearlyStatisticsState();
}

class _YearlyStatisticsState extends State<YearlyStatistics> {
  late DateTime _yearStart;
  late String athleteUID = widget.athleteUID;

  //----------------------------------------------------
  // initState
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _yearStart = _startOfYear(now);
  }

  //----------------------------------------------------
  // Get start of year
  DateTime _startOfYear(DateTime d) {
    return DateTime(d.year, 1, 1);
  }

  //----------------------------------------------------
  // Move to previous year
  void _prevYear() async {
    setState(() {
      _yearStart = DateTime(_yearStart.year - 1, 1, 1);
    });
  }

  //----------------------------------------------------
  // Move to next year
  void _nextYear() async {  
    setState(() {
      _yearStart = DateTime(_yearStart.year + 1, 1, 1);
    });
  }  

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final yearLabel = DateFormat.y().format(_yearStart);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header2(header: 'Yearly Statistics:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        Row(
          children: [
            IconButton(onPressed: _prevYear, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Center(
                child: body(header: yearLabel, color: localAppTheme['anchorColors']['primaryColor'], context: context),
              ),
            ),
            IconButton(onPressed: _nextYear, icon: const Icon(Icons.chevron_right)),
          ],
        ),
        SizedBox(height: 10),
        StatisticsWindow(
          startDate: _yearStart, 
          endDate: DateTime(_yearStart.year + 1, 1, 0), 
          athleteUID: athleteUID,
        )
      ],
    );
  }
}