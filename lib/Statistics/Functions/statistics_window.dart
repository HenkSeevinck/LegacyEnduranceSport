import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class StatisticsWindow extends StatefulWidget {
  DateTime startDate;
  DateTime endDate;
  String athleteUID;
  int workoutTypeID;
  StatisticsWindow({super.key, required this.startDate, required this.endDate, required this.athleteUID, required this.workoutTypeID});

  @override
  State<StatisticsWindow> createState() => _StatisticsWindowState();
}

class _StatisticsWindowState extends State<StatisticsWindow> {
  Future<void>? _fetchDataFuture;
  late final ScrollController _horizontalController;
  bool _hasScrolledToToday = false;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(workoutsProvider);
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  //----------------------------------------------------
  // Reload when inputs change (new week or athlete)
  @override
  void didUpdateWidget(covariant StatisticsWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final inputsChanged =
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.athleteUID != widget.athleteUID ||
        oldWidget.workoutTypeID != widget.workoutTypeID;

    if (inputsChanged) {
      setState(() {
        final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
        _fetchDataFuture = _fetchData(workoutsProvider);
      });
    }
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(WorkoutsProvider workoutsProvider) async {
    //await workoutsProvider.fetchLoadedWorkoutsBetweenDatesForStatistics(
    await workoutsProvider.fetchLoadedWorkoutsBetweenDatesForStatistics(widget.athleteUID, widget.startDate, widget.endDate, widget.workoutTypeID);
  }

  //----------------------------------------------------
  // Line graph data preparation between dates
  Widget _lineGraph(List<Map<String, dynamic>> statisticsBetweenDates) {
    // Aggregate distances by day and compute cumulative totals.
    //print('StartDate: ${widget.startDate}, EndDate: ${widget.endDate}, Data: $statisticsBetweenDates');

    // Helper to convert possible Timestamp/map types to DateTime
    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      try {
        if (v is DateTime) return v;
        if (v is Map && v.containsKey('seconds')) {
          final seconds = v['seconds'];
          return DateTime.fromMillisecondsSinceEpoch((seconds * 1000).toInt());
        }
        try {
          final dt = v.toDate();
          if (dt is DateTime) return dt;
        } catch (_) {}
      } catch (_) {}
      return null;
    }

    // Sum distances per calendar day (local)
    final Map<DateTime, double> daily = {};
    for (var item in statisticsBetweenDates) {
      final rawDate = item['workoutDate'];
      final dt = _toDate(rawDate);
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final cw = item['completedworkoutData'];
      double dist = 0.0;
      if (cw is Map && cw['distance'] != null) {
        final d = cw['distance'];
        if (d is num) dist = d.toDouble();
        if (d is String) dist = double.tryParse(d) ?? 0.0;
      }
      daily[day] = (daily[day] ?? 0.0) + dist;
    }

    // Build ordered list of days between start and end (inclusive)
    final start = DateTime(widget.startDate.year, widget.startDate.month, widget.startDate.day);
    final end = DateTime(widget.endDate.year, widget.endDate.month, widget.endDate.day);
    final List<DateTime> days = [];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    // Compute cumulative sums and FlSpots (x = index, y = cumulative distance)
    final List<FlSpot> spots = [];
    double cumulative = 0.0;
    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      cumulative += (daily[day] ?? 0.0);
      spots.add(FlSpot(i.toDouble(), cumulative));
    }

    // Formatters for axis labels
    String bottomLabel(double value) {
      final idx = value.round();
      if (idx < 0 || idx >= days.length) return '';
      final d = days[idx];
      return '${d.month}/${d.day}';
    }

    return Padding(
      padding: EdgeInsetsGeometry.only(top: 70, bottom: 20),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        width: days.length * 25 < MediaQuery.of(context).size.width 
        ? MediaQuery.of(context).size.width * 0.85
        : days.isNotEmpty ? days.length * 25 : MediaQuery.of(context).size.width,
        child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (v, meta) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(bottomLabel(v), style: const TextStyle(fontSize: 8)),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (spots.isNotEmpty ? (spots.last.y / 4).clamp(1, double.infinity) : 1),
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 8), // <- change font size here
                  ),
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                  color: Colors.blue,
                ),
              ],
              minX: 0,
              maxX: (days.length - 1).toDouble().clamp(0, double.infinity),
              minY: 0,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touched) {
                    return touched.map((t) {
                      final idx = t.x.toInt();
                      final date = (idx >= 0 && idx < days.length) ? days[idx] : null;
                      final dateLabel = date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : '';
                      return LineTooltipItem('$dateLabel\n${t.y.toStringAsFixed(2)} km', const TextStyle(color: Colors.white));
                    }).toList();
                  },
                ),
              ),
            ),
          ),
      ),
    );
  }

  //----------------------------------------------------
  // Build method
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
          final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: true);
          final statisticsBetweenDates = workoutsProvider.statisticsBetweenDates;

          // Compute days/count and chart sizing to determine scroll target for today
          final start = DateTime(widget.startDate.year, widget.startDate.month, widget.startDate.day);
          final end = DateTime(widget.endDate.year, widget.endDate.month, widget.endDate.day);
          final daysCount = end.isBefore(start) ? 0 : end.difference(start).inDays + 1;
          final screenWidth = MediaQuery.of(context).size.width;
          final chartWidth = (daysCount * 25) < screenWidth ? screenWidth * 0.85 : (daysCount * 25).toDouble();
          final perDay = daysCount > 0 ? chartWidth / daysCount : 25.0;

          // Schedule one-time scroll to today's index (centered) after first layout
          if (!_hasScrolledToToday) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_horizontalController.hasClients) return;
              final today = DateTime.now();
              int targetIndex = 0;
              if (daysCount > 0) {
                final clippedToday = DateTime(today.year, today.month, today.day);
                if (clippedToday.isBefore(start)) {
                  targetIndex = 0;
                } else if (clippedToday.isAfter(end)) {
                  targetIndex = daysCount - 1;
                } else {
                  targetIndex = clippedToday.difference(start).inDays;
                }
              }

              // Desired scroll to center the day's column
              final desired = (targetIndex * perDay) - (screenWidth / 2) + (perDay / 2);
              final maxScroll = _horizontalController.position.maxScrollExtent;
              final offset = desired.clamp(0.0, maxScroll);
              if (offset > 0) {
                _horizontalController.animateTo(offset, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
              }
              _hasScrolledToToday = true;
            });
          }

          return SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _lineGraph(statisticsBetweenDates),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 1,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [body(header: 'Table', color: localAppTheme['anchorColors']['primaryColor'], context: context)],
                //   ),
                // ),
              ],
            ),
          );
        }
      },
    );
  }
}
