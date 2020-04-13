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

String historyDurationToString(HistoryDuration historyDuration) {
  switch (historyDuration) {
    case HistoryDuration.day:
      return '24h';
    case HistoryDuration.threeDays:
      return '3d';
    case HistoryDuration.month:
      return '1m';
    case HistoryDuration.threeMonths:
      return '3m';
    case HistoryDuration.sixMonths:
      return '6m';
    case HistoryDuration.year:
      return '1y';
    case HistoryDuration.twoYears:
      return '2y';
  }
}

HistoryDuration historyDurationFromString(String str) {
  switch (str) {
    case '24h':
      return HistoryDuration.day;
    case '3d':
      return HistoryDuration.threeDays;
    case '1m':
      return HistoryDuration.month;
    case '3m':
      return HistoryDuration.threeMonths;
    case '6m':
      return HistoryDuration.sixMonths;
    case '1y':
      return HistoryDuration.year;
    case '2y':
      return HistoryDuration.twoYears;
    default:
      return null;
  }
}
