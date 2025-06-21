import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/Home/Functions/longrangeplanbuilder.dart';
import 'package:legacyendurancesport/Coach/WorkoutCalendar/Functions/editdialog.dart';
import 'package:legacyendurancesport/Coach/WorkoutCalendar/Functions/isoweeknumber.dart';
import 'package:legacyendurancesport/General/Functions/sidebar_onHover.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

class Workoutcalendar extends StatefulWidget {
  const Workoutcalendar({super.key});

  @override
  State<Workoutcalendar> createState() => _WorkoutcalendarState();
}

class _WorkoutcalendarState extends State<Workoutcalendar> {
  int selectedYear = DateTime.now().year;
  int firstDayOfWeek = DateTime.monday;
  final List<String> draggableItems = ['📅 Meeting', '🎉 Event', '📌 Reminder'];
  final Map<String, List<String>> droppedItems = {};
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  double _sidebarWidth = 50;

  // Add keys for each month
  final List<GlobalKey> _monthKeys = List.generate(12, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    //firstYear = currentYear - 3;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToMonth(int monthIndex) async {
    final context = _monthKeys[monthIndex].currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(context, duration: Duration(milliseconds: 400), alignment: 0.1);
    }
  }

  void _scrollToToday() {
    final today = DateTime.now();
    if (selectedYear == today.year) {
      _scrollToMonth(today.month - 1);
    }
  }

  void _updateSidebar(bool expanded, double width) {
    setState(() {
      _isExpanded = expanded;
      _sidebarWidth = width;
    });
  }

  void _handleScroll() {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final firstYear = internalStatusProvider.firstYear;
    final lastYear = internalStatusProvider.lastYear;

    // If user scrolls above first month
    if (_scrollController.offset <= 0 && selectedYear > firstYear) {
      setState(() {
        selectedYear--;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMonth(11); // December
      });
    }
    // If user scrolls below last month
    double maxScroll = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset >= maxScroll && selectedYear < lastYear) {
      setState(() {
        selectedYear++;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMonth(0); // January
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);

    final firstYear = internalStatusProvider.firstYear;
    final lastYear = internalStatusProvider.lastYear;

    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<int>(
          value: selectedYear,
          underline: Container(),
          dropdownColor: Colors.blue,
          style: TextStyle(color: Colors.white, fontSize: 20),
          items: List.generate(lastYear - firstYear, (index) => firstYear + index)
              //.map((y) => DropdownMenuItem(value: y, child: Text('$y')))
              .map(
                (y) => DropdownMenuItem(
                  value: y,
                  child: header1(header: '$y', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                ),
              )
              .toList(),
          onChanged: (newYear) {
            if (newYear != null) setState(() => selectedYear = newYear);
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
          },
        ),
      ),
      body: MouseRegion(
        onHover: (details) => sidebarOnHover(details, _isExpanded, _updateSidebar),
        child: Row(
          children: [
            // Sidebar with hover effect
            Container(
              padding: const EdgeInsets.all(0),
              width: _sidebarWidth,
              decoration: BoxDecoration(
                color: localAppTheme['anchorColors']['primaryColor'],
                border: Border.all(color: localAppTheme['anchorColors']['secondaryColor']),
              ),
              child: Column(
                children: [
                  if (!_isExpanded) ...[
                    const Center(child: Icon(Icons.menu, color: Colors.white)),
                  ] else ...[
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          header3(header: 'MENU:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                          const SizedBox(height: 5),
                          Divider(color: localAppTheme['anchorColors']['secondaryColor']),
                          Visibility(
                            visible: true,
                            child: ListTile(
                              leading: Icon(Icons.settings, color: localAppTheme['anchorColors']['secondaryColor']),
                              title: Center(
                                child: body(header: 'MAINTENANCE', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                              ),
                              onTap: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LongRangePlanBuilder()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Sidebar
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              color: Colors.grey[200],
              child: ListView(
                children: draggableItems
                    .map(
                      (item) => Draggable<String>(
                        data: item,
                        feedback: Material(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.blueAccent,
                            //child: Text(item, style: TextStyle(color: Colors.white)),
                            child: header2(header: item, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: ListTile(
                            title: header2(header: item, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          ),
                        ),
                        child: ListTile(
                          title: header2(header: item, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            // Calendar
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: List.generate(12, (monthIndex) {
                    final DateTime firstDayOfMonth = DateTime(selectedYear, monthIndex + 1, 1);
                    final int daysInMonth = DateTime(selectedYear, monthIndex + 2, 0).day;
                    final int startOffset = (firstDayOfMonth.weekday - firstDayOfWeek + 7) % 7;
                    final totalSlots = ((daysInMonth + startOffset) / 7.0).ceil() * 7;

                    return Container(
                      key: _monthKeys[monthIndex], // <-- Add key here
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: MediaQuery.of(context).size.height / 2 < (totalSlots / 7) * 80 ? Colors.yellow[100] : Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          header1(header: DateFormat.MMMM().format(firstDayOfMonth), context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          SizedBox(height: 4),
                          // --- Updated header row for 9 columns ---
                          Row(
                            children: [
                              // Week number header
                              Expanded(
                                child: Container(
                                  width: double.infinity / 9,
                                  alignment: Alignment.center,
                                  //child: Text('Wk', style: TextStyle(fontWeight: FontWeight.bold)),
                                  child: header2(header: 'Wk', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                ),
                              ),
                              // 7 day headers
                              ...List.generate(7, (i) {
                                final day = DateFormat.E().format(DateTime(selectedYear, 1, firstDayOfWeek + i > 7 ? firstDayOfWeek + i - 7 : firstDayOfWeek + i));
                                return Expanded(
                                  child: Container(
                                    width: double.infinity / 9,
                                    alignment: Alignment.center,
                                    child: header2(header: day, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                  ),
                                );
                              }),
                              // Headings column header
                              Expanded(
                                child: Container(
                                  width: double.infinity / 9,
                                  alignment: Alignment.center,
                                  child: header2(header: 'ASSIGNED', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                ),
                              ),
                            ],
                          ),
                          // --- End header row update ---
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9, // 7 days + 2 extra columns
                              childAspectRatio: 1,
                            ),
                            itemCount: (totalSlots / 7).ceil() * 9, // 9 columns per week row
                            itemBuilder: (context, index) {
                              final weekRow = index ~/ 9;
                              final weekCol = index % 9;
                              final weekStartDay = weekRow * 7 - startOffset + 1;
                              final weekFirstDate = DateTime(selectedYear, monthIndex + 1, (weekStartDay < 1) ? 1 : weekStartDay);
                              final weekNumber = isoWeekNumber(weekFirstDate);

                              // Left-most column: Week number
                              if (weekCol == 0) {
                                return Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    color: Colors.grey[100],
                                  ),
                                  child: header3(header: 'W$weekNumber', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                );
                              }

                              // Right-most column: Headings
                              if (weekCol == 8) {
                                return Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    color: Colors.grey[100],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Rest', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text('Endurance', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text('Taper', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text('Lactate Threshold', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text('VO2 Max', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }

                              // Calendar day cells
                              final dayIndex = weekRow * 7 + (weekCol - 1);
                              final dayNum = dayIndex - startOffset + 1;
                              if (dayIndex < startOffset || dayNum > daysInMonth) {
                                return Container();
                              }
                              final currentDate = DateTime(selectedYear, monthIndex + 1, dayNum);
                              final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
                              final items = droppedItems[dateKey] ?? [];

                              return DragTarget<String>(
                                onAcceptWithDetails: (details) {
                                  setState(() {
                                    droppedItems.putIfAbsent(dateKey, () => []).add(details.data);
                                  });
                                },
                                builder: (context, candidateData, rejectedData) => InkWell(
                                  onTap: items.isNotEmpty ? () => editDialog(dateKey, items.last, context) : null,
                                  child: Container(
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      color: candidateData.isNotEmpty ? Colors.blue[50] : Colors.transparent,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        header3(header: '$dayNum', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                                        ...items.map((e) => header3(header: e, context: context, color: localAppTheme['anchorColors']['primaryColor'])),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
