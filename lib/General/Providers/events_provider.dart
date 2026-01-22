import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';

class EventsProvider with ChangeNotifier {
  final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('Events');

  List<Map<String, dynamic>>? _events;
  List<Map<String, dynamic>>? get events => _events;

  List<Map<String, dynamic>>? _eventsBetweenDates;
  List<Map<String, dynamic>>? get eventsBetweenDates => _eventsBetweenDates;

  List<Map<String, dynamic>>? _todaysEvents;
  List<Map<String, dynamic>>? get todaysEvents => _todaysEvents;

  List<Map<String, dynamic>>? _attendees;
  List<Map<String, dynamic>>? get attendees => _attendees;

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

  //---------------------------------------------------------------
  // Update an event in Firestore
  Future<void> updateEvent(String eventID, Map<String, dynamic> updatedData) async {
    try {
      // Apply update on server
      await _eventsCollection.doc(eventID).update(updatedData);
      final doc = await _eventsCollection.doc(eventID).get();
      if (doc.exists) {
        final serverData = doc.data() as Map<String, dynamic>;
        serverData['eventID'] = doc.id;
        if (_events != null) {
          final index = _events!.indexWhere((event) => event['eventID'] == eventID);
          if (index != -1) {
            _events![index] = serverData;
          } else {
            _events!.add(serverData);
          }
          notifyListeners();
        }
      }
    } catch (e) {
      Exception('Error updating Event: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }

  //---------------------------------------------------------------
  // Fetch events for betwee two dates
  Future<void> fetchEventsBetweenDates(DateTime startDate, DateTime endDate) async {
    try {
      final QuerySnapshot snapshot = await _eventsCollection
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      _eventsBetweenDates = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['eventID'] = doc.id; // Add the document ID
        return data;
      }).toList();
      notifyListeners();
    } catch (e) {
      Exception('Error fetching Events between dates: $e');
      rethrow; // Re-throw the error for further handling if needed
    }
  }

  //---------------------------------------------------------------
  // Filter _eventsBetweenDates today's events for _todaysEvents
  Future<void> filterTodaysEvents(DateTime selectedDate) async {
    if (_eventsBetweenDates == null) return;

    _todaysEvents = _eventsBetweenDates!.where((event) {
      final eventDateTimestamp = event['eventDate'] as Timestamp?;
      if (eventDateTimestamp == null) return false;
      final eventDate = eventDateTimestamp.toDate();
      return eventDate.year == selectedDate.year &&
          eventDate.month == selectedDate.month &&
          eventDate.day == selectedDate.day;
    }).toList();
    notifyListeners();
  }

  //---------------------------------------------------------------
  // Fetch attendees for a specific event
  Future<void> fetchAttendeesForEvent(List athleteUIDs, AppUserProvider appUserProvider) async {
    for (var athleteUID in athleteUIDs) {
      try {
        final appUserData = await appUserProvider.getUserRecord(athleteUID);
        if (appUserData != null) {
          _attendees ??= [];
          _attendees!.add(appUserData);
          notifyListeners();
        }
      } catch (e) {
        Exception('Error fetching Attendee with UID $athleteUID: $e');
        rethrow;
      }
    }
  }
}
