import 'dart:math' as math;
import 'package:math_guru/features/junior_secondary/jss2/statistics_2/timetables_and_charts/timetables_and_charts.dart';

class TimetablesAndChartsLogic {
  /// The 20 major Nigerian cities from Figure 18.5 in exact textbook order.
  static const List<String> nigerianCities = [
    "Abeokuta",
    "Abuja",
    "Akure",
    "Bauchi",
    "Benin City",
    "Calabar",
    "Enugu",
    "Ibadan",
    "Ikeja",
    "Ilorin",
    "Jos",
    "Kaduna",
    "Kano",
    "Maiduguri",
    "Makurdi",
    "Minna",
    "Owerri",
    "Port Harcourt",
    "Sokoto",
    "Yola",
  ];

  /// Lower-triangular distance matrix (in km) from Figure 18.5.
  /// Row i contains distances from city[i] to city[0 .. i-1].
  static const List<List<int>> _lowerDistanceTriangle = [
    [], // 0: Abeokuta
    [740], // 1: Abuja
    [277, 700], // 2: Akure
    [1072, 445, 835], // 3: Bauchi
    [329, 450, 171, 893], // 4: Benin City
    [765, 857, 607, 998, 463], // 5: Calabar
    [577, 595, 389, 741, 248, 283], // 6: Enugu
    [77, 659, 200, 995, 291, 727, 539], // 7: Ibadan
    [81, 879, 312, 1147, 328, 748, 526, 147], // 8: Ikeja
    [236, 500, 191, 913, 362, 755, 498, 159, 306], // 9: Ilorin
    [940, 313, 703, 132, 761, 866, 609, 863, 1015, 781], // 10: Jos
    [836, 180, 761, 412, 791, 921, 662, 759, 906, 600, 280], // 11: Kaduna
    [1086, 442, 1023, 321, 1057, 1183, 924, 1009, 1156, 850, 421, 262], // 12: Kano
    [1536, 918, 1299, 464, 1357, 1462, 1179, 1459, 1606, 1377, 596, 876, 614], // 13: Maiduguri
    [821, 323, 551, 471, 492, 529, 270, 711, 820, 651, 339, 502, 760, 740], // 14: Makurdi
    [673, 117, 543, 591, 601, 860, 664, 596, 743, 437, 459, 300, 550, 1055, 442], // 15: Minna
    [565, 733, 407, 889, 236, 184, 174, 527, 564, 604, 757, 812, 1074, 1353, 418, 751], // 16: Owerri
    [693, 830, 535, 996, 364, 184, 281, 625, 662, 732, 864, 917, 1179, 1460, 525, 849, 98], // 17: Port Harcourt
    [969, 793, 924, 778, 1095, 1408, 1149, 892, 1050, 732, 646, 487, 583, 1204, 985, 627, 1299, 1404], // 18: Sokoto
    [1428, 855, 1166, 436, 1099, 1136, 877, 1366, 1427, 1236, 568, 848, 447, 409, 691, 1027, 1025, 1132, 1214], // 19: Yola
  ];

  /// Looks up the road distance (km) between any two cities in Figure 18.5.
  static int getCityDistanceKm(int cityIdxA, int cityIdxB) {
    if (cityIdxA == cityIdxB) return 0;
    final int r = math.max(cityIdxA, cityIdxB);
    final int c = math.min(cityIdxA, cityIdxB);
    return _lowerDistanceTriangle[r][c];
  }

  static const List<TimetableChartPreset> textbookPresets = [
    TimetableChartPreset(
      chipLabel: "Ex 18e: 12h/24h Clock",
      topicMode: 0,
      clockSubMode: 0,
      clockListCsv:
      "5.40 a.m., 7.25 p.m., 22:25 hours, 5 to 9 at night, 10 past 6 in the morning, Midday, 3 minutes past midnight",
      clockStart: "06:00",
      clockEnd: "11:30",
    ),
    TimetableChartPreset(
      chipLabel: "Fig 18.2: 201 UP Train",
      topicMode: 1,
      serviceTitle: "Figure 18.2: Ibadan–Offa Railway (201 UP)",
      stops: [
        JourneyStopInput(stationName: "Ibadan", departureTime: "6.00 pm"),
        JourneyStopInput(
            stationName: "Oshogbo",
            arrivalTime: "9.32 pm",
            departureTime: "9.42 pm"),
        JourneyStopInput(stationName: "Offa", arrivalTime: "11.45 pm"),
      ],
      originStopIdx: 0,
      destStopIdx: 2,
      compareLegDuration: "1 h 48 min",
    ),
    TimetableChartPreset(
      chipLabel: "Fig 18.2: 202 DN Train",
      topicMode: 1,
      serviceTitle: "Figure 18.2: Offa–Ibadan Railway (202 DN)",
      stops: [
        JourneyStopInput(stationName: "Offa", departureTime: "6.00 am"),
        JourneyStopInput(
            stationName: "Oshogbo",
            arrivalTime: "7.48 am",
            departureTime: "7.58 am"),
        JourneyStopInput(stationName: "Ibadan", arrivalTime: "11.30 am"),
      ],
      originStopIdx: 0,
      destStopIdx: 2,
      compareLegDuration: "2 h 03 min",
    ),
    TimetableChartPreset(
      chipLabel: "Fig 18.4: Lagos–Nairobi Flight",
      topicMode: 1,
      serviceTitle: "Figure 18.4: Flight WT751 / WT753 (Lagos to Nairobi)",
      stops: [
        JourneyStopInput(stationName: "Lagos", departureTime: "13:00"),
        JourneyStopInput(
            stationName: "Douala",
            arrivalTime: "14:15",
            departureTime: "15:00"),
        JourneyStopInput(stationName: "Nairobi", arrivalTime: "20:55"),
      ],
      originStopIdx: 0,
      destStopIdx: 2,
      actualFlightDuration: "6 h 10 min",
    ),
    TimetableChartPreset(
      chipLabel: "Fig 18.6: School Timetable",
      topicMode: 2,
      periodSlotsCsv:
      "07:00-07:40, 07:40-08:20, 08:20-09:00, 10:00-10:40, 10:40-11:20, 11:20-12:00, 12:20-13:00, 13:00-13:40",
      schoolDays: [
        SchoolDayInput(
            dayName: "MON.",
            subjectsCsv: "Lang., Lit., Maths, Sci., Sci., R.K., Hist., Econ."),
        SchoolDayInput(
            dayName: "TUE.",
            subjectsCsv:
            "Hist., Geog., Lang., Econ., Maths, Lit., Comm., Comm."),
        SchoolDayInput(
            dayName: "WED.",
            subjectsCsv:
            "Maths, Comm., R.K., Geog., Hist., Lit., Econ., Lang."),
        SchoolDayInput(
            dayName: "THU.",
            subjectsCsv: "Maths, Lit., Geog., Lang., Sci., Sci., Hist., Econ."),
        SchoolDayInput(
            dayName: "FRI.",
            subjectsCsv: "Econ., Geog., Lang., Comm., R.K., Maths, Lit., Sci."),
      ],
    ),
    TimetableChartPreset(
      chipLabel: "Fig 18.5: Distance Chart",
      topicMode: 3,
      distanceSubMode: 0,
      originCityIdx: 4, // Benin City
      destCityIdx: 11, // Kaduna
      viaCityIdx: 9, // Ilorin
      multiStopRouteCsv: "Port Harcourt, Owerri, Enugu, Calabar, Port Harcourt",
    ),
    TimetableChartPreset(
      chipLabel: "Fig 18.7: Table Tennis Bracket",
      topicMode: 4,
      chartSubMode: 0,
      bracketTitle: "Figure 18.7: Table Tennis Competition",
      matches: [
        KnockoutMatchInput(
            roundName: "1st Round",
            player1Name: "Joshua",
            player1Score: 15,
            player2Name: "Mohammed",
            player2Score: 21),
        KnockoutMatchInput(
            roundName: "1st Round",
            player1Name: "Daudu",
            player1Score: 14,
            player2Name: "Aliyu",
            player2Score: 21),
        KnockoutMatchInput(
            roundName: "1st Round",
            player1Name: "Ojo",
            player1Score: 21,
            player2Name: "Femi",
            player2Score: 12),
        KnockoutMatchInput(
            roundName: "1st Round",
            player1Name: "Johnson",
            player1Score: 21,
            player2Name: "Audu",
            player2Score: 18),
        KnockoutMatchInput(
            roundName: "Semifinals",
            player1Name: "Mohammed",
            player1Score: 22,
            player2Name: "Aliyu",
            player2Score: 24),
        KnockoutMatchInput(
            roundName: "Semifinals",
            player1Name: "Ojo",
            player1Score: 21,
            player2Name: "Johnson",
            player2Score: 14),
        KnockoutMatchInput(
            roundName: "Finals",
            player1Name: "Aliyu",
            player1Score: 26,
            player2Name: "Ojo",
            player2Score: 24),
      ],
      targetPlayerName: "Ojo",
      targetChartTitle: "Figure 18.8: Gbenga's Walking Target Chart",
      targetUnit: "paces",
      targetThreshold: "8000",
      targetLabelsCsv: "Sun (S), Mon (M), Tue (T), Wed (W), Thu (T), Fri (F), Sat (S)",
      targetValuesCsv: "10000, 9000, 0, 8000, 7000, 5000, 9000",
    ),
    TimetableChartPreset(
      chipLabel: "Fig 18.8: Walking Target Chart",
      topicMode: 4,
      chartSubMode: 1,
      bracketTitle: "Figure 18.7: Table Tennis Competition",
      matches: [
        KnockoutMatchInput(
            roundName: "1st Round",
            player1Name: "Joshua",
            player1Score: 15,
            player2Name: "Mohammed",
            player2Score: 21),
        KnockoutMatchInput(
            roundName: "1st Round",
            player1Name: "Daudu",
            player1Score: 14,
            player2Name: "Aliyu",
            player2Score: 21),
        KnockoutMatchInput(
            roundName: "1st Round",
            player1Name: "Ojo",
            player1Score: 21,
            player2Name: "Femi",
            player2Score: 12),
        KnockoutMatchInput(
            roundName: "1st Round",
            player1Name: "Johnson",
            player1Score: 21,
            player2Name: "Audu",
            player2Score: 18),
        KnockoutMatchInput(
            roundName: "Semifinals",
            player1Name: "Mohammed",
            player1Score: 22,
            player2Name: "Aliyu",
            player2Score: 24),
        KnockoutMatchInput(
            roundName: "Semifinals",
            player1Name: "Ojo",
            player1Score: 21,
            player2Name: "Johnson",
            player2Score: 14),
        KnockoutMatchInput(
            roundName: "Finals",
            player1Name: "Aliyu",
            player1Score: 26,
            player2Name: "Ojo",
            player2Score: 24),
      ],
      targetPlayerName: "Aliyu",
      targetChartTitle: "Figure 18.8: Gbenga's Walking Target Chart",
      targetUnit: "paces",
      targetThreshold: "8000",
      targetLabelsCsv: "Sun (S), Mon (M), Tue (T), Wed (W), Thu (T), Fri (F), Sat (S)",
      targetValuesCsv: "10000, 9000, 0, 8000, 7000, 5000, 9000",
    ),
  ];

