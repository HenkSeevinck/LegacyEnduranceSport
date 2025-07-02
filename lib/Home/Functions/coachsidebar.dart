import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/athletes.dart';
import 'package:legacyendurancesport/Home/Functions/newathlete.dart';
import 'package:legacyendurancesport/Home/Functions/workoutbuilder.dart';
import 'package:legacyendurancesport/ProfileSetup/Functions/coachprofilesetup.dart';
import 'package:provider/provider.dart';

class CoachSidebar extends StatefulWidget {
  const CoachSidebar({super.key});

  @override
  State<CoachSidebar> createState() => _CoachSidebarState();
}

class _CoachSidebarState extends State<CoachSidebar> {
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
      if (internalStatusProvider.homePageSidebar == 'CoachSidebar') {
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
      title: body(header: 'Coach Menu', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
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
            child: body(header: 'My Coaching Profile', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ),
          onTap: () {
            internalStatusProvider.setHomeMainContent(const Coachprofilesetup());
          },
        ),
        ListTile(
          leading: Icon(Icons.settings, color: localAppTheme['anchorColors']['secondaryColor']),
          title: Align(
            alignment: Alignment.centerLeft,
            child: body(header: 'My Workouts', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ),
          onTap: () {
            internalStatusProvider.setHomeMainContent(const WorkoutBuilder());
          },
        ),
        ExpansionTile(
          title: body(header: 'My Athletes', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          initiallyExpanded: false,
          leading: Icon(Icons.people, color: localAppTheme['anchorColors']['secondaryColor']),
          children: [
            ListTile(
              leading: Icon(Icons.people, color: localAppTheme['anchorColors']['secondaryColor']),
              title: Align(
                alignment: Alignment.centerLeft,
                child: body(header: 'Athletes', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
              ),
              onTap: () {
                internalStatusProvider.setHomeMainContent(const Athletes());
              },
            ),
            ListTile(
              leading: Icon(Icons.add, color: localAppTheme['anchorColors']['secondaryColor']),
              title: Align(
                alignment: Alignment.centerLeft,
                child: body(header: 'New Athlete', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
              ),
              onTap: () {
                internalStatusProvider.setHomeMainContent(const NewAthlete());
              },
            ),
          ],
        ),
      ],
      onExpansionChanged: (value) {
        if (value) {
          internalStatusProvider.setHomePageSidebar('CoachSidebar');
        }
      },
    );
  }
}
