import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';

class UpdateMe extends StatefulWidget {
  const UpdateMe({super.key});

  @override
  State<UpdateMe> createState() => _UpdateMeState();
}

class _UpdateMeState extends State<UpdateMe> {
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
          // Call providers

          return const SizedBox();
        }
      },
    );
  }
}
