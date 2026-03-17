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
  Future<void> requestPermission(String userId, String platform) async {
    _userId = userId;
    
    // First, check current permission status
    final currentSettings = await _firebaseMessaging.getNotificationSettings();
    
    if (currentSettings.authorizationStatus == AuthorizationStatus.authorized ||
        currentSettings.authorizationStatus == AuthorizationStatus.provisional) {
      // Permission already granted, just get the token
      //print('Notification permission already granted - retrieving token');
      await _getFCMToken(platform);
      return;
    }
    
    // Permission not yet determined, request it
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
        //print('User granted web notification permission');
        await _getFCMToken(platform);
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        //('User granted provisional web notification permission');
        await _getFCMToken(platform);
      } else {
        //print('User declined or has not accepted web notification permission');
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
        //print('User granted notification permission');
        await _getFCMToken(platform);
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        //print('User granted provisional notification permission');
        await _getFCMToken(platform);
      } else {
        //print('User declined or has not accepted notification permission');
      }
    }
  }

  //------------------------------------------------------
  // Get FCM Token and save to user's profile
  Future<void> _getFCMToken(String platform) async {
    try {
      if (kIsWeb) {
        // For web, you need to provide your VAPID key from Firebase Console
        _fcmToken = await _firebaseMessaging.getToken(
          vapidKey: 'BE9cG17QN3y2jHAVX7IwCTZph4veyinXo_Y9ncFQhexBUNFXEQoDm__WhNqXKPUW1laajjFiai24nR5V85xpzJU',
        );
      } else {
        _fcmToken = await _firebaseMessaging.getToken();
      }

      if (_fcmToken != null && _userId != null) {
        final userDocRef = _firestore.collection('AppUsers').doc(_userId);

        // **THIS IS THE CHANGE**
        // Clear existing tokens and set the new one
        await userDocRef.update({
          'fcmTokens': [ // Replace the entire array with a new array containing only the current token
            {
              'token': _fcmToken,
              'device': kIsWeb ? 'web' : 'mobile',
              'platform': platform,
              'addedAt': Timestamp.now(),
            }
          ],
        });

        //print('FCM Token saved to user profile: $_fcmToken (Platform: $platform)');
      } else {
        //print('FCM Token: $_fcmToken (User ID: $_userId)');
      }
      notifyListeners();
    } catch (e) {
      //print('Error getting FCM token: $e');
    }
  }

  //------------------------------------------------------
  // Initialize messaging listeners
  void initializeListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //print('Received foreground message: ${message.notification?.title}');
      // Handle the message (show notification, update UI, etc.)
    });

    // Handle when user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      //print('Notification tapped: ${message.notification?.title}');
      // Navigate to specific screen based on message data
    });
  }
}