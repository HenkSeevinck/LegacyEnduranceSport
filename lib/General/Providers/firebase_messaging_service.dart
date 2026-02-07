import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService with ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _fcmToken;
  String? _userId;

  String? get fcmToken => _fcmToken;

  //------------------------------------------------------
  // Notifications Permissions
  Future<void> requestPermission(String userId) async {
    _userId = userId;
    if (kIsWeb) {
      // For web, request notification permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted web notification permission');
        // Get FCM token for web
        await _getFCMToken();
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional web notification permission');
        await _getFCMToken();
      } else {
        print('User declined or has not accepted web notification permission');
      }
    } else {
      // For mobile platforms
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
        await _getFCMToken();
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
        await _getFCMToken();
      } else {
        print('User declined or has not accepted notification permission');
      }
    }
  }

  //------------------------------------------------------
  // Get FCM Token and save to user's profile
  Future<void> _getFCMToken() async {
    try {
      if (kIsWeb) {
        // For web, you need to provide your VAPID key from Firebase Console
        _fcmToken = await _firebaseMessaging.getToken(
          vapidKey: 'zLTrzAIC09nvz6vsX6qOQ3sndeOFd6ugKXRcmLDdG04',
        );
      } else {
        _fcmToken = await _firebaseMessaging.getToken();
      }
      
      if (_fcmToken != null && _userId != null) {
        // Save FCM token to user's AppUser profile
        await _firestore.collection('AppUsers').doc(_userId).update({
          'fcmToken': _fcmToken,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('FCM Token saved to user profile: $_fcmToken');
      } else {
        print('FCM Token: $_fcmToken (User ID: $_userId)');
      }
      notifyListeners();
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  //------------------------------------------------------
  // Initialize messaging listeners
  void initializeListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      // Handle the message (show notification, update UI, etc.)
    });

    // Handle when user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.notification?.title}');
      // Navigate to specific screen based on message data
    });
  }
}