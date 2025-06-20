import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppUserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _appUser = {};
  Map<String, dynamic> get appUser => _appUser;

  // Method to create a new user record in Firestore
  Future<void> createUserRecord(User user) async {
    await _firestore.collection('AppUsers').doc(user.uid).set({'uid': user.uid, 'email': user.email});
    _appUser = {'uid': user.uid, 'email': user.email};
    notifyListeners();
  }

  // Method to update an existing user record in Firestore
  Future<void> updateUserRecord(User user, Map<String, dynamic> data) async {
    await _firestore.collection('AppUsers').doc(user.uid).update(data);
    _appUser = {..._appUser, ...data};
    notifyListeners();
  }

  // Method to get the user record from Firestore
  Future<Map<String, dynamic>?> getUserRecord(String uid) async {
    final doc = await _firestore.collection('AppUsers').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        _appUser = {'uid': uid, ...data};
        notifyListeners();
      }
      return data;
    }
    return null;
  }

  // Method to clear the user data
  void clearUserData() {
    _appUser = {};
    notifyListeners();
  }
}
