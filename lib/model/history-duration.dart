enum HistoryDuration {
  day,
  threeDays,
  month,
  threeMonths,
  sixMonths,
  year,
  twoYears,
}

DateTime pastDate(HistoryDuration historyDuration) {
  var now = DateTime.now();
  switch (historyDuration) {
    case HistoryDuration.day:
      return DateTime(now.year, now.month, now.day - 1);
    case HistoryDuration.threeDays:
      return DateTime(now.year, now.month, now.day - 3);
    case HistoryDuration.month:
      return DateTime(now.year, now.month - 1, now.day);
    case HistoryDuration.threeMonths:
      return DateTime(now.year, now.month - 3, now.day);
    case HistoryDuration.sixMonths:
      return DateTime(now.year, now.month - 6, now.day);
    case HistoryDuration.year:
      return DateTime(now.year - 1, now.month, now.day);
    case HistoryDuration.twoYears:
      return DateTime(now.year - 2, now.month, now.day);
  }
}

int getDays(HistoryDuration historyDuration) {
  return DateTime.now().difference(pastDate(historyDuration)).inDays;
}
