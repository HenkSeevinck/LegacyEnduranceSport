import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/weekdays_table.dart';
import 'package:provider/provider.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  //------------------------------------------------------------------------------
  //Admin Section
  Widget _adminSection(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    return ExpansionTile(
      collapsedShape: Border(
        bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.admin_panel_settings, color: localAppTheme['anchorColors']['primaryColor']),
          SizedBox(width: 10),
          header2(header: 'Admin / Moderator', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ],
      ),
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
            ),
          ),
          child: Row(
            children: [
              Visibility(
                visible: appUser['isAdmin'] ?? false,
                child: Expanded(
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
              ),
              Visibility(
                visible: appUser['isModerator'] ?? false,
                child: Expanded(
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  //------------------------------------------------------------------------------
  //Coach Section
  Widget _coachSection(BuildContext context, availableWidth, itemHeight) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final homePageOptions = internalStatusProvider.homePageOptions;
    final coachOptions = homePageOptions.where((option) => option['coachOnly'] == true).toList();
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;

    // Calculate a reasonable item height for coach section if itemHeight is 0
    final calculatedItemHeight = itemHeight > 0 ? itemHeight : 120.0;

    return ExpansionTile(
      collapsedShape: Border(
        bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.co_present, color: localAppTheme['anchorColors']['primaryColor']),
          SizedBox(width: 10),
          header2(header: 'Coach', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ],
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
            ),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: availableWidth / ((calculatedItemHeight * 4) - 34)),
            itemCount: coachOptions.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  internalStatusProvider.setUserUIDToShow(appUser['uid']);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => coachOptions[index]['navigateTo']));
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Icon(
                          coachOptions[index]['icon'],
                          color: localAppTheme['anchorColors']['primaryColor'],
                          size: double.parse((calculatedItemHeight * 0.4).toStringAsFixed(0)),
                        ),
                      ),
                      SizedBox(height: 10),
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
                            child: header2(header: coachOptions[index]['pageName'], color: localAppTheme['anchorColors']['primaryColor'], context: context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //------------------------------------------------------------------------------
  //Athlete Section
  Widget _athleteSection(BuildContext context, availableWidth, itemHeight) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final homePageOptions = internalStatusProvider.homePageOptions;
    final athleteOptions = homePageOptions.where((option) => option['coachOnly'] == false).toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: availableWidth / (itemHeight * 4)),
      itemCount: athleteOptions.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            internalStatusProvider.setUserUIDToShow(appUser['uid']);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => athleteOptions[index]['navigateTo']));
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
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
                SizedBox(height: 10),
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
                      child: header2(header: athleteOptions[index]['pageName'], color: localAppTheme['anchorColors']['primaryColor'], context: context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    final isCoach = appUser['isCoach'] ?? false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: appheader(
          context: context, 
          automaticallyImplyLeading: false
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 10.0),
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
                  final athleteOptions = homePageOptions.where((option) => option['coachOnly'] == false).toList();
                  final itemCount = athleteOptions.length;
                  final availableHeight = constraints.maxHeight;
                  final availableWidth = constraints.maxWidth;
                  final itemHeight = itemCount > 0 ? availableHeight / itemCount : availableHeight;

                  return _athleteSection(context, availableWidth, itemHeight);
                },
              ),
            ),
            //Coach Section
            if (isCoach)
              _coachSection(context, MediaQuery.of(context).size.width - 20, 90),
            //Admin Section
            appUser['isAdmin'] || appUser['isModerator'] 
            ? _adminSection(context) 
            : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
