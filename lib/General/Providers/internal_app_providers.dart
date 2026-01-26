import 'package:flutter/material.dart';
import 'package:legacyendurancesport/Events/Page/events_page.dart';
import 'package:legacyendurancesport/Goals/Page/goals_page.dart';
import 'package:legacyendurancesport/MyAthletes/Page/my_athletes_page.dart';
import 'package:legacyendurancesport/Profile/Page/profile_page.dart';
import 'package:legacyendurancesport/Statistics/Page/statistics_page.dart';
import 'package:legacyendurancesport/Workouts/Page/workouts_page.dart';

//Form Status Provider
class InternalStatusProvider with ChangeNotifier {
  String signInsignUpStatus = 'SignIn';
  String platform = '';
  String userUIDToShow = '';

  List<Map<String, dynamic>> eventTypes = [
    {'id': 1, 'eventType': 'Run'},
    {'id': 2, 'eventType': 'Cycle'},
    {'id': 3, 'eventType': 'Swim'},
    {'id': 4, 'eventType': 'Triathlon'},
    {'id': 5, 'eventType': 'Other'},
  ];

  List<Map<String, dynamic>> homePageOptions = [
    {'selection': 'myProfile', 'pageName': 'MY PROFILE', 'icon': Icons.person, 'navigateTo': UserProfile(isCoachView: false, formEditable: true), 'coachOnly': false},
    {'selection': 'myGoals', 'pageName': 'MY GOALS', 'icon': Icons.flag_outlined, 'navigateTo': GoalsPage(isCoachView: false), 'coachOnly': false},
    {'selection': 'events', 'pageName': 'EVENTS', 'icon': Icons.event, 'navigateTo': EventPage(), 'coachOnly': false},
    {'selection': 'events', 'pageName': 'STATISTICS', 'icon': Icons.bar_chart, 'navigateTo': StatisticsPage(isCoachView: false), 'coachOnly': false},
    {'selection': 'athletes', 'pageName': 'MY ATHLETES', 'icon': Icons.people, 'navigateTo': MyAthletesPage(), 'coachOnly': true},
    {'selection': 'workouts', 'pageName': 'MY WORKOUTS', 'icon': Icons.fitness_center, 'navigateTo': Workouts(), 'coachOnly': true},
  ];

  List<Map<String, dynamic>> longRangePlanBlocks = [
    {'planBlockID': 1, 'setting': 'ADD TRAINING BLOCKS'},
    {'planBlockID': 2, 'setting': 'ADD BLOCK GOALS'},
    {'planBlockID': 3, 'setting': 'ADD TRAINING FOCUS'},
  ];

  List<Map<String, dynamic>> focusBlocks = [
    {'blockTypeID': 1, 'blockType': 'RECOVERY'},
    {'blockTypeID': 2, 'blockType': 'TAPER'},
    {'blockTypeID': 3, 'blockType': 'ENDURANCE'},
    {'blockTypeID': 4, 'blockType': 'LACTATE'},
    {'blockTypeID': 5, 'blockType': 'VO2 MAX'},
    {'blockTypeID': 6, 'blockType': 'STRENGTH'},
  ];

  List<Map<String, dynamic>> mesoBlocks = [
    {'mesoBlockID': 7, 'mesoBlock': 'WARM UP'},
    {'mesoBlockID': 2, 'mesoBlock': 'ENDURANCE'},
    {'mesoBlockID': 3, 'mesoBlock': 'STEADY STATE'},
    {'mesoBlockID': 4, 'mesoBlock': 'TEMPO'},
    {'mesoBlockID': 5, 'mesoBlock': 'INTERVALS'},
    {'mesoBlockID': 6, 'mesoBlock': 'TAPER'},
    {'mesoBlockID': 9, 'mesoBlock': 'REST'},
    {'mesoBlockID': 1, 'mesoBlock': 'RECOVERY'},
    {'mesoBlockID': 8, 'mesoBlock': 'COOL DOWN'},
  ];

  List<Map<String, dynamic>> workoutTypes = [
    {'workoutTypeID': 1, 'workoutType': 'RUN', 'icon': Icons.directions_run, 'color': Colors.blue},
    {'workoutTypeID': 2, 'workoutType': 'CYCLE', 'icon': Icons.directions_bike, 'color': Colors.green},
    {'workoutTypeID': 3, 'workoutType': 'SWIM', 'icon': Icons.pool, 'color': Colors.teal},
    {'workoutTypeID': 4, 'workoutType': 'WORKOUT', 'icon': Icons.fitness_center, 'color': Colors.orange},
    {'workoutTypeID': 5, 'workoutType': 'WALK', 'icon': Icons.directions_walk, 'color': Colors.orange},
  ];

  List<Map<String, dynamic>> durationTypes = [
    {'durationTypeID': 1, 'durationType': 'Time', 'value': 'e.g., 10:00'},
    {'durationTypeID': 2, 'durationType': 'Distance', 'value': 'e.g., 5km'},
  ];
  
  List<Map<String, dynamic>> intensityTargetTypes = [
    {'intensityTargetTypeID': 1, 'intensityTargetType': 'Pace', 'value': 'e.g., 5:00/km'},
    {'intensityTargetTypeID': 2, 'intensityTargetType': 'Heart Rate', 'value': 'e.g., 150 bpm'},
    {'intensityTargetTypeID': 3, 'intensityTargetType': 'Power', 'value': 'e.g., 250 W'},
    {'intensityTargetTypeID': 4, 'intensityTargetType': 'RPE', 'value': 'e.g., 7/10'},
  ];

  void setSignInSignUpStatus(String status) {
    signInsignUpStatus = status;
    notifyListeners();
  }

  Future<void> setPlatform(String value) async {
    platform = value;
    notifyListeners();
  }

  Future<void> setUserUIDToShow(String value) async {
    userUIDToShow = value;
    notifyListeners();
  }
}
