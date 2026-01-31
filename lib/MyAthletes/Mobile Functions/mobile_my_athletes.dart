import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Goals/Page/goals_page.dart';
import 'package:legacyendurancesport/Home/General%20Functions/weekdays_table.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/MyAthletes/Mobile%20Functions/Sub%20Mobile%20Functions/athlete_selection_popup.dart';
import 'package:legacyendurancesport/Profile/Page/profile_page.dart';
import 'package:legacyendurancesport/Statistics/Page/statistics_page.dart';
import 'package:provider/provider.dart';

class MobileMyAthletes extends StatefulWidget {
  const MobileMyAthletes({super.key});

  @override
  State<MobileMyAthletes> createState() => _MobileMyAthletesState();
}

class _MobileMyAthletesState extends State<MobileMyAthletes> {
  bool isLoading = false;

  //----------------------------------------------------
  // Athlete Selection Popup Dialog
  Future<void> _showAthleteSelectionPopupDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AthleteSelectionPopup();
      },
    );
  }

  //-----------------------------------------------------
  // Navigate to user profile page
  Future<void> _navigateToUserProfilePage(String athleteUID) async {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    internalStatusProvider.setUserUIDToShow(athleteUID);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfile(
          isCoachView: true,
          formEditable: false,
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Navigate to athlete goals page
  Future<void> _navigateToAthleteGoalsPage(String athleteUID) async {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    internalStatusProvider.setUserUIDToShow(athleteUID);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoalsPage(
          isCoachView: true,
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Navigate to athlete statistics page
  Future<void> _navigateToAthleteStatisticsPage(String athleteUID) async {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    internalStatusProvider.setUserUIDToShow(athleteUID);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatisticsPage(
          isCoachView: true,
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Remove Athlete from Coach
  Future<void> _removeAthleteFromCoach(String coachDocID, String athleteUID) async {
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    try {
      setState(() {
        isLoading = true;
      });
      await appUserProvider.removeAthleteFromCoach(coachDocID, athleteUID);
      setState(() {
        isLoading = false;
      });
      showGeneralPopupDialog(context, 'Success!', 'Athlete removed successfully.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showGeneralPopupDialog(context, 'Error!', 'Failed to remove athlete.');
    }
  }

  //----------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(
          context: context, 
          automaticallyImplyLeading: true, 
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage()
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    header1(header: 'My Athletes:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                    iconButton(
                      label: null,
                      backgroundColor: null,
                      iconColor: localAppTheme['anchorColors']['primaryColor'],
                      icon: Icons.add,
                      size: 30,
                      toolTip: 'ADD ATHLETE',
                      onPressed: () {
                        _showAthleteSelectionPopupDialog(context);
                      },
                      context: context,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              appUser['athletes'] != null && (appUser['athletes'] as List).isNotEmpty
                  ? Column(
                      children: List<Widget>.generate((appUser['athletes'] as List).length, (index) {
                        final itemCount = (appUser['athletes'] as List).length;
                        final athlete = appUser['athletes'][index];

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: localAppTheme['anchorColors']['primaryColor'],
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                color: localAppTheme['anchorColors']['primaryColor'],
                                width: index == (itemCount - 1) ? 1.0 : 0.0,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: localAppTheme['anchorColors']['primaryColor'],
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    header2(
                                      //header: athlete['email'] ?? 'Unnamed Athlete', 
                                      header: '${athlete['name']} ${athlete['surname']}',
                                      color: localAppTheme['anchorColors']['primaryColor'], 
                                      context: context
                                    ),
                                    iconButton(
                                      label: null,
                                      backgroundColor: null,
                                      iconColor: localAppTheme['anchorColors']['primaryColor'],
                                      icon: Icons.delete,
                                      size: 20,
                                      toolTip: 'REMOVE ATHLETE',
                                      onPressed: () async{ 
                                        _removeAthleteFromCoach(appUser['coachDocID'], athlete['uid']);
                                      },
                                      context: context,
                                    ),
                                  ],
                                ),
                              ),
                              WeekDaysTable(
                                key: ValueKey(athlete['uid']),
                                athleteUID: athlete['uid'], 
                                navPath: 'MyAthletesPage'
                                ),
                              SizedBox(height: 10.0),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: localAppTheme['anchorColors']['primaryColor'],
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  color: localAppTheme['anchorColors']['primaryColor']!,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                            child: iconButton(
                                              label: 'PROFILE', 
                                              backgroundColor: null, 
                                              iconColor: localAppTheme['anchorColors']['primaryColor'], 
                                              icon: Icons.person, 
                                              size: 30, 
                                              toolTip: 'VIEW PROFILE', 
                                              onPressed: () async {
                                                await _navigateToUserProfilePage(athlete['uid']);
                                              },
                                              context: context, 
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: localAppTheme['anchorColors']['primaryColor']!,
                                                  width: 1.0,
                                                ),
                                                left: BorderSide(
                                                  color: localAppTheme['anchorColors']['primaryColor']!,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                            child: iconButton(
                                              label: 'GOALS', 
                                              backgroundColor: null, 
                                              iconColor: localAppTheme['anchorColors']['primaryColor'], 
                                              icon: Icons.flag_outlined, 
                                              size: 30, 
                                              toolTip: 'VIEW GOALS', 
                                              onPressed: () async {
                                                await _navigateToAthleteGoalsPage(athlete['uid']);
                                              },
                                              context: context, 
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: localAppTheme['anchorColors']['primaryColor']!,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                            child: iconButton(
                                              label: 'TRAINING PLAN', 
                                              backgroundColor: null, 
                                              iconColor: localAppTheme['anchorColors']['primaryColor'], 
                                              icon: Icons.bar_chart, 
                                              size: 30, 
                                              toolTip: 'VIEW TRAINING PLAN', 
                                              onPressed: () {
                                                _navigateToAthleteStatisticsPage(athlete['uid']);
                                              },
                                              context: context, 
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0),
                            ],
                          ),
                        );
                      }),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}