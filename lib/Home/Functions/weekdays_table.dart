import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';

/// WeekDaysTable
/// - shows 7 days for a current week (Mon-Sun by default)
/// - has back / forward controls to move weeks
/// - reports selected day via `onDaySelected`
class WeekDaysTable extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDaySelected;
  final double minTileHeight;

  const WeekDaysTable({super.key, this.initialDate, this.onDaySelected, this.minTileHeight = 64});

  @override
  State<WeekDaysTable> createState() => _WeekDaysTableState();
}

class _WeekDaysTableState extends State<WeekDaysTable> {
  late DateTime _weekStart; // Monday of the current week
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    _weekStart = _startOfWeek(now);
    _selectedDate = now;
  }

  DateTime _startOfWeek(DateTime d) {
    // treat Monday as start of week
    final weekday = d.weekday; // Mon = 1
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
  }

  void _prevWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  void _selectDate(DateTime d) {
    setState(() {
      _selectedDate = d;
    });
    widget.onDaySelected?.call(d);
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = List<DateTime>.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final weekLabel = '${DateFormat.yMMMd().format(weekDays.first)} - ${DateFormat.yMMMd().format(weekDays.last)}';
    final localAppTheme = ResponsiveTheme(context).theme;

    return Column(
      children: [
        //Padding(
          //padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          //child:
          Row(
            children: [
              IconButton(onPressed: _prevWeek, icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Center(
                  child: body(header: weekLabel, color: localAppTheme['anchorColors']['primaryColor'], context: context)
                  //Text(weekLabel, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
              IconButton(onPressed: _nextWeek, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        //),
        //const SizedBox(height: 4),
        LayoutBuilder(builder: (context, constraints) {
          final tileWidth = (constraints.maxWidth) / 7;
          final tileHeight = tileWidth * 1.0; // square-ish tiles; can be adjusted
          final effectiveHeight = tileHeight < widget.minTileHeight ? widget.minTileHeight : tileHeight;

          return SizedBox(
            height: effectiveHeight, //+ 5, // space for weekday + date labels
            child: Row(
              children: weekDays.map((d) {
                final isSelected = _selectedDate != null && _isSameDay(_selectedDate!, d);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _selectDate(d),
                        child: Container(
                          height: effectiveHeight,
                          decoration: BoxDecoration(
                            color: isSelected ? localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: localAppTheme['anchorColors']['primaryColor'],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //Text(DateFormat.E().format(d), style: Theme.of(context).textTheme.bodySmall),
                              //const SizedBox(height: 6),
                              //Text(DateFormat.d().format(d), style: Theme.of(context).textTheme.titleMedium),
                              body(
                                header: DateFormat.d().format(d), 
                                color: localAppTheme['anchorColors']['primaryColor'], 
                                context: context,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
