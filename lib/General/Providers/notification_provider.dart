import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  List<String> _notificationMedia = [];
  List<String> get notificationMedia => _notificationMedia;

//---------------------------------------------------------
// Get url's of all Images in /notifications/Current folder in Firebase Storage
  Future<List<String>> fetchNotificationMedia() async {
    final Reference reference = FirebaseStorage.instance.ref().child('notifications');
    final ListResult result = await reference.listAll();

    final List<String> urls = [];
    for (final ref in result.items) {
      try {
        final String url = await ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        // ignore individual file errors but continue
        continue;
      }
    }

    _notificationMedia = urls;
    notifyListeners();
    return urls;
  }
}