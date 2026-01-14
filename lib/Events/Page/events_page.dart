import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/events_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(eventsProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(EventsProvider eventsProvider) async {
    await eventsProvider.fetchAllEvents();
  }

  // Parse various stored date representations into a DateTime
  DateTime? _parseToDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileEventPage() {
    final localAppTheme = ResponsiveTheme(context).theme;
    final eventsProvider = Provider.of<EventsProvider>(context, listen: true);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final eventTypes = internalStatusProvider.eventTypes;
    final appUser = appUserProvider.appUser;
    final events = eventsProvider.events?.where((event) {
      final eventDate = _parseToDate(event['eventDate']);
      return eventDate != null && eventDate.isAfter(DateTime.now());
    }).toList();

    // Sort earliest -> latest
    events?.sort((a, b) {
      final da = _parseToDate(a['eventDate']);
      final db = _parseToDate(b['eventDate']);
      if (da == null && db == null) return 0;
      if (da == null) return 1; // put nulls last
      if (db == null) return -1;
      return da.compareTo(db);
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SafeArea(
          top: true,
          child: Stack(
            children: [
              Center(child: Image.asset('images/Legacy-Endurance-Logo.png', height: 70, width: 70, fit: BoxFit.contain)),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: iconButton(
                  label: null,
                  backgroundColor: null,
                  iconColor: localAppTheme['anchorColors']['primaryColor'],
                  icon: Icons.arrow_back,
                  size: 30,
                  toolTip: 'BACK',
                  context: context,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header1(header: 'Upcoming Events:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
              SizedBox(height: 20.0),
              events != null && events.isNotEmpty
                  ? Column(
                      children: List<Widget>.generate(events.length, (index) {
                        final itemCount = events.length;
                        final event = events[index];
                        final hasRSVPed = event['attendees'] != null && (event['attendees'] as List).contains(appUser['uid']);
                        String eventDateStr = 'No Date Provided';
                        final rawDate = event['eventDate'];
                        if (rawDate != null) {
                          if (rawDate is Timestamp) {
                            eventDateStr = DateFormat.yMMMMd().add_jm().format(rawDate.toDate());
                          } else if (rawDate is DateTime) {
                            eventDateStr = DateFormat.yMMMMd().add_jm().format(rawDate);
                          } else {
                            eventDateStr = rawDate.toString();
                          }
                        }
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                              bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == (itemCount - 1) ? 1.0 : 0.0),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: [
                              SizedBox(height: 10.0),
                              SizedBox(
                                width: double.infinity,
                                child: header2(
                                  header: event['name'] ?? 'Unnamed Event',
                                  color: localAppTheme['anchorColors']['primaryColor'],
                                  context: context,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.event, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                          SizedBox(width: 20.0),
                                          body(header: eventDateStr, color: localAppTheme['anchorColors']['primaryColor'], context: context),
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Icon(Icons.terrain, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                          SizedBox(width: 20.0),
                                          body(header: event['terrain'], color: localAppTheme['anchorColors']['primaryColor'], context: context),
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Icon(Icons.flag_outlined, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                          SizedBox(width: 20.0),
                                          body(
                                            header: eventTypes.firstWhere((type) => type['id'] == event['type'])['eventType'] ?? 'Unknown',
                                            color: localAppTheme['anchorColors']['primaryColor'],
                                            context: context,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Icon(Icons.straighten, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                          SizedBox(width: 20.0),
                                          body(
                                            header: '${event['distance'].toString()} km',
                                            color: localAppTheme['anchorColors']['primaryColor'],
                                            context: context,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 75,
                                    padding: const EdgeInsets.only(left: 10.0),
                                    decoration: BoxDecoration(
                                      border: Border(left: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                                    ),
                                    child: Column(
                                      children: [
                                        iconButton(
                                          label: null,
                                          backgroundColor: null,
                                          iconColor: hasRSVPed ? Colors.green : localAppTheme['anchorColors']['primaryColor'],
                                          icon: Icons.rsvp_outlined,
                                          size: 30,
                                          toolTip: 'RSVP',
                                          context: context,
                                          onPressed: () {
                                            try{
                                            if (!hasRSVPed) {
                                              eventsProvider.updateEvent(event['eventID'], {
                                                'attendees': FieldValue.arrayUnion(appUser['uid'] != null ? [appUser['uid']] : []),
                                              });
                                            } else {
                                              eventsProvider.updateEvent(event['eventID'], {
                                                'attendees': FieldValue.arrayRemove(appUser['uid'] != null ? [appUser['uid']] : []),
                                              });
                                            }
                                            } catch (e) {
                                              showGeneralPopupDialog(context, 'Error', 'An error occurred while updating your RSVP. Please try again later.');
                                            }
                                          },
                                        ),
                                        SizedBox(height: 10.0),
                                        iconButton(
                                          label: null,
                                          backgroundColor: null,
                                          iconColor: localAppTheme['anchorColors']['primaryColor'],
                                          icon: Icons.group_outlined,
                                          size: 30,
                                          toolTip: 'See Attendees',
                                          context: context,
                                          onPressed: () {
                                            
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                            ],
                          ),
                        );
                      }),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopEventPage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackEventPage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Fallback Layout Coming Soon')));
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
          final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
          final platform = internalStatusProvider.platform;

          if (platform == 'MobileWeb' || platform == 'Mobile') {
            return _buildMobileEventPage();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopEventPage();
          } else {
            return _buildFallbackEventPage();
          }
        }
      },
    );
  }
}
