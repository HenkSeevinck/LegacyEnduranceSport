import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

class AdminSidebar extends StatefulWidget {
  const AdminSidebar({super.key});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
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
      if (internalStatusProvider.homePageSidebar == 'AdminSidebar') {
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
      title: body(header: 'Admin Menu', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
      initiallyExpanded: false,
      children: [
        ListTile(
          leading: Icon(Icons.people, color: localAppTheme['anchorColors']['secondaryColor']),
          title: Align(
            alignment: Alignment.centerLeft,
            child: body(header: 'All Coaches', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.people, color: localAppTheme['anchorColors']['secondaryColor']),
          title: Align(
            alignment: Alignment.centerLeft,
            child: body(header: 'All Athletes', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ),
          onTap: () {},
        ),
      ],
      onExpansionChanged: (value) {
        if (value) {
          internalStatusProvider.setHomePageSidebar('AdminSidebar');
        }
      },
    );
  }
}
