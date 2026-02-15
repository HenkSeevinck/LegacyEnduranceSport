import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/SignInSignUp/DesktopFunctions/desktop_signin_signup.dart';
import 'package:legacyendurancesport/SignInSignUp/MobileFunctions/mobile_signin_signup.dart';
import 'package:provider/provider.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackLayout() {
    return Scaffold(body: const Center(child: Text('Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final platform = internalStatusProvider.platform;

    if (platform == 'MobileWeb' || platform == 'Mobile') {
      return MobileSigninSignup();
    } else if (platform == 'ComputerWeb' || platform == 'Computer') {
      return DesktopSigninSignup();
    } else {
      return _buildFallbackLayout();
    }
  }
}
