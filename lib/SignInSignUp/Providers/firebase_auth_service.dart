import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';

class FirebaseAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  User? get user => _user;

  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password, context) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = credential.user;
      notifyListeners();
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

  // Sign up with email and password
  Future<UserCredential?> signUp(String email, String password, context) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = credential.user;
      notifyListeners();
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

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
