import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Goals/Page/goals_page.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/Profile/Page/profile_page.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class MyAthletesPage extends StatefulWidget {
  const MyAthletesPage({super.key});

  @override
  State<MyAthletesPage> createState() => _MyAthletesPageState();
}

class _MyAthletesPageState extends State<MyAthletesPage> {
  bool showsearch = false;
  String? searchPrase;
  late Future<void>? _fetchDataFuture;
  bool isLoading = false;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(appUserProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(AppUserProvider appUserProvider) async {
    await appUserProvider.getAllUserRecords();
    // Additional data fetching logic can be added here in the future
  }

  //----------------------------------------------------
  // Athlete Selection Popup Dialog
  Future<void> _showAthleteSelectionPopupDialog(BuildContext context) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    final allUsers = appUserProvider.allUsers;
    Map<String, dynamic>? selectedAthlete;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
          title: header1(header: 'Select Athlete:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          content: SingleChildScrollView(
            child: SearchableDropdown(
              labelText: 'Search Athletes:',
              hint: 'Select Athlete',
              dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
              searchBoxVisable: true,
              dropDownList: allUsers,
              header: '',
              iconColor: localAppTheme['anchorColors']['primaryColor'],
              idField: 'uid',
              displayField: 'email',
              onChanged: (value) {
                setState(() {
                  selectedAthlete = value;
                });
              },
              isEnabled: true,
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: elevatedButton(
                    label: 'CANCEL',
                    onPressed: () {
                      selectedAthlete = null;
                      Navigator.of(context).pop();
                    },
                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                    leadingIcon: null,
                    trailingIcon: null,
                    context: context,
                  ),
                ),
                Expanded(
                  child: elevatedButton(
                    label: 'SUBMIT',
                    onPressed: () async {
                      if (selectedAthlete != null) {
                        try {
                          setState(() {
                            isLoading = true;
                          });
                          await appUserProvider.addAthleteToCoach(appUser['coachDocID'], selectedAthlete!['uid'], selectedAthlete!['email']);
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop();
                          showGeneralPopupDialog(context, 'Success!', 'Athlete added successfully.');
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop();
                          showGeneralPopupDialog(context, 'Error!', 'Failed to add athlete.');
                        }
                      }
                    },
                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                    leadingIcon: null,
                    trailingIcon: null,
                    context: context,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileMyAthletesPage() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SafeArea(
          top: true,
          child: Stack(
            children: [
              Center(child: Image.asset('images/Legacy-Endurance-Logo.png', height: 70, width: 70, fit: BoxFit.contain)),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: iconButton(
                  label: null,
                  backgroundColor: null,
                  iconColor: localAppTheme['anchorColors']['primaryColor'],
                  icon: Icons.arrow_back,
                  size: 30,
                  toolTip: 'BACK',
                  context: context,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
              ),
            ],
          ),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  body(
                                    header: athlete['email'] ?? 'Unnamed Athlete', 
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
                                      try {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await appUserProvider.removeAthleteFromCoach(appUser['coachDocID'], athlete['uid']);
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
                                    },
                                    context: context,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  iconButton(
                                    label: 'PROFILE', 
                                    backgroundColor: null, 
                                    iconColor: localAppTheme['anchorColors']['primaryColor'], 
                                    icon: Icons.person, 
                                    size: 30, 
                                    toolTip: 'VIEW PROFILE', 
                                    onPressed: () {
                                      internalStatusProvider.setUserUIDToShow(athlete['uid']);
                                      // Navigate to athlete profile page
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => UserProfile(
                                            isCoachView: true,
                                          ),
                                        ),
                                      );
                                    },
                                    context: context, 
                                  ),
                                  iconButton(
                                    label: 'GOALS', 
                                    backgroundColor: null, 
                                    iconColor: localAppTheme['anchorColors']['primaryColor'], 
                                    icon: Icons.flag_outlined, 
                                    size: 30, 
                                    toolTip: 'VIEW GOALS', 
                                    onPressed: () {
                                      internalStatusProvider.setUserUIDToShow(athlete['uid']);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => GoalsPage(
                                            isCoachView: true,
                                          ),
                                        ),
                                      );
                                    },
                                    context: context, 
                                  ),
                                  iconButton(
                                    label: 'TRAINING PLAN', 
                                    backgroundColor: null, 
                                    iconColor: localAppTheme['anchorColors']['primaryColor'], 
                                    icon: Icons.nordic_walking, 
                                    size: 30, 
                                    toolTip: 'VIEW TRAINING PLAN', 
                                    onPressed: () {},
                                    context: context, 
                                  ),
                                ],
                              )
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

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopMyAthletesPage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackMyAthletesPage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Fallback Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Build Method
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
            return _buildMobileMyAthletesPage();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopMyAthletesPage();
          } else {
            return _buildFallbackMyAthletesPage();
          }
        }
      },
    );
  }
}
