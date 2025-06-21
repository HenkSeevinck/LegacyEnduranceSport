import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/Coach/WorkoutCalendar/Functions/getfirstdayoftheweek.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:provider/provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';

class LongRangePlanBuilder extends StatefulWidget {
  const LongRangePlanBuilder({super.key});

  @override
  State<LongRangePlanBuilder> createState() => _LongRangePlanBuilderState();
}

class _LongRangePlanBuilderState extends State<LongRangePlanBuilder> {
  late int selectedYear;
  late int firstYear;
  late int lastYear;
  late int totalWeeks;
  final ScrollController _scrollController = ScrollController();
  int firstDayOfWeek = DateTime.sunday; //TODO: Make this configurable in settings

  static const double weekCardWidth = 450.0;
  static const double weekCardMargin = 8.0;

  bool _hasScrolledToCurrentWeek = false;
  bool _isJumpingYear = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    firstYear = internalStatusProvider.firstYear;
    lastYear = internalStatusProvider.lastYear;
    selectedYear = DateTime.now().year;
    totalWeeks = internalStatusProvider.getTotalWeeks(selectedYear);

    if (!_hasScrolledToCurrentWeek) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
      _hasScrolledToCurrentWeek = true;
    }

    _scrollController.removeListener(_handleScrollEdge);
    _scrollController.addListener(_handleScrollEdge);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollEdge);
    _scrollController.dispose();
    super.dispose();
  }

  void _onYearChanged(int year) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    setState(() {
      selectedYear = year;
      totalWeeks = internalStatusProvider.getTotalWeeks(selectedYear);
      _hasScrolledToCurrentWeek = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
  }

  void _scrollToCurrentWeek() {
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

  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final localAppTheme = ResponsiveTheme(context).theme;
    final athleteKeyProvider = Provider.of<AthleteKeyProvider>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: header3(header: 'Athlete: ${athleteKeyProvider.selectedAthlete['name']} ${athleteKeyProvider.selectedAthlete['surname']}', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: header3(header: 'MACROCYCLE PLANNING:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0),
                top: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!, width: 1.0),
              ),
            ),
            child: internalStatusProvider.lrpbTopWidget,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: header3(header: 'MESOCYCLE PLANNING:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
        ),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton<int>(
                  value: selectedYear,
                  underline: Container(),
                  dropdownColor: localAppTheme['anchorColors']['secondaryColor'],
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  items: List.generate(lastYear - firstYear + 1, (index) => firstYear + index)
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: body(header: '$y', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                        ),
                      )
                      .toList(),
                  onChanged: (newYear) {
                    if (newYear != null) _onYearChanged(newYear);
                  },
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    itemCount: totalWeeks,
                    itemBuilder: (context, weekIndex) {
                      final weekNumber = weekIndex + 1;
                      final isCurrentWeek = (selectedYear == DateTime.now().year) && (weekNumber == internalStatusProvider.getCurrentWeekNumber(selectedYear));
                      final weekStartDate = getWeekStartDate(selectedYear, weekIndex, firstDayOfWeek);
                      final formattedWeekStart = DateFormat('dd-MMM-yyyy').format(weekStartDate);

                      return Container(
                        width: weekCardWidth,
                        margin: EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: isCurrentWeek ? Colors.lightBlue[50] : Colors.white,
                          border: Border(
                            bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                            right: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                            top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                                ),
                                child: header3(header: '$weekNumber: $formattedWeekStart', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                                ),
                                child: header3(header: 'RACES', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                                ),
                                child: header3(header: 'TRAINING BLOCK', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                                ),
                                child: header3(header: 'BLOCK GOALS', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor']!)),
                                ),
                                child: header3(header: 'TRAINING FOCUS', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                //decoration: BoxDecoration(border: Border.all(color: localAppTheme['anchorColors']['primaryColor']!)),
                                child: header3(header: 'Goal Durations', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
