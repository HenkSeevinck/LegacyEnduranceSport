import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/General/Providers/firebase_messaging_service.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Mobile%20Functions/mobile_home.dart';
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
  final sharedPreferences = SharedPreferences.getInstance();
    
  _fetchDataFuture = _fetchData(clubsProvider, eventsProvider, appUserProvider, messagingService, sharedPreferences);
}

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(
    ClubsProvider clubsProvider, 
    EventsProvider eventsProvider, 
    AppUserProvider appUserProvider,
    FirebaseMessagingService messagingService,
    Future<SharedPreferences> sharedPreferences
    ) async {
    await clubsProvider.fetchAllClubs();
    await eventsProvider.fetchAllEvents();
    final appUser = appUserProvider.appUser;
    final prefs = await sharedPreferences;
    final startTimeStr = prefs.getString('auth_session_start');
    final expiryDate = startTimeStr != null ? DateTime.parse(startTimeStr).add(const Duration(days: 14)) : null;

    if (appUser.isEmpty) {
      await appUserProvider.getUserRecord(FirebaseAuthService().currentUser?.uid ?? ''); 
    }

    // Check for 14-day session expiry
    if (startTimeStr != null && expiryDate != null) {
      if (DateTime.now().isAfter(expiryDate)) {
      
        // Sign out of Firebase
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

    // Initialize notification listeners and request permission (for PWA and mobile)
    if (kIsWeb || true) { // Request for all platforms
      messagingService.initializeListeners();
      
      // Check if user has already been asked for notifications
      final hasAskedForNotifications = prefs.getBool('notifications_requested') ?? false;
      
      if (!hasAskedForNotifications) {
        // Request notification permission and pass user ID to save token
        final userId = appUser['uid'] ?? FirebaseAuthService().currentUser?.uid;
        if (userId != null) {
          await messagingService.requestPermission(userId);
          // Mark that we've asked
          await prefs.setBool('notifications_requested', true);
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
