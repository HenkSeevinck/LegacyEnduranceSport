import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AthleteKeyProvider with ChangeNotifier {
  final CollectionReference _athleteKeysCollection = FirebaseFirestore.instance.collection('AthleteKeys');
  final CollectionReference _appUsersCollection = FirebaseFirestore.instance.collection('AppUsers');

  /// Returns the athleteKey (existing or new) or null on error.
  Future<Map<String, dynamic>?> createAthleteKey(Map<String, dynamic> data) async {
    final String athleteEmail = data['athleteEmail'];
    final String coachUID = data['coachUID'];
    final DateTime now = DateTime.now();

    // Query for active key
    final QuerySnapshot existing = await _athleteKeysCollection.where('athleteEmail', isEqualTo: athleteEmail).where('coachUID', isEqualTo: coachUID).where('keyExpirationDate', isGreaterThan: now).get();

    if (existing.docs.isNotEmpty) {
      // Return the existing athleteKey
      final existingKey = existing.docs.first['athleteKey'] as String?;
      return {'athleteKey': existingKey, 'isExisting': true};
    }

    // No active key, create new
    DocumentReference docRef = await _athleteKeysCollection.add(data);
    await docRef.update({'athleteKey': docRef.id});
    notifyListeners();
    return {'athleteKey': docRef.id, 'isExisting': false};
  }

  //--------------------------------------------------------------------------------------------------------------------------
  // All Athlete Keys where coachUID matches appUser's UID.
  List<Map<String, dynamic>> _athletes = [];
  List<Map<String, dynamic>> get athletes => _athletes;

  Future<List<Map<String, dynamic>>> getAthleteKeys(String coachUID) async {
    final DateTime now = DateTime.now();
    final QuerySnapshot snapshot = await _athleteKeysCollection.where('coachUID', isEqualTo: coachUID).where('keyExpirationDate', isGreaterThan: now).get();

    // Convert to list of maps
    List<Map<String, dynamic>> athleteList = [];
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final athleteUID = data['athleteUID'];
      if (athleteUID != null) {
        // Fetch user info from AppUsers
        final userSnap = await _appUsersCollection.where('uid', isEqualTo: athleteUID).limit(1).get();
        if (userSnap.docs.isNotEmpty) {
          final userData = userSnap.docs.first.data() as Map<String, dynamic>;
          data['name'] = userData['name'] ?? '-';
          data['surname'] = userData['surname'] ?? '-';
        } else {
          data['name'] = '-';
          data['surname'] = '-';
        }
      } else {
        data['name'] = '-';
        data['surname'] = '-';
      }
      athleteList.add(data);
    }

    _athletes = athleteList;
    notifyListeners();
    return _athletes;
  }

  //--------------------------------------------------------------------------------------------------------------------------
  // Check if athleteKey valid for the given email.
  Future<bool> isAthleteKeyValid(String athleteEmail, String athleteKey) async {
    final DateTime now = DateTime.now();
    final QuerySnapshot snapshot = await _athleteKeysCollection.where('athleteEmail', isEqualTo: athleteEmail).where('athleteKey', isEqualTo: athleteKey).where('keyExpirationDate', isGreaterThan: now).get();

    return snapshot.docs.isNotEmpty;
  }

  // Update AthleteKey record with athleteUID
  Future<void> updateAthleteKeyWithUID(String athleteEmail, String athleteKey, String athleteUID) async {
    final QuerySnapshot snapshot = await _athleteKeysCollection.where('athleteEmail', isEqualTo: athleteEmail).where('athleteKey', isEqualTo: athleteKey).get();

    if (snapshot.docs.isNotEmpty) {
      DocumentReference docRef = snapshot.docs.first.reference;
      await docRef.update({'athleteUID': athleteUID});
      notifyListeners();
    } else {
      throw Exception('Athlete key not found for the given email and key.');
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------
  // get selected athlete from athletes list
  Map<String, dynamic> _selectedAthlete = {};
  Map<String, dynamic> get selectedAthlete => _selectedAthlete;

  Future<void> setSelectedAthlete(String athleteUID) async {
    final QuerySnapshot userSnap = await _appUsersCollection.where('uid', isEqualTo: athleteUID).limit(1).get();

    if (userSnap.docs.isNotEmpty) {
      _selectedAthlete = userSnap.docs.first.data() as Map<String, dynamic>;
    } else {
      _selectedAthlete = {};
    }
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------------------
  // Clear selected athlete
  void clearSelectedAthlete() {
    _selectedAthlete = {};
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------------------
  // Delete athleteKey by athleteKey
  Future<void> deleteAthleteKey(String athleteKey) async {
    final QuerySnapshot snapshot = await _athleteKeysCollection.where('athleteKey', isEqualTo: athleteKey).get();

    if (snapshot.docs.isNotEmpty) {
      DocumentReference docRef = snapshot.docs.first.reference;
      await docRef.delete();
      notifyListeners();
    } else {
      throw Exception('Athlete key not found.');
    }
  }
}
