import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Helper extension for dayOfYear
extension DateTimeDayOfYear on DateTime {
  int get dayOfYear {
    return int.parse(DateFormat("D").format(this));
  }
}

//Form Status Provider
class InternalStatusProvider with ChangeNotifier {
  bool adminMode = false;
  String signInsignUpStatus = 'SignIn';
  int get currentYear => DateTime.now().year;
  String? selectedUserRole;
  late int firstYear = currentYear - 3;
  late int lastYear = currentYear + 3;
  late int totalWeeks = getTotalWeeks(currentYear);
  String homePageSidebar = '';
  Widget? homeMainContent;
  String lrpbFormStatus = 'MacroCycle';
  int planBlockID = 1;
  Map<String, dynamic>? athleteKey;
  List<Map<String, dynamic>> longRangePlanBlocks = [
    {'planBlockID': 1, 'setting': 'ADD TRAINING BLOCKS'},
    {'planBlockID': 2, 'setting': 'ADD BLOCK GOALS'},
    {'planBlockID': 3, 'setting': 'ADD TRAINING FOCUS'},
  ];
  Map<String, dynamic>? selectedLongRangePlanBlocks;
  int firstDayOfWeek = DateTime.sunday;
  List<Map<String, dynamic>> focusBlocks = [
    {'blockTypeID': 1, 'blockType': 'RECOVERY'},
    {'blockTypeID': 2, 'blockType': 'TAPER'},
    {'blockTypeID': 3, 'blockType': 'ENDURANCE'},
    {'blockTypeID': 4, 'blockType': 'LACTATE'},
    {'blockTypeID': 5, 'blockType': 'VO2 MAX'},
  ];

  void setAdminMode(bool status) {
    adminMode = status;
    notifyListeners();
  }

  void setAthleteKey(Map<String, dynamic>? record) {
    athleteKey = record;
    notifyListeners();
  }

  void setSelectedLongRangePlanBlocks(Map<String, dynamic>? record) {
    selectedLongRangePlanBlocks = record;
    notifyListeners();
  }

  void setHomeMainContent(Widget? widget) {
    homeMainContent = widget;
    notifyListeners();
  }

  void setHomePageSidebar(String status) {
    homePageSidebar = status;
    notifyListeners();
  }

  void setlrpbFormStatus(String status) {
    lrpbFormStatus = status;
    notifyListeners();
  }

  void setSignInSignUpStatus(String status) {
    signInsignUpStatus = status;
    notifyListeners();
  }

  int getTotalWeeks(int year) {
    final dec28 = DateTime(year, 12, 28);
    final week = ((dec28.dayOfYear - dec28.weekday + 10) / 7).floor();
    return week;
  }

  void setUserRole(String? status) {
    selectedUserRole = status;
    notifyListeners();
  }

  void setPlanBlockID(int value) {
    planBlockID = value;
    notifyListeners();
  }

  int getCurrentWeekNumber(int year) {
    final now = DateTime.now();
    if (now.year != year) return 1;
    final jan4 = DateTime(year, 1, 4);
    final diff = now.difference(jan4.subtract(Duration(days: jan4.weekday - 1)));
    return (diff.inDays / 7).floor() + 1;
  }
}
