import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/Coach/WorkoutCalendar/Functions/editdialog.dart';

class Workoutcalendar extends StatefulWidget {
  const Workoutcalendar({super.key});

  @override
  State<Workoutcalendar> createState() => _WorkoutcalendarState();
}

class _WorkoutcalendarState extends State<Workoutcalendar> {
  int selectedYear = DateTime.now().year;
  int firstDayOfWeek = DateTime.monday; // Configurable start of the week
  final List<String> draggableItems = ['📅 Meeting', '🎉 Event', '📌 Reminder'];
  final Map<String, List<String>> droppedItems = {}; // Key: 'yyyy-MM-dd'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<int>(
          value: selectedYear,
          underline: Container(),
          dropdownColor: Colors.blue,
          style: TextStyle(color: Colors.white, fontSize: 20),
          items: List.generate(5, (index) => 2023 + index)
              .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
              .toList(),
          onChanged: (newYear) {
            if (newYear != null) setState(() => selectedYear = newYear);
          },
        ),
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 100,
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
                          child: Text(item, style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ListTile(title: Text(item)),
                      ),
                      child: ListTile(title: Text(item)),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Calendar
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(12, (monthIndex) {
                  final DateTime firstDayOfMonth = DateTime(selectedYear, monthIndex + 1, 1);
                  final int daysInMonth = DateTime(selectedYear, monthIndex + 2, 0).day;
                  final int startOffset = (firstDayOfMonth.weekday - firstDayOfWeek + 7) % 7;
                  final totalSlots = ((daysInMonth + startOffset) / 7.0).ceil() * 7;

                  return Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: MediaQuery.of(context).size.height / 2 < (totalSlots / 7) * 80
                          ? Colors.yellow[100]
                          : Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.MMMM().format(firstDayOfMonth),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) =>
                              Text(DateFormat.E().format(DateTime(2024, 1, firstDayOfWeek + i > 7 ? firstDayOfWeek + i - 7 : firstDayOfWeek + i)),
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1,
                          ),
                          itemCount: totalSlots,
                          itemBuilder: (context, index) {
                            final dayNum = index - startOffset + 1;
                            if (index < startOffset || dayNum > daysInMonth) {
                              return Container();
                            }
                            final currentDate = DateTime(selectedYear, monthIndex + 1, dayNum);
                            final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
                            final items = droppedItems[dateKey] ?? [];

                            return DragTarget<String>(
                              onAccept: (data) {
                                setState(() {
                                  droppedItems.putIfAbsent(dateKey, () => []).add(data);
                                });
                              },
                              builder: (context, candidateData, rejectedData) => InkWell(
                                onTap: items.isNotEmpty
                                    ? () => editDialog(dateKey, items.last, context)
                                    : null,
                                child: Container(
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    color: candidateData.isNotEmpty
                                        ? Colors.blue[50]
                                        : Colors.transparent,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$dayNum', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ...items.map((e) => Text(e, style: TextStyle(fontSize: 10))).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}