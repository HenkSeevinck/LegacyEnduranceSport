import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/General/Providers/firebase_messaging_service.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/MobileFunctions/mobile_home.dart';
import 'package:legacyendurancesport/General/Providers/clubs_provided.dart';
import 'package:legacyendurancesport/Landing/Page/landing_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
void initState() {
  super.initState();
  final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
  final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
  final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
  final messagingService = Provider.of<FirebaseMessagingService>(context, listen: false);
  final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
  final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
  final sharedPreferences = SharedPreferences.getInstance();
    
  _fetchDataFuture = _fetchData(clubsProvider, eventsProvider, appUserProvider, messagingService, sharedPreferences, internalStatusProvider, workoutsProvider);
}

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(
    ClubsProvider clubsProvider, 
    EventsProvider eventsProvider, 
    AppUserProvider appUserProvider,
    FirebaseMessagingService messagingService,
    Future<SharedPreferences> sharedPreferences,
    InternalStatusProvider internalStatusProvider,
    WorkoutsProvider workoutsProvider
    ) async {
    try {
      await clubsProvider.fetchAllClubs();
    } catch (e, s) {
      throw Exception('Error in fetchAllClubs: $e\n$s');
    }

    try {
      await eventsProvider.fetchAllEvents();
    } catch (e, s) {
      throw Exception('Error in fetchAllEvents: $e\n$s');
    }

    try {
      final appUser = appUserProvider.appUser;
      if (appUser.isEmpty) {
        await appUserProvider.getUserRecord(FirebaseAuthService().currentUser?.uid ?? '');
      }
    } catch (e, s) {
      throw Exception('Error during appUser access or getUserRecord: $e\n$s');
    }

    try {
      await _checkExpiryDateOfSession(sharedPreferences);
    } catch (e, s) {
      throw Exception('Error in _checkExpiryDateOfSession: $e\n$s');
    }

    try {
      await _initializeNotifications(appUserProvider, messagingService, sharedPreferences, internalStatusProvider);
    } catch (e, s) {
      throw Exception('Error in _initializeNotifications: $e\n$s');
    }

    try {
      await appUserProvider.getAllUserRecords();
    } catch (e, s) {
      throw Exception('Error in getAllUserRecords: $e\n$s');
    }

    try {
      await workoutsProvider.fetchCompletedWorkoutsForAllAthletesLast7Days(appUserProvider.allUsers);
    } catch (e, s) {
      throw Exception('Error in fetchCompletedWorkoutsForAllAthletesLast7Days: $e\n$s');
    }
  }

  //----------------------------------------------------
  // Initialize notification listeners and request permission (for PWA and mobile)
  Future<void> _initializeNotifications(
    AppUserProvider appUserProvider, 
    FirebaseMessagingService messagingService, 
    Future<SharedPreferences> sharedPreferences,
    InternalStatusProvider internalStatusProvider
    ) async {
    try {
      final appUser = appUserProvider.appUser;
      final prefs = await sharedPreferences;
      final platform = internalStatusProvider.platform;

      if (platform == null) {
        return;
      }

      if (kIsWeb || true) {
        messagingService.initializeListeners();
        
        final userId = appUser['uid'] ?? FirebaseAuthService().currentUser?.uid;
        if (userId != null) {
          // --- THE FINAL FIX ---
          // On iOS Web, the getNotificationSettings() call fails. We will skip it on that platform.
          if (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
            return;
          }

          final settings = await FirebaseMessaging.instance.getNotificationSettings();
          final hasAskedForNotifications = prefs.getBool('notifications_requested') ?? false;
          
          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            await messagingService.requestPermission(userId, platform);
          } else if (!hasAskedForNotifications) {
            await messagingService.requestPermission(userId, platform);
            await prefs.setBool('notifications_requested', true);
          }
        }
      }
    } catch (e, s) {
      throw Exception('A crash occurred inside _initializeNotifications: $e\n$s');
    }
  }

  //----------------------------------------------------
  // 14-day session check and platform detection logic moved to MyApp for better app flow control
  Future<void> _checkExpiryDateOfSession(Future<SharedPreferences> sharedPreferences) async {
    final prefs = await sharedPreferences;
    final startTimeStr = prefs.getString('auth_session_start');
    final expiryDate = startTimeStr != null ? DateTime.parse(startTimeStr).add(const Duration(days: 3)) : null;
    
    if (startTimeStr != null && expiryDate != null) {
      if (DateTime.now().isAfter(expiryDate)) {
      
        // Sign out of Firebase
        await prefs.clear();
        await FirebaseAuthService().forceLogout();
        
        // Navigate back to Landing/Login page
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false,
          );
        }
      }
    }
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopHomePage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackHomePage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Fallback Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Build method with FutureBuilder
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        final localAppTheme = ResponsiveTheme(context).theme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          );
        } else {
          final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
          final platform = internalStatusProvider.platform;

          if (platform == 'MobileWeb' || platform == 'Mobile') {
            return MobileHome();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopHomePage();
          } else {
            return _buildFallbackHomePage();
          }
        }
      },
    );
  }
}
