import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class EventsProvider with ChangeNotifier {
  final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('Events');

  List<Map<String, dynamic>>? _events;
  List<Map<String, dynamic>>? get events => _events;
  //---------------------------------------------------------------
  // Fetch all events from Firestore
  Future<void> fetchAllEvents() async {
    try {
      final QuerySnapshot snapshot = await _eventsCollection.get();

      _events = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['eventID'] = doc.id; // Add the document ID
        return data;
      }).toList();
      notifyListeners(); // Notify listeners after fetching
    } catch (e) {
      Exception('Error fetching Events: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }
}