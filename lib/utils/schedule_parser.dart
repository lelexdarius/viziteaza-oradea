/// Parses the 4 supported schedule formats from Firestore `schedule` field
/// and determines whether an event occurs on a given date.
///
/// Supported formats:
///   1. "3 Feb - 10 Mai - Ora 9:00"
///        → every day from Feb 3 to May 10
///
///   2. "3 Feb - Ora 10:00"
///        → only on Feb 3 (single date)
///
///   3. "3 Feb - 10 Mai - Ora 9:00, Zilele Marti - Duminica"
///        → Tue–Sun from Feb 3 to May 10
///
///   4. "3 Feb - 10 Mai - Ora 10:00, Zilele: Luni, Miercuri, Vineri"
///        → Mon / Wed / Fri from Feb 3 to May 10
///
/// Romanian diacritics are optional (Marti = Marți, Sambata = Sâmbătă etc.).
/// Years are always inferred as the current year (or next year when the end
/// month is before the start month, e.g. a winter event "1 Nov - 28 Feb").
class ScheduleParser {
  ScheduleParser._();

  // ----------------------------------------------------------------
  // Lookup tables
  // ----------------------------------------------------------------

  static const Map<String, int> _months = {
    'ianuarie': 1, 'ian': 1,
    'februarie': 2, 'feb': 2,
    'martie': 3, 'mar': 3,
    'aprilie': 4, 'apr': 4,
    'mai': 5,
    'iunie': 6, 'iun': 6,
    'iulie': 7, 'iul': 7,
    'august': 8, 'aug': 8,
    'septembrie': 9, 'sep': 9, 'sept': 9,
    'octombrie': 10, 'oct': 10,
    'noiembrie': 11, 'nov': 11,
    'decembrie': 12, 'dec': 12,
  };

  static const Map<String, int> _days = {
    'luni': 1,
    'marți': 2, 'marti': 2,
    'miercuri': 3,
    'joi': 4,
    'vineri': 5,
    'sâmbătă': 6, 'sâmbata': 6, 'sambata': 6, 'sambătă': 6,
    'duminică': 7, 'duminica': 7,
  };

  // ----------------------------------------------------------------
  // Regexes
  // ----------------------------------------------------------------

  // Separates date/time part from weekday restriction
  // Matches:  ", Zilele:"  /  ", Zilele "  (case-insensitive after .toLowerCase())
  static final RegExp _zileleSplitRe = RegExp(r',\s*zilele[:\s]+');

  // Strips the time suffix "- Ora HH:MM" or ", Ora HH:MM" (and everything after)
  static final RegExp _oraSplitRe = RegExp(r'\s*[-,]\s*ora\b');

  // Date range:  "3 Feb - 10 Mai"
  static final RegExp _dateRangeRe = RegExp(
    r'(\d{1,2})\s+([a-zăâîșț]+)\s*-\s*(\d{1,2})\s+([a-zăâîșț]+)',
  );

  // Single date: "3 Feb"  (anchored so it doesn't match inside a range)
  static final RegExp _singleDateRe = RegExp(
    r'^(\d{1,2})\s+([a-zăâîșț]+)$',
  );

  // Weekday range: "Marti - Duminica"
  static final RegExp _weekdayRangeRe = RegExp(
    r'(luni|marți|marti|miercuri|joi|vineri'
    r'|sâmbătă|sâmbata|sambata|sambătă'
    r'|duminică|duminica)'
    r'\s*-\s*'
    r'(luni|marți|marti|miercuri|joi|vineri'
    r'|sâmbătă|sâmbata|sambata|sambătă'
    r'|duminică|duminica)',
  );

  // Any single weekday name (used for list parsing)
  static final RegExp _anyWeekdayRe = RegExp(
    r'luni|marți|marti|miercuri|joi|vineri'
    r'|sâmbătă|sâmbata|sambata|sambătă'
    r'|duminică|duminica',
  );

  // ----------------------------------------------------------------
  // Public API
  // ----------------------------------------------------------------

