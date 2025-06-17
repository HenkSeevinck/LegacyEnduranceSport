import 'package:flutter/material.dart';
import 'package:legacyendurancesport/Coach/WorkoutCalendar/Page/workoutcalendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yearly Calendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Workoutcalendar(),
    );
  }
}
