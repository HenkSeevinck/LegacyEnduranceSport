import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/SignInSignUp/Page/signin_signup.dart';

class MobileLanding extends StatefulWidget {
  const MobileLanding({super.key});

  @override
  State<MobileLanding> createState() => _MobileLandingState();
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
// Mobile Layout
class _MobileLandingState extends State<MobileLanding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mobileAppBar(context),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: MediaQuery.of(context).size.height*2,
            child: const Center(
              child: Text('Landing Page - Mobile Layout Coming Soon'),
            ),
          );
        },
      ),
      // Center(
      //   child: Text('Landing Page - Mobile Layout Coming Soon')
      // ),
    );
  }
}