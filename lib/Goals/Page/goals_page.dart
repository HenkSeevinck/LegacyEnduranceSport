import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  Future<void>? _fetchDataFuture;
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    //Add Providers you want to fetch data from here
    _fetchDataFuture = _fetchData();
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData() async {
    //Add fetch functions from Providers you want to fetch data from here
    titleController.text = '';
    distanceController.text = '';
    dateController.text = '';
  }

  //----------------------------------------------------
  // Athlete Selection Popup Dialog
  Future<void> _showCreateGoalPopupDialog(BuildContext context) async {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    //final allUsers = appUserProvider.allUsers;
    final eventTypes = internalStatusProvider.eventTypes;
    Map<String, dynamic>? selectedAthlete;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
          title: header1(header: 'Create a Goal:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                FormInputField(
                  label: 'Title:',
                  errorMessage: 'Please enter a valid goal title.',
                  isMultiline: false,
                  isPassword: false,
                  prefixIcon: null,
                  suffixIcon: null,
                  showLabel: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid goal title.';
                    }
                    return null;
                  },
                  controller: titleController
                ),
                SizedBox(height: 10.0),
                SearchableDropdown(
                  labelText: 'Event Type:',
                  hint: 'Event Type',
                  dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                  searchBoxVisable: false,
                  dropDownList: eventTypes,
                  header: '',
                  iconColor: localAppTheme['anchorColors']['primaryColor'],
                  idField: 'id',
                  displayField: 'eventType',
                  onChanged: (value) {
                    setState(() {
                      //selectedAthlete = value;
                    });
                  },
                  isEnabled: true,
                ),
                SizedBox(height: 10.0),
                FormInputField(
                  label: 'Distance:',
                  errorMessage: 'Please enter a valid goal distance (integer).',
                  isMultiline: false,
                  isPassword: false,
                  prefixIcon: null,
                  suffixIcon: null,
                  showLabel: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid goal distance.';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer distance.';
                    }
                    return null;
                  },
                  controller: distanceController
                ),
                SizedBox(height: 10.0),
                body(
                  header: 'Duration:', 
                  color: localAppTheme['anchorColors']['primaryColor'], 
                  context: context
                  ),
                SizedBox(height: 5.0),
                durationInputWidget(context: context),
                SizedBox(height: 10.0),
                DatePicker(
                  buttonLabelColor: localAppTheme['anchorColors']['primaryColor'], 
                  label: 'Date:', 
                  buttonVisibility: true, 
                  initialDate: null, 
                  validator: (date) {
                    if (date == null) {
                      return 'Please select a valid date.';
                    }
                    return null;
                  }, 
                  controller: dateController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: elevatedButton(
                    label: 'CANCEL',
                    onPressed: () {
                      selectedAthlete = null;
                      Navigator.of(context).pop();
                    },
                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                    leadingIcon: null,
                    trailingIcon: null,
                    context: context,
                  ),
                ),
                Expanded(
                  child: elevatedButton(
                    label: 'SUBMIT',
                    onPressed: () async {
                      if (selectedAthlete != null) {
                        try {
                          setState(() {
                            isLoading = true;
                          });
                          await appUserProvider.addAthleteToCoach(appUser['coachDocID'], selectedAthlete!['uid'], selectedAthlete!['email']);
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop();
                          showGeneralPopupDialog(context, 'Success!', 'Athlete added successfully.');
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop();
                          showGeneralPopupDialog(context, 'Error!', 'Failed to add athlete.');
                        }
                      }
                    },
                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                    leadingIcon: null,
                    trailingIcon: null,
                    context: context,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  //----------------------------------------------------
  // Mobile Layout
  Widget _buildMobileGoalsPage() {
    final localAppTheme = ResponsiveTheme(context).theme;
    //final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    //final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    //final appUser = appUserProvider.appUser;

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
        child: Form(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      header1(header: 'My Goals:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      iconButton(
                        label: null,
                        backgroundColor: null,
                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                        icon: Icons.add,
                        size: 30,
                        toolTip: 'ADD GOAL',
                        onPressed: () {
                          _showCreateGoalPopupDialog(context);
                        },
                        context: context,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopGoalsPage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackGoalsPage() {
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
            return _buildMobileGoalsPage();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopGoalsPage();
          } else {
            return _buildFallbackGoalsPage();
          }
        }
      },
    );
  }
}
