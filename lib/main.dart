import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for session check
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legacyendurancesport/General/Providers/firebase_messaging_service.dart';
import 'package:legacyendurancesport/General/Providers/notification_provider.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legacyendurancesport/General/Providers/ai_provider.dart';
import 'package:legacyendurancesport/General/Providers/clubs_provided.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/image_verification_provider.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'package:legacyendurancesport/Landing/Page/landing_page.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/firebase_options.dart';
import 'package:provider/provider.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set Firebase persistence for Web
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AppInfo>(create: (_) => AppInfo(appInfo)),
        ChangeNotifierProvider(create: (_) => InternalStatusProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (_) => AppUserProvider()),
        ChangeNotifierProvider(create: (_) => ClubsProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutsProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => ImageVerificationProvider()),
        ChangeNotifierProvider(create:  (_) => FirebaseMessagingService()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Keep your existing _detectAndSetPlatform logic...
  String _detectAndSetPlatform(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    String platform;
    if (kIsWeb) {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
        platform = 'MobileWeb';
      } else {
        platform = 'ComputerWeb';
      }
    } else {
      platform = 'Unknown';
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.fuchsia:
          platform = 'Mobile';
          break;
        case TargetPlatform.macOS:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          platform = 'Computer';
          break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      internalStatusProvider.setPlatform(platform);
    });
    return platform;
  }

  /// Logic to check if the session is still valid
  Future<bool> _isSessionValid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final startTimeStr = prefs.getString('auth_session_start');

    if (startTimeStr == null) return false;

    final startTime = DateTime.parse(startTimeStr);
    final expiryTime = startTime.add(const Duration(days: 14));

    if (DateTime.now().isAfter(expiryTime)) {
      await FirebaseAuth.instance.signOut();
      await prefs.remove('auth_session_start');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _detectAndSetPlatform(context);
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          surface: Colors.white,
        ),
      ),
      navigatorKey: navigatorKey,
      title: 'Legacy Endurance Sport',
      home: FutureBuilder<bool>(
        future: _isSessionValid(),
        builder: (context, snapshot) {
          // While checking storage, show a loader
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // If session is valid, go Home. Otherwise, go to LandingPage (Login)
          if (snapshot.data == true) {
            return const HomePage();
          } else {
            return const LandingPage();
          }
        },
      ),
    );
  }
}