  static String formatNumber(double v, {int maxDecimals = 1}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String _cleanTex(String s) {
    return s
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('&', ' and ')
        .replaceAll('%', ' pct')
        .replaceAll('_', ' ')
        .trim();
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// Formats minutes since midnight into 24-hour string "HH:MM hours".
  static String format24Hour(int totalMins) {
    final int wrapped = ((totalMins % 1440) + 1440) % 1440;
    final int h = wrapped ~/ 60;
    final int m = wrapped % 60;
    return "${_twoDigits(h)}:${_twoDigits(m)}";
  }

  /// Formats minutes since midnight into 12-hour textbook string (e.g. "5.40 a.m.").
  static String format12Hour(int totalMins) {
    final int wrapped = ((totalMins % 1440) + 1440) % 1440;
    final int h24 = wrapped ~/ 60;
    final int m = wrapped % 60;
    if (h24 == 0 && m == 0) return "12.00 midnight";
    if (h24 == 12 && m == 0) return "12.00 noon (midday)";
    final String suffix = h24 < 12 ? "a.m." : "p.m.";
    final int h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
    return "$h12.${_twoDigits(m)} $suffix";
  }

  /// Formats a duration in minutes as "X h Y min" or "Y min".
  static String formatDuration(int mins) {
    final int absM = mins.abs();
    final int h = absM ~/ 60;
    final int m = absM % 60;
    if (h == 0) return "$m min";
    if (m == 0) return "$h h";
    return "$h h ${_twoDigits(m)} min";
  }

  /// Parses standard 12h ("5.40 a.m.", "9:32 pm"), 24h ("14:15", "20 55", "04:15 hours"),
  /// and textbook English phrases ("5 to 9 at night", "10 past 6 in the morning", "midday", "3 minutes past midnight").
  static Map<String, dynamic> parseTimeToken(String raw) {
    final String clean = raw.trim();
    if (clean.isEmpty) {
      throw const FormatException("Time string cannot be empty.");
    }
    final String lower = clean.toLowerCase();

    // 1. Check special word phrases ("midday", "noon", "midnight")
    if (lower == 'midday' || lower == 'noon' || lower == '12 noon') {
      return {
        'totalMins': 12 * 60,
        'isInput12h': true,
        'wordExplain': "'Midday' (12 noon) is the middle of the day = 12:00",
      };
    }
    if (lower == 'midnight' || lower == '12 midnight') {
      return {
        'totalMins': 0,
        'isInput12h': true,
        'wordExplain': "'Midnight' is the start of the 24-hour day = 00:00",
      };
    }

    // 2. Check English relative phrases: "X [minutes] past/to Y [in the morning / at night / in the afternoon / in the evening]"
    final RegExp wordPhraseReg = RegExp(
      r'^(\d+)\s*(?:minutes?|mins?)?\s+(past|to)\s+(\d+|midnight|midday|noon)(?:\s+(.*))?$',
      caseSensitive: false,
    );
    final Match? wordMatch = wordPhraseReg.firstMatch(lower);
    if (wordMatch != null) {
      final int offsetMins = int.parse(wordMatch.group(1)!);
      final String dir = wordMatch.group(2)!.toLowerCase(); // 'past' or 'to'
      final String baseToken = wordMatch.group(3)!.toLowerCase();
      final String periodHint = (wordMatch.group(4) ?? '').toLowerCase();

      int baseHour = 0;
      if (baseToken == 'midnight') {
        baseHour = 0;
      } else if (baseToken == 'midday' || baseToken == 'noon') {
        baseHour = 12;
      } else {
        baseHour = int.parse(baseToken);
      }

      final bool isNightOrEvening = periodHint.contains('night') ||
          periodHint.contains('evening') ||
          periodHint.contains('afternoon') ||
          periodHint.contains('p.m') ||
          periodHint.contains('pm');

      if (baseHour >= 1 && baseHour <= 11 && isNightOrEvening) {
        baseHour += 12;
      } else if (baseHour == 12 &&
          (periodHint.contains('midnight') ||
              (periodHint.contains('morning') && !periodHint.contains('noon')))) {
        baseHour = 0;
      }

      final int totalMins = dir == 'past'
          ? (baseHour * 60 + offsetMins)
          : (baseHour * 60 - offsetMins);
      final int wrapped = ((totalMins % 1440) + 1440) % 1440;

      final String stepExplain = dir == 'past'
          ? "'$clean' means $offsetMins minutes after ${_twoDigits(baseHour)}:00 = ${format12Hour(wrapped)}"
          : "'$clean' means $offsetMins minutes before ${_twoDigits(baseHour)}:00 (${_twoDigits(baseHour)}:00 - 0:${_twoDigits(offsetMins)}) = ${format12Hour(wrapped)}";

      return {
        'totalMins': wrapped,
        'isInput12h': true,
        'wordExplain': stepExplain,
      };
    }

    // 3. Standard 12-hour or 24-hour numeric formats
    final bool hasAm = lower.contains('a.m') ||
        RegExp(r'\bam\b').hasMatch(lower) ||
        lower.contains('morning');
    final bool hasPm = lower.contains('p.m') ||
        RegExp(r'\bpm\b').hasMatch(lower) ||
        lower.contains('night') ||
        lower.contains('afternoon') ||
        lower.contains('evening');

    String stripped = lower
        .replaceAll('a.m.', '')
        .replaceAll('p.m.', '')
        .replaceAll('a.m', '')
        .replaceAll('p.m', '')
        .replaceAll('am', '')
        .replaceAll('pm', '')
        .replaceAll('hours', '')
        .replaceAll('hour', '')
        .replaceAll('hrs', '')
        .replaceAll('a.', '')
        .replaceAll('d.', '')
        .replaceAll('→', '')
        .replaceAll('←', '')
        .trim();

    int hours = 0;
    int mins = 0;

    if (stripped.contains(':') || stripped.contains('.')) {
      final List<String> parts = stripped.split(RegExp(r'[:\.]'));
      hours = int.parse(parts[0].trim());
      mins = parts.length > 1 && parts[1].trim().isNotEmpty
          ? int.parse(parts[1].trim().split(RegExp(r'\s+')).first)
          : 0;
    } else if (RegExp(r'^\d+\s+\d+$').hasMatch(stripped)) {
      final List<String> parts = stripped.split(RegExp(r'\s+'));
      hours = int.parse(parts[0]);
      mins = int.parse(parts[1]);
    } else if (stripped.length == 4 && int.tryParse(stripped) != null) {
      hours = int.parse(stripped.substring(0, 2));
      mins = int.parse(stripped.substring(2, 4));
    } else {
      hours = int.parse(stripped);
      mins = 0;
    }

    if (mins < 0 || mins >= 60) {
      throw FormatException("Minutes in '$raw' must be between 00 and 59.");
    }

    if (hasAm || hasPm) {
      if (hours < 1 || hours > 12) {
        throw FormatException(
            "12-hour clock time '$raw' must have hours between 1 and 12.");
      }
      int h24 = hours;
      if (hasAm && hours == 12) h24 = 0;
      if (hasPm && hours < 12) h24 = hours + 12;
      return {
        'totalMins': h24 * 60 + mins,
        'isInput12h': true,
        'wordExplain': null,
      };
    } else {
      if (hours < 0 || hours > 23) {
        throw FormatException(
            "24-hour clock time '$raw' must have hours between 00 and 23.");
      }
      return {
        'totalMins': hours * 60 + mins,
        'isInput12h': false,
        'wordExplain': null,
      };
    }
  }

  /// Parses a duration string like "6 h 10 min", "2:03", or "45 min" into total minutes.
  static int? parseDurationToMinutes(String raw) {
    final String s = raw.trim().toLowerCase();
    if (s.isEmpty) return null;

    final RegExp hmReg = RegExp(r'(\d+)\s*(?:h|hr|hrs|hours?)\s*(\d+)?');
    final Match? hmMatch = hmReg.firstMatch(s);
    if (hmMatch != null) {
      final int h = int.parse(hmMatch.group(1)!);
      final int m =
      hmMatch.group(2) != null ? int.parse(hmMatch.group(2)!) : 0;
      return h * 60 + m;
    }

    if (s.contains(':')) {
      final List<String> parts = s.split(':');
      final int? h = int.tryParse(parts[0].trim());
      final int? m = parts.length > 1 ? int.tryParse(parts[1].trim()) : 0;
      if (h != null && m != null) return h * 60 + m;
    }

    final int? onlyMins =
    int.tryParse(s.replaceAll(RegExp(r'[^\d]'), ''));
    return onlyMins;
  }

  static TimetableChartResult solveClockAndTime({
    required int subMode, // 0: Convert List, 1: Elapsed Time, 2: Add/Subtract Duration
    required String clockListCsv,
    required String startTimeStr,
    required String endTimeStr,
    required String durationHoursStr,
    required String durationMinsStr,
    required bool isAddDuration,
  }) {
    try {
      final List<TimetableChartStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};
      final List<ParsedClockVisual> visuals = [];

      workings.add(
          "\\text{\\textbf{Step 1: 12-Hour (a.m./p.m.) and 24-Hour Clock Rules}}");
      workings.add(
          "\\bullet \\text{ a.m. (Midnight to 11:59 a.m.): Write as 4 digits } (00:00 \\text{ to } 11:59 \\text{ hours}).");
      workings.add(
          "\\bullet \\text{ p.m. (1:00 p.m. to 11:59 p.m.): Add } 12 \\text{ to the hour } (\\text{e.g. } 7.25\\text{ p.m.} \\rightarrow 7 + 12 = 19:25 \\text{ hours}).");
      workings.add("");

      steps.add(const TimetableChartStep(
        title: "Step 1: Recall the 12-Hour and 24-Hour Clock Rules",
        description:
        "• 12-hour clock uses a.m. (before midday) and p.m. (after midday).\n"
            "• 24-hour clock always uses 4 digits (HH:MM hours) from 00:00 (midnight) to 23:59:\n"
            "   1. For 12 midnight, write 00:00. For 1:00 a.m. to 11:59 a.m., keep the hour the same and add a leading zero if needed (e.g. 5.40 a.m. → 05:40 hours).\n"
            "   2. For 12 noon (midday), write 12:00. For 1:00 p.m. to 11:59 p.m., ADD 12 to the hour (e.g. 7.25 p.m. → 7 + 12 = 19:25 hours).\n"
            "   3. To convert 24-hour times above 12:59 back to p.m., SUBTRACT 12 from the hour (e.g. 22:25 hours → 22 − 12 = 10.25 p.m.).",
        mathLaTeX:
        "\\text{a.m.: Hour stays same (leading } 0\\text{)} \\quad ; \\quad \\text{p.m.: Hour} + 12 = \\text{24-hour clock}",
      ));

      if (subMode == 0) {
        final List<String> tokens = clockListCsv
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (tokens.isEmpty) {
          throw const FormatException(
              "Please enter at least one time to convert.");
        }

        workings.add(
            "\\text{\\textbf{Step 2: Step-by-Step Clock Conversions}}");
        final List<String> stepDescLines = [];
        final List<String> stepMathLines = [];

        for (int i = 0; i < tokens.length; i++) {
          final String tok = tokens[i];
          final Map<String, dynamic> parsed = parseTimeToken(tok);
          final int totalMins = parsed['totalMins'] as int;
          final bool is12h = parsed['isInput12h'] as bool;
          final String? wordExplain = parsed['wordExplain'] as String?;

          final int h24 = totalMins ~/ 60;
          final int m = totalMins % 60;
          final String f24 = "${format24Hour(totalMins)} hours";
          final String f12 = format12Hour(totalMins);

          visuals.add(ParsedClockVisual(
            rawInput: tok,
            hours24: h24,
            minutes: m,
            formatted12h: f12,
            formatted24h: f24,
          ));

          final String cleanTok = _cleanTex(tok);
          if (is12h) {
            final int h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
            final String ruleMath = h24 >= 13
                ? "($h12 + 12 = $h24) \\rightarrow ${_twoDigits(h24)}:${_twoDigits(m)} \\text{ hours}"
                : (h24 == 0
                ? "(12 \\text{ midnight} \\rightarrow 00) \\rightarrow 00:${_twoDigits(m)} \\text{ hours}"
                : "${_twoDigits(h24)}:${_twoDigits(m)} \\text{ hours}");
            workings.add("\\bullet \\text{ $cleanTok} \\rightarrow $ruleMath");
            stepMathLines.add("\\text{$cleanTok} = $ruleMath");

            final String wordPrefix =
            wordExplain != null ? "$wordExplain. Then: " : "";
            final String howText = h24 >= 13
                ? "Since it is p.m. (afternoon/night), add 12 to the hour: $h12 + 12 = $h24 → $f24."
                : (h24 == 0
                ? "Since it is past midnight (12 a.m. hour), the 24-hour clock hour is 00 → $f24."
                : "Since it is a.m. (morning), keep the hour and write with 4 digits → $f24.");
            stepDescLines.add("• $tok: $wordPrefix$howText");
            answers[tok] = f24;
          } else {
            final String ruleMath = h24 >= 13
                ? "($h24 - 12 = ${h24 - 12}) \\rightarrow ${_cleanTex(f12)}"
                : "\\text{${_cleanTex(f12)}}";
            workings.add("\\bullet \\text{ $cleanTok} \\rightarrow $ruleMath");
            stepMathLines.add("\\text{$cleanTok} = $ruleMath");

            final String howText = h24 >= 13
                ? "Since the hour ($h24) is greater than 12, subtract 12: $h24 − 12 = ${h24 - 12} p.m. → $f12."
                : (h24 == 0
                ? "Hour 00 is midnight (12 a.m.) → $f12."
                : "Since the hour ($h24) is less than 12, it is in the morning (a.m.) → $f12.");
            stepDescLines.add("• $tok: $howText");
            answers[tok] = f12;
          }
        }

        steps.add(TimetableChartStep(
          title: "Step 2: Convert Each Time Step-by-Step",
          description: stepDescLines.join("\n\n"),
          mathLaTeX: stepMathLines.join("\n"),
        ));
      } else if (subMode == 1) {
        // Elapsed Time between Start and End
        final Map<String, dynamic> pStart = parseTimeToken(startTimeStr);
        final Map<String, dynamic> pEnd = parseTimeToken(endTimeStr);
        final int startMins = pStart['totalMins'] as int;
        final int endMins = pEnd['totalMins'] as int;

        final int sH = startMins ~/ 60, sM = startMins % 60;
        int eH = endMins ~/ 60, eM = endMins % 60;

        bool crossesMidnight = false;
        if (endMins < startMins) {
          crossesMidnight = true;
          eH += 24;
        }

        visuals.add(ParsedClockVisual(
          rawInput: "Start: $startTimeStr",
          hours24: sH,
          minutes: sM,
          formatted12h: format12Hour(startMins),
          formatted24h: "${format24Hour(startMins)} hours",
        ));
        visuals.add(ParsedClockVisual(
          rawInput: "End: $endTimeStr",
          hours24: endMins ~/ 60,
          minutes: eM,
          formatted12h: format12Hour(endMins),
          formatted24h: "${format24Hour(endMins)} hours",
        ));

        workings.add(
            "\\text{\\textbf{Step 2: Convert Both Times to 24-Hour Clock}}");
        workings.add(
            "\\text{Start Time} = ${_cleanTex(startTimeStr)} = ${_twoDigits(sH)}:${_twoDigits(sM)} \\text{ hours}");
        workings.add(
            "\\text{End Time} = ${_cleanTex(endTimeStr)} = ${format24Hour(endMins)} \\text{ hours}");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 3: Subtract Start Time from End Time (Base-60 Borrowing)}}");

        int calcEndH = eH;
        int calcEndM = eM;
        String borrowExplainPlain = "";
        if (calcEndM < sM) {
          workings.add(
              "\\text{Since } ${_twoDigits(calcEndM)}\\text{ min} < ${_twoDigits(sM)}\\text{ min, borrow } 1\\text{ hour } (60\\text{ min}) \\text{ from } $calcEndH\\text{ h:}");
          workings.add(
              "$calcEndH\\text{ h } ${_twoDigits(calcEndM)}\\text{ min} = ${calcEndH - 1}\\text{ h } ($calcEndM + 60)\\text{ min} = ${calcEndH - 1}\\text{ h } ${calcEndM + 60}\\text{ min}");
          borrowExplainPlain =
          "\n• Base-60 Borrowing: Since the ending minutes ($calcEndM min) are smaller than the starting minutes ($sM min), borrow 1 hour (= 60 minutes) from $calcEndH h to get ${calcEndH - 1} h ${calcEndM + 60} min.";
          calcEndH -= 1;
          calcEndM += 60;
        }

        final int diffH = calcEndH - sH;
        final int diffM = calcEndM - sM;
        final int totalElapsed = diffH * 60 + diffM;

        workings.add(
            "\\text{Hours: } $calcEndH - $sH = $diffH\\text{ h} \\quad ; \\quad \\text{Minutes: } $calcEndM - $sM = $diffM\\text{ min}");
        workings.add(
            "\\text{Elapsed Time} = ${formatDuration(totalElapsed)} \\text{ ($totalElapsed minutes)}");

        steps.add(TimetableChartStep(
          title: "Step 2: Subtract Start Time from End Time",
          description:
          "1. Convert both times to 24-hour clock: Start = ${_twoDigits(sH)}:${_twoDigits(sM)} hours, End = ${format24Hour(endMins)} hours.${crossesMidnight ? ' (Crosses midnight, so add 24 hours to End Time → $eH:${_twoDigits(eM)}).' : ''}"
              "$borrowExplainPlain\n"
              "2. Subtract the hours ($calcEndH − $sH = $diffH h) and subtract the minutes ($calcEndM − $sM = $diffM min).\n"
              "3. Total time elapsed = ${formatDuration(totalElapsed)} ($totalElapsed minutes).",
          mathLaTeX:
          "\\text{Elapsed Time} = $calcEndH\\text{ h } ${_twoDigits(calcEndM)}\\text{ min} - $sH\\text{ h } ${_twoDigits(sM)}\\text{ min} = ${formatDuration(totalElapsed)}",
        ));

        answers["Start (24h)"] = "${format24Hour(startMins)} hours";
        answers["End (24h)"] = "${format24Hour(endMins)} hours";
        answers["Elapsed Duration"] = formatDuration(totalElapsed);
        answers["Total Minutes"] = "$totalElapsed min";
      } else {
        // Add / Subtract Duration from Start Time
        final Map<String, dynamic> pStart = parseTimeToken(startTimeStr);
        final int startMins = pStart['totalMins'] as int;
        final int sH = startMins ~/ 60, sM = startMins % 60;

        final int dH = int.tryParse(durationHoursStr.trim()) ?? 0;
        final int dM = int.tryParse(durationMinsStr.trim()) ?? 0;
        final int deltaMins = dH * 60 + dM;
        final int resultMins =
        isAddDuration ? (startMins + deltaMins) : (startMins - deltaMins);
        final int wrappedResult = ((resultMins % 1440) + 1440) % 1440;

        visuals.add(ParsedClockVisual(
          rawInput: "Start: $startTimeStr",
          hours24: sH,
          minutes: sM,
          formatted12h: format12Hour(startMins),
          formatted24h: "${format24Hour(startMins)} hours",
        ));
        visuals.add(ParsedClockVisual(
          rawInput: "Result Time",
          hours24: wrappedResult ~/ 60,
          minutes: wrappedResult % 60,
          formatted12h: format12Hour(wrappedResult),
          formatted24h: "${format24Hour(wrappedResult)} hours",
        ));

        final String opSym = isAddDuration ? "+" : "-";
        workings.add(
            "\\text{\\textbf{Step 2: ${isAddDuration ? 'Add' : 'Subtract'} Duration ($dH h $dM min)}}");
        workings.add(
            "\\text{Start Time} = ${_twoDigits(sH)}:${_twoDigits(sM)} \\text{ hours} \\quad $opSym \\quad $dH\\text{ h } ${_twoDigits(dM)}\\text{ min}");
        workings.add(
            "\\text{Result (24-Hour Clock)} = ${format24Hour(wrappedResult)} \\text{ hours}");
        workings.add(
            "\\text{Result (12-Hour Clock)} = ${_cleanTex(format12Hour(wrappedResult))}");

        steps.add(TimetableChartStep(
          title:
          "Step 2: ${isAddDuration ? 'Add' : 'Subtract'} $dH h $dM min ${isAddDuration ? 'to' : 'from'} ${format24Hour(startMins)} hours",
          description:
          "Starting at ${format24Hour(startMins)} hours (${format12Hour(startMins)}), we ${isAddDuration ? 'add' : 'subtract'} $dH hours and $dM minutes (carrying or borrowing 60 minutes = 1 hour where needed).\n"
              "• 24-hour clock result: ${format24Hour(wrappedResult)} hours.\n"
              "• 12-hour clock result: ${format12Hour(wrappedResult)}.",
          mathLaTeX:
          "${_twoDigits(sH)}:${_twoDigits(sM)} $opSym $dH\\text{ h } ${_twoDigits(dM)}\\text{ min} = ${format24Hour(wrappedResult)} \\text{ hours } (${_cleanTex(format12Hour(wrappedResult))})",
        ));

        answers["Result (24-Hour)"] = "${format24Hour(wrappedResult)} hours";
        answers["Result (12-Hour)"] = format12Hour(wrappedResult);
      }

      return TimetableChartResult(
        topicMode: 0,
        subMode: subMode,
        title: "12-Hour & 24-Hour Clock Conversions",
        clockVisuals: visuals,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
      );
    } catch (e) {
      return TimetableChartResult.error(
        topicMode: 0,
        title: "Clock & Time Calculator",
        message: e is FormatException
            ? e.message
            : "Please check your time format (e.g. 5.40 a.m., 19:25, or '5 to 9 at night').",
      );
    }
  }

  static TimetableChartResult solveJourneyTimetable({
    required String serviceTitle,
    required List<JourneyStopInput> stops,
    required int originIdx,
    required int destIdx,
    required String actualFlightDurationStr,
    required String compareLegDurationStr,
  }) {
    try {
      if (stops.length < 2) {
        throw const FormatException(
            "Please enter at least 2 stations/stops in the timetable.");
      }

      final int safeOrigin = originIdx.clamp(0, stops.length - 1);
      final int safeDest = destIdx.clamp(0, stops.length - 1);
      if (safeOrigin >= safeDest) {
        throw const FormatException(
            "Select a Destination station that comes after the Origin station in the journey list.");
      }

      final String cleanTitle = serviceTitle.trim().isEmpty
          ? "Journey Timetable Analysis"
          : serviceTitle.trim();

      final List<TimetableChartStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      // Parse all stops
      final List<int?> arrMins = [];
      final List<int?> depMins = [];
      final List<String> stationNames = [];

      for (int i = 0; i < stops.length; i++) {
        final String sName = stops[i].stationName.trim().isEmpty
            ? "Station ${i + 1}"
            : stops[i].stationName.trim();
        stationNames.add(sName);

        arrMins.add(stops[i].arrivalTime.trim().isEmpty
            ? null
            : parseTimeToken(stops[i].arrivalTime)['totalMins'] as int);
        depMins.add(stops[i].departureTime.trim().isEmpty
            ? null
            : parseTimeToken(stops[i].departureTime)['totalMins'] as int);
      }

      if (depMins[safeOrigin] == null) {
        throw FormatException(
            "Origin station '${stationNames[safeOrigin]}' must have a Departure time (D).");
      }
      if (arrMins[safeDest] == null) {
        throw FormatException(
            "Destination station '${stationNames[safeDest]}' must have an Arrival time (A).");
      }

      // Step 1: Decode D (Depart) and A (Arrive)
      workings.add(
          "\\text{\\textbf{Step 1: Reading Arrival (A) and Departure (D) Times}}");
      workings.add(
          "\\text{Service: ${_cleanTex(cleanTitle)}} \\quad (\\text{D} = \\text{Depart}, \\; \\text{A} = \\text{Arrive})");

      final List<String> scheduleLinesPlain = [];
      for (int i = 0; i < stops.length; i++) {
        final String aStr = arrMins[i] != null
            ? "${stops[i].arrivalTime.trim()} (${format24Hour(arrMins[i]!)})"
            : "—";
        final String dStr = depMins[i] != null
            ? "${stops[i].departureTime.trim()} (${format24Hour(depMins[i]!)})"
            : "—";
        workings.add(
            "\\bullet \\text{ ${_cleanTex(stationNames[i])}: Arrive (A)} = ${_cleanTex(aStr)}, \\quad \\text{Depart (D)} = ${_cleanTex(dStr)}");
        scheduleLinesPlain.add(
            "• ${stationNames[i]}: Arrive (A) = $aStr  |  Depart (D) = $dStr");
      }
      workings.add("");

      steps.add(TimetableChartStep(
        title: "Step 1: Decode 'D' (Departure) and 'A' (Arrival) in 24-Hour Time",
        description:
        "In a railway or flight timetable, 'D' (or 'd.') stands for Departure time (when the train/aircraft leaves) and 'A' (or 'a.') stands for Arrival time (when it reaches a station). Converting all times to the 24-hour clock makes subtraction easy:\n\n"
            "${scheduleLinesPlain.join('\n')}",
        mathLaTeX:
        "\\text{Origin (${_cleanTex(stationNames[safeOrigin])}) Depart} = ${format24Hour(depMins[safeOrigin]!)} \\text{ hours}\n"
            "\\text{Destination (${_cleanTex(stationNames[safeDest])}) Arrive} = ${format24Hour(arrMins[safeDest]!)} \\text{ hours}",
      ));

      answers["${stationNames[safeOrigin]} Depart"] =
      "${stops[safeOrigin].departureTime.trim()} (${format24Hour(depMins[safeOrigin]!)})";
      answers["${stationNames[safeDest]} Arrive"] =
      "${stops[safeDest].arrivalTime.trim()} (${format24Hour(arrMins[safeDest]!)})";

      // Step 2: Intermediate Stopover / Ground Waiting Times
      final List<String> stopoverDescriptions = [];
      final List<String> stopoverMath = [];
      final List<int?> stopoverMinsList = List.filled(stops.length, null);

      workings.add(
          "\\text{\\textbf{Step 2: Stopover / Waiting Time at Intermediate Stations}}");
      for (int i = 0; i < stops.length; i++) {
        if (arrMins[i] != null && depMins[i] != null) {
          int wait = depMins[i]! - arrMins[i]!;
          if (wait < 0) wait += 1440;
          stopoverMinsList[i] = wait;

          final String sClean = _cleanTex(stationNames[i]);
          final String a24 = format24Hour(arrMins[i]!);
          final String d24 = format24Hour(depMins[i]!);
          workings.add(
              "\\bullet \\text{ Wait at $sClean} = \\text{Depart } ($d24) - \\text{Arrive } ($a24) = ${formatDuration(wait)}");
          stopoverDescriptions.add(
              "• ${stationNames[i]}: Arrives at ${stops[i].arrivalTime.trim()} ($a24) and departs at ${stops[i].departureTime.trim()} ($d24).\n"
                  "   Waiting time on the ground = $d24 − $a24 = ${formatDuration(wait)}.");
          stopoverMath.add(
              "\\text{Wait at $sClean} = $d24 - $a24 = ${formatDuration(wait)}");
          answers["Wait at ${stationNames[i]}"] = formatDuration(wait);
        }
      }

      if (stopoverDescriptions.isNotEmpty) {
        steps.add(TimetableChartStep(
          title:
          "Step 2: Calculate Stopover / Ground Waiting Time at Intermediate Stops",
          description:
          "To find how long the train or aircraft stays at an intermediate station, subtract its Arrival time (A) at that station from its Departure time (D) from the same station:\n\n"
              "${stopoverDescriptions.join('\n\n')}",
          mathLaTeX: stopoverMath.join("\n"),
        ));
      } else {
        workings.add("\\text{No intermediate stopover times recorded.}");
      }
      workings.add("");

      // Step 3: Leg-by-Leg & Total Journey Duration (with explicit base-60 borrowing)
      workings.add(
          "\\text{\\textbf{Step 3: Leg Durations and Total Journey Time}}");
      final List<int?> legMinsToNext = List.filled(stops.length, null);
      final List<String> legPlainLines = [];

      for (int i = 0; i < stops.length - 1; i++) {
        if (depMins[i] != null && arrMins[i + 1] != null) {
          int leg = arrMins[i + 1]! - depMins[i]!;
          if (leg < 0) leg += 1440;
          legMinsToNext[i] = leg;

          final String fromClean = _cleanTex(stationNames[i]);
          final String toClean = _cleanTex(stationNames[i + 1]);
          final String d24 = format24Hour(depMins[i]!);
          final String a24 = format24Hour(arrMins[i + 1]!);

          workings.add(
              "\\bullet \\text{ Leg ($fromClean to $toClean)} = $a24 - $d24 = ${formatDuration(leg)}");
          legPlainLines.add(
              "• Leg ${i + 1} (${stationNames[i]} → ${stationNames[i + 1]}): Arrive $a24 − Depart $d24 = ${formatDuration(leg)}.");
        }
      }

      final int startM = depMins[safeOrigin]!;
      final int endM = arrMins[safeDest]!;
      final int sH = startM ~/ 60, sMin = startM % 60;
      int eH = endM ~/ 60, eMin = endM % 60;
      if (endM < startM) eH += 24;

      int borrowH = eH, borrowMin = eMin;
      String borrowNote = "";
      if (borrowMin < sMin) {
        borrowNote =
        "\n• Base-60 Borrowing: Since $borrowMin min is less than $sMin min, borrow 1 hour (= 60 min) from $borrowH h to get ${borrowH - 1} h ${borrowMin + 60} min.";
        borrowH -= 1;
        borrowMin += 60;
      }

      final int totalJourneyMins = (borrowH - sH) * 60 + (borrowMin - sMin);
      final String origClean = _cleanTex(stationNames[safeOrigin]);
      final String destClean = _cleanTex(stationNames[safeDest]);

      workings.add(
          "\\Rightarrow \\text{Total Journey ($origClean to $destClean)} = ${format24Hour(endM)} - ${format24Hour(startM)} = ${formatDuration(totalJourneyMins)}");

      steps.add(TimetableChartStep(
        title:
        "Step 3: Calculate Leg Times and Total Journey (${stationNames[safeOrigin]} → ${stationNames[safeDest]})",
        description:
        "To find the journey time between '${stationNames[safeOrigin]}' and '${stationNames[safeDest]}', subtract the Departure time at ${stationNames[safeOrigin]} (${format24Hour(startM)}) from the Arrival time at ${stationNames[safeDest]} (${format24Hour(endM)}):"
            "$borrowNote\n"
            "• Hours: $borrowH − $sH = ${borrowH - sH} h  |  Minutes: $borrowMin − $sMin = ${borrowMin - sMin} min.\n"
            "• Total Journey Duration = ${formatDuration(totalJourneyMins)}.\n\n"
            "Individual Leg Breakdown:\n${legPlainLines.join('\n')}",
        mathLaTeX:
        "\\text{Journey Time ($origClean to $destClean)} = ${format24Hour(endM)} - ${format24Hour(startM)} = ${formatDuration(totalJourneyMins)}",
      ));

      answers["${stationNames[safeOrigin]} → ${stationNames[safeDest]} Time"] =
          formatDuration(totalJourneyMins);

      // Optional Step 4A: Compare with another service/leg duration (Ex 18c #8c)
      final int? compMins = parseDurationToMinutes(compareLegDurationStr);
      if (compMins != null && compMins > 0) {
        final int diffMins = (totalJourneyMins - compMins).abs();
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 4: Time Difference Between Services / Legs}}");
        workings.add(
            "\\text{Difference} = |${formatDuration(totalJourneyMins)} - ${formatDuration(compMins)}| = |$totalJourneyMins\\text{ min} - $compMins\\text{ min}| = ${formatDuration(diffMins)}");

        steps.add(TimetableChartStep(
          title:
          "Step 4: Compare Duration Against ${formatDuration(compMins)} (Exercise 18c #8c)",
          description:
          "To find the difference between ${formatDuration(totalJourneyMins)} ($totalJourneyMins minutes) and ${formatDuration(compMins)} ($compMins minutes), subtract the smaller time from the larger time (borrowing 1 hour = 60 minutes if needed):\n"
              "• Difference = |$totalJourneyMins min − $compMins min| = ${formatDuration(diffMins)}.",
          mathLaTeX:
          "\\text{Time Difference} = ${formatDuration(math.max(totalJourneyMins, compMins))} - ${formatDuration(math.min(totalJourneyMins, compMins))} = ${formatDuration(diffMins)}",
        ));
        answers["Time Difference"] = formatDuration(diffMins);
      }

      // Optional Step 4B: Actual Flight Time & Local Time Zone Difference (Ex 18e #3c–d & #4c)
      final int? actualFlightMins =
      parseDurationToMinutes(actualFlightDurationStr);
      if (actualFlightMins != null && actualFlightMins > 0) {
        final int watchArrivalMins = (startM + actualFlightMins) % 1440;
        final int tzDiffMins = (endM - watchArrivalMins).abs();
        final String aheadBehind = endM >= watchArrivalMins ? "ahead of" : "behind";

        workings.add("");
        workings.add(
            "\\text{\\textbf{Step ${compMins != null ? 5 : 4}: Watch Time vs. Local Time Zone Difference}}");
        workings.add(
            "\\text{Origin Watch Time at Arrival} = ${format24Hour(startM)} + ${formatDuration(actualFlightMins)} = ${format24Hour(watchArrivalMins)} \\text{ hours}");
        workings.add(
            "\\text{Destination Local Time} = ${format24Hour(endM)} \\text{ hours}");
        workings.add(
            "\\text{Local Time Difference} = |${format24Hour(endM)} - ${format24Hour(watchArrivalMins)}| = ${formatDuration(tzDiffMins)}");

        steps.add(TimetableChartStep(
          title:
          "Step ${compMins != null ? 5 : 4}: Find Watch Time and Local Time Zone Difference (Ex 18e #3c–d)",
          description:
          "1. The traveller's watch is still set to ${stationNames[safeOrigin]} time (${format24Hour(startM)} hours).\n"
              "2. Add the actual journey duration (${formatDuration(actualFlightMins)}) to ${format24Hour(startM)}: Watch shows ${format24Hour(watchArrivalMins)} hours (${format12Hour(watchArrivalMins)}).\n"
              "3. However, the timetable shows the local arrival time in ${stationNames[safeDest]} is ${format24Hour(endM)} hours!\n"
              "4. Subtract the two times to find the difference in local times: |${format24Hour(endM)} − ${format24Hour(watchArrivalMins)}| = ${formatDuration(tzDiffMins)} (${stationNames[safeDest]} is ${formatDuration(tzDiffMins)} $aheadBehind ${stationNames[safeOrigin]}).",
          mathLaTeX:
          "\\text{Watch Time} = ${format24Hour(startM)} + ${formatDuration(actualFlightMins)} = ${format24Hour(watchArrivalMins)} \\text{ hours}\n"
              "\\text{Time Zone Difference} = ${format24Hour(endM)} - ${format24Hour(watchArrivalMins)} = ${formatDuration(tzDiffMins)}",
        ));

        answers["Watch Time on Arrival"] =
        "${format24Hour(watchArrivalMins)} hours";
        answers["Local Time Difference"] = formatDuration(tzDiffMins);
      }

      final List<ParsedStationVisual> visuals = List.generate(stops.length, (i) {
        return ParsedStationVisual(
          name: stationNames[i],
          arr24: arrMins[i] != null ? format24Hour(arrMins[i]!) : "—",
          dep24: depMins[i] != null ? format24Hour(depMins[i]!) : "—",
          stopoverMins: stopoverMinsList[i],
          legMinsToNext: legMinsToNext[i],
        );
      });

      return TimetableChartResult(
        topicMode: 1,
        title: cleanTitle,
        stationVisuals: visuals,
        selectedOriginIdx: safeOrigin,
        selectedDestIdx: safeDest,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
      );
    } catch (e) {
      return TimetableChartResult.error(
        topicMode: 1,
        title: serviceTitle,
        message: e is FormatException
            ? e.message
            : "Please check your station arrival and departure times.",
      );
    }
  }

  static TimetableChartResult solveSchoolTimetable({
    required String periodSlotsCsv,
    required List<SchoolDayInput> schoolDays,
  }) {
    try {
      final List<String> rawSlots = periodSlotsCsv
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (rawSlots.isEmpty) {
        throw const FormatException(
            "Please enter at least one period time slot (e.g. 07:00-07:40).");
      }
      if (schoolDays.isEmpty) {
        throw const FormatException("Please add at least one school day row.");
      }

      final List<int> slotStarts = [];
      final List<int> slotEnds = [];
      final List<int> slotLengths = [];

      for (final String slot in rawSlots) {
        final List<String> parts = slot
            .replaceAll(' to ', '-')
            .split('-')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (parts.length != 2) {
          throw FormatException(
              "Period slot '$slot' must have a start and end time separated by '-' or 'to' (e.g. 07:00-07:40).");
        }
        final int sM = parseTimeToken(parts[0])['totalMins'] as int;
        final int eM = parseTimeToken(parts[1])['totalMins'] as int;
        final int len = eM >= sM ? (eM - sM) : (eM + 1440 - sM);
        slotStarts.add(sM);
        slotEnds.add(eM);
        slotLengths.add(len);
      }

      final int numPeriods = rawSlots.length;
      final int firstLen = slotLengths.first;

      final List<TimetableChartStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      // Step 1: Periods per day & Length of each period
      workings.add(
          "\\text{\\textbf{Step 1: Number of Periods and Length of Each Period}}");
      workings.add(
          "\\text{Periods per Day} = $numPeriods \\text{ periods} \\quad (\\text{from } ${format24Hour(slotStarts.first)} \\text{ to } ${format24Hour(slotEnds.last)})");
      workings.add(
          "\\text{Length of 1 Period} = ${format24Hour(slotEnds.first)} - ${format24Hour(slotStarts.first)} = $firstLen \\text{ minutes}");
      workings.add("");

      steps.add(TimetableChartStep(
        title: "Step 1: Count Daily Periods and Subtract to Find Period Length",
        description:
        "1. Count the period columns across the top of the timetable: there are $numPeriods periods each day.\n"
            "2. Subtract the start time of Period 1 (${format24Hour(slotStarts.first)}) from its end time (${format24Hour(slotEnds.first)}):\n"
            "   ${format24Hour(slotEnds.first)} − ${format24Hour(slotStarts.first)} = $firstLen minutes per period.",
        mathLaTeX:
        "\\text{Periods per day} = $numPeriods \\quad ; \\quad \\text{Period Length} = ${format24Hour(slotEnds.first)} - ${format24Hour(slotStarts.first)} = $firstLen \\text{ min}",
      ));

      answers["Periods per Day"] = "$numPeriods periods";
      answers["Length of 1 Period"] = "$firstLen minutes";

      // Step 2: Detect Breaks Between Non-Contiguous Period Slots
      workings.add(
          "\\text{\\textbf{Step 2: Finding Break Durations Between Periods}}");
      final List<String> breakSummaries = [];
      final List<String> breakPlainLines = [];
      final List<String> breakMathLines = [];

      for (int i = 0; i < numPeriods - 1; i++) {
        final int prevEnd = slotEnds[i];
        final int nextStart = slotStarts[i + 1];
        if (nextStart > prevEnd) {
          final int gapMins = nextStart - prevEnd;
          final int bNum = breakSummaries.length + 1;
          final String bLabel =
              "Break $bNum (${format24Hour(prevEnd)}–${format24Hour(nextStart)}): ${formatDuration(gapMins)}";
          breakSummaries.add(bLabel);

          workings.add(
              "\\bullet \\text{ Break $bNum (after Period ${i + 1}): } ${format24Hour(nextStart)} - ${format24Hour(prevEnd)} = ${formatDuration(gapMins)} \\text{ ($gapMins min)}");
          breakPlainLines.add(
              "• Break $bNum (between Period ${i + 1} and Period ${i + 2}):\n"
                  "   Period ${i + 1} ends at ${format24Hour(prevEnd)}, but Period ${i + 2} starts at ${format24Hour(nextStart)}.\n"
                  "   Break length = ${format24Hour(nextStart)} − ${format24Hour(prevEnd)} = ${formatDuration(gapMins)} ($gapMins minutes).");
          breakMathLines.add(
              "\\text{Break $bNum} = ${format24Hour(nextStart)} - ${format24Hour(prevEnd)} = ${formatDuration(gapMins)}");
          answers["Break $bNum Length"] = formatDuration(gapMins);
        }
      }

      if (breakSummaries.isEmpty) {
        workings.add("\\text{All periods are back-to-back (0 breaks detected).}");
        steps.add(const TimetableChartStep(
          title: "Step 2: Check for Breaks Between Periods",
          description:
          "Every period starts at the exact minute the previous period ends, so there are no breaks between periods.",
          mathLaTeX: "\\text{Breaks} = 0",
        ));
      } else {
        steps.add(TimetableChartStep(
          title:
          "Step 2: Subtract Consecutive Period Times to Find Break Lengths",
          description:
          "Whenever the next period starts later than the previous period ended, there is a break in between:\n\n"
              "${breakPlainLines.join('\n\n')}",
          mathLaTeX: breakMathLines.join("\n"),
        ));
      }
      workings.add("");

      // Step 3: Tally Subjects Across the Week
      workings.add(
          "\\text{\\textbf{Step 3: Weekly Subject Frequency Tally}}");
      final Map<String, List<int>> subjectDailyCounts = {};
      final List<String> dayNames = [];

      for (int d = 0; d < schoolDays.length; d++) {
        final String dName = schoolDays[d].dayName.trim().isEmpty
            ? "Day ${d + 1}"
            : schoolDays[d].dayName.trim();
        dayNames.add(dName);

        final List<String> subs = schoolDays[d]
            .subjectsCsv
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        for (final String sub in subs) {
          subjectDailyCounts.putIfAbsent(
              sub, () => List.filled(schoolDays.length, 0));
          subjectDailyCounts[sub]![d] += 1;
        }
      }

      final Map<String, int> subjectTotals = {};
      final List<String> subPlainLines = [];
      final List<String> subMathLines = [];
      int grandTotalPeriods = 0;

      final List<String> sortedSubjects = subjectDailyCounts.keys.toList()
        ..sort((a, b) {
          final int sumA = subjectDailyCounts[a]!.fold(0, (x, y) => x + y);
          final int sumB = subjectDailyCounts[b]!.fold(0, (x, y) => x + y);
          if (sumB != sumA) return sumB.compareTo(sumA);
          return a.compareTo(b);
        });

      for (final String sub in sortedSubjects) {
        final List<int> daily = subjectDailyCounts[sub]!;
        final int total = daily.fold(0, (a, b) => a + b);
        subjectTotals[sub] = total;
        grandTotalPeriods += total;

        final String cleanSub = _cleanTex(sub);
        final String dailySumStr = daily.join(' + ');
        workings.add(
            "\\bullet \\text{ $cleanSub}: $dailySumStr = $total \\text{ periods/week}");
        subPlainLines.add(
            "• $sub: ${daily.asMap().entries.map((e) => '${dayNames[e.key]}=${e.value}').join(', ')} → Sum = $dailySumStr = $total periods.");
        subMathLines.add("\\text{$cleanSub} = $dailySumStr = $total \\text{ periods}");
        answers["$sub Periods"] = "$total / week";
      }

      workings.add(
          "\\text{Check Total: } ${subjectTotals.values.join(' + ')} = $grandTotalPeriods \\text{ periods} \\quad (${ sortedSubjects.length } \\text{ distinct subjects})");

      steps.add(TimetableChartStep(
        title:
        "Step 3: Tally Different Subjects (${sortedSubjects.length} Subjects, $grandTotalPeriods Weekly Periods)",
        description:
        "Count how many times each subject appears from ${dayNames.first} to ${dayNames.last} and add them up:\n\n"
            "${subPlainLines.join('\n')}\n\n"
            "• Total Check: ${subjectTotals.values.join(' + ')} = $grandTotalPeriods periods per week.",
        mathLaTeX:
        "${subMathLines.join('\n')}\n"
            "\\text{Total Weekly Periods} = $grandTotalPeriods",
      ));

      answers["Different Subjects"] = "${sortedSubjects.length} subjects";

      return TimetableChartResult(
        topicMode: 2,
        title: "School Timetable Analysis",
        periodHeaders: rawSlots,
        breakSummaries: breakSummaries,
        subjectFrequencies: subjectTotals,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
      );
    } catch (e) {
      return TimetableChartResult.error(
        topicMode: 2,
        title: "School Timetable",
        message: e is FormatException
            ? e.message
            : "Please check your period time slots and daily subject lists.",
      );
    }
  }

  static TimetableChartResult solveDistanceChart({
    required int subMode, // 0: Direct vs Via Intermediate City, 1: Multi-Stop Tour
    required int originCityIdx,
    required int destCityIdx,
    required int viaCityIdx,
    required String multiStopRouteCsv,
  }) {
    try {
      final List<TimetableChartStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      // Find global furthest and nearest city pairs in Figure 18.5
      int maxDist = -1;
      int minDist = 999999;
      String maxPair = "";
      String minPair = "";

      for (int r = 1; r < nigerianCities.length; r++) {
        for (int c = 0; c < r; c++) {
          final int d = _lowerDistanceTriangle[r][c];
          if (d > maxDist) {
            maxDist = d;
            maxPair = "${nigerianCities[c]} & ${nigerianCities[r]}";
          }
          if (d < minDist) {
            minDist = d;
            minPair = "${nigerianCities[c]} & ${nigerianCities[r]}";
          }
        }
      }

      workings.add(
          "\\text{\\textbf{Step 1: Reading the Triangular Distance Chart (Figure 18.5)}}");
      workings.add(
          "\\text{Furthest Cities in Chart: ${_cleanTex(maxPair)}} = $maxDist \\text{ km}");
      workings.add(
          "\\text{Nearest Cities in Chart: ${_cleanTex(minPair)}} = $minDist \\text{ km}");
      workings.add("");

      steps.add(TimetableChartStep(
        title: "Step 1: How to Read a Triangular Distance Chart (Figure 18.5)",
        description:
        "To find the road distance between two cities in a triangular distance chart:\n"
            "1. Locate the earlier city in alphabetical order along the top diagonal step and move vertically DOWN its column.\n"
            "2. Locate the second city on the left/right row and move horizontally ACROSS its row.\n"
            "3. The box where the row and column meet gives the road distance in kilometres (km).\n"
            "• Furthest cities in Figure 18.5: $maxPair ($maxDist km).\n"
            "• Nearest cities in Figure 18.5: $minPair ($minDist km).",
        mathLaTeX:
        "\\text{Furthest Apart: ${_cleanTex(maxPair)}} = $maxDist \\text{ km}\n"
            "\\text{Nearest Together: ${_cleanTex(minPair)}} = $minDist \\text{ km}",
      ));

      if (subMode == 0) {
        final int safeOrig = originCityIdx.clamp(0, nigerianCities.length - 1);
        final int safeDest = destCityIdx.clamp(0, nigerianCities.length - 1);
        final int safeVia = viaCityIdx.clamp(0, nigerianCities.length - 1);

        if (safeOrig == safeDest) {
          throw const FormatException(
              "Please choose two different cities for Origin and Destination.");
        }

        final String origName = nigerianCities[safeOrig];
        final String destName = nigerianCities[safeDest];
        final String viaName = nigerianCities[safeVia];

        final int directKm = getCityDistanceKm(safeOrig, safeDest);
        final int leg1Km = getCityDistanceKm(safeOrig, safeVia);
        final int leg2Km = getCityDistanceKm(safeVia, safeDest);
        final int viaTotalKm = leg1Km + leg2Km;
        final int extraKm = viaTotalKm - directKm;

        workings.add(
            "\\text{\\textbf{Step 2: Direct Route vs. Route Via $viaName}}");
        workings.add(
            "\\text{1. Direct Distance ($origName to $destName)} = $directKm \\text{ km}");
        workings.add(
            "\\text{2. Route Via $viaName: } (\\text{$origName to $viaName}) + (\\text{$viaName to $destName}) = $leg1Km + $leg2Km = $viaTotalKm \\text{ km}");
        workings.add(
            "\\text{3. Extra Distance Via $viaName} = $viaTotalKm - $directKm = $extraKm \\text{ km}");

        steps.add(TimetableChartStep(
          title:
          "Step 2: Compare Direct Route ($origName → $destName) vs. Via $viaName",
          description:
          "1. Direct Route ($origName → $destName): Cross-referencing '$origName' and '$destName' in the chart gives $directKm km.\n"
              "2. Indirect Route Via $viaName ($origName → $viaName → $destName):\n"
              "   • Leg 1 ($origName to $viaName) = $leg1Km km.\n"
              "   • Leg 2 ($viaName to $destName) = $leg2Km km.\n"
              "   • Total distance via $viaName = $leg1Km + $leg2Km = $viaTotalKm km.\n"
              "3. Difference: Travelling via $viaName adds $viaTotalKm − $directKm = $extraKm km compared to the direct road.",
          mathLaTeX:
          "\\text{Direct ($origName to $destName)} = $directKm \\text{ km}\n"
              "\\text{Via $viaName} = $leg1Km + $leg2Km = $viaTotalKm \\text{ km} \\quad (\\text{Difference} = $extraKm \\text{ km})",
        ));

        answers["$origName → $destName (Direct)"] = "$directKm km";
        answers["Via $viaName"] = "$viaTotalKm km ($leg1Km + $leg2Km)";
        answers["Difference"] = "+$extraKm km";
        answers["Chart Furthest"] = "$maxPair ($maxDist km)";
        answers["Chart Nearest"] = "$minPair ($minDist km)";

        return TimetableChartResult(
          topicMode: 3,
          subMode: 0,
          title: "Distance Chart: $origName to $destName",
          routeCities: [origName, viaName, destName],
          routeLegDistances: [leg1Km.toDouble(), leg2Km.toDouble()],
          directDistance: directKm.toDouble(),
          viaDistance: viaTotalKm.toDouble(),
          viaCityName: viaName,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
        );
      } else {
        // Multi-stop tour (e.g. Port Harcourt -> Owerri -> Enugu -> Calabar -> Port Harcourt)
        final List<String> rawStops = multiStopRouteCsv
            .split(RegExp(r'[,→>-]+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (rawStops.length < 2) {
          throw const FormatException(
              "Enter at least 2 city names separated by commas (e.g. Port Harcourt, Owerri, Enugu, Calabar, Port Harcourt).");
        }

        final List<int> stopIndices = [];
        final List<String> matchedNames = [];

        for (final String token in rawStops) {
          final int idx = nigerianCities.indexWhere(
                  (c) => c.toLowerCase() == token.toLowerCase() ||
                  c.toLowerCase().contains(token.toLowerCase()));
          if (idx == -1) {
            throw FormatException(
                "City '$token' is not in Figure 18.5. Available cities: ${nigerianCities.join(', ')}.");
          }
          stopIndices.add(idx);
          matchedNames.add(nigerianCities[idx]);
        }

        workings.add(
            "\\text{\\textbf{Step 2: Multi-Stop Route Distance Calculation}}");
        final List<double> legKmList = [];
        final List<String> legPlainLines = [];
        final List<String> legTerms = [];
        int totalTourKm = 0;

        for (int i = 0; i < stopIndices.length - 1; i++) {
          final int d = getCityDistanceKm(stopIndices[i], stopIndices[i + 1]);
          legKmList.add(d.toDouble());
          totalTourKm += d;
          legTerms.add(d.toString());

          final String c1 = matchedNames[i];
          final String c2 = matchedNames[i + 1];
          workings.add("\\bullet \\text{ Leg ${i + 1} ($c1 to $c2)} = $d \\text{ km}");
          legPlainLines
              .add("• Leg ${i + 1}: $c1 → $c2 = $d km (from chart intersection).");
        }

        final String sumExpr = legTerms.join(' + ');
        workings.add(
            "\\Rightarrow \\text{Total Route Distance} = $sumExpr = $totalTourKm \\text{ km}");

        steps.add(TimetableChartStep(
          title:
          "Step 2: Look Up Each Leg and Add for Total Route Distance",
          description:
          "Read the distance for each stage of the journey (${matchedNames.join(' → ')}) from the distance chart and add them together:\n\n"
              "${legPlainLines.join('\n')}\n\n"
              "• Total Distance Travelled = $sumExpr = $totalTourKm km.",
          mathLaTeX:
          "\\text{Total Distance} = $sumExpr = $totalTourKm \\text{ km}",
        ));

        answers["Total Trip Distance"] = "$totalTourKm km";
        for (int i = 0; i < legKmList.length; i++) {
          answers["Leg ${i + 1} (${matchedNames[i]}→${matchedNames[i + 1]})"] =
          "${legKmList[i].round()} km";
        }

        return TimetableChartResult(
          topicMode: 3,
          subMode: 1,
          title: "Multi-Stop Tour (${matchedNames.first} → ${matchedNames.last})",
          routeCities: matchedNames,
          routeLegDistances: legKmList,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
        );
      }
    } catch (e) {
      return TimetableChartResult.error(
        topicMode: 3,
        title: "Distance Chart",
        message: e is FormatException
            ? e.message
            : "Please check your city selections and route list.",
      );
    }
  }

  static TimetableChartResult solveKnockoutBracket({
    required String bracketTitle,
    required List<KnockoutMatchInput> matches,
    required String targetPlayerName,
  }) {
    try {
      if (matches.isEmpty) {
        throw const FormatException(
            "Please enter at least one tournament match.");
      }

      final List<TimetableChartStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      // Collect unique players and count first-round entrants
      final Set<String> allPlayers = {};
      for (final m in matches) {
        allPlayers.add(m.player1Name.trim());
        allPlayers.add(m.player2Name.trim());
      }
      final int numEntrants = allPlayers.length;
      final int totalMatches = matches.length;
      final KnockoutMatchInput finalMatch = matches.last;
      final String champion = finalMatch.winnerName;

      // Step 1: Entrants & Matches Played
      final int r1Count =
          matches.where((m) => m.roundName.toLowerCase().contains('1')).length;
      final int semiCount = matches
          .where((m) => m.roundName.toLowerCase().contains('semi'))
          .length;
      final int finCount = matches
          .where((m) => m.roundName.toLowerCase().contains('final') &&
          !m.roundName.toLowerCase().contains('semi'))
          .length;

      workings.add(
          "\\text{\\textbf{Step 1: Entrants, Total Matches, and Tournament Winner}}");
      workings.add(
          "\\text{Number of Entrants (Players)} = $numEntrants \\text{ players}");
      if (r1Count + semiCount + finCount == totalMatches && r1Count > 0) {
        workings.add(
            "\\text{Matches Played} = $r1Count \\text{ (1st Round)} + $semiCount \\text{ (Semifinals)} + $finCount \\text{ (Final)} = $totalMatches \\text{ matches}");
      } else {
        workings.add(
            "\\text{Matches Played (Knockout Rule: } N - 1\\text{)} = $numEntrants - 1 = $totalMatches \\text{ matches}");
      }
      workings.add(
          "\\text{Tournament Winner} = \\text{${_cleanTex(champion)} (beat ${_cleanTex(finalMatch.loserName)} ${finalMatch.winnerScore} to ${finalMatch.loserScore} in Final)}");
      workings.add("");

      steps.add(TimetableChartStep(
        title: "Step 1: Count Total Entrants, Matches Played, and Overall Winner",
        description:
        "• Total Entrants: Counting all players in the 1st Round column gives $numEntrants players (${allPlayers.join(', ')}).\n"
            "• Total Matches Played: Add the matches in each round ($r1Count in 1st Round + $semiCount in Semifinals + $finCount in Final = $totalMatches matches). In any knockout tournament, every match eliminates 1 player, so $numEntrants players require $numEntrants − 1 = $totalMatches matches.\n"
            "• Tournament Winner: $champion (won the Final ${finalMatch.winnerScore} to ${finalMatch.loserScore} against ${finalMatch.loserName}).",
        mathLaTeX:
        "\\text{Entrants } (N) = $numEntrants \\quad ; \\quad \\text{Matches} = $r1Count + $semiCount + $finCount = $totalMatches\n"
            "\\text{Champion} = \\text{${_cleanTex(champion)}}",
      ));

      answers["Total Entrants"] = "$numEntrants players";
      answers["Total Matches"] = "$totalMatches matches";
      answers["Tournament Winner"] = champion;

      // Step 2: Trace Winner's Full Stats (Question 4c)
      _addPlayerTraceStep(
        stepNumber: 2,
        playerLabel: "Winner ($champion)",
        playerName: champion,
        matches: matches,
        workings: workings,
        steps: steps,
        answers: answers,
        isChampion: true,
      );

      // Step 3: Trace Selected Target Player's Stats (e.g. Ojo in Question 4d)
      final String cleanTarget = targetPlayerName.trim().isEmpty
          ? finalMatch.loserName
          : targetPlayerName.trim();
      if (cleanTarget.toLowerCase() != champion.toLowerCase()) {
        workings.add("");
        _addPlayerTraceStep(
          stepNumber: 3,
          playerLabel: cleanTarget,
          playerName: cleanTarget,
          matches: matches,
          workings: workings,
          steps: steps,
          answers: answers,
          isChampion: false,
        );
      }

      return TimetableChartResult(
        topicMode: 4,
        subMode: 0,
        title: bracketTitle.trim().isEmpty
            ? "Knockout Tournament Bracket"
            : bracketTitle.trim(),
        bracketMatches: matches,
        highlightedPlayer: cleanTarget,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
      );
    } catch (e) {
      return TimetableChartResult.error(
        topicMode: 4,
        title: bracketTitle,
        message: "Please check your tournament bracket matches and scores.",
      );
    }
  }

  static void _addPlayerTraceStep({
    required int stepNumber,
    required String playerLabel,
    required String playerName,
    required List<KnockoutMatchInput> matches,
    required List<String> workings,
    required List<TimetableChartStep> steps,
    required Map<String, String> answers,
    required bool isChampion,
  }) {
    final List<KnockoutMatchInput> playerMatches = matches
        .where((m) =>
    m.player1Name.toLowerCase() == playerName.toLowerCase() ||
        m.player2Name.toLowerCase() == playerName.toLowerCase())
        .toList();

    if (playerMatches.isEmpty) return;

    final List<int> pointsFor = [];
    final List<int> pointsAgainst = [];
    final List<String> beatenOpponents = [];
    final List<String> matchBreakdownLines = [];

    for (final m in playerMatches) {
      final bool isP1 =
          m.player1Name.toLowerCase() == playerName.toLowerCase();
      final int myScore = isP1 ? m.player1Score : m.player2Score;
      final int oppScore = isP1 ? m.player2Score : m.player1Score;
      final String oppName = isP1 ? m.player2Name : m.player1Name;
      final bool won = myScore >= oppScore;

      pointsFor.add(myScore);
      pointsAgainst.add(oppScore);
      if (won) beatenOpponents.add(oppName);

      matchBreakdownLines.add(
          "• ${m.roundName}: $playerName ($myScore) vs $oppName ($oppScore) → ${won ? 'Beat $oppName' : 'Lost to $oppName'}.");
    }

    final int sumFor = pointsFor.fold(0, (a, b) => a + b);
    final int sumAgainst = pointsAgainst.fold(0, (a, b) => a + b);
    final String forExpr = pointsFor.join(' + ');
    final String againstExpr = pointsAgainst.join(' + ');
    final String pClean = _cleanTex(playerName);
    final String beatenStr =
    beatenOpponents.isEmpty ? "None" : beatenOpponents.join(', ');

    workings.add(
        "\\text{\\textbf{Step $stepNumber: Performance Breakdown for $pClean}}");
    workings.add(
        "\\bullet \\text{ Matches Played by $pClean} = ${playerMatches.length} \\quad ; \\quad \\text{People Beaten: ${_cleanTex(beatenStr)}}");
    workings.add(
        "\\bullet \\text{ Points Scored BY $pClean} = $forExpr = $sumFor \\text{ points}");
    workings.add(
        "\\bullet \\text{ Points Scored AGAINST $pClean} = $againstExpr = $sumAgainst \\text{ points}");

    steps.add(TimetableChartStep(
      title:
      "Step $stepNumber: Trace $playerLabel Across All Rounds",
      description:
      "Follow $playerName through each column of the bracket:\n"
          "${matchBreakdownLines.join('\n')}\n\n"
          "• Matches played: ${playerMatches.length}.\n"
          "• Opponents beaten: $beatenStr.\n"
          "• Total points scored BY $playerName: $forExpr = $sumFor points.\n"
          "• Total points scored AGAINST $playerName (by opponents): $againstExpr = $sumAgainst points.",
      mathLaTeX:
      "\\text{$pClean Points Scored} = $forExpr = $sumFor \\text{ pts}\n"
          "\\text{Points Scored Against $pClean} = $againstExpr = $sumAgainst \\text{ pts}",
    ));

    if (isChampion) {
      answers["$playerName Beaten"] = beatenStr;
      answers["$playerName Points"] = "$sumFor pts ($forExpr)";
    } else {
      answers["$playerName Scored"] = "$sumFor pts ($forExpr)";
      answers["Against $playerName"] = "$sumAgainst pts ($againstExpr)";
    }
  }

  static TimetableChartResult solveTargetChart({
    required String chartTitle,
    required String unitStr,
    required String thresholdStr,
    required String labelsCsv,
    required String valuesCsv,
  }) {
    try {
      final List<String> labels = labelsCsv
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> valTokens = valuesCsv
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (labels.isEmpty || valTokens.isEmpty) {
        throw const FormatException(
            "Please enter both period labels and values separated by commas.");
      }
      if (labels.length != valTokens.length) {
        throw FormatException(
            "You entered ${labels.length} labels but ${valTokens.length} values. Both lists must have the same count.");
      }

      final double? target =
      double.tryParse(thresholdStr.trim().replaceAll(',', ''));
      if (target == null) {
        throw const FormatException("Please enter a valid target threshold.");
      }

      final List<double> values = [];
      for (final String t in valTokens) {
        final double? v = double.tryParse(t.replaceAll(',', ''));
        if (v == null) {
          throw FormatException("Could not parse '$t' as a valid number.");
        }
        values.add(v);
      }

      final String cleanTitle = chartTitle.trim().isEmpty
          ? "Target Performance Chart"
          : chartTitle.trim();
      final String unit = unitStr.trim();
      final String plainUnit = unit.isEmpty ? "" : " $unit";
      final String texUnit = unit.isEmpty ? "" : " \\text{ ${_cleanTex(unit)}}";

      final List<String> achievedDays = [];
      final List<String> zeroDays = [];
      final List<String> otherBelowDays = [];
      final List<String> allBelowDays = [];

      for (int i = 0; i < labels.length; i++) {
        final double v = values[i];
        final String lbl = labels[i];
        if (v >= target - 1e-9) {
          achievedDays.add("$lbl (${formatNumber(v)})");
        } else {
          allBelowDays.add("$lbl (${formatNumber(v)})");
          if (v.abs() < 1e-9) {
            zeroDays.add(lbl);
          } else {
            otherBelowDays.add("$lbl (${formatNumber(v)})");
          }
        }
      }

      final double totalSum = values.fold(0.0, (a, b) => a + b);
      final double meanVal = totalSum / values.length;
      final int intSum = totalSum.round();
      final int count = values.length;
      final int wholeMean = intSum ~/ count;
      final int remMean = intSum % count;

      final List<TimetableChartStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      // Step 1: Read Each Point Against Target Line
      workings.add(
          "\\text{\\textbf{Step 1: Comparing Daily Values Against Target (${formatNumber(target)}$texUnit)}}");
      final List<String> readingPairs = List.generate(
          labels.length, (i) => "${_cleanTex(labels[i])} = ${formatNumber(values[i])}");
      workings.add("\\text{Readings: } ${readingPairs.join(', \\; ')}");
      workings.add(
          "\\bullet \\text{ Achieved Target } (\\ge ${formatNumber(target)}): \\text{${_cleanTex(achievedDays.isEmpty ? 'None' : achievedDays.join(', '))}}");
      workings.add(
          "\\bullet \\text{ Zero / Did Not Walk } (= 0): \\text{${_cleanTex(zeroDays.isEmpty ? 'None' : zeroDays.join(', '))}}");
      workings.add(
          "\\bullet \\text{ Other Days Below Target } (< ${formatNumber(target)}): \\text{${_cleanTex(otherBelowDays.isEmpty ? 'None' : otherBelowDays.join(', '))}}");
      workings.add("");

      steps.add(TimetableChartStep(
        title:
        "Step 1: Compare Each Plotted Point Against the Target Line (${formatNumber(target)}$plainUnit)",
        description:
        "Read the height of each plotted cross (+) on the vertical axis and compare it with the horizontal Target line at ${formatNumber(target)}$plainUnit:\n"
            "• Achieved Target (on or above ${formatNumber(target)}$plainUnit): ${achievedDays.isEmpty ? 'None' : achievedDays.join(', ')}.\n"
            "• Did Not Go / Zero Activity (= 0$plainUnit): ${zeroDays.isEmpty ? 'None' : zeroDays.join(', ')}.\n"
            "• Other Days Below Target (between 0 and ${formatNumber(target)}$plainUnit): ${otherBelowDays.isEmpty ? 'None' : otherBelowDays.join(', ')}.",
        mathLaTeX:
        "\\text{Achieved } (\\ge ${formatNumber(target)}) \\rightarrow \\text{${_cleanTex(achievedDays.isEmpty ? 'None' : achievedDays.join(', '))}}\n"
            "\\text{Zero } (= 0) \\rightarrow \\text{${_cleanTex(zeroDays.isEmpty ? 'None' : zeroDays.join(', '))}}\n"
            "\\text{Other Below } (< ${formatNumber(target)}) \\rightarrow \\text{${_cleanTex(otherBelowDays.isEmpty ? 'None' : otherBelowDays.join(', '))}}",
      ));

      // Step 2: Average for the Week (including 0 days!)
      final String addTerms = values.map(formatNumber).join(' + ');
      final String mixedFracTex = remMean != 0 && (totalSum - intSum).abs() < 1e-9
          ? " = $wholeMean\\frac{$remMean}{$count} \\approx ${formatNumber(meanVal, maxDecimals: 0)}$texUnit"
          : " = ${formatNumber(meanVal, maxDecimals: 1)}$texUnit";

      workings.add(
          "\\text{\\textbf{Step 2: Average (Mean) Across All $count Days}}");
      workings.add("\\text{Total} = $addTerms = ${formatNumber(totalSum)}$texUnit");
      workings.add(
          "\\text{Average} = \\frac{${formatNumber(totalSum)}}{$count}$mixedFracTex");

      steps.add(TimetableChartStep(
        title: "Step 2: Calculate the Average per Day for the Whole Period",
        description:
        "To find the average for all $count days (including any day with 0$plainUnit!), add all $count readings together and divide by $count:\n"
            "• Total = $addTerms = ${formatNumber(totalSum)}$plainUnit.\n"
            "• Average = ${formatNumber(totalSum)} ÷ $count = ${remMean != 0 ? '$wholeMean $remMean/$count (≈ ${formatNumber(meanVal, maxDecimals: 0)})' : formatNumber(meanVal, maxDecimals: 1)}$plainUnit per day.",
        mathLaTeX:
        "\\text{Total} = $addTerms = ${formatNumber(totalSum)}$texUnit\n"
            "\\text{Average} = \\frac{${formatNumber(totalSum)}}{$count}$mixedFracTex",
      ));

      answers["Achieved Target"] =
      achievedDays.isEmpty ? "None" : achievedDays.join(', ');
      answers["Zero Activity (0)"] =
      zeroDays.isEmpty ? "None" : zeroDays.join(', ');
      answers["Other Below Target"] =
      otherBelowDays.isEmpty ? "None" : otherBelowDays.join(', ');
      answers["Average per Day"] = remMean != 0
          ? "$wholeMean $remMean/$count (≈ ${formatNumber(meanVal, maxDecimals: 0)}$plainUnit)"
          : "${formatNumber(meanVal, maxDecimals: 1)}$plainUnit";

      return TimetableChartResult(
        topicMode: 4,
        subMode: 1,
        title: cleanTitle,
        targetLabels: labels,
        targetValues: values,
        targetThreshold: target,
        targetUnit: unit,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
      );
    } catch (e) {
      return TimetableChartResult.error(
        topicMode: 4,
        title: chartTitle,
        message: e is FormatException
            ? e.message
            : "Please check your target threshold and comma-separated values.",
      );
    }
  }
}