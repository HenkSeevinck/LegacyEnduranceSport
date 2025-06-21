DateTime getWeekStartDate(int year, int weekNumber, int firstDayOfWeek) {
  // Find the first day of the year
  DateTime firstDayOfYear = DateTime(year, 1, 1);
  // Calculate the offset to the first desired weekday
  int offset = (firstDayOfWeek - firstDayOfYear.weekday + 7) % 7;
  DateTime firstWeekStart = firstDayOfYear.add(Duration(days: offset));
  // Calculate the start date for the given week number
  return firstWeekStart.add(Duration(days: (weekNumber - 1) * 7));
}
