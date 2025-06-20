import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/ProfileSetup/Functions/roleselection.dart';
import 'package:legacyendurancesport/ProfileSetup/Page/athleteprofilesetup.dart';
import 'package:legacyendurancesport/ProfileSetup/Page/coachprofilesetup.dart';
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
            child: userRole == null
                ? Roleselection()
                : userRole == 'Coach'
                ? Coachprofilesetup()
                : userRole == 'Athlete'
                ? Athleteprofilesetup()
                : Center(child: Text('Please select a role')),
          ),
          pageFooter(context: context, userRole: ''),
        ],
      ),
    );
  }
}
