import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/MyAthletes/Page/my_athletes_page.dart';
import 'package:legacyendurancesport/Statistics/Functions/Yearly_statistics.dart';
import 'package:legacyendurancesport/Statistics/Functions/monthly_statistics.dart';
import 'package:legacyendurancesport/Statistics/Functions/weekly_statistics.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatefulWidget {
   final bool isCoachView;
  
  const StatisticsPage({super.key,
    required this.isCoachView,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Future<void>? _fetchDataFuture;
  late bool isCoachView = widget.isCoachView;
  late String? athleteUID;
  int _currentWorkoutTypeIndex = 0;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    //Add Providers you want to fetch data from here
    _fetchDataFuture = _fetchData(internalStatusProvider, appUserProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(InternalStatusProvider internalStatusProvider, AppUserProvider appUserProvider) async {
    if (isCoachView) {
      athleteUID = internalStatusProvider.userUIDToShow;
    } else {
      final appUser = appUserProvider.appUser;
      athleteUID = appUser['uid'];
    }
  }

  //----------------------------------------------------
  // Navigate to previous workout type
  void _prevWorkoutType() {
    setState(() {
      _currentWorkoutTypeIndex = (_currentWorkoutTypeIndex - 1).clamp(0, _currentWorkoutTypeIndex);
    });
  }

  //----------------------------------------------------
  // Navigate to next workout type
  void _nextWorkoutType() {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final workoutTypes = internalStatusProvider.workoutTypes;
    final maxIndex = workoutTypes.length - 1;
    setState(() {
      _currentWorkoutTypeIndex = (_currentWorkoutTypeIndex + 1).clamp(0, maxIndex);
    });
  }

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileStatisticsPage() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final workoutTypes = internalStatusProvider.workoutTypes;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final userProfileToShow = appUserProvider.userProfileToShow;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(
          context: context,
          automaticallyImplyLeading: true,
          onPressed: () {
            if (isCoachView) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyAthletesPage(),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomePage()
                ),
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageHeaderImage(
                  imagePath: 'images/Statistics.png', 
                  context: context, 
                  toolTip: '', 
                  userProfileToShow: userProfileToShow, 
                  pageTitle: 'STATISTICS',
                  isCoachView: widget.isCoachView,
                  buttonVisibility: false,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0),
                      bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(onPressed: _prevWorkoutType, icon: const Icon(Icons.chevron_left)),
                      Expanded(
                        child: Center(
                          child: body(
                            header: workoutTypes[_currentWorkoutTypeIndex]['workoutType'],
                            color: localAppTheme['anchorColors']['primaryColor'],
                            context: context,
                          ),
                        ),
                      ),
                      IconButton(onPressed: _nextWorkoutType, icon: const Icon(Icons.chevron_right)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0)),
                          ),
                          child: WeeklyStatistics(athleteUID: athleteUID!, workoutTypeID: workoutTypes[_currentWorkoutTypeIndex]['workoutTypeID']),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0)),
                          ),
                          child: MonthlyStatistics(athleteUID: athleteUID!, workoutTypeID: workoutTypes[_currentWorkoutTypeIndex]['workoutTypeID']),
                        ),
                        SizedBox(
                          child: YearlyStatistics(athleteUID: athleteUID!, workoutTypeID: workoutTypes[_currentWorkoutTypeIndex]['workoutTypeID']),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopStatisticsPage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackStatisticsPage() {
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
            return _buildMobileStatisticsPage();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopStatisticsPage();
          } else {
            return _buildFallbackStatisticsPage();
          }
        }
      },
    );
  }
}
