import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
//import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
//import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';
import 'package:legacyendurancesport/General/Providers/notification_provider.dart';

class NotificationMedia extends StatefulWidget {
  const NotificationMedia({super.key});

  @override
  State<NotificationMedia> createState() => _NotificationMediaState();
}

class _NotificationMediaState extends State<NotificationMedia> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(notificationProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(NotificationProvider notificationProvider) async {
    await notificationProvider.fetchNotificationMedia();
  }

  //----------------------------------------------------
  // Build method with FutureBuilder
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
            final provider = Provider.of<NotificationProvider>(context, listen: true);
            final urls = provider.notificationMedia;

            return AlertDialog(
              backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
              title: header1(header: 'Notifications', color: localAppTheme['anchorColors']['primaryColor'], context: context),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: urls.isEmpty
                    ? body(header: 'No notification media found', color: localAppTheme['anchorColors']['primaryColor'], context: context)
                    : SingleChildScrollView(
                        child: Column(
                          children: urls.map((u) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(u, fit: BoxFit.contain, errorBuilder: (c, e, s) => Text('Image load error', style: TextStyle(color: localAppTheme['anchorColors']['primaryColor']))),
                            );
                          }).toList(),
                        ),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close', style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'])),
                )
              ],
            );
        }
      },
    );
  }
}
