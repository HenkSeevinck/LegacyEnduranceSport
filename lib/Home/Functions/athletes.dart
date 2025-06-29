import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/Home/Functions/longrangeplanbuilder.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/Home/Providers/macrocycleprovider.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class Athletes extends StatefulWidget {
  const Athletes({super.key});

  @override
  State<Athletes> createState() => _AthletesState();
}

class _AthletesState extends State<Athletes> {
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final athleteKeyProvider = Provider.of<AthleteKeyProvider>(context, listen: false);
    _fetchDataFuture = fetchAppStartupInformation(appUserProvider, athleteKeyProvider);
  }

  Future<void> fetchAppStartupInformation(AppUserProvider appUserProvider, AthleteKeyProvider athleteKeyProvider) async {
    final appUser = appUserProvider.appUser;
    await athleteKeyProvider.getAthleteKeys(appUser['uid']);
    // Remove or uncomment other startup calls as needed
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final macroCycleProvider = Provider.of<MacroCycleProvider>(context, listen: true);

    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          );
        } else {
          final athleteKeyProvider = Provider.of<AthleteKeyProvider>(context, listen: true);
          final athletes = athleteKeyProvider.athletes;
          final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemCount: athletes.length,
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage(athletes[index]['athleteImage'] ?? 'images/UserPlaceHolder.png'), fit: BoxFit.cover),
                              border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: localAppTheme['anchorColors']['secondaryColor'],
                              border: const Border(bottom: BorderSide(), left: BorderSide(), right: BorderSide()),
                            ),
                            child: Visibility(
                              visible: athletes[index]['athleteUID'] != null,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () async {
                                        try {
                                          await athleteKeyProvider.setSelectedAthlete(athletes[index]['athleteUID']);
                                        } catch (e) {
                                          snackbar(context: context, header: 'Error: $e');
                                        }
                                      },
                                      tooltip: 'Athlete Profile',
                                      icon: Icon(Icons.person, size: MediaQuery.of(context).size.width * 0.02, color: localAppTheme['anchorColors']['primaryColor']),
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () async {
                                        try {
                                          macroCycleProvider.clearSelectedMacroCycle();
                                          await athleteKeyProvider.setSelectedAthlete(athletes[index]['athleteUID']);
                                          internalStatusProvider.setHomeMainContent(const LongRangePlanBuilder());
                                        } catch (e) {
                                          snackbar(context: context, header: 'Error: $e');
                                        }
                                      },
                                      tooltip: 'Macrocycles & Mesocycles Planning',
                                      icon: Icon(Icons.timeline, size: MediaQuery.of(context).size.width * 0.02, color: localAppTheme['anchorColors']['primaryColor']),
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () async {
                                        try {
                                          await athleteKeyProvider.setSelectedAthlete(athletes[index]['athleteUID']);
                                        } catch (e) {
                                          snackbar(context: context, header: 'Error: $e');
                                        }
                                      },
                                      tooltip: 'Microcycle Planning',
                                      icon: Icon(Icons.event_note, size: MediaQuery.of(context).size.width * 0.02, color: localAppTheme['anchorColors']['primaryColor']),
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () async {
                                        try {
                                          await athleteKeyProvider.setSelectedAthlete(athletes[index]['athleteUID']);
                                        } catch (e) {
                                          snackbar(context: context, header: 'Error: $e');
                                        }
                                      },
                                      tooltip: 'Athlete Notes',
                                      icon: Icon(Icons.note_alt_outlined, size: MediaQuery.of(context).size.width * 0.02, color: localAppTheme['anchorColors']['primaryColor']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: athletes[index]['athleteUID'] == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                header1(header: 'UNCLAIMED', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                                SizedBox(height: 10),
                                header3(header: 'Email: ${athletes[index]['athleteEmail']}', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                                SizedBox(height: 5),
                                header3(header: 'Key: ${athletes[index]['athleteKey']}', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                                SizedBox(height: 5),
                                header3(header: 'Key Expiry: ${DateFormat('dd-MMM-yyyy').format(athletes[index]['keyExpirationDate'].toDate())}', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                header2(header: '${athletes[index]['name']} ${athletes[index]['surname']}', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                                SizedBox(height: 10),
                                header3(header: 'Key Expiry: ${DateFormat('dd-MMM-yyyy').format(athletes[index]['keyExpirationDate'].toDate())}', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }
}
