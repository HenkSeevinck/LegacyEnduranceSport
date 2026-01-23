import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/SignInSignUp/Functions/resetpassword.dart';
import 'package:legacyendurancesport/SignInSignUp/Functions/usersignin.dart';
import 'package:legacyendurancesport/SignInSignUp/Functions/usersignup.dart';
import 'package:provider/provider.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileLayout() {
    //final localAppTheme = ResponsiveTheme(context).theme;
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
                  ? UserSignUp(width: 0.8, height: 0.4) 
                  : ResetPassword(width: 0.8, height: 0.27),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopLayout() {
    return Scaffold(body: const Center(child: Text('Desktop Layout Coming Soon')));
  }

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
      return _buildMobileLayout();
    } else if (platform == 'ComputerWeb' || platform == 'Computer') {
      return _buildDesktopLayout();
    } else {
      return _buildFallbackLayout();
    }
  }
}
