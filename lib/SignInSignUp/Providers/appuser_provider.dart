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
        _appUserDeepStore = jsonDecode(jsonEncode(_appUser));
        notifyListeners();
      }
      return data;
    }
    return null;
  }

  // //--------------------------------------------------------------
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
}