  /// Returns true if the event occurs on [date].
  ///
  /// [endDate] is accepted for API compatibility but not used — the date
  /// range is now fully encoded in the [schedule] text.
  static bool occursOn({
    required String schedule,
    required DateTime? endDate,
    required DateTime date,
  }) {
    final raw = schedule.trim();
    if (raw.isEmpty) return true; // no schedule → always visible

    // Normalise: lowercase + standardise rare cedilla variants
    final s = raw
        .toLowerCase()
        .replaceAll('\u015f', '\u0219') // ş → ș
        .replaceAll('\u015e', '\u0218')
        .replaceAll('\u0163', '\u021b') // ţ → ț
        .replaceAll('\u0162', '\u021a');

    final today = DateTime(date.year, date.month, date.day);

    // ── Step 1: split off ", Zilele ..." weekday restriction ────
    final parts = s.split(_zileleSplitRe);
    final datePart = parts[0].trim();
    final weekdayStr = parts.length > 1 ? parts[1].trim() : null;

    // ── Step 2: strip "- Ora HH:MM" from the date part ─────────
    final dateOnly = datePart.split(_oraSplitRe).first.trim();

    // ── Step 3: parse start / end date ──────────────────────────
    DateTime? start;
    DateTime? end;

    final rangeMatch = _dateRangeRe.firstMatch(dateOnly);
    if (rangeMatch != null) {
      final d1 = int.tryParse(rangeMatch.group(1)!);
      final m1 = _months[rangeMatch.group(2)!.trim()];
      final d2 = int.tryParse(rangeMatch.group(3)!);
      final m2 = _months[rangeMatch.group(4)!.trim()];
      if (d1 != null && m1 != null && d2 != null && m2 != null) {
        start = DateTime(today.year, m1, d1);
        end = DateTime(today.year, m2, d2);
        // Winter events cross a year boundary (e.g. "1 Nov - 28 Feb")
        if (end.isBefore(start)) {
          end = DateTime(today.year + 1, m2, d2);
        }
      }
    } else {
      final singleMatch = _singleDateRe.firstMatch(dateOnly);
      if (singleMatch != null) {
        final d = int.tryParse(singleMatch.group(1)!);
        final m = _months[singleMatch.group(2)!.trim()];
        if (d != null && m != null) {
          start = DateTime(today.year, m, d);
          end = start;
        }
      }
    }

    // Could not parse a date range — check weekday restriction before fallback.
    // Handles formats like "Ora: 21:00, Zilele: Joi" (recurring weekly, no date bound).
    if (start == null || end == null) {
      if (weekdayStr != null && weekdayStr.isNotEmpty) {
        final allowed = _parseAllowedWeekdays(weekdayStr);
        if (allowed.isNotEmpty) return allowed.contains(date.weekday);
      }
      return true; // completely unparseable → always visible
    }

    // ── Step 4: is today within [start, end]? ───────────────────
    if (today.isBefore(start) || today.isAfter(end)) return false;

    // ── Step 5: weekday restriction (formats 3 & 4) ─────────────
    if (weekdayStr != null && weekdayStr.isNotEmpty) {
      final allowed = _parseAllowedWeekdays(weekdayStr);
      if (allowed.isNotEmpty) return allowed.contains(date.weekday);
    }

    return true;
  }

  // ----------------------------------------------------------------
  // Private helpers
  // ----------------------------------------------------------------

  /// Returns the set of allowed weekday numbers from a string like
  /// "Marti - Duminica"  or  "Luni, Miercuri, Vineri".
  static List<int> _parseAllowedWeekdays(String s) {
    // Range: "Marti - Duminica"
    final rangeMatch = _weekdayRangeRe.firstMatch(s);
    if (rangeMatch != null) {
      final from = _days[rangeMatch.group(1)!];
      final to = _days[rangeMatch.group(2)!];
      if (from != null && to != null) {
        final result = <int>[];
        if (from <= to) {
          for (var i = from; i <= to; i++) {
            result.add(i);
          }
        } else {
          // Wrap-around, e.g. Sâmbătă(6) – Luni(1)
          for (var i = from; i <= 7; i++) {
            result.add(i);
          }
          for (var i = 1; i <= to; i++) {
            result.add(i);
          }
        }
        return result;
      }
    }

    // List: "Luni, Miercuri, Vineri"
    final result = <int>{};
    for (final m in _anyWeekdayRe.allMatches(s)) {
      final d = _days[m.group(0)!];
      if (d != null) result.add(d);
    }
    return result.toList();
  }
}
