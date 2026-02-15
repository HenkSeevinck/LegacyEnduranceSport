import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/SignInSignUp/GeneralFunctions/resetpassword.dart';
import 'package:legacyendurancesport/SignInSignUp/GeneralFunctions/usersignin_page.dart';
import 'package:legacyendurancesport/SignInSignUp/GeneralFunctions/usersignup_page.dart';
import 'package:provider/provider.dart';

class MobileSigninSignup extends StatefulWidget {
  const MobileSigninSignup({super.key});

  @override
  State<MobileSigninSignup> createState() => _MobileSigninSignupState();
}

class _MobileSigninSignupState extends State<MobileSigninSignup> {
  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final signInsignUpStatus = internalStatusProvider.signInsignUpStatus;

    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
          top: true,
          child: Center(
            child: Image.asset('images/Legacy-Endurance-Logo.png', 
              height: 70, 
              width: 70, 
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(),
              child: Center(
                child: SizedBox(
                  child: signInsignUpStatus == 'SignIn' 
                  ? UserSignIn(width: 0.8, height: 0.4) 
                  : signInsignUpStatus == 'SignUp' 
                  ? UserSignUp(width: 0.8, height: 0.8) 
                  : ResetPassword(width: 0.8, height: 0.27),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}