import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';

// ignore: must_be_immutable
class StatisticsWindow extends StatefulWidget {
  DateTime startDate;
  DateTime endDate;
  String athleteUID;
  StatisticsWindow({
    super.key, 
    required this.startDate, 
    required this.endDate, 
    required this.athleteUID
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
    //Add Providers you want to fetch data from here
    _fetchDataFuture = _fetchData();
  }

  //----------------------------------------------------
  // Reload when inputs change (new week or athlete)
  @override
  void didUpdateWidget(covariant StatisticsWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final inputsChanged =
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.athleteUID != widget.athleteUID;

    if (inputsChanged) {
      setState(() {
        _fetchDataFuture = _fetchData();
      });
    }
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData() async {
    //Add fetch functions from Providers you want to fetch data from here
  }


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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header3(header: widget.startDate.toString(), context: context, color: localAppTheme['anchorColors']['primaryColor']),
              header3(header: widget.endDate.toString(), context: context, color: localAppTheme['anchorColors']['primaryColor']),
              header3(header: widget.athleteUID, context: context, color: localAppTheme['anchorColors']['primaryColor']),
            ],
          );
        }
      },
    );
  }
}