import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  User? get user => _user;
  FirebaseAuth get _firebaseAuth => _auth;
  User? get currentUser => _auth.currentUser;

  //--------------------------------------------------------------
  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password, context) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = credential.user;
      notifyListeners();

      // Require email verification before allowing sign-in
      if (_user != null && !_user!.emailVerified) {
        await _auth.signOut();
        snackbar(context: context, header: 'Please verify your email. A verification link has been sent to ${_user!.email}.');
        return null;
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      snackbar(context: context, header: e.message.toString());
      return null;
    } on FirebaseException catch (e) {
      snackbar(context: context, header: e.message.toString());
      return null;
    } catch (e) {
      snackbar(context: context, header: e.toString());
      return null;
    }
  }

  //--------------------------------------------------------------
  // Sign up with email and password
  Future<UserCredential?> signUp(String email, String password, context) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = credential.user;
      notifyListeners();
      // Send email verification to the newly created user
      try {
        await _user?.sendEmailVerification();
        snackbar(context: context, header: 'Verification email sent to ${_user?.email}');
      } catch (e) {
        snackbar(context: context, header: 'Failed to send verification email: ${e.toString()}');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      snackbar(context: context, header: e.message.toString());
      return null;
    } on FirebaseException catch (e) {
      snackbar(context: context, header: e.message.toString());
      return null;
    } catch (e) {
      snackbar(context: context, header: e.toString());
      return null;
    }
  }

  //--------------------------------------------------------------
  // Resend verification email for the current user (if not verified)
  Future<void> resendVerificationEmail(context) async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        snackbar(context: context, header: 'Verification email resent to ${user.email}');
      } catch (e) {
        snackbar(context: context, header: e.toString());
      }
    } else {
      snackbar(context: context, header: 'No unverified user found.');
    }
  }

  //--------------------------------------------------------------
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --------------------------------------------------------------
  // Force logout and clear session data
  Future<void> forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_session_start');
    await _firebaseAuth.signOut(); 
    notifyListeners();
  }
}
