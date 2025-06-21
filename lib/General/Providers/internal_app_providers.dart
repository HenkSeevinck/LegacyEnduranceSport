import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/LRPB/blockgoals.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/LRPB/lrpb_default_top.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/LRPB/trainingblock.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/LRPB/trainingfocus.dart';

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
  Widget lrpbTopWidget = LRPBDefaultTop();
  Map<String, dynamic>? athleteKey;
  List<Map<String, dynamic>> longRangePlanBlocks = [
    {'blockTypeID': 1, 'setting': 'SETUP TRAINING BLOCKS', 'navigate': const TrainingBlock()},
    {'blockTypeID': 2, 'setting': 'SETUP BLOCK GOALS', 'navigate': const BlockGoals()},
    {'blockTypeID': 3, 'setting': 'SETUP TRAINING FOCUS', 'navigate': const TrainingFocus()},
  ];
  int? selectedBlockTypeID; // Default to 'Training Block'

  void setAdminMode(bool status) {
    adminMode = status;
    notifyListeners();
  }

  void setAthleteKey(Map<String, dynamic>? record) {
    athleteKey = record;
    notifyListeners();
  }

  void setBlockTypeID(int? value) {
    selectedBlockTypeID = value;
    notifyListeners();
  }

  void setHomeMainContent(Widget? widget) {
    homeMainContent = widget;
    notifyListeners();
  }

  void setlrpbTopWidget(Widget widget) {
    lrpbTopWidget = widget;
    notifyListeners();
  }

  void setHomePageSidebar(String status) {
    homePageSidebar = status;
    notifyListeners();
  }

  void setSignInSignUpStatus(String status) {
    signInsignUpStatus = status;
    notifyListeners();
  }

  void setUserRole(String? status) {
    selectedUserRole = status;
    notifyListeners();
  }

  int getTotalWeeks(int year) {
    final dec28 = DateTime(year, 12, 28);
    final week = ((dec28.dayOfYear - dec28.weekday + 10) / 7).floor();
    return week;
  }

  int getCurrentWeekNumber(int year) {
    final now = DateTime.now();
    if (now.year != year) return 1;
    final jan4 = DateTime(year, 1, 4);
    final diff = now.difference(jan4.subtract(Duration(days: jan4.weekday - 1)));
    return (diff.inDays / 7).floor() + 1;
  }
}
