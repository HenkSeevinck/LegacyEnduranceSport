import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppUserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _appUser = {};
  Map<String, dynamic> get appUser => _appUser;

  Map<String, dynamic> _userProfileToShow = {};
  Map<String, dynamic> get userProfileToShow => _userProfileToShow;

  Map<String, dynamic> _appUserDeepStore = {};
  Map<String, dynamic> get appUserDeepStore => _appUserDeepStore;

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> get allUsers => _allUsers;

  List<Map<String, dynamic>> _athletesByCoach = [];
  List<Map<String, dynamic>> get athletesByCoach => _athletesByCoach;

  List<Map<String, dynamic>> _goalsBetweenDates = [];
  List<Map<String, dynamic>> get goalsBetweenDates => _goalsBetweenDates;

  List<Map<String, dynamic>> _todaysGoals = [];
  List<Map<String, dynamic>> get todaysGoals => _todaysGoals;

  //--------------------------------------------------------------
  // Helper to convert Firestore types (e.g. Timestamp) into JSON-encodable
  // values so jsonEncode/jsonDecode won't throw. Keeps strings for dates.
  dynamic _safeForJson(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is Map) {
      final Map<String, dynamic> out = {};
      value.forEach((k, v) {
        out[k.toString()] = _safeForJson(v);
      });
      return out;
    }
    if (value is List) {
      return value.map((e) => _safeForJson(e)).toList();
    }
    return value;
  }

  // Method to create a new user record in Firestore
  Future<void> createUserRecord(User user) async {
    await _firestore.collection('AppUsers').doc(user.uid).set({'uid': user.uid, 'email': user.email});
    _appUser = {'uid': user.uid, 'email': user.email};
    _appUserDeepStore = _safeForJson(_appUser) as Map<String, dynamic>;
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to update an existing user record in Firestore
  Future<void> updateUserRecord(Map<String, dynamic> data) async {
    await _firestore.collection('AppUsers').doc(data['uid']).update(data);
    _appUser = {..._appUser, ...data};
    // Only update deep store after a successful submit to Firestore.
    _appUserDeepStore = _safeForJson(_appUser) as Map<String, dynamic>;
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Method to get the logged-in user's record from Firestore
  Future<Map<String, dynamic>?> getUserRecord(String uid) async {
    final doc = await _firestore.collection('AppUsers').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        _appUser = {'uid': uid, ...data};
        
        await _isUserCoach(uid).then((isCoach) {
          _appUser['isCoach'] = isCoach;
        });
        await _isUserAdmin(uid).then((isAdmin) {
          _appUser['isAdmin'] = isAdmin;
        });
        await _isUserModerator(uid).then((isModerator) {
          _appUser['isModerator'] = isModerator;
        });

        notifyListeners();
      }
      return data;
    }
    return null;
  }

  //--------------------------------------------------------------
  // Method to get another user's profile which may be different from the logged-in user
  Future<Map<String, dynamic>?> getUserProfileToShow (String uid) async {
    final doc = await _firestore.collection('AppUsers').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
       
        _userProfileToShow = {'uid': uid, ...data};
        _appUserDeepStore = _safeForJson(_userProfileToShow) as Map<String, dynamic>;

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
    _userProfileToShow = jsonDecode(jsonEncode(_appUserDeepStore));
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
  // Check if user is admininator
  Future<bool> _isUserAdmin(String userID) async {
    try {
      final query = await FirebaseFirestore.instance.collection('Administrators').where('uid', isEqualTo: userID).limit(1).get();
      if (query.docs.isNotEmpty) {
        final Map<String, dynamic> data = query.docs.first.data();
        if (data.isNotEmpty) {
          _appUser['isAdmin'] = true;
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
  // Check if user is moderator
  Future<bool> _isUserModerator(String userID) async {
    try {
      final query = await FirebaseFirestore.instance.collection('Moderators').where('uid', isEqualTo: userID).limit(1).get();
      if (query.docs.isNotEmpty) {
        final Map<String, dynamic> data = query.docs.first.data();
        if (data.isNotEmpty) {
          _appUser['isModerator'] = true;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      Exception('Error checking moderator status: $e'); // Log the error
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
  // Get coach's athlete list
  Future<List<Map<String, dynamic>>> getCoachAthletes(String coachUserID) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Coaches')
          .where('userID', isEqualTo: coachUserID)
          .get();

      final List<Map<String, dynamic>> aggregatedAthletes = [];

      for (final coachDoc in querySnapshot.docs) {
        final data = coachDoc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final rawAthletes = data['athletes'] ?? [];
        final List<Map<String, dynamic>> athleteList = List<Map<String, dynamic>>.from(
          (rawAthletes as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );

        for (var athlete in athleteList) {
          try {
            final athleteDoc = await _firestore.collection('AppUsers').doc(athlete['uid']).get();
            if (athleteDoc.exists) {
              final athleteData = athleteDoc.data();
              if (athleteData != null) athlete.addAll(athleteData);
            }
          } catch (e) {
            Exception('Error fetching athlete data for UID: ${athlete['uid']}');
            rethrow;
          }
          aggregatedAthletes.add(athlete);
        }
      }

      _athletesByCoach = aggregatedAthletes;
      notifyListeners();
      return aggregatedAthletes;
    } catch (e) {
      Exception('Error retrieving coach athletes: $e');
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

  //--------------------------------------------------------------
  // Method to get user goals between dates
  Future<void> fetchUserGoalsBetweenDates(DateTime startDate, DateTime endDate) async {
    try {
      // Helper to parse stored date types (Timestamp, DateTime, ISO string, or map)
      DateTime? parseDate(dynamic v) {
        if (v == null) return null;
        if (v is DateTime) return v;
        if (v is Timestamp) return v.toDate();
        if (v is Map) {
          final seconds = v['seconds'] ?? v['_seconds'];
          final nanoseconds = v['nanoseconds'] ?? v['_nanoseconds'] ?? 0;
          if (seconds is int) {
            final ms = seconds * 1000 + (nanoseconds ~/ 1000000);
            return DateTime.fromMillisecondsSinceEpoch(ms.toInt());
          }
        }
        if (v is String) return DateTime.tryParse(v);
        return null;
      }

      final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
      final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

      final rawGoals = _appUser['goals'] ?? [];
      final List<Map<String, dynamic>> goalsList = List<Map<String, dynamic>>.from(rawGoals);
      _goalsBetweenDates = goalsList.where((goal) {
        final parsed = parseDate(goal['date']);
        if (parsed == null) return false;
        final goalDateOnly = DateTime(parsed.year, parsed.month, parsed.day);
        return !goalDateOnly.isBefore(startOnly) && !goalDateOnly.isAfter(endOnly);
      }).toList();
      notifyListeners();
    } catch (e) {
      Exception('Error retrieving user goals: $e');
      rethrow;
    }
  }

  //--------------------------------------------------------------
  // Filter _goalsBetweenDates today's goals for _todaysGoals
  Future<void> filterTodaysGoals(DateTime selectedDate) async {
    _todaysGoals = _goalsBetweenDates.where((goal) {
      final goalDateRaw = goal['date'];
      DateTime? goalDate;
      if (goalDateRaw is Timestamp) {
        goalDate = goalDateRaw.toDate();
      } else if (goalDateRaw is DateTime) {
        goalDate = goalDateRaw;
      } else if (goalDateRaw is String) {
        goalDate = DateTime.tryParse(goalDateRaw);
      }
      if (goalDate == null) return false;
      return goalDate.year == selectedDate.year &&
          goalDate.month == selectedDate.month &&
          goalDate.day == selectedDate.day;
    }).toList();
    notifyListeners();
  }
}
