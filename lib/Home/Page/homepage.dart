import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/weekdays_table.dart';
import 'package:legacyendurancesport/Home/Providers/clubsprovided.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
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
    
    _fetchDataFuture = _fetchData(
      clubsProvider
    );
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(ClubsProvider clubsProvider) async {
    await clubsProvider.fetchAllClubs();
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
          child: Center(
            child: Image.asset('images/Legacy-Endurance-Logo.png', 
              height: 70, 
              width: 70, 
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ExpansionTile(
              collapsedShape: Border(
                top: BorderSide(
                  color: localAppTheme['anchorColors']['primaryColor'],
                  width: 1.0,
                ),
              ),
              showTrailingIcon: false,
              title:  WeekDaysTable(),
              children: [
              body(header: 'Select an option to navigate to that page.', color: localAppTheme['anchorColors']['primaryColor'], context: context),
              ]
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  //final itemCount = homePageOptions.length;
                  final itemCount = isCoach
                    ? homePageOptions.length
                    : homePageOptions.where((option) => option['coachOnly'] == false).length;
                  final availableHeight = constraints.maxHeight;
                  final availableWidth = constraints.maxWidth;
                  final itemHeight = itemCount > 0 ? availableHeight / itemCount : availableHeight;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: availableWidth / itemHeight,
                    ),
                    itemCount: isCoach
                      ? homePageOptions.length
                      : homePageOptions.where((option) => option['coachOnly'] == false).length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          internalStatusProvider.setUserUIDToShow(appUser['uid']);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => homePageOptions[index]['navigateTo'],
                              ),
                            );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              // Draw a top border for every tile (this creates the separators),
                              // and draw a bottom border only on the last tile to close the list.
                              top: BorderSide(
                                color: localAppTheme['anchorColors']['primaryColor'],
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                color: localAppTheme['anchorColors']['primaryColor'],
                                width: index == (itemCount - 1) ? 1.0 : 0.0,
                              ),
                            ),
                            //borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                  child: Icon(  
                                    homePageOptions[index]['icon'],
                                    color: localAppTheme['anchorColors']['primaryColor'],
                                    size: double.parse((itemHeight*0.4).toStringAsFixed(0)),
                                  ),
                                ),
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                                    ),
                                    child: header2(
                                      header: homePageOptions[index]['pageName'],
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
                  );
                },
              ),
            ),
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
