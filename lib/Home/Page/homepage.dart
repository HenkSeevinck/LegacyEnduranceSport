import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/weekdays_table.dart';
import 'package:legacyendurancesport/General/Providers/clubs_provided.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showsearch = false;
  String? searchPhrase;
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    _fetchDataFuture = _fetchData(clubsProvider, eventsProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(ClubsProvider clubsProvider, EventsProvider eventsProvider) async {
    await clubsProvider.fetchAllClubs();
    await eventsProvider.fetchAllEvents();
  }

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileHomePage() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final homePageOptions = internalStatusProvider.homePageOptions;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final isCoach = appUser['isCoach'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
          top: true,
          child: Center(child: Image.asset('images/Legacy-Endurance-Logo.png', height: 70, width: 70, fit: BoxFit.cover)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                bottom: 10.0,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                  bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                ),
              ),
              child: WeekDaysTable(athleteUID: appUser['uid'], navPath: 'HomePage'),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemCount = isCoach ? homePageOptions.length : homePageOptions.where((option) => option['coachOnly'] == false).length;
                  final availableHeight = constraints.maxHeight;
                  final availableWidth = constraints.maxWidth;
                  final itemHeight = itemCount > 0 ? availableHeight / itemCount : availableHeight;
                  final coachOptions = homePageOptions.where((option) => option['coachOnly'] == true).toList();
                  //final coachOptionCount = coachOptions.length;
                  final athleteOptions = homePageOptions.where((option) => option['coachOnly'] == false).toList();
                  //final athleteOptionCount = athleteOptions.length;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        //All Users Options
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: availableWidth / ((itemHeight * 4) - 34)),
                          itemCount: athleteOptions.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                internalStatusProvider.setUserUIDToShow(appUser['uid']);
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => athleteOptions[index]['navigateTo']));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                    left: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0 * (index % 2 == 1 ? 1.0 : 0.0)),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Icon(
                                        athleteOptions[index]['icon'],
                                        color: localAppTheme['anchorColors']['primaryColor'],
                                        size: double.parse((itemHeight * 0.4).toStringAsFixed(0)),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        width: 150,
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                        decoration: BoxDecoration(
                                          color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                                        ),
                                        child: Center(
                                          child: header2(
                                            header: athleteOptions[index]['pageName'],
                                            color: localAppTheme['anchorColors']['primaryColor'],
                                            context: context,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),                       
                        //Coach Only Options
                        if(isCoach)
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1),
                                border: Border(
                                  bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                ),
                              ),
                              height: 50,
                              child: header2(
                                header: 'Coach Options:', 
                                context: context, 
                                color: localAppTheme['anchorColors']['primaryColor'],
                                ),
                            ),
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: availableWidth / ((itemHeight * 4) - 34)),
                              itemCount: coachOptions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    internalStatusProvider.setUserUIDToShow(appUser['uid']);
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => coachOptions[index]['navigateTo']));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0 * (index % 2 == 1 ? 1.0 : 0.0)),
                                        bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Icon(
                                            coachOptions[index]['icon'],
                                            color: localAppTheme['anchorColors']['primaryColor'],
                                            size: double.parse((itemHeight * 0.4).toStringAsFixed(0)),
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: 150,
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8.0),
                                              border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                                            ),
                                            child: Center(
                                              child: header2(
                                                header: coachOptions[index]['pageName'],
                                                color: localAppTheme['anchorColors']['primaryColor'],
                                                context: context,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            appUser['isAdmin'] || appUser['isModerator']
                ? Column(
                  children: [
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Visibility(
                          visible: appUser['isAdmin'] ?? false,
                          child: Expanded(
                            child: elevatedButton(
                              label: 'Activate Admin', 
                              onPressed: (){}, 
                              backgroundColor: localAppTheme['anchorColors']['primaryColor'], 
                              labelColor: localAppTheme['anchorColors']['secondaryColor'], 
                              leadingIcon: null, 
                              trailingIcon: null, 
                              context: context,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: appUser['isModerator'] ?? false,
                          child: Expanded(
                            child: elevatedButton(
                              label: 'Activate Moderator', 
                              onPressed: (){}, 
                              backgroundColor: localAppTheme['anchorColors']['primaryColor'], 
                              labelColor: localAppTheme['anchorColors']['secondaryColor'], 
                              leadingIcon: null, 
                              trailingIcon: null, 
                              context: context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopHomePage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackHomePage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Fallback Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Build method with FutureBuilder
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        final localAppTheme = ResponsiveTheme(context).theme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          );
        } else {
          final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
          final platform = internalStatusProvider.platform;

          if (platform == 'MobileWeb' || platform == 'Mobile') {
            return _buildMobileHomePage();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopHomePage();
          } else {
            return _buildFallbackHomePage();
          }
        }
      },
    );
  }
}
