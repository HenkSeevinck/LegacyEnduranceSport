import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/ProfileSetup/Functions/athleteprofilesetup.dart';
import 'package:provider/provider.dart';

class AthleteSidebar extends StatefulWidget {
  const AthleteSidebar({super.key});

  @override
  State<AthleteSidebar> createState() => _AthleteSidebarState();
}

class _AthleteSidebarState extends State<AthleteSidebar> {
  late ExpansibleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpansibleController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (internalStatusProvider.homePageSidebar == 'AthleteSidebar') {
        _controller.expand();
      } else {
        _controller.collapse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final localAppTheme = ResponsiveTheme(context).theme;
    return ExpansionTile(
      controller: _controller,
      title: body(header: 'Athlete Menu', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
      initiallyExpanded: false,
      children: [
        ListTile(
          leading: Icon(Icons.home, color: localAppTheme['anchorColors']['secondaryColor']),
          title: Align(
            alignment: Alignment.centerLeft,
            child: body(header: 'Home', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.person, color: localAppTheme['anchorColors']['secondaryColor']),
          title: Align(
            alignment: Alignment.centerLeft,
            child: body(header: 'My Profile', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ),
          onTap: () {
            internalStatusProvider.setHomeMainContent(const Athleteprofilesetup());
          },
        ),
        ListTile(
          leading: Icon(Icons.calendar_month, color: localAppTheme['anchorColors']['secondaryColor']),
          title: Align(
            alignment: Alignment.centerLeft,
            child: body(header: 'My Calender', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ),
          onTap: () {},
        ),
      ],
      onExpansionChanged: (value) {
        if (value) {
          internalStatusProvider.setHomePageSidebar('AthleteSidebar');
        }
      },
    );
  }
}
