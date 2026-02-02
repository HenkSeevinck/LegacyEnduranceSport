//----------------------------------------------------
// Signin function
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> signInUser(BuildContext context, AppUserProvider appUserProvider, String email, String password) async {
  try {
    final FirebaseAuthService authService = FirebaseAuthService();
    final userCredential = await authService.signIn(email, password, context);
    
    if (userCredential != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        
        // --- 14-DAY PERSISTENCE LOGIC START ---
        final prefs = await SharedPreferences.getInstance();
        // Record the current time as the start of the 14-day window
        await prefs.setString('auth_session_start', DateTime.now().toIso8601String());
        // --- 14-DAY PERSISTENCE LOGIC END ---

        await appUserProvider.getUserRecord(user.uid);
        
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
      } else {
        snackbar(context: context, header: 'User not found.');
      }
    }
  } catch (e) {
    snackbar(context: context, header: e.toString());
  }
}