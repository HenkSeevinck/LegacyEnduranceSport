import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ClubsProvider with ChangeNotifier {
  final CollectionReference _clubsCollection = FirebaseFirestore.instance.collection('Clubs');

  List<Map<String, dynamic>>? _Clubs;
  List<Map<String, dynamic>>? get Clubs => _Clubs;

  //---------------------------------------------------------------
  // Fetch all clubs from Firestore
  Future<void> fetchAllClubs() async {
    try {
      final QuerySnapshot snapshot = await _clubsCollection.get();

      _Clubs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['clubID'] = doc.id; // Add the document ID
        return data;
      }).toList();
      notifyListeners(); // Notify listeners after fetching
    } catch (e) {
      Exception('Error fetching Clubs: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }
}