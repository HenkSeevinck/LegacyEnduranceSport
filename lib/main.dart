import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/Home/Providers/macromesocycleprovider.dart';
import 'package:legacyendurancesport/ProfileSetup/Page/profilesetup.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/SignInSignUp/Page/signin_signup.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- Add this
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<AppInfo>(create: (_) => AppInfo(appInfo)),
        ChangeNotifierProvider(create: (_) => InternalStatusProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (_) => AppUserProvider()),
        ChangeNotifierProvider(create: (_) => AthleteKeyProvider()),
        ChangeNotifierProvider(create: (_) => MacroMesoCycleProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartScreen(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SigninPage();

    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final record = await appUserProvider.getUserRecord(user.uid);
    //print('User Record: $record');
    //print('User: $user');

    if (record?['userRole'] == null || (record?['userRole'] is List && (record?['userRole'] as List).isEmpty)) {
      // User record exists, but roles is empty, go to RoleSelection
      return const ProfileSetup();
    } else {
      // User record and roles exist, go to HomePage
      return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yearly Calendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<Widget>(
        future: _getStartScreen(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          // Fallback in case of error
          return const SigninPage();
        },
      ),
    );
  }
}
