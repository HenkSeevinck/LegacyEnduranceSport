import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/Coach/WorkoutCalendar/Functions/getfirstandlastdaysoftheweek.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/LRPB/helperfunctions.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/LRPB/macrocycleinput.dart';
import 'package:legacyendurancesport/Home/Functions/Sub%20Functions/LRPB/mesocycleinput.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/Home/Providers/macrocycleprovider.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';

class LongRangePlanBuilder extends StatefulWidget {
  const LongRangePlanBuilder({super.key});

  @override
  State<LongRangePlanBuilder> createState() => _LongRangePlanBuilderState();
}

class _LongRangePlanBuilderState extends State<LongRangePlanBuilder> {
  late Future<void> _fetchDataFuture;
  late int selectedYear;
  late int firstYear;
  late int lastYear;
  late int totalWeeks;
  final ScrollController _scrollController = ScrollController();

  static const double weekCardWidth = 450.0;
  static const double weekCardMargin = 8.0;

  bool _hasScrolledToCurrentWeek = false;
  bool _isJumpingYear = false;

  @override
  void initState() {
    super.initState();
    final athleteKeyProvider = Provider.of<AthleteKeyProvider>(context, listen: false);
    final macroMesoCycleProvider = Provider.of<MacroCycleProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    _fetchDataFuture = fetchAppStartupInformation(athleteKeyProvider, macroMesoCycleProvider, appUserProvider);
  }

