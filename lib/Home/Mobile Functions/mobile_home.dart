import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/General%20Functions/weekdays_table.dart';
import 'package:provider/provider.dart';

// Simple view state used by coach users to switch screens
enum LandingView { landing, athleteGrid, coachGrid }

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  static const double _iconSize = 48.0;
  LandingView _view = LandingView.landing;

  //------------------------------------------------------------------------------
  // Shared Grid Builder for Athlete and Coach Sections
  Widget _buildSectionGrid({required BuildContext context, required List<Map<String, dynamic>> options, required String userUid}) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        const crossAxisCount = 2;
        final tileWidth = width / crossAxisCount;
        final rowsNeeded = (options.length / crossAxisCount).ceil();
        final rowsToShow = rowsNeeded < 1 ? 1 : (rowsNeeded > 3 ? 3 : rowsNeeded);
        final tileHeight = height / rowsToShow;
        final aspectRatio = tileWidth / tileHeight;

        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: aspectRatio),
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  internalStatusProvider.setUserUIDToShow(userUid);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => options[index]['navigateTo']));
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(options[index]['icon'], color: localAppTheme['anchorColors']['primaryColor'], size: _iconSize),
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
                          child: header2(header: options[index]['pageName'], color: localAppTheme['anchorColors']['primaryColor'], context: context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  //------------------------------------------------------------------------------
  //Coach Section
  Widget _coachSection(BuildContext context, List<Map<String, dynamic>> coachOptions, String userUid) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'BACK',
            icon: const Icon(Icons.arrow_back),
            color: localAppTheme['anchorColors']['secondaryColor'],
            onPressed: () {
              setState(() {
                _view = LandingView.landing;
              });
            },
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: localAppTheme['anchorColors']['secondaryColor']),
              const SizedBox(width: 10),
              header2(header: 'ATHLETES:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
            ],
          ),
          backgroundColor: localAppTheme['anchorColors']['primaryColor'],
          elevation: 0,
        ),
        Expanded(child: _buildSectionGrid(context: context, options: coachOptions, userUid: userUid)),
      ],
    );
  }

  //------------------------------------------------------------------------------
  //Athlete Section
  Widget _athleteSection(BuildContext context, List<Map<String, dynamic>> athleteOptions, String userUid, bool isCoach) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          leading: isCoach
              ? IconButton(
                  tooltip: 'BACK',
                  icon: const Icon(Icons.arrow_back),
                  color: localAppTheme['anchorColors']['secondaryColor'],
                  onPressed: () {
                    setState(() {
                      _view = LandingView.landing;
                    });
                  },
                )
              : null,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: localAppTheme['anchorColors']['secondaryColor']),
              const SizedBox(width: 10),
              header2(header: 'ATHLETES:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
            ],
          ),
          backgroundColor: localAppTheme['anchorColors']['primaryColor'],
          elevation: 0,
        ),
        Expanded(child: _buildSectionGrid(context: context, options: athleteOptions, userUid: userUid))
      ],
    );
  }

  //------------------------------------------------------------------------------
  //Coach Landing
  Widget _coachLanding(BuildContext context, {required VoidCallback onAthleteTap, required VoidCallback onCoachTap}) {
    final localAppTheme = ResponsiveTheme(context).theme;
    //final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: InkWell(
            onTap: onAthleteTap,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: localAppTheme['anchorColors']['primaryColor'], size: 150),
                  const SizedBox(height: 10),
                  header2(header: 'ATHLETE SECTION', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: InkWell(
            onTap: onCoachTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
              ),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.co_present, color: localAppTheme['anchorColors']['primaryColor'], size: 150),
                  const SizedBox(height: 10),
                  header2(header: 'COACH SECTION', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // No initState logic that depends on inherited widgets; derive UI in build()

  //------------------------------------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final isCoach = appUser['isCoach'] == true;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final homePageOptions = internalStatusProvider.homePageOptions;
    final athleteOptions = homePageOptions.where((option) => option['coachOnly'] == false).toList();
    final coachOptions = homePageOptions.where((option) => option['coachOnly'] == true).toList();
    final isAdmin = appUser['isAdmin'];
    final isModerator = appUser['isModerator'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(context: context, automaticallyImplyLeading: false, onPressed: null, isAdmin: isAdmin, isModerator: isModerator),
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
              child: isCoach
                  ? Builder(
                      builder: (_) {
                        switch (_view) {
                          case LandingView.landing:
                            return _coachLanding(
                              context,
                              onAthleteTap: () => setState(() => _view = LandingView.athleteGrid),
                              onCoachTap: () => setState(() => _view = LandingView.coachGrid),
                            );
                          case LandingView.athleteGrid:
                            return _athleteSection(context, athleteOptions, appUser['uid'], isCoach);
                          case LandingView.coachGrid:
                            return _coachSection(context, coachOptions, appUser['uid']);
                        }
                      },
                    )
                  : _athleteSection(context, athleteOptions, appUser['uid'], isCoach),
            )
          ],
        ),
      ),
    );
  }
}
