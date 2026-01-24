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
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _clampDouble(double v, double lo, double hi) => (v.isFinite ? (v < lo ? lo : (v > hi ? hi : v)) : lo);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sectionHeight = size.height * 0.95;

    //---------------------------------------------------------------------------------
    // Build Hero Section with parallax logo and fading text
    Widget buildHero() {
      final localAppTheme = ResponsiveTheme(context).theme;
      final double clampedOffset = _clampDouble(_scrollOffset, 0.0, sectionHeight);
      final double logoTranslate = -(clampedOffset) * 0.25;
      double t = 1 - (_scrollOffset / 250);
      final double titleOpacity = _clampDouble(t, 0.0, 1.0);

      return SizedBox(
        height: sectionHeight,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, logoTranslate),
              child: Image.asset(
                'images/Legacy-Endurance-Logo.png',
                height: size.width * 0.8,
                width: size.width * 0.8,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 80,
              child: Opacity(
                opacity: titleOpacity,
                child: Column(
                  children: [
                    header1(header: 'Legacy Endurance Sport', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                    const SizedBox(height: 6),
                    header2(header: 'Move farther. Train smarter. Stay curious.', context: context, color: localAppTheme['anchorColors']['primaryColor'])
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    //---------------------------------------------------------------------------------
    // Allow custom section heights so cards/CTA can be closer vertically
    final List<double> sectionHeights = [
      sectionHeight, // hero
      sectionHeight * 0.55, // card 1
      sectionHeight * 0.55, // card 2 (smaller)
      sectionHeight, // CTA (full page height so previous card scrolls off and button centers)
    ];

    //-----------------------------------------------------------------------------
    // Total height of all sections
    final double totalHeight = sectionHeights.reduce((a, b) => a + b);

    //---------------------------------------------------------------------------------
    // Compute cumulative top position for each section
    double cumulativeTop(int idx) {
      double t = 0.0;
      for (int i = 0; i < idx; i++) t += sectionHeights[i];
      return t;
    }

    //---------------------------------------------------------------------------------
    // compute progress for a section based on distance of its center to viewport center
    double sectionProgress(int idx) {
      final double top = cumulativeTop(idx);
      final double h = sectionHeights[idx];
      final double sectionCenterY = top + h / 2;
      final double relativeCenterY = sectionCenterY - _scrollOffset; // relative to viewport top
      final double distanceToViewportCenter = (relativeCenterY - (size.height / 2)).abs();
      final double maxDist = h; // distance at which progress becomes 0
      double p = 1 - (distanceToViewportCenter / maxDist);
      return _clampDouble(p, 0.0, 1.0);
    }

    //---------------------------------------------------------------------------------
    // Build a card with animated entrance based on scroll
    Widget buildCard(int index, String title, String subtitle, IconData icon) {
      final localAppTheme = ResponsiveTheme(context).theme;
      final double progress = sectionProgress(index);
      // apply easing for smoother entrance and horizontal range so cards come fully on-screen
      final double eased = Curves.easeOut.transform(progress);
      final double sign = (index % 2 == 0) ? -1.0 : 1.0;
      final double translateX = sign * size.width * (1 - eased) * 0.9;
      final double opacity = eased;

      return Transform.translate(
        offset: Offset(translateX, 0),
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: sectionHeights[index] * 0.65,
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  CircleAvatar(backgroundColor: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1), radius: 34, child: Icon(icon, color: localAppTheme['anchorColors']['primaryColor'], size: 30)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        header2(header: title, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                        const SizedBox(height: 4),
                        header3(header: subtitle, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                ],
              ),
            ),
          ),
        ),
      );
    }

    //---------------------------------------------------------------------------------
    // Build Call to Action section
    Widget buildCTA() {
      final localAppTheme = ResponsiveTheme(context).theme;
      final double progress = sectionProgress(3);
      final double eased = Curves.easeOut.transform(progress);

      return Container(
        height: sectionHeights[3],
        alignment: Alignment.center,
        child: Opacity(
          opacity: eased,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ready to start?', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: 200,
                child: elevatedButton(
                  label: 'Sign Up Now', 
                  onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SigninPage())), 
                  backgroundColor: localAppTheme['anchorColors']['primaryColor'], 
                  labelColor: localAppTheme['anchorColors']['secondaryColor'], 
                  leadingIcon: Icons.fitness_center, 
                  trailingIcon: null, 
                  context: context,
                ),
              ),
              // ElevatedButton.icon(
              //   style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              //   onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SigninPage())),
              //   icon: const Icon(Icons.fitness_center),
              //   label: const Text('Dive In'),
              // ),
            ],
          ),
        ),
      );
    }

    //---------------------------------------------------------------------------------  
    // Helper to compute a positioned child using per-section heights
    Positioned positionedSection(int idx, Widget child) {
      final double top = cumulativeTop(idx);
      final double h = sectionHeights[idx];
      return Positioned(top: top, left: 0, right: 0, height: h, child: child);
    }

    //---------------------------------------------------------------------------------
    // Scaffold with scrollable sections
    return Scaffold(
      appBar: mobileAppBar(context),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            height: totalHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                positionedSection(0, buildHero()),
                positionedSection(1, buildCard(1, 'Guided Workouts', 'Plans tailored to your goals and time.', Icons.directions_run)),
                positionedSection(2, buildCard(2, 'Track Progress', 'Graphs and insights to keep you motivated.', Icons.show_chart)),
                positionedSection(3, buildCTA()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}