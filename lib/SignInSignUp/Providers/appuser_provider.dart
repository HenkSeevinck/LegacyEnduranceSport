import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppUserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _appUser = {};
  Map<String, dynamic> get appUser => _appUser;

  Map<String, dynamic> _appUserDeepStore = {};
  Map<String, dynamic> get appUserDeepStore => _appUserDeepStore;

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> get allUsers => _allUsers;

  //--------------------------------------------------------------
  // Method to create a new user record in Firestore
  Future<void> createUserRecord(User user) async {
    await _firestore.collection('AppUsers').doc(user.uid).set({'uid': user.uid, 'email': user.email});
    _appUser = {'uid': user.uid, 'email': user.email};
    _appUserDeepStore = jsonDecode(jsonEncode(_appUser));
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to update an existing user record in Firestore
  Future<void> updateUserRecord(Map<String, dynamic> data) async {
    await _firestore.collection('AppUsers').doc(data['uid']).update(data);
    _appUser = {..._appUser, ...data};
    // Only update deep store after a successful submit to Firestore.
    _appUserDeepStore = jsonDecode(jsonEncode(_appUser));
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to get the user record from Firestore
  Future<Map<String, dynamic>?> getUserRecord(String uid) async {
    final doc = await _firestore.collection('AppUsers').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        _appUser = {'uid': uid, ...data};
        
        await _isUserCoach(uid).then((isCoach) {
          _appUser['isCoach'] = isCoach;
        });
        
        _appUserDeepStore = jsonDecode(jsonEncode(_appUser));

        notifyListeners();
      }
      return data;
    }
    return null;
  }

  //--------------------------------------------------------------
  // Get all user records from Firestore
  Future<void> getAllUserRecords() async {
    final querySnapshot = await _firestore.collection('AppUsers').get();
    _allUsers = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {'uid': doc.id, ...data};
    }).toList();
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Update local app user without touching the deep-store (for UI edits)
  void updateLocalUser(Map<String, dynamic> data) {
    _appUser = {..._appUser, ...data};
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to clear the user data
  void clearUserData() {
    _appUser = {};
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to reset user data to deep store state
  Future<void> refreshDeepStore() async {
    // Use a deep-copy to avoid assigning the same Map instance
    // so subsequent local edits don't modify the deep store.
    _appUser = jsonDecode(jsonEncode(_appUserDeepStore));
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Check if user is in the coach role
  Future<bool> _isUserCoach(String userID) async {
    try {
      final query = await FirebaseFirestore.instance.collection('Coaches').where('userID', isEqualTo: userID).limit(1).get();
      if (query.docs.isNotEmpty) {
        final Map<String, dynamic> data = query.docs.first.data();
        if (data.isNotEmpty) {
          _appUser['athletes'] = List<Map<String, dynamic>>.from(data['athletes'] ?? []);
          _appUser['coachDocID'] = query.docs.first.id;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      Exception('Error checking admin status: $e'); // Log the error
      rethrow;
    }
  }

  //--------------------------------------------------------------
  // Add athlete to coach's athlete list
  Future<void> addAthleteToCoach(String coachUserID, String athleteUID, String email) async {
    try {
      final coachDocRef = _firestore.collection('Coaches').doc(coachUserID);
      final Map<String, dynamic> athleteEntry = {'uid': athleteUID, 'email': email};
      await coachDocRef.update({
        'athletes': FieldValue.arrayUnion([athleteEntry])
      });
      _appUser['athletes'].add(athleteEntry);
      notifyListeners();
    } catch (e) {
      Exception('Error adding athlete to coach: $e'); // Log the error
      rethrow;
    }
  }

  //--------------------------------------------------------------
  // Remove athlete from coach's athlete list
  Future<void> removeAthleteFromCoach(String coachUserID, String athleteUID) async {
    try {
      final coachDocRef = _firestore.collection('Coaches').doc(coachUserID);
      final athleteList = List<Map<String, dynamic>>.from(_appUser['athletes'] ?? []);
      final athleteToRemove = athleteList.firstWhere((athlete) => athlete['uid'] == athleteUID, orElse: () => {});
      if (athleteToRemove.isNotEmpty) {
        await coachDocRef.update({
          'athletes': FieldValue.arrayRemove([athleteToRemove])
        });
        athleteList.removeWhere((athlete) => athlete['uid'] == athleteUID);
        _appUser['athletes'] = athleteList;
        notifyListeners();
      }
    } catch (e) {
      Exception('Error removing athlete from coach: $e'); // Log the error
      rethrow;
    }
  }
}
