import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkoutProvider with ChangeNotifier {
  final CollectionReference _workoutsCollection = FirebaseFirestore.instance.collection('Workouts');

  Map<String, dynamic>? _selectedWorkout;
  Map<String, dynamic>? get selectedWorkout => _selectedWorkout;

  List<Map<String, dynamic>> _workoutCycles = [];
  List<Map<String, dynamic>> get workoutCycles => _workoutCycles;

  //-----------------------------------------------------------------------------------------------------------
  // Adds a new workout cycle
  Future<void> addWorkoutCycle(Map<String, dynamic> workoutData) async {
    try {
      // Create a copy to avoid modifying the original map during the async operation
      final dataToAdd = Map<String, dynamic>.from(workoutData)..remove('workoutID');
      DocumentReference docRef = await _workoutsCollection.add(dataToAdd);
      final newData = {...workoutData, 'workoutID': docRef.id};
      _workoutCycles.add(newData);
      notifyListeners();
    } catch (e) {
      print('Error adding Workout Cycle: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }

  //-----------------------------------------------------------------------------------------------------------
  // Updates an existing workout cycle
  Future<void> updateWorkoutCycle(String workoutID, Map<String, dynamic> updatedData) async {
    try {
      // Create a copy to avoid modifying the original map during the async operation
      final dataToUpdate = Map<String, dynamic>.from(updatedData)..remove('workoutID');
      await _workoutsCollection.doc(workoutID).update(dataToUpdate);
      int index = _workoutCycles.indexWhere((cycle) => cycle['workoutID'] == workoutID);
      if (index != -1) {
        _workoutCycles[index] = updatedData;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating Workout Cycle: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }

  //-----------------------------------------------------------------------------------------------------------
  // Get all workout cycles for a specific and coach
  Future<void> getWorkoutCyclesByAthleteAndCoachAndYear(String coachUID) async {
    try {
      final QuerySnapshot snapshot = await _workoutsCollection.where('coachUID', isEqualTo: coachUID).get();

      _workoutCycles = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['workoutID'] = doc.id; // Add the document ID
        return data;
      }).toList();
      notifyListeners(); // Notify listeners after fetching
    } catch (e) {
      print('Error fetching Workout Cycles: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }

  //-----------------------------------------------------------------------------------------------------------
  // Deletes a workout cycle
  Future<void> deleteWorkoutCycle(String workoutID) async {
    try {
      await _workoutsCollection.doc(workoutID).delete();
      _workoutCycles.removeWhere((cycle) => cycle['workoutID'] == workoutID);
      notifyListeners();
    } catch (e) {
      print('Error deleting Workout Cycle: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }

  //-----------------------------------------------------------------------------------------------------------
  // Select a workout cycle
  void selectWorkoutCycle(Map<String, dynamic> workout) {
    _selectedWorkout = workout;
    notifyListeners();
  }
}
