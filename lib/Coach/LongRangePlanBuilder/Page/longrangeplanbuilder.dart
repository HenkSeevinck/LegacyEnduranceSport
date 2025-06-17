import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Functions/sidebar_onHover.dart';

class WeekScrollPage extends StatefulWidget {
  const WeekScrollPage({super.key});

  @override
  State<WeekScrollPage> createState() => _WeekScrollPageState();
}

class _WeekScrollPageState extends State<WeekScrollPage> {
  bool _isExpanded = false;
  double _sidebarWidth = 50;
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

  void _updateSidebar(bool expanded, double width) {
    setState(() {
      _isExpanded = expanded;
      _sidebarWidth = width;
    });
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
    final double screenWidth = MediaQuery.of(context).size.width - _sidebarWidth;
    final double targetOffset = (weekNumber - 1) * (weekCardWidth + weekCardMargin * 2)
      - (screenWidth / 2) + (weekCardWidth / 2);
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
    final localAppTheme = Theme.of(context);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<int>(
          value: selectedYear,
          underline: Container(),
          dropdownColor: Colors.blue,
          style: TextStyle(color: Colors.white, fontSize: 20),
          items: List.generate(lastYear - firstYear + 1, (index) => firstYear + index)
              .map((y) => DropdownMenuItem(
                    value: y,
                    child: Text('$y', style: TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: (newYear) {
            if (newYear != null) _onYearChanged(newYear);
          },
        ),
      ),
      body: MouseRegion(
        onHover: (details) => sidebarOnHover(details, _isExpanded, _updateSidebar),
        child: Row(
          children: [
            // Expandable Sidebar
            Container(
              width: _sidebarWidth,
              decoration: BoxDecoration(
                color: localAppTheme.primaryColor,
                border: Border.all(color: localAppTheme.colorScheme.secondary),
              ),
              child: Column(
                children: [
                  if (!_isExpanded)
                    const Center(child: Icon(Icons.menu, color: Colors.white))
                  else
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          Text('MENU:', style: TextStyle(color: localAppTheme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Divider(color: localAppTheme.colorScheme.secondary),
                          ListTile(
                            leading: Icon(Icons.settings, color: localAppTheme.colorScheme.secondary),
                            title: Center(
                              child: Text('MAINTENANCE', style: TextStyle(color: localAppTheme.colorScheme.secondary)),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Horizontal week scroll
            Expanded(
              child: Container(
                color: Colors.grey[100],
                height: 350,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    itemCount: totalWeeks,
                    itemBuilder: (context, weekIndex) {
                      final weekNumber = weekIndex + 1;
                      final isCurrentWeek = (selectedYear == DateTime.now().year) &&
                          (weekNumber == internalStatusProvider.getCurrentWeekNumber(selectedYear));
                      return Container(
                        width: weekCardWidth,
                        margin: EdgeInsets.symmetric(vertical: 24, horizontal: weekCardMargin),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrentWeek ? Colors.lightBlue[50] : Colors.white,
                          border: Border.all(
                            color: isCurrentWeek ? Colors.blue : Colors.blueGrey.shade100,
                            width: isCurrentWeek ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Week $weekNumber',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCurrentWeek ? Colors.blue : Colors.blueGrey[800],
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}