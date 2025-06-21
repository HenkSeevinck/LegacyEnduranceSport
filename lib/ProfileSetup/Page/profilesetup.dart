import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/ProfileSetup/Functions/athletekeyinsert.dart';
import 'package:legacyendurancesport/ProfileSetup/Functions/roleselection.dart';
import 'package:legacyendurancesport/ProfileSetup/Functions/athleteprofilesetup.dart';
import 'package:legacyendurancesport/ProfileSetup/Functions/coachprofilesetup.dart';
import 'package:provider/provider.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final userRole = internalStatusProvider.selectedUserRole;

    return Scaffold(
      body: Column(
        children: [
          pageHeader(context: context, topText: '', bottomText: ''),
          Expanded(
            child: Builder(
              builder: (context) {
                if (userRole == null) {
                  return Roleselection();
                } else if (userRole == 'Coach') {
                  return Coachprofilesetup();
                } else if (userRole == 'Athlete' && internalStatusProvider.athleteKey == null) {
                  return AthleteKeyInsert();
                } else if (userRole == 'Athlete' && internalStatusProvider.athleteKey != null) {
                  return Athleteprofilesetup();
                } else {
                  return Center(child: Text('Please select a role'));
                }
              },
            ),
          ),
          pageFooter(context: context, userRole: ''),
        ],
      ),
    );
  }
}
