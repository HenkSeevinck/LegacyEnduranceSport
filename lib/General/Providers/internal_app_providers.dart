import 'package:flutter/material.dart';
import 'package:legacyendurancesport/MyAthletes/Page/my_athletes_page.dart';
import 'package:legacyendurancesport/Profile/Page/profile_page.dart';

//Form Status Provider
class InternalStatusProvider with ChangeNotifier {
  String signInsignUpStatus = 'SignIn';
  String platform = '';

  List<Map<String, dynamic>> homePageOptions = [
    {'selection': 'myProfile', 'pageName': 'MY PROFILE', 'icon': Icons.person, 'navigateTo': UserProfile(isCoachView: false), 'coachOnly': false},
    {'selection': 'myGoals', 'pageName': 'MY GOALS', 'icon': Icons.flag, 'navigateTo': SizedBox(), 'coachOnly': false},
    {'selection': 'events', 'pageName': 'EVENTS', 'icon': Icons.event, 'navigateTo': SizedBox(), 'coachOnly': false},
    {'selection': 'athletes', 'pageName': 'MY ATHLETES', 'icon': Icons.people, 'navigateTo': MyAthletesPage(), 'coachOnly': true},
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
    {'workoutTypeID': 1, 'workoutType': 'run', 'icon': Icons.directions_run, 'color': Colors.blue},
    {'workoutTypeID': 2, 'workoutType': 'cycle', 'icon': Icons.directions_bike, 'color': Colors.green},
    {'workoutTypeID': 3, 'workoutType': 'swim', 'icon': Icons.pool, 'color': Colors.teal},
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
}
