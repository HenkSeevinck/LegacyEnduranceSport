import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

class Roleselection extends StatelessWidget {
  const Roleselection({super.key});

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      internalStatusProvider.setUserRole('Coach');
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1)),
                          child: Image.asset('images/CoachingArea.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                        ),
                        Center(
                          child: Container(
                            color: Colors.white.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: customHeader(header: 'I AM A COACH', context: context, color: localAppTheme['anchorColors']['primaryColor'], fontWeight: FontWeight.bold, size: 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      internalStatusProvider.setUserRole('Athlete');
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1)),
                          child: Image.asset('images/AtheleteArea.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity, alignment: Alignment.center),
                        ),
                        Center(
                          child: Container(
                            color: Colors.white.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: customHeader(header: 'I AM AN ATHLETE', context: context, color: localAppTheme['anchorColors']['primaryColor'], fontWeight: FontWeight.bold, size: 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
