import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Landing/GeneralFunctions/web_iframe_web.dart';

class MobileLanding extends StatefulWidget {
  const MobileLanding({super.key});

  @override
  State<MobileLanding> createState() => _MobileLandingState();
}

//----------------------------------------------------
// Mobile Layout
class _MobileLandingState extends State<MobileLanding> {

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