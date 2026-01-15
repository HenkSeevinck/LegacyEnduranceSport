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
}