//---------------------------------------------------------------------------------------------------------------------------
// This file contains a function to get the start date of a week based on the year, week number, and first day of the week.
DateTime getWeekStartDate(int year, int weekNumber, int firstDayOfWeek) {
  DateTime firstDayOfYear = DateTime(year, 1, 1);
  int offset = (firstDayOfWeek - firstDayOfYear.weekday + 7) % 7;
  DateTime firstWeekStart = firstDayOfYear.add(Duration(days: offset));
  return firstWeekStart.add(Duration(days: (weekNumber - 1) * 7));
}

//---------------------------------------------------------------------------------------------------------------------------
// This function returns the last day of the week based on the start date and first day of the week.
DateTime getWeekEndDate(int year, int weekNumber, int firstDayOfWeek) {
  DateTime firstDayOfYear = DateTime(year, 1, 1);
  int offset = (firstDayOfWeek - firstDayOfYear.weekday + 7) % 7;
  DateTime firstWeekStart = firstDayOfYear.add(Duration(days: offset));
  DateTime weekStart = firstWeekStart.add(Duration(days: (weekNumber - 1) * 7));
  return weekStart.add(const Duration(days: 6));
}

//-----------------------------------------------------------------------------------------------------------
// This function returns the week number based on a date provided.
int getWeekNumber(DateTime date, int firstDayOfWeek) {
  DateTime firstDayOfYear = DateTime(date.year, 1, 1);
  int offset = (firstDayOfWeek - firstDayOfYear.weekday + 7) % 7;
  DateTime firstWeekStart = firstDayOfYear.add(Duration(days: offset));

  // Calculate the difference in days from the first week start
  int daysDifference = date.difference(firstWeekStart).inDays;

  // Calculate the week number
  return (daysDifference ~/ 7) + 1;
}
