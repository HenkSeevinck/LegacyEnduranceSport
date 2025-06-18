import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/SignInSignUp/Functions/usersignin.dart';
import 'package:legacyendurancesport/SignInSignUp/Functions/usersignup.dart';
import 'package:provider/provider.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final signInsignUpStatus = internalStatusProvider.signInsignUpStatus;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(border: BoxBorder.all(color: localAppTheme['anchorColors']['primaryColor'])),
              child: Center(
                child: Image.asset('images/login-image.jpg', fit: BoxFit.cover, height: double.infinity, alignment: const Alignment(0.3, 0.5)),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Center(child: SizedBox(child: signInsignUpStatus == 'SignIn' ? UserSignIn() : UserSignUp())),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(),
              child: Image.asset('images/Legacy-Endurance-Logo.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
