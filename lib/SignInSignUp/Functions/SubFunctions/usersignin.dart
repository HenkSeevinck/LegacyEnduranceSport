//----------------------------------------------------
// Signin function
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';

Future<void> signInUser(BuildContext context, AppUserProvider appUserProvider, String email, String password) async {
    try {
      //var _authService;
      final FirebaseAuthService authService = FirebaseAuthService();
      final userCredential = await authService.signIn(email, password, context);
      
      if (userCredential != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await appUserProvider.getUserRecord(user.uid);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          snackbar(context: context, header: 'User not found.');
        }
      }
    } catch (e) {
      snackbar(context: context, header: e.toString());
    }
  }