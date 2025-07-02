import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MesoCycleProvider with ChangeNotifier {
  final CollectionReference _mesoCycleCollection = FirebaseFirestore.instance.collection('MesoCycle');

  Map<String, dynamic>? _selectedMesoCycle;
  Map<String, dynamic>? get selectedMesoCycle => _selectedMesoCycle;

  List<Map<String, dynamic>> _mesoCycles = [];
  List<Map<String, dynamic>> get mesoCycles => _mesoCycles;

  //-----------------------------------------------------------------------------------------------------------
  // Adds a new meso cycle
  Future<void> addMesoCycle(Map<String, dynamic> mesoCycleData) async {
    try {
      // Create a copy to avoid modifying the original map during the async operation
      final dataToAdd = Map<String, dynamic>.from(mesoCycleData)..remove('mesoCycleID');
      DocumentReference docRef = await _mesoCycleCollection.add(dataToAdd);
      final newData = {...mesoCycleData, 'mesoCycleID': docRef.id};
      _mesoCycles.add(newData);
      notifyListeners();
    } catch (e) {
      print('Error adding Meso Cycle: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }

  //-----------------------------------------------------------------------------------------------------------
  // Updates an existing meso cycle
  Future<void> updateMesoCycle(String mesoCycleID, Map<String, dynamic> updatedData) async {
    try {
      // Create a copy to avoid modifying the original map during the async operation
      final dataToUpdate = Map<String, dynamic>.from(updatedData)..remove('mesoCycleID');
      await _mesoCycleCollection.doc(mesoCycleID).update(dataToUpdate);
      int index = _mesoCycles.indexWhere((cycle) => cycle['mesoCycleID'] == mesoCycleID);
      if (index != -1) {
        _mesoCycles[index] = updatedData;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating Meso Cycle: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }

  //-----------------------------------------------------------------------------------------------------------
  // Get all meso cycles for a specific athlete and coach and year
  Future<void> getMesoCyclesByAthleteAndCoachAndYear(String athleteUID, String coachUID, int year) async {
    try {
      final QuerySnapshot snapshot = await _mesoCycleCollection.where('athleteUID', isEqualTo: athleteUID).where('coachUID', isEqualTo: coachUID).where('year', isEqualTo: year).get();

      _mesoCycles = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['mesoCycleID'] = doc.id; // Add the document ID
        return data;
      }).toList();
      notifyListeners(); // Notify listeners after fetching
    } catch (e) {
      print('Error fetching Meso Cycles: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }
}
