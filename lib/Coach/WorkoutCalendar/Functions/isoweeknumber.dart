// Helper function to get ISO week number
int isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: (4 - date.weekday) % 7));
  final firstThursday = DateTime(thursday.year, 1, 1).add(Duration(days: (4 - DateTime(thursday.year, 1, 1).weekday) % 7));
  return 1 + ((thursday.difference(firstThursday).inDays) ~/ 7);
}
