import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/weekdays_table.dart';
import 'package:provider/provider.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  // Constants for consistent sizing
  static const double _iconSize = 48.0;
  static const double _gridAspectRatio = 1.2;

  //------------------------------------------------------------------------------
  // Shared Grid Builder for Athlete and Coach Sections
  Widget _buildSectionGrid({
    required BuildContext context,
    required List<Map<String, dynamic>> options,
    required String userUid,
  }) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: _gridAspectRatio,
        ),
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              internalStatusProvider.setUserUIDToShow(userUid);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => options[index]['navigateTo']),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    options[index]['icon'],
                    color: localAppTheme['anchorColors']['primaryColor'],
                    size: _iconSize,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                    ),
                    child: Center(
                      child: header2(
                        header: options[index]['pageName'],
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //------------------------------------------------------------------------------
  //Admin Section
  Widget _adminSection(BuildContext context, Map<String, dynamic> appUser) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return ExpansionTile(
      collapsedShape: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.admin_panel_settings, color: localAppTheme['anchorColors']['primaryColor']),
          const SizedBox(width: 10),
          header2(header: 'Admin / Moderator', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
          ),
          child: Row(
            children: [
              if (appUser['isAdmin'] == true)
                Expanded(
                  child: elevatedButton(
                    label: 'Activate Admin',
                    onPressed: () {},
                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                    leadingIcon: null,
                    trailingIcon: null,
                    context: context,
                  ),
                ),
              if (appUser['isModerator'] == true)
                Expanded(
                  child: elevatedButton(
                    label: 'Activate Moderator',
                    onPressed: () {},
                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                    leadingIcon: null,
                    trailingIcon: null,
                    context: context,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  //------------------------------------------------------------------------------
  //Coach Section
  Widget _coachSection(BuildContext context, List<Map<String, dynamic>> coachOptions, String userUid) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return ExpansionTile(
      collapsedShape: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.co_present, color: localAppTheme['anchorColors']['primaryColor']),
          const SizedBox(width: 10),
          header2(header: 'Coach', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ],
      ),
      children: [
        _buildSectionGrid(
          context: context,
          options: coachOptions,
          userUid: userUid,
        ),
      ],
    );
  }

  //------------------------------------------------------------------------------
  //Athlete Section
  Widget _athleteSection(BuildContext context, List<Map<String, dynamic>> athleteOptions, String userUid) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return ExpansionTile(
      initiallyExpanded: true,
      collapsedShape: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.person, color: localAppTheme['anchorColors']['primaryColor']),
          const SizedBox(width: 10),
          header2(header: 'Athlete', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ],
      ),
      children: [
        _buildSectionGrid(
          context: context,
          options: athleteOptions,
          userUid: userUid,
        ),
      ],
    );
  }

  //------------------------------------------------------------------------------
  //Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final homePageOptions = internalStatusProvider.homePageOptions;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final isCoach = appUser['isCoach'] == true;
    final isAdmin = appUser['isAdmin'] == true;
    final isModerator = appUser['isModerator'] == true;

    // Pre-filter options
    final athleteOptions = homePageOptions.where((option) => option['coachOnly'] == false).toList();
    final coachOptions = homePageOptions.where((option) => option['coachOnly'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(context: context, automaticallyImplyLeading: false),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                  bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                ),
              ),
              child: WeekDaysTable(athleteUID: appUser['uid'], navPath: 'HomePage'),
            ),
            Expanded(
              child: Column(
                children: [
                  _athleteSection(context, athleteOptions, appUser['uid']),
                  if (isCoach) _coachSection(context, coachOptions, appUser['uid']),
                  if (isAdmin || isModerator) _adminSection(context, appUser),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
