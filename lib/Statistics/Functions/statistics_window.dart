import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class StatisticsWindow extends StatefulWidget {
  DateTime startDate;
  DateTime endDate;
  String athleteUID;
  int workoutTypeID;
  StatisticsWindow({
    super.key, 
    required this.startDate, 
    required this.endDate, 
    required this.athleteUID, 
    required this.workoutTypeID,
    });

  @override
  State<StatisticsWindow> createState() => _StatisticsWindowState();
}

class _StatisticsWindowState extends State<StatisticsWindow> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(workoutsProvider);
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
    await workoutsProvider.fetchLoadedWorkoutsBetweenDatesForStatistics(
      widget.athleteUID, 
      widget.startDate, 
      widget.endDate,
      widget.workoutTypeID,
    );
  }

  //----------------------------------------------------
  // Line graph data preparation between dates
  Widget _lineGraph(List<Map<String, dynamic>> statisticsBetweenDates) {
  print('StartDate: ${widget.startDate}, EndDate: ${widget.endDate}, Data: $statisticsBetweenDates');
    return Container(
      //height: 200,
      color: Colors.blueAccent,
      child: Center(child: Text('Line Graph Placeholder')),
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header3(header: widget.startDate.toString(), context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      header3(header: widget.endDate.toString(), context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      header3(header: widget.athleteUID, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      header3(header: widget.workoutTypeID.toString(), context: context, color: localAppTheme['anchorColors']['primaryColor']),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      body(header: 'Line Graph', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                      _lineGraph(statisticsBetweenDates),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      body(header: 'Table', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}