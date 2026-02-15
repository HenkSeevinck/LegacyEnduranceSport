import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Goals/Page/goals_page.dart';
import 'package:legacyendurancesport/Home/GeneralFunctions/weekdays_table.dart';
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                pageHeaderImage(
                  imagePath: 'images/Athletes.png', 
                  context: context, 
                  toolTip: 'ADD ATHLETE', 
                  userProfileToShow: {}, 
                  pageTitle: 'MY ATHLETES',
                  isCoachView: false,
                  buttonVisibility: true,
                  showCreateGoalPopupDialog: () {
                    _showAthleteSelectionPopupDialog(context);
                  },
                ),
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
                                            child: imageButtonWithHeader(
                                              width: double.infinity, 
                                              height: 60, 
                                              onPressed: () async {
                                                await _navigateToUserProfilePage(athlete['uid']);
                                              }, 
                                              toolTip: 'VIEW PROFILE', 
                                              imagePath: 'images/Profile.png', 
                                              context: context, 
                                              headerText: 'PROFILE'
                                              ),
                                          ),
                                          Expanded(
                                            child: imageButtonWithHeader(
                                              width: double.infinity, 
                                              height: 60, 
                                              onPressed: () async {
                                                await _navigateToAthleteGoalsPage(athlete['uid']);
                                              }, 
                                              toolTip: 'VIEW GOALS', 
                                              imagePath: 'images/Goals.png', 
                                              context: context, 
                                              headerText: 'GOALS'
                                              ), 
                                          ),
                                          Expanded(
                                            child: imageButtonWithHeader(
                                              width: double.infinity, 
                                              height: 60, 
                                              onPressed: () async {
                                                await _navigateToAthleteStatisticsPage(athlete['uid']);
                                              }, 
                                              toolTip: 'VIEW STATISTICS', 
                                              imagePath: 'images/Statistics.png', 
                                              context: context, 
                                              headerText: 'STATS'
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
      ),
    );
  }
}