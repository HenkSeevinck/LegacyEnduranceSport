import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MacroMesoCycleProvider with ChangeNotifier {
  final CollectionReference _macroMesoCycleCollection = FirebaseFirestore.instance.collection('MacroMesoCycle');

  final List<Map<String, dynamic>> _macroMesoCycles = [];
  List<Map<String, dynamic>> get macroMesoCycles => _macroMesoCycles;

  final List<Map<String, dynamic>> _trainingBlocks = [];
  List<Map<String, dynamic>> get trainingBlocks => _trainingBlocks;

  final List<Map<String, dynamic>> _blockGoals = [];
  List<Map<String, dynamic>> get blockGoals => _blockGoals;

  final List<Map<String, dynamic>> _trainingFocus = [];
  List<Map<String, dynamic>> get trainingFocus => _trainingFocus;

  final List<DateTimeRange> _trainingBlocksDateRanges = [];
  List<DateTimeRange> get trainingBlocksDateRanges => _trainingBlocksDateRanges;

  final List<DateTimeRange> _blockGoalsDateRanges = [];
  List<DateTimeRange> get blockGoalsDateRanges => _blockGoalsDateRanges;

  final List<DateTimeRange> _trainingFocusDateRanges = [];
  List<DateTimeRange> get trainingFocusDateRanges => _trainingFocusDateRanges;

  //-----------------------------------------------------------------------------------------------------------
  // Fetches all macro/meso cycles for the given athleteUID
  Future<void> getMacroMesoCyclesByAthleteAndCoachUID(String athleteUID, String coachUID) async {
    // Clear previous data to avoid duplicates
    _macroMesoCycles.clear();
    _trainingBlocks.clear();
    _blockGoals.clear();
    _trainingFocus.clear();

    final QuerySnapshot snapshot = await _macroMesoCycleCollection.where('atheleteUID', isEqualTo: athleteUID).where('coachUID', isEqualTo: coachUID).get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['planBlockID'] == 1) {
        _trainingBlocks.add(data);
      } else if (data['planBlockID'] == 2) {
        _blockGoals.add(data);
      } else if (data['planBlockID'] == 3) {
        _trainingFocus.add(data);
      }
      _macroMesoCycles.add(data);
    }

    _rebuildDateRanges();
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Adds a new macro/meso cycle
  Future<void> addMacroMesoCycle(Map<String, dynamic> data) async {
    DocumentReference docRef = await _macroMesoCycleCollection.add(data);
    await docRef.update({'macroMesoCycleID': docRef.id});
    final newData = {...data, 'macroMesoCycleID': docRef.id};

    // Add to the main list
    _macroMesoCycles.add(newData);

    // Add to the correct local section
    if (newData['planBlockID'] == 1) {
      _trainingBlocks.add(newData);
    } else if (newData['planBlockID'] == 2) {
      _blockGoals.add(newData);
    } else if (newData['planBlockID'] == 3) {
      _trainingFocus.add(newData);
    }

    _rebuildDateRanges();
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Selects a macro/meso cycle by its ID
  Future<Map<String, dynamic>?> selectMacroMesoCycleByID(String macroMesoCycleID) async {
    final QuerySnapshot snapshot = await _macroMesoCycleCollection.where('macroMesoCycleID', isEqualTo: macroMesoCycleID).get();

    if (snapshot.docs.isNotEmpty) {
      Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
      return data;
    }
    return null;
  }

  //-----------------------------------------------------------------------------------------------------------
  // Updates an existing macro/meso cycle
  Future<void> updateMacroMesoCycle(String macroMesoCycleID, Map<String, dynamic> data) async {
    await _macroMesoCycleCollection.doc(macroMesoCycleID).update(data);
    int index = _macroMesoCycles.indexWhere((cycle) => cycle['macroMesoCycleID'] == macroMesoCycleID);
    if (index != -1) {
      _macroMesoCycles[index] = {..._macroMesoCycles[index], ...data};
      notifyListeners();
    }
  }

  //-----------------------------------------------------------------------------------------------------------
  // Deletes a macro/meso cycle
  Future<void> deleteMacroMesoCycle(String macroMesoCycleID) async {
    await _macroMesoCycleCollection.doc(macroMesoCycleID).delete();
    _macroMesoCycles.removeWhere((cycle) => cycle['macroMesoCycleID'] == macroMesoCycleID);

    // Remove from the specific lists
    _trainingBlocks.removeWhere((block) => block['macroMesoCycleID'] == macroMesoCycleID);
    _blockGoals.removeWhere((goal) => goal['macroMesoCycleID'] == macroMesoCycleID);
    _trainingFocus.removeWhere((focus) => focus['macroMesoCycleID'] == macroMesoCycleID);

    _rebuildDateRanges();
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Helpers to get the date ranges for each section
  void _rebuildDateRanges() {
    _trainingBlocksDateRanges.clear();
    for (var block in _trainingBlocks) {
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

//-----------------------------------------------------------------------------------------------------------
