import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Returns true if the goal overlaps with the week.
bool isGoalInWeek(DateTime weekStart, DateTime weekEnd, DateTime goalStart, DateTime goalEnd) {
  return !(goalEnd.isBefore(weekStart) || goalStart.isAfter(weekEnd));
}

/// Returns the first goal color for the week, or transparent if none.
Color getWeekGoalColor(List<Map<String, dynamic>> weekGoals) {
  if (weekGoals.isNotEmpty && weekGoals.first['color'] != null) {
    return Color(weekGoals.first['color']);
  }
  return Colors.transparent;
}

/// Converts Firestore Timestamp or DateTime to DateTime
DateTime toDateTime(dynamic value) {
  if (value == null) return DateTime(1970, 1, 1); // or handle null as needed
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime(1970, 1, 1);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  throw ArgumentError('Unsupported date type: ${value.runtimeType}');
}

// Returns the name of the block type based on its ID.
String? getBlockTypeName(int? blockTypeID, List<Map<String, dynamic>> focusBlocks) {
  if (blockTypeID == null) return null;
  final match = focusBlocks.firstWhere((block) => block['blockTypeID'] == blockTypeID, orElse: () => {});
  return match.isNotEmpty ? match['blockType'] as String? : null;
}

void clearInputForm({required TextEditingController goalController, required TextEditingController startDateController, required TextEditingController endDateController, required void Function(Color) setColor}) {
  goalController.clear();
  startDateController.clear();
  endDateController.clear();
  setColor(Colors.transparent);
}
