import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Functions/sidebar_onHover.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/adminsidebar.dart';
import 'package:legacyendurancesport/Home/Functions/athletesidebar.dart';
import 'package:legacyendurancesport/Home/Functions/coachsidebar.dart';
import 'package:legacyendurancesport/SignInSignUp/Page/signin_signup.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/firebase_auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isExpanded = false;
  double _sidebarWidth = 50;

  void _updateSidebar(bool expanded, double width) {
    setState(() {
      _isExpanded = expanded;
      _sidebarWidth = width;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final firebaseAuthService = Provider.of<FirebaseAuthService>(context, listen: true);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);

    return Scaffold(
      body: MouseRegion(
        onHover: (details) => sidebarOnHover(details, _isExpanded, _updateSidebar),
        child: Column(
          children: [
            pageHeader(context: context, topText: "", bottomText: ""),
            Expanded(
              child: Row(
                children: [
                  // Expandable Sidebar
                  Container(
                    width: _sidebarWidth,
                    decoration: BoxDecoration(
                      color: localAppTheme['anchorColors']['primaryColor'],
                      border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                    ),
                    child: Column(
                      children: [
                        if (!_isExpanded)
                          const Center(child: Icon(Icons.menu, color: Colors.white))
                        else ...[
                          const SizedBox(height: 15),
                          body(header: 'MENU:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                          const SizedBox(height: 5),
                          Divider(color: localAppTheme['anchorColors']['secondaryColor']),
                          Visibility(visible: (appUser['userRole'] is List && appUser['userRole'].contains('Coach')), child: CoachSidebar()),
                          Visibility(visible: (appUser['userRole'] is List && appUser['userRole'].contains('Athlete')), child: AthleteSidebar()),
                          Visibility(visible: (appUser['userRole'] is List && appUser['userRole'].contains('Admin')), child: AdminSidebar()),
                          Expanded(child: SizedBox()),
                          Divider(color: localAppTheme['anchorColors']['secondaryColor']),
                          ListTile(
                            leading: Icon(Icons.settings, color: localAppTheme['anchorColors']['secondaryColor']),
                            title: Align(
                              alignment: Alignment.center,
                              child: body(header: 'SIGN OUT', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                            ),
                            onTap: () async {
                              try {
                                await firebaseAuthService.signOut();
                                appUserProvider.clearUserData();
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SigninPage()));
                              } catch (e) {
                                snackbar(context: context, header: e.toString());
                              }
                            },
                          ),
                          const SizedBox(height: 5),
                        ],
                      ],
                    ),
                  ),
                  // Main content area (replace with your actual content)
                  internalStatusProvider.homeMainContent != null
                      ? Expanded(child: internalStatusProvider.homeMainContent!)
                      : Expanded(
                          child: Container(
                            color: Colors.transparent,
                            // Add your main content here
                            child: Center(child: Text('Main Content Area')),
                          ),
                        ),
                ],
              ),
            ),
            pageFooter(context: context, userRole: ""),
          ],
        ),
      ),
    );
  }
}
