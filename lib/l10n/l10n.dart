import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

/// Locale-aware wording for dates and greetings. Dates themselves stay in
/// the design's format ("Wed, 14 Oct") in both languages; only the words
/// around them are translated.
extension L10nFormat on AppLocalizations {
  /// "Today", "Yesterday", or "Sun, 12 Oct".
  String dayLabel(DateTime date, {DateTime? now}) {
    final diff = _day(now ?? DateTime.now()).difference(_day(date)).inDays;
    if (diff == 0) return today;
    if (diff == 1) return yesterday;
    return DateFormat('EEE, d MMM').format(date);
  }

  /// "Updated today" style label for a book.
  String updatedLabel(DateTime date, {DateTime? now}) {
    final diff = _day(now ?? DateTime.now()).difference(_day(date)).inDays;
    if (diff <= 0) return updatedToday;
    if (diff == 1) return updatedYesterday;
    if (diff < 7) return updatedDaysAgo(diff);
    if (diff < 14) return updatedLastWeek;
    return updatedOn(DateFormat('d MMM').format(date));
  }

  String greeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return greetingMorning;
    if (hour < 17) return greetingAfternoon;
    return greetingEvening;
  }

  List<String> weekdays({bool short = false}) =>
      (short ? weekdaysShort : weekdaysLong).split(',');
}
