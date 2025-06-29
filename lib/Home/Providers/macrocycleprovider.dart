import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MacroCycleProvider with ChangeNotifier {
  final CollectionReference _macroMesoCycleCollection = FirebaseFirestore.instance.collection('MacroCycle');

  final List<Map<String, dynamic>> _macroCycles = [];
  List<Map<String, dynamic>> get macroCycles => _macroCycles;

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
  Future<void> getMacroCyclesByAthleteAndCoachUID(String athleteUID, String coachUID) async {
    // Clear previous data to avoid duplicates
    _macroCycles.clear();
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
      _macroCycles.add(data);
    }

    _rebuildDateRanges();
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Adds a new macro/meso cycle
  Future<void> addMacroCycle(Map<String, dynamic> data) async {
    DocumentReference docRef = await _macroMesoCycleCollection.add(data);
    await docRef.update({'macroCycleID': docRef.id});
    final newData = {...data, 'macroCycleID': docRef.id};

    // Add to the main list
    _macroCycles.add(newData);

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
  Map<String, dynamic> _selectedMacroCycle = {};
  Map<String, dynamic> get selectedMacroCycle => _selectedMacroCycle;

  Future<void> selectMacroCycleByID(String macroCycleID) async {
    final QuerySnapshot snapshot = await _macroMesoCycleCollection.where('macroCycleID', isEqualTo: macroCycleID).get();

    removeFromCollections(macroCycleID); // Testing

    if (snapshot.docs.isNotEmpty) {
      Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
      _selectedMacroCycle = data;
      notifyListeners();
    }
  }

  //-----------------------------------------------------------------------------------------------------------
  // Clear selected a macro/meso cycle
  void clearSelectedMacroCycle() {
    if (_selectedMacroCycle.isNotEmpty) {
      final macroCycleID = _selectedMacroCycle['macroCycleID'];
      final planBlockID = _selectedMacroCycle['planBlockID'];

      // Add back to the main list if missing
      if (!_macroCycles.any((cycle) => cycle['macroCycleID'] == macroCycleID)) {
        _macroCycles.add(_selectedMacroCycle);
      }
      // Add back to the correct section
      if (planBlockID == 1 && !_trainingBlocks.any((b) => b['macroCycleID'] == macroCycleID)) {
        _trainingBlocks.add(_selectedMacroCycle);
      } else if (planBlockID == 2 && !_blockGoals.any((g) => g['macroCycleID'] == macroCycleID)) {
        _blockGoals.add(_selectedMacroCycle);
      } else if (planBlockID == 3 && !_trainingFocus.any((f) => f['macroCycleID'] == macroCycleID)) {
        _trainingFocus.add(_selectedMacroCycle);
      }
      _rebuildDateRanges();
    }
    _selectedMacroCycle = {};
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Updates an existing macro/meso cycle
  Future<void> updateMacroCycle(Map<String, dynamic> data) async {
    await _macroMesoCycleCollection.doc(data['macroCycleID']).update(data);
    // Update the main list
    if (_selectedMacroCycle.isNotEmpty) {
      final macroCycleID = data['macroCycleID'];
      final planBlockID = data['planBlockID'];

      // Add back to the main list if missing
      if (!_macroCycles.any((cycle) => cycle['macroCycleID'] == macroCycleID)) {
        _macroCycles.add(data);
        print('Added to macroCycles: $data');
      }
      // Add back to the correct section
      if (planBlockID == 1 && !_trainingBlocks.any((cycle) => cycle['macroCycleID'] == macroCycleID)) {
        _trainingBlocks.add(data);
        print('Added to trainingBlocks: $data');
        for (var item in _trainingBlocks) {
          print('In training blocks: $item');
        }
      } else if (planBlockID == 2 && !_blockGoals.any((cycle) => cycle['macroCycleID'] == macroCycleID)) {
        _blockGoals.add(data);
        print('Added to blockGoals: $data');
      } else if (planBlockID == 3 && !_trainingFocus.any((cycle) => cycle['macroCycleID'] == macroCycleID)) {
        _trainingFocus.add(data);
        print('Added to trainingFocus: $data');
      }
      _rebuildDateRanges();
    }

    //_rebuildDateRanges();
    _selectedMacroCycle = {};
    notifyListeners();
  }

  //-----------------------------------------------------------------------------------------------------------
  // Deletes a macro/meso cycle
  Future<void> deleteMacroCycle(String macroMesoCycleID) async {
    await _macroMesoCycleCollection.doc(macroMesoCycleID).delete();
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

  //-----------------------------------------------------------------------------------------------------------
  // Helpers to remove selected macro/meso cycle from the lists - Testing
  void removeFromCollections(String macroCycleID) {
    _macroCycles.removeWhere((cycle) => cycle['macroCycleID'] == macroCycleID);
    _trainingBlocks.removeWhere((block) => block['macroCycleID'] == macroCycleID);
    _blockGoals.removeWhere((goal) => goal['macroCycleID'] == macroCycleID);
    _trainingFocus.removeWhere((focus) => focus['macroCycleID'] == macroCycleID);
    _rebuildDateRanges();
    notifyListeners();
  }
}
