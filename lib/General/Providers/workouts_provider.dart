import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class WorkoutsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _allWorkouts = [];
  List<Map<String, dynamic>> get allWorkouts => _allWorkouts;
  
  //--------------------------------------------------------------
  // Method to create a new workout record in Firestore
  Future<void> createWorkoutRecord(Map<String, dynamic> workout) async {
    DocumentReference docRef = await _firestore.collection('Workouts').add(workout);
    workout['id'] = docRef.id;
    _allWorkouts.add(workout);
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to update an existing workout record in Firestore
  Future<void> updateWorkoutRecord(Map<String, dynamic> workout) async {
    String workoutId = workout['id'];
    await _firestore.collection('Workouts').doc(workoutId).update(workout);
    
    int index = _allWorkouts.indexWhere((w) => w['id'] == workoutId);
    if (index != -1) {
      _allWorkouts[index] = workout;
      notifyListeners();
    }
  }

  //--------------------------------------------------------------
  // Get all workouts from Firestore for a specific coach
  Future<void> fetchWorkoutsForCoach(String coachUID) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('Workouts')
        .where('coachUID', isEqualTo: coachUID)
        .get();

    _allWorkouts.clear();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> workoutData = doc.data() as Map<String, dynamic>;
      workoutData['id'] = doc.id;
      _allWorkouts.add(workoutData);
    }
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Get loaded workout by atheleteUID, coachUID, and date
  Future<Map<String, dynamic>?> getTodaysLoadedWorkout(String athleteUID, String coachUID, DateTime date) async {
    try {
      // Prefer querying by Firestore Timestamp stored in `workoutDate`.
      // Build a UTC midnight range for the provided date so we match any Timestamp
      // that falls on that calendar day regardless of timezone.
      final startUtc = DateTime(date.year, date.month, date.day).toUtc(); // local-midnight converted to UTC
      final endUtc = startUtc.add(const Duration(days: 1));
      final startTs = Timestamp.fromDate(startUtc);
      final endTs = Timestamp.fromDate(endUtc);

      QuerySnapshot querySnapshot = await _firestore
          .collection('LoadedWorkouts')
          .where('athleteUID', isEqualTo: athleteUID)
          .where('coachUID', isEqualTo: coachUID)
          .where('workoutDate', isGreaterThanOrEqualTo: startTs)
          .where('workoutDate', isLessThan: endTs)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>?;
        // If the loaded workout references a workout UID, attach the full
        // workout object from `_allWorkouts` so callers get the complete data.
        if (data != null && data['workout'] is Map) {
          final workoutRef = data['workout'] as Map<String, dynamic>;
          final workoutUID = workoutRef['workoutUID'];
          if (workoutUID != null) {
            try {
              final matched = _allWorkouts.firstWhere((w) => w['id'] == workoutUID, orElse: () => {});
              if (matched.isNotEmpty) {
                data['workout'] = Map<String, dynamic>.from(matched);
              }
            } catch (e) {
              Exception('Error matching workouts: $e');
              rethrow;
            }
          }
        }
        return {'loadedWorkoutUID': doc.id, ...?data};
      }
      return null;
    } catch (e) {
      Exception('Error retrieving loaded workout: $e');
      rethrow;
    }
  }
}