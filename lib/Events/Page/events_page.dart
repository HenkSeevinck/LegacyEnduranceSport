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
import 'package:url_launcher/url_launcher.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Future<void>? _fetchDataFuture;
  final TextEditingController searchController = TextEditingController();

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(eventsProvider);
  }

  //----------------------------------------------------
  // Open URL function
  Future<void> _openUrl(String rawUrl) async {
    try {
      final urlString = (rawUrl.isEmpty) ? 'https://www.google.com' : rawUrl;
      final uri = Uri.parse(urlString.startsWith('http') ? urlString : 'https://$urlString');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // ignore errors for now
    }
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(EventsProvider eventsProvider) async {
    await eventsProvider.fetchAllEvents();
  }

  //----------------------------------------------------
  // Dispose controllers
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

    // Apply search filter
    final searchText = searchController.text.toLowerCase();
    final filteredEvents = (events != null)
        ? events.where((event) {
            final name = (event['name'] ?? '').toString().toLowerCase();
            final terrain = (event['terrain'] ?? '').toString().toLowerCase();
            final typeId = event['type']?.toString().toLowerCase() ?? '';
            final typeName = eventTypes.firstWhere((type) => type['id'].toString().toLowerCase() == typeId, orElse: () => {'eventType': ''})['eventType'].toString().toLowerCase();
            return name.contains(searchText) || terrain.contains(searchText) || typeName.contains(searchText);
          }).toList()
        : events;

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header1(header: 'Upcoming Events:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                SizedBox(height: 20.0),
                filteredEvents != null && filteredEvents.isNotEmpty
                    ? Column(
                      children: [
                        FormInputField(
                          label: 'Search Events', 
                          errorMessage: '', 
                          isMultiline: false, 
                          isPassword: false, 
                          prefixIcon: null, 
                          suffixIcon: null, 
                          showLabel: true,
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          ),
                        SizedBox(height: 20.0),
                        Column(
                            children: List<Widget>.generate(filteredEvents.length, (index) {
                              final itemCount = filteredEvents.length;
                              final event = filteredEvents[index];
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
                                // decoration: BoxDecoration(
                                //       border: Border(
                                //         top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                //         bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == (itemCount - 1) ? 1.0 : 0.0),
                                //       ),
                                //     ),
                                child: ExpansionTile(
                                  shape: Border(
                                    top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                    bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == (itemCount - 1) ? 1.0 : 0.0),
                                  ),
                                  collapsedShape: Border(
                                    top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                    bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == (itemCount - 1) ? 1.0 : 0.0),
                                  ),
                                  showTrailingIcon: false,
                                  title: Column(
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
                                                SizedBox(height: 10.0),
                                                Row(
                                                  children: [
                                                    Icon(Icons.link, color: localAppTheme['anchorColors']['primaryColor'], size: 20),
                                                    SizedBox(width: 20.0),
                                                    InkWell(
                                                      onTap: () => _openUrl(event['link']?.toString() ?? 'www.google.com'),
                                                      child: body(
                                                        header: event['link']?.toString() ?? 'www.google.com',
                                                        color: localAppTheme['anchorColors']['primaryColor'],
                                                        context: context,
                                                      ),
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
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                            child: filteredEvents[index]['attendees'] == null || (filteredEvents[index]['attendees'] as List).isEmpty
                                                ? body(header: 'No athletes have RSVP\'ed yet.', color: localAppTheme['anchorColors']['primaryColor'], context: context)
                                                : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                     header3(
                                                        header: 'Athletes who RSVP\'ed',
                                                        color: localAppTheme['anchorColors']['primaryColor'],
                                                        context: context,
                                                      ),
                                                    SizedBox(height: 20.0),
                                                    Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: List<Widget>.generate(filteredEvents[index]['attendees'].length, (attendeeIndex) {
                                                          final attendeeId = filteredEvents[index]['attendees'][attendeeIndex];
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                            child: body(
                                                              header: attendeeId.toString(),
                                                              color: localAppTheme['anchorColors']['primaryColor'],
                                                              context: context,
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                  ],
                                                ),
                                          
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                ),
                              );
                            }),
                          ),
                      ],
                    )
                    : Container(),
              ],
            ),
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
