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
    
    // First, check current permission status
    final currentSettings = await _firebaseMessaging.getNotificationSettings();
    
    if (currentSettings.authorizationStatus == AuthorizationStatus.authorized ||
        currentSettings.authorizationStatus == AuthorizationStatus.provisional) {
      // Permission already granted, just get the token
      print('Notification permission already granted - retrieving token');
      await _getFCMToken();
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
        print('User granted web notification permission');
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
          vapidKey: 'BE9cG17QN3y2jHAVX7IwCTZph4veyinXo_Y9ncFQhexBUNFXEQoDm__WhNqXKPUW1laajjFiai24nR5V85xpzJU',
        );
      } else {
        _fcmToken = await _firebaseMessaging.getToken();
      }
      
      if (_fcmToken != null && _userId != null) {
        // First, check if this token already exists for the user
        final userDoc = await _firestore.collection('AppUsers').doc(_userId).get();
        final existingTokens = List<Map<String, dynamic>>.from(
          (userDoc.data()?['fcmTokens'] ?? []) as List
        );
        
        // Check if token already exists
        final tokenExists = existingTokens.any((t) => t['token'] == _fcmToken);
        
        if (!tokenExists) {
          // Token doesn't exist, add it
          await _firestore.collection('AppUsers').doc(_userId).update({
            'fcmTokens': FieldValue.arrayUnion([
              {
                'token': _fcmToken,
                'device': kIsWeb ? 'web' : 'mobile',
                'platform': _getPlatformName(),
                'addedAt': Timestamp.now(),
              }
            ]),
          });
          print('FCM Token saved to user profile: $_fcmToken (Platform: ${_getPlatformName()})');
        } else {
          // Token already exists, just log it
          print('FCM Token already exists for this device: $_fcmToken');
        }
      } else {
        print('FCM Token: $_fcmToken (User ID: $_userId)');
      }
      notifyListeners();
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  //------------------------------------------------------
  // Get platform name for identification
  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    // For native, you'd need to import dart:io and check
    return 'Mobile';
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