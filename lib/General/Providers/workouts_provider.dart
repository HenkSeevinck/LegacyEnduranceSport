import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class WorkoutsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _allWorkouts = [];
  List<Map<String, dynamic>> get allWorkouts => _allWorkouts;

  List<Map<String, dynamic>> _workoutsBetweenDates = [];
  List<Map<String, dynamic>> get workoutsBetweenDates => _workoutsBetweenDates;

  List<Map<String, dynamic>> _statisticsBetweenDates = [];
  List<Map<String, dynamic>> get statisticsBetweenDates => _statisticsBetweenDates;

  List<Map<String, dynamic>> _todaysWorkouts = [];
  List<Map<String, dynamic>> get todaysWorkouts => _todaysWorkouts;
  
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

  //--------------------------------------------------------------
  // Method to create a new loaded workout record in Firestore
  Future<void> createLoadedWorkoutRecord(Map<String, dynamic> workout) async {
    DocumentReference docRef = await _firestore.collection('LoadedWorkouts').add(workout);
    workout['loadedWorkoutUID'] = docRef.id;
    _todaysWorkouts.add(workout);
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to update an existing loaded workout record in Firestore
  Future<void> updateLoadedWorkoutRecord(String loadedWorkoutUID, Map<String, dynamic> workout) async {
    await _firestore.collection('LoadedWorkouts').doc(loadedWorkoutUID).set(workout);
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to add completed workout data to an existing loaded workout record
  Future<void> addCompletedWorkoutData(String loadedWorkoutUID, Map<String, dynamic> completedworkoutData) async {
    await _firestore.collection('LoadedWorkouts').doc(loadedWorkoutUID).update({
      'completedworkoutData': completedworkoutData,
    });
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Medhod to loop through a list of workouts and load or update them
  Future<void> loadOrUpdateWorkouts(List<Map<String, dynamic>> assignedAthletes) async {
    for (var workout in assignedAthletes) {
      if (workout['assinedWorkoutUID'] != null) {
        await updateLoadedWorkoutRecord(workout['assinedWorkoutUID'], workout['workoutToLoad']);
      } else {
        await createLoadedWorkoutRecord(workout['workoutToLoad']);
      }
    }
  }

  //--------------------------------------------------------------
  // Method to get loaded workouts for a specific athlete between dates
  Future<void> fetchLoadedWorkoutsBetweenDates(String athleteUID, DateTime startDate, DateTime endDate) async {
    final startTs = Timestamp.fromDate(startDate);
    final endTs = Timestamp.fromDate(endDate.add(const Duration(days: 1)));

    QuerySnapshot querySnapshot = await _firestore
        .collection('LoadedWorkouts')
        .where('athleteUID', isEqualTo: athleteUID)
        .where('workoutDate', isGreaterThanOrEqualTo: startTs)
        .where('workoutDate', isLessThan: endTs)
        .get();

    _workoutsBetweenDates = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['loadedWorkoutUID'] = doc.id; // Add the document ID
      return data;
    }).toList();
    notifyListeners();
  }

  //---------------------------------------------------------------
  // Filter _workoutsBetweenDates to get today's workouts for _todaysWorkouts
  Future<void> filterTodaysWorkouts(DateTime selectedDate) async {
    final List<Map<String, dynamic>> todays = [];
    for (var workout in _workoutsBetweenDates) {
      final workoutDate = workout['workoutDate'];
      if (workoutDate is Timestamp) {
        final date = workoutDate.toDate();
        if (
        date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day) {
          if (workout['workout'] is Map && workout['workout']['workoutUID'] != null) {
            final Map<String, dynamic>? fetchedWorkout = await fetchWorkoutByID(workout['workout']['workoutUID']);
            if (fetchedWorkout != null) {
              workout['workout'] = fetchedWorkout;
            }
          }
          todays.add(workout);
        }
      }
    }
    _todaysWorkouts = todays;
    notifyListeners();
  }

  //---------------------------------------------------------------
  // fetch workout by workout ID
  Future<Map<String, dynamic>?> fetchWorkoutByID(String workoutID) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Workouts').doc(workoutID).get();
      if (doc.exists) {
        Map<String, dynamic> workoutData = doc.data() as Map<String, dynamic>;
        workoutData['id'] = doc.id;
        return workoutData;
      }
      return null;
    } catch (e) {
      Exception('Error fetching workout by ID: $e');
      rethrow;
    }
  }

  //--------------------------------------------------------------
  // Method to get loaded workouts for a specific athlete between dates
  Future<void> fetchLoadedWorkoutsBetweenDatesForStatistics(String athleteUID, DateTime startDate, DateTime endDate, int workoutType) async {
    final startTs = Timestamp.fromDate(startDate);
    final endTs = Timestamp.fromDate(endDate.add(const Duration(days: 1)));

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('LoadedWorkouts')
          .where('athleteUID', isEqualTo: athleteUID)
          .where('workoutDate', isGreaterThanOrEqualTo: startTs)
          .where('workoutDate', isLessThan: endTs)
          .where('completedworkoutData', isNotEqualTo: null)
          .where('completedworkoutData.type', isEqualTo: workoutType)
          .get();

      _statisticsBetweenDates = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['loadedWorkoutUID'] = doc.id; // Add the document ID
        return data;
      }).toList();
      notifyListeners();
    } catch (e) {
      Exception('Error fetching workouts for statistics: $e');
      rethrow;
    }
  }
}
