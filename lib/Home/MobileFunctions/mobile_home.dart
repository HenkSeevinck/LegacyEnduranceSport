import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/GeneralFunctions/activity_carousel.dart';
import 'package:legacyendurancesport/Home/GeneralFunctions/notification_media.dart';
import 'package:legacyendurancesport/Home/GeneralFunctions/weekdays_table.dart';
import 'package:provider/provider.dart';

// Simple view state used by coach users to switch screens
enum LandingView { landing, athleteGrid, coachGrid }

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  static const double _iconSize = 150;
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
                  padding: EdgeInsets.only(
                    top: 10.0,
                    left: index % 2 == 0 ? 0.0 : 5.0,
                    right: index % 2 == 0 ? 5.0 : 0.0,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          options[index]['image'],
                          width: _iconSize,
                          height: _iconSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              options[index]['icon'],
                              size: _iconSize,
                              color: localAppTheme['anchorColors']['primaryColor'],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 150,
                        height: 40,
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: localAppTheme['anchorColors']['secondaryColor'].withOpacity(0.7),
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
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'BACK',
            icon: const Icon(Icons.arrow_back),
            color: localAppTheme['anchorColors']['secondaryColor'],
            onPressed: () {
              internalStatusProvider.sethomePageSelectedOption(null);
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
              header2(header: 'COACH:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
            ],
          ),
          backgroundColor: localAppTheme['anchorColors']['primaryColor'],
          elevation: 0,
          actions: [
            SizedBox(
              width: 60,
                child: IconButton(
                tooltip: 'NOTIFICATIONS',
                icon: const Icon(Icons.notifications),
                color: localAppTheme['anchorColors']['secondaryColor'],
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const NotificationMedia(),
                  );
                },
              ),
            ),
          ],
        ),
        Expanded(child: _buildSectionGrid(context: context, options: coachOptions, userUid: userUid)),
      ],
    );
  }

  //------------------------------------------------------------------------------
  //Athlete Section
  Widget _athleteSection(BuildContext context, List<Map<String, dynamic>> athleteOptions, String userUid, bool isCoach) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

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
                    internalStatusProvider.sethomePageSelectedOption(null);
                    setState(() {
                      _view = LandingView.landing;
                    });
                  },
                )
              : null,
          actions: [
            SizedBox(
              width: 60,
              child: IconButton(
                tooltip: 'NOTIFICATIONS',
                icon: const Icon(Icons.notifications),
                color: localAppTheme['anchorColors']['secondaryColor'],
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const NotificationMedia(),
                  );
                },
              ),
            ),
          ],
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person, 
                color: localAppTheme['anchorColors']['secondaryColor'],
                ),
              const SizedBox(width: 10),
              header2(header: 'ATHLETE:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
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
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'images/AthleteArea.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 150,
                          color: localAppTheme['anchorColors']['primaryColor'],
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 40,
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: localAppTheme['anchorColors']['secondaryColor'].withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                    ),
                    child: Center(
                      child: header2(header: 'ATHLETE SECTION', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onCoachTap,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'images/CoachArea.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 150,
                          color: localAppTheme['anchorColors']['primaryColor'],
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 40,
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: localAppTheme['anchorColors']['secondaryColor'].withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                    ),
                    child: Center(
                      child: header2(header: 'COACH SECTION', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

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
    final homePageSelectedOption = internalStatusProvider.homePageSelectedOption;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(
          context: context, 
          automaticallyImplyLeading: false, 
          onPressed: null, 
          isAdmin: isAdmin, 
          isModerator: isModerator,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              body(
                header: '© ${DateTime.now().year} Legacy Endurance Sport', 
                color: localAppTheme['anchorColors']['primaryColor'], 
                context: context
              ),
              body(
                header: appInfo['version'] != null ? 'v${appInfo['version']}' : '', 
                color: localAppTheme['anchorColors']['primaryColor'], 
                context: context
              ),
            ],
          ),
        ),
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
            ActivityCarousel(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                  ),
                ),
                child: isCoach
                    ? (homePageSelectedOption == 'Coach'
                        ? _coachSection(context, coachOptions, appUser['uid'])
                        : homePageSelectedOption == 'Athlete'
                            ? _athleteSection(context, athleteOptions, appUser['uid'], isCoach)
                            : Builder(
                                builder: (_) {
                                  switch (_view) {
                                    case LandingView.landing:
                                      return _coachLanding(
                                        context,
                                        onAthleteTap: () => setState(() {
                                          _view = LandingView.athleteGrid;
                                          internalStatusProvider.sethomePageSelectedOption('Athlete');
                                        }),
                                        onCoachTap: () => setState(() {
                                          _view = LandingView.coachGrid;
                                          internalStatusProvider.sethomePageSelectedOption('Coach');
                                        }),
                                      );
                                    case LandingView.athleteGrid:
                                      return _athleteSection(context, athleteOptions, appUser['uid'], isCoach);
                                    case LandingView.coachGrid:
                                      return _coachSection(context, coachOptions, appUser['uid']);
                                  }
                                },
                              ))
                    : _athleteSection(context, athleteOptions, appUser['uid'], isCoach),
              ),
            )
          ],
        ),
      ),
    );
  }
}
