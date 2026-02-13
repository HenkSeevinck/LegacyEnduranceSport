import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Landing/GeneralFunctions/web_iframe_web.dart';

class DesktopLanding extends StatefulWidget {
  const DesktopLanding({super.key});

  @override
  State<DesktopLanding> createState() => _DesktopLandingState();
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
      appBar: landingPageAppBar(context),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: WebIframe(url: 'https://www.legacyendurancesport.com'),
        ),
    );
  }
}