  Future<void> fetchAppStartupInformation(AthleteKeyProvider athleteKeyProvider, MacroCycleProvider macroMesoCycleProvider, AppUserProvider appUserProvider) async {
    final athleteUID = athleteKeyProvider.selectedAthlete['uid'];
    final coachUID = appUserProvider.appUser['uid'];
    await macroMesoCycleProvider.getMacroCyclesByAthleteAndCoachUID(athleteUID, coachUID);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    firstYear = internalStatusProvider.firstYear;
    lastYear = internalStatusProvider.lastYear;
    selectedYear = DateTime.now().year;
    totalWeeks = internalStatusProvider.getTotalWeeks(selectedYear);
    _scrollController.removeListener(_handleScrollEdge);
    _scrollController.addListener(_handleScrollEdge);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollEdge);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentWeek() {
    if (!_scrollController.hasClients) return;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final weekNumber = internalStatusProvider.getCurrentWeekNumber(selectedYear);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetOffset = (weekNumber - 1) * (weekCardWidth + weekCardMargin * 2) - (screenWidth / 2) + (weekCardWidth / 2);
    final double maxOffset = _scrollController.position.maxScrollExtent;
    final double minOffset = 0;
    final double offset = targetOffset.clamp(minOffset, maxOffset);

    _scrollController.animateTo(offset, duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  void _scrollToStartOfYear() {
    _scrollController.jumpTo(0);
  }

  void _scrollToEndOfYear() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _handleScrollEdge() async {
    if (_isJumpingYear) return;
    final atStart = _scrollController.offset <= 0;
    final atEnd = _scrollController.offset >= _scrollController.position.maxScrollExtent;

    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    if (atStart && selectedYear > firstYear) {
      _isJumpingYear = true;
      setState(() {
        selectedYear--;
        totalWeeks = internalStatusProvider.getTotalWeeks(selectedYear);
        _hasScrolledToCurrentWeek = false;
      });
      await Future.delayed(Duration(milliseconds: 50));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToEndOfYear();
        _isJumpingYear = false;
      });
    } else if (atEnd && selectedYear < lastYear) {
      _isJumpingYear = true;
      setState(() {
        selectedYear++;
        totalWeeks = internalStatusProvider.getTotalWeeks(selectedYear);
        _hasScrolledToCurrentWeek = false;
      });
      await Future.delayed(Duration(milliseconds: 50));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToStartOfYear();
        _isJumpingYear = false;
      });
    }
  }

  bool isGoalInWeek(DateTime weekStart, DateTime weekEnd, DateTime goalStart, DateTime goalEnd) {
    return !(goalEnd.isBefore(weekStart) || goalStart.isAfter(weekEnd));
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          );
        } else {
          final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
          final athleteKeyProvider = Provider.of<AthleteKeyProvider>(context, listen: true);
          final macroCycleProvider = Provider.of<MacroCycleProvider>(context, listen: true);
          final blockGoals = macroCycleProvider.blockGoals;
          final trainingFocus = macroCycleProvider.trainingFocus;
          final trainingBlocks = macroCycleProvider.trainingBlocks;
          final firstDayOfWeek = internalStatusProvider.firstDayOfWeek;

          // SCROLL TO CURRENT WEEK after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_hasScrolledToCurrentWeek && _scrollController.hasClients) {
              _scrollToCurrentWeek();
              _hasScrolledToCurrentWeek = true;
            }
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: header3(header: '${athleteKeyProvider.selectedAthlete['name'].toString().toUpperCase()} ${athleteKeyProvider.selectedAthlete['surname'].toString().toUpperCase()}', context: context, color: localAppTheme['anchorColors']['primaryColor']),
              ),
              Container(
                color: localAppTheme['anchorColors']['primaryColor'],
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        //clearInputForm(goalController: _goalController, startDateController: _startDateController, endDateController: _endDateController, setColor: (color) => setState(() => _selectedColor = color));
                        macroCycleProvider.clearSelectedMacroCycle();
                        internalStatusProvider.lrpbFormStatus == 'MacroCycle' ? internalStatusProvider.setlrpbFormStatus('MesoCycle') : internalStatusProvider.setlrpbFormStatus('MacroCycle');
                      },
                      icon: Icon(Icons.change_circle_outlined, color: localAppTheme['anchorColors']['secondaryColor']),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: header3(header: internalStatusProvider.lrpbFormStatus == 'MacroCycle' ? 'MACROCYCLE PLANNING:' : 'MESOCYCLE PLANNING:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    itemCount: totalWeeks,
                    itemBuilder: (context, weekIndex) {
                      final weekNumber = weekIndex + 1;
                      final isCurrentWeek = (selectedYear == DateTime.now().year) && (weekNumber == internalStatusProvider.getCurrentWeekNumber(selectedYear));
                      final weekStartDate = getWeekStartDate(selectedYear, weekIndex, firstDayOfWeek);
                      final weekEndDate = weekStartDate.add(const Duration(days: 6));
                      final formattedWeekStart = DateFormat('dd-MMM-yyyy').format(weekStartDate);

                      // Find all goals that overlap with this week
                      final weekGoals = blockGoals.where((goal) {
                        final startDate = toDateTime(goal['startDate']);
                        final endDate = toDateTime(goal['endDate']);
                        return isGoalInWeek(weekStartDate, weekEndDate, startDate, endDate);
                      }).toList();

                      // Find all Training Focus  that overlap with this week
                      final weekFocus = trainingFocus.where((goal) {
                        final startDate = toDateTime(goal['startDate']);
                        final endDate = toDateTime(goal['endDate']);
                        return isGoalInWeek(weekStartDate, weekEndDate, startDate, endDate);
                      }).toList();

                      // Find all Training blocks that overlap with this week
                      final weekBlocks = trainingBlocks.where((goal) {
                        final startDate = toDateTime(goal['startDate']);
                        final endDate = toDateTime(goal['endDate']);
                        return isGoalInWeek(weekStartDate, weekEndDate, startDate, endDate);
                      }).toList();

                      // Get week block names
                      final weekBlockNames = weekBlocks.map((g) => getBlockTypeName(g['userInput'], internalStatusProvider.focusBlocks)).where((name) => name != null).join(", ");

                      // Get week goals colors
                      final weekGoalColor = getWeekGoalColor(weekGoals);

                      // Get week Focus colors
                      final weekFocusColor = getWeekGoalColor(weekFocus);

                      // Get week blocks colors
                      final weekBlockColor = getWeekGoalColor(weekBlocks);

                      return Container(
                        width: weekCardWidth,
                        margin: EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: isCurrentWeek ? Colors.lightBlue[50] : Colors.white,
                          border: Border(
                            bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                            right: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                            top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            customHeader(header: 'WEEK: $weekNumber', context: context, color: localAppTheme['anchorColors']['primaryColor'], fontWeight: FontWeight.bold, size: MediaQuery.of(context).size.width * 0.00875 / 1.75),
                            Container(
                              alignment: Alignment.centerLeft,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                              ),
                              child: body(header: formattedWeekStart, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                              ),
                              child: header3(header: 'RACES', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                            ),
                            Container(
                              color: internalStatusProvider.planBlockID == 1 ? localAppTheme['utilityColorPair1']['color1'] : Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  customHeader(header: 'Training Block:', context: context, color: localAppTheme['anchorColors']['primaryColor'], fontWeight: FontWeight.bold, size: MediaQuery.of(context).size.width * 0.00875 / 1.75),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      color: weekBlockColor,
                                      border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                                    ),
                                    child: weekBlocks.isNotEmpty ? body(header: weekBlockNames, context: context, color: localAppTheme['anchorColors']['primaryColor']) : body(header: '', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: internalStatusProvider.planBlockID == 2 ? localAppTheme['utilityColorPair1']['color1'] : Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  customHeader(header: 'Block Goals:', context: context, color: localAppTheme['anchorColors']['primaryColor'], fontWeight: FontWeight.bold, size: MediaQuery.of(context).size.width * 0.00875 / 1.75),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      color: weekGoalColor,
                                      border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                                    ),
                                    child: weekGoals.isNotEmpty ? body(header: weekGoals.map((g) => g['userInput']).join(", "), context: context, color: localAppTheme['anchorColors']['primaryColor']) : body(header: '', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: internalStatusProvider.planBlockID == 3 ? localAppTheme['utilityColorPair1']['color1'] : Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  customHeader(header: 'Training Focus:', context: context, color: localAppTheme['anchorColors']['primaryColor'], fontWeight: FontWeight.bold, size: MediaQuery.of(context).size.width * 0.00875 / 1.75),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      color: weekFocusColor,
                                      border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                                    ),
                                    child: weekFocus.isNotEmpty ? body(header: weekFocus.map((g) => g['userInput']).join(", "), context: context, color: localAppTheme['anchorColors']['primaryColor']) : body(header: '', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(visible: internalStatusProvider.lrpbFormStatus == 'MesoCycle', child: MesoCycleInput(weekNumber, selectedYear)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Visibility(
                visible: internalStatusProvider.lrpbFormStatus == 'MacroCycle',
                child: Expanded(
                  //flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0)),
                    ),
                    //child: internalStatusProvider.lrpbTopWidget,
                    child: MacroCycleInput(),
                  ),
                ),
              ),
              //     ],
              //   ),
              // ),
            ],
          );
        }
      },
    );
  }
}
