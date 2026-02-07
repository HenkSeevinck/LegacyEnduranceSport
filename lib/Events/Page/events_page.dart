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
  bool isLoadingAthleteList = false;
  // Track which event tiles are expanded so we know when to refresh attendees after RSVP.
  final Set<String> _expandedEventIds = <String>{};

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
        title: appheader(
          context: context, 
          automaticallyImplyLeading: true,
          onPressed: (){
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomePage()
                ),
              );
            },
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
                pageHeaderImage(
                  imagePath: 'images/Events.png',
                  context: context,
                  toolTip: '',
                  userProfileToShow: {},
                  pageTitle: 'EVENTS',
                  isCoachView: false,
                  buttonVisibility: false,
                ),
                SizedBox(height: 10.0),
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
                SizedBox(height: 10.0),
                filteredEvents != null && filteredEvents.isNotEmpty
                    ? Column(
                      children: [
                        Column(
                            children: List<Widget>.generate(filteredEvents.length, (index) {
                              final itemCount = filteredEvents.length;
                              final event = filteredEvents[index];
                              final attendees = event['attendees'] as List?;
                              final hasRSVPed = attendees != null && (attendees).contains(appUser['uid']);
                              final attendeesExpanded = eventsProvider.attendees ?? [];
                              final String eventId = (event['eventID'] ?? '').toString();
                              final bool isExpanded = _expandedEventIds.contains(eventId);
                              String eventDateStr = 'No Date Provided';                                                            
                              final rawDate = event['eventDate'];
                              if (rawDate != null) {
                                if (rawDate is Timestamp) {
                                  eventDateStr = DateFormat.yMMMMd().format(rawDate.toDate());
                                } else if (rawDate is DateTime) {
                                  eventDateStr = DateFormat.yMMMMd().format(rawDate);
                                } else {
                                  eventDateStr = rawDate.toString();
                                }
                              }


                             
                              return ExpansionTile(
                                  shape: Border(
                                    top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                    bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == (itemCount - 1) ? 1.0 : 0.0),
                                  ),
                                  collapsedShape: Border(
                                    top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                    bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: index == (itemCount - 1) ? 1.0 : 0.0),
                                  ),
                                  showTrailingIcon: false,
                                  tilePadding: EdgeInsets.all(0),
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
                                                      child: SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.5,
                                                        child: body(
                                                          header: event['link']?.toString() ?? 'www.google.com',
                                                          color: localAppTheme['anchorColors']['primaryColor'],
                                                          context: context,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            imageButtonWithHeader(
                                              width: 75, 
                                              height: 130, 
                                              onPressed: () async{
                                                try{
                                                // Update RSVP status
                                                List<dynamic> updatedAttendees = List<dynamic>.from(event['attendees'] ?? <dynamic>[]);
                                                if (!hasRSVPed) {
                                                  await eventsProvider.updateEvent(event['eventID'], {
                                                    'attendees': FieldValue.arrayUnion(appUser['uid'] != null ? [appUser['uid']] : []),
                                                  });
                                                  updatedAttendees.add(appUser['uid']);
                                                } else {
                                                  await eventsProvider.updateEvent(event['eventID'], {
                                                    'attendees': FieldValue.arrayRemove(appUser['uid'] != null ? [appUser['uid']] : []),
                                                  });
                                                  updatedAttendees.remove(appUser['uid']);
                                                }
                                                } catch (e) {
                                                  showGeneralPopupDialog(context, 'Error', 'An error occurred while updating your RSVP. Please try again later.');
                                                }
                                                                                                    
                                                // Load attendees if not already loaded
                                                if (isExpanded) {
                                                  setState(() {
                                                    isLoadingAthleteList = true;
                                                  });
                                                  eventsProvider.clearAttendees();
                                                  await eventsProvider.fetchAttendeesForEvent(
                                                    (!hasRSVPed)
                                                      ? (List<dynamic>.from(event['attendees'] ?? <dynamic>[])..add(appUser['uid']))
                                                      : (List<dynamic>.from(event['attendees'] ?? <dynamic>[])..remove(appUser['uid'])),
                                                    appUserProvider
                                                  );
                                                  setState(() {
                                                    isLoadingAthleteList = false;
                                                  });
                                                }
                                              },
                                              toolTip: 'RSVP', 
                                              imagePath: hasRSVPed ? 'images/RSVPed.png' : 'images/RSVP.png', 
                                              context: context, 
                                              headerText: 'RSVP'
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                      ],
                                    ),
                                  children: [
                                    !isLoadingAthleteList
                                    ? Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                        ),
                                      ),
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
                                                        children: List<Widget>.generate(attendeesExpanded.length, (attendeeIndex) {
                                                          final attendeeId = attendeesExpanded[attendeeIndex];
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                            child: body(
                                                              header: '${attendeeId['name'] ?? ''} ${attendeeId['surname'] ?? ''}',
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
                                    )
                                    : Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                                        ),
                                      ),
                                        height: 100,
                                        width: double.infinity,
                                        child: Center(
                                      child: CircularProgressIndicator()
                                      ),
                                    ),
                                  ],
                                  onExpansionChanged: (value) async{
                                    if (value) {
                                      setState(() {
                                        isLoadingAthleteList = true;
                                      });
                                      _expandedEventIds.add(eventId);
                                      eventsProvider.clearAttendees();
                                      await eventsProvider.fetchAttendeesForEvent(event['attendees'] ?? [], appUserProvider);
                                      setState(() {
                                        isLoadingAthleteList = false;
                                      });
                                    } else {
                                      _expandedEventIds.remove(eventId);
                                    }
                                  },
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
