import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Landing/Functions/mobile_landing.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool showsearch = false;
  String? searchPrase;
  late Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch data
    _fetchDataFuture = _fetchData(
      // Add any parameters if needed
    );
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData() async {
    // Fetch data from the providers
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopLayout() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackLayout() {
    return Scaffold(body: const Center(child: Text('Landing Page - Fallback Layout Coming Soon')));
  }

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
            return MobileLanding();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopLayout();
          } else {
            return _buildFallbackLayout();
          }
        }
      },
    );
  }
}
