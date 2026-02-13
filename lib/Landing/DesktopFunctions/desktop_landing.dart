import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Landing/GeneralFunctions/web_iframe_web.dart';
import 'package:legacyendurancesport/SignInSignUp/Page/signin_signup.dart';

class DesktopLanding extends StatefulWidget {
  const DesktopLanding({super.key});

  @override
  State<DesktopLanding> createState() => _DesktopLandingState();
}

//----------------------------------------------------
//Appbar with logo and login button
PreferredSizeWidget mobileAppBar(BuildContext context) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return AppBar(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 36, height: 36),
        Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(),
          child: Image.asset('images/Legacy-Endurance-Logo.png', height: 70, width: 70, fit: BoxFit.cover),
        ),
        iconButton(
          label: null,
          backgroundColor: null,
          iconColor: localAppTheme['anchorColors']['primaryColor'],
          icon: Icons.person,
          size: 30,
          toolTip: 'User Login',
          context: context,
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SigninPage()));
          },
        ),
      ],
    ),
  );
}

//----------------------------------------------------
// Desktop Layout
class _DesktopLandingState extends State<DesktopLanding> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    //---------------------------------------------------------------------------------
    // Scaffold with scrollable sections
    return Scaffold(
      appBar: mobileAppBar(context),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: WebIframe(url: 'https://www.legacyendurancesport.com'),
        ),
    );
  }
}