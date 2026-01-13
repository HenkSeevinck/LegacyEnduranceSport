import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legacyendurancesport/General/Providers/clubs_provided.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/workoutsprovider.dart';
import 'package:legacyendurancesport/Landing/Page/landing_page.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/firebase_options.dart';
import 'package:provider/provider.dart';

// Global navigator key (useful for navigation from outside widget tree)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- Add this
  // Prevent google_fonts from trying to read AssetManifest.json at runtime
  // (some build setups use AssetManifest.bin.json which older google_fonts
  // versions may not recognize). Disable runtime fetching so the app uses
  // platform fonts instead of attempting to load remote/bundled assets.
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<AppInfo>(create: (_) => AppInfo(appInfo)),
        ChangeNotifierProvider(create: (_) => InternalStatusProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (_) => AppUserProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create:  (_) => ClubsProvider()),
        ChangeNotifierProvider(create:  (_) => EventsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //------------------------------------------------------------
  // Determine platform and record it in InternalStatusProvider.
  // This is synchronous and safe to call from build().
  String _detectAndSetPlatform(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    String platform;

    if (kIsWeb) {
      // On web, use target platform to differentiate mobile web vs desktop web
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
        platform = 'MobileWeb';
      } else {
        platform = 'ComputerWeb';
      }
    } else {
      // Native platforms
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
    // Defer notifying the provider until after the current build frame
    // to avoid calling notifyListeners() during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      internalStatusProvider.setPlatform(platform);
    });
    return platform;
  }

  @override
  Widget build(BuildContext context) {
    _detectAndSetPlatform(context);
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      navigatorKey: navigatorKey,
      title: 'Legacy Endurance Sport',
      home: const LandingPage(),
    );
  }
}
