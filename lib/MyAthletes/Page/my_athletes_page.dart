import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/MyAthletes/Mobile%20Functions/mobile_my_athletes.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class MyAthletesPage extends StatefulWidget {
  const MyAthletesPage({super.key,});

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
            return MobileMyAthletes();
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
