import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MacroCycleProvider with ChangeNotifier {
  final CollectionReference _macroCycleCollection = FirebaseFirestore.instance.collection('MacroCycle');

  final List<Map<String, dynamic>> _macroCycles = [];
  List<Map<String, dynamic>> get macroCycles {
    // Return a copy to prevent state mutation from UI
    return _macroCycles.toList();
  }

  final List<Map<String, dynamic>> _trainingBlocks = [];
  List<Map<String, dynamic>> get trainingBlocks {
    // Return a copy to prevent state mutation from UI
    return _trainingBlocks.toList();
  }

  final List<Map<String, dynamic>> _blockGoals = [];
  List<Map<String, dynamic>> get blockGoals {
    // Return a copy to prevent state mutation from UI
    return _blockGoals.toList();
  }

  final List<Map<String, dynamic>> _trainingFocus = [];
  List<Map<String, dynamic>> get trainingFocus {
    // Return a copy to prevent state mutation from UI
    return _trainingFocus.toList();
  }

  final List<DateTimeRange> _trainingBlocksDateRanges = [];
  List<DateTimeRange> get trainingBlocksDateRanges => _trainingBlocksDateRanges;

  final List<DateTimeRange> _blockGoalsDateRanges = [];
  List<DateTimeRange> get blockGoalsDateRanges => _blockGoalsDateRanges;

  final List<DateTimeRange> _trainingFocusDateRanges = [];
  List<DateTimeRange> get trainingFocusDateRanges => _trainingFocusDateRanges;

  //-----------------------------------------------------------------------------------------------------------
  // Fetches all macro/meso cycles for the given athleteUID
  Future<void> getMacroCyclesByAthleteAndCoachUID(String athleteUID, String coachUID) async {
    // Clear previous data to avoid duplicates
    _macroCycles.clear();
    _trainingBlocks.clear();
    _blockGoals.clear();
    _trainingFocus.clear();

    final QuerySnapshot snapshot = await _macroCycleCollection.where('atheleteUID', isEqualTo: athleteUID).where('coachUID', isEqualTo: coachUID).get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // Only add if not empty and has a macroCycleID
      if (data.isNotEmpty && data['macroCycleID'] != null) {
        if (data['planBlockID'] == 1) {
          _trainingBlocks.add(data);
        } else if (data['planBlockID'] == 2) {
          _blockGoals.add(data);
        } else if (data['planBlockID'] == 3) {
          _trainingFocus.add(data);
        }
        _macroCycles.add(data);
      }
    }

    _rebuildDateRanges();
    // Remove any empty maps
    _trainingBlocks.removeWhere((item) => item.isEmpty);
    _macroCycles.removeWhere((item) => item.isEmpty);
    _blockGoals.removeWhere((item) => item.isEmpty);
    _trainingFocus.removeWhere((item) => item.isEmpty);
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Adds a new macro/meso cycle
  Future<void> addMacroCycle(Map<String, dynamic> data) async {
    DocumentReference docRef = await _macroCycleCollection.add(data);
    await docRef.update({'macroCycleID': docRef.id});
    final newData = {...data, 'macroCycleID': docRef.id};

    // Add to the main list
    if (newData['macroCycleID'] != null && newData.isNotEmpty) {
      _macroCycles.add(newData);
    } else {}

    // Add to the correct local section
    if (newData['planBlockID'] == 1 && newData['macroCycleID'] != null && newData.isNotEmpty) {
      _trainingBlocks.add(newData);
    } else if (newData['planBlockID'] == 2 && newData['macroCycleID'] != null && newData.isNotEmpty) {
      _blockGoals.add(newData);
    } else if (newData['planBlockID'] == 3 && newData['macroCycleID'] != null && newData.isNotEmpty) {
      _trainingFocus.add(newData);
    }

    _rebuildDateRanges();
    // Remove any empty maps
    _trainingBlocks.removeWhere((item) => item.isEmpty);
    _macroCycles.removeWhere((item) => item.isEmpty);
    _blockGoals.removeWhere((item) => item.isEmpty);
    _trainingFocus.removeWhere((item) => item.isEmpty);
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Selects a macro/meso cycle by its ID
  Map<String, dynamic> _selectedMacroCycle = {};
  Map<String, dynamic> get selectedMacroCycle => _selectedMacroCycle;

  void selectMacroCycleByID(String macroCycleID) {
    // Find the item in the local list without removing it.
    final index = _macroCycles.indexWhere((cycle) => cycle['macroCycleID'] == macroCycleID);
    if (index != -1) {
      // Set the selected item. The UI will listen to this change.
      _selectedMacroCycle = Map<String, dynamic>.from(_macroCycles[index]);
      _rebuildDateRanges(macroCycleIDToExclude: macroCycleID);
    } else {
      _selectedMacroCycle = {};
    }
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Clear selected a macro/meso cycle
  void clearSelectedMacroCycle() {
    // Simply clear the selection. No need to add items back as they were never removed.
    _rebuildDateRanges();
    _selectedMacroCycle = {};
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Updates an existing macro/meso cycle
  Future<void> updateMacroCycle(Map<String, dynamic> data) async {
    final Map<String, dynamic> dataCopy = Map<String, dynamic>.from(data);
    await _macroCycleCollection.doc(dataCopy['macroCycleID']).update(dataCopy);

    final macroCycleID = dataCopy['macroCycleID'];
    final planBlockID = dataCopy['planBlockID'];

    // Update in _macroCycles
    int index = _macroCycles.indexWhere((cycle) => cycle['macroCycleID'] == macroCycleID);
    if (index != -1) {
      _macroCycles[index] = dataCopy;
    }

    // Update in the correct specific list
    if (planBlockID == 1) {
      int blockIndex = _trainingBlocks.indexWhere((block) => block['macroCycleID'] == macroCycleID);
      if (blockIndex != -1) {
        _trainingBlocks[blockIndex] = dataCopy;
      }
    } else if (planBlockID == 2) {
      int goalIndex = _blockGoals.indexWhere((goal) => goal['macroCycleID'] == macroCycleID);
      if (goalIndex != -1) {
        _blockGoals[goalIndex] = dataCopy;
      }
    } else if (planBlockID == 3) {
      int focusIndex = _trainingFocus.indexWhere((focus) => focus['macroCycleID'] == macroCycleID);
      if (focusIndex != -1) {
        _trainingFocus[focusIndex] = dataCopy;
      }
    }

    _rebuildDateRanges();

    // Remove any empty maps
    _trainingBlocks.removeWhere((item) => item.isEmpty);
    _macroCycles.removeWhere((item) => item.isEmpty);
    _blockGoals.removeWhere((item) => item.isEmpty);
    _trainingFocus.removeWhere((item) => item.isEmpty);

    // for (var item in trainingBlocks) {
    //   print('Item in trainingBlocks provider: $item');
    // }
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Deletes a macro/meso cycle
  Future<void> deleteMacroCycle(String macroMesoCycleID) async {
    await _macroCycleCollection.doc(macroMesoCycleID).delete();
    _macroCycles.removeWhere((cycle) => cycle['macroCycleID'] == macroMesoCycleID);

    // Remove from the specific lists
    _trainingBlocks.removeWhere((block) => block['macroCycleID'] == macroMesoCycleID);
    _blockGoals.removeWhere((goal) => goal['macroCycleID'] == macroMesoCycleID);
    _trainingFocus.removeWhere((focus) => focus['macroCycleID'] == macroMesoCycleID);

    _rebuildDateRanges();
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Helpers to get the date ranges for each section
  void _rebuildDateRanges({String? macroCycleIDToExclude}) {
    _trainingBlocksDateRanges.clear();
    for (var block in _trainingBlocks) {
      if (block['macroCycleID'] == macroCycleIDToExclude) continue;
      final s = block['startDate'];
      final e = block['endDate'];
      if (s != null && e != null) {
        final start = s is Timestamp ? s.toDate() : s;
        final end = e is Timestamp ? e.toDate() : e;
        _trainingBlocksDateRanges.add(DateTimeRange(start: DateTime(start.year, start.month, start.day), end: DateTime(end.year, end.month, end.day)));
      }
    }

    _blockGoalsDateRanges.clear();
    for (var goal in _blockGoals) {
      if (goal['macroCycleID'] == macroCycleIDToExclude) continue;
      final s = goal['startDate'];
      final e = goal['endDate'];
      if (s != null && e != null) {
        final start = s is Timestamp ? s.toDate() : s;
        final end = e is Timestamp ? e.toDate() : e;
        _blockGoalsDateRanges.add(DateTimeRange(start: DateTime(start.year, start.month, start.day), end: DateTime(end.year, end.month, end.day)));
      }
    }

    _trainingFocusDateRanges.clear();
    for (var focus in _trainingFocus) {
      if (focus['macroCycleID'] == macroCycleIDToExclude) continue;
      final s = focus['startDate'];
      final e = focus['endDate'];
      if (s != null && e != null) {
        final start = s is Timestamp ? s.toDate() : s;
        final end = e is Timestamp ? e.toDate() : e;
        _trainingFocusDateRanges.add(DateTimeRange(start: DateTime(start.year, start.month, start.day), end: DateTime(end.year, end.month, end.day)));
      }
    }
  }
}
