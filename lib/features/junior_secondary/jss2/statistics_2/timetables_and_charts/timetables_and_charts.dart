/// Represents a single pedagogical step in the Timetables and Charts solver.
class TimetableChartStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const TimetableChartStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a single station/stop row in a Journey or Flight Timetable (Mode 1).
class JourneyStopInput {
  final String stationName;
  final String arrivalTime; // Empty for starting station
  final String departureTime; // Empty for final destination

  const JourneyStopInput({
    required this.stationName,
    this.arrivalTime = '',
    this.departureTime = '',
  });
}

/// Represents a single day's subject row in a School Timetable (Mode 2).
class SchoolDayInput {
  final String dayName;
  final String subjectsCsv;

  const SchoolDayInput({
    required this.dayName,
    required this.subjectsCsv,
  });
}

/// Represents a single match in a Knockout Tournament Bracket (Mode 4).
class KnockoutMatchInput {
  final String roundName; // 'Round 1', 'Semifinal', 'Final'
  final String player1Name;
  final int player1Score;
  final String player2Name;
  final int player2Score;

  const KnockoutMatchInput({
    required this.roundName,
    required this.player1Name,
    required this.player1Score,
    required this.player2Name,
    required this.player2Score,
  });

  String get winnerName =>
      player1Score >= player2Score ? player1Name : player2Name;
  String get loserName =>
      player1Score >= player2Score ? player2Name : player1Name;
  int get winnerScore =>
      player1Score >= player2Score ? player1Score : player2Score;
  int get loserScore =>
      player1Score >= player2Score ? player2Score : player1Score;
}

/// Pre-configured textbook preset for instant one-tap loading across all 5 modes.
class TimetableChartPreset {
  final String chipLabel;
  final int topicMode; // 0: Clock, 1: Journey, 2: School, 3: Distance, 4: Bracket/Target

  // Mode 0: Clock & Time Arithmetic
  final int clockSubMode;
  final String clockListCsv;
  final String clockStart;
  final String clockEnd;
  final String durationHours;
  final String durationMins;
  final bool durationIsAdd;

  // Mode 1: Journey / Flight Timetable
  final String serviceTitle;
  final List<JourneyStopInput> stops;
  final int originStopIdx;
  final int destStopIdx;
  final String actualFlightDuration;
  final String compareLegDuration;

  // Mode 2: School Timetable
  final String periodSlotsCsv;
  final List<SchoolDayInput> schoolDays;

  // Mode 3: Triangular Distance Chart
  final int distanceSubMode; // 0: Direct vs Via, 1: Multi-Stop Tour
  final int originCityIdx;
  final int destCityIdx;
  final int viaCityIdx;
  final String multiStopRouteCsv;

  // Mode 4: Knockout Bracket & Target Chart
  final int chartSubMode; // 0: Knockout Bracket, 1: Target Line Chart
  final String bracketTitle;
  final List<KnockoutMatchInput> matches;
  final String targetPlayerName;
  final String targetChartTitle;
  final String targetUnit;
  final String targetThreshold;
  final String targetLabelsCsv;
  final String targetValuesCsv;

  const TimetableChartPreset({
    required this.chipLabel,
    required this.topicMode,
    this.clockSubMode = 0,
    this.clockListCsv = '',
    this.clockStart = '06:00',
    this.clockEnd = '11:30',
    this.durationHours = '6',
    this.durationMins = '10',
    this.durationIsAdd = true,
    this.serviceTitle = '',
    this.stops = const [],
    this.originStopIdx = 0,
    this.destStopIdx = 1,
    this.actualFlightDuration = '',
    this.compareLegDuration = '',
    this.periodSlotsCsv = '',
    this.schoolDays = const [],
    this.distanceSubMode = 0,
    this.originCityIdx = 4,
    this.destCityIdx = 11,
    this.viaCityIdx = 9,
    this.multiStopRouteCsv = '',
    this.chartSubMode = 0,
    this.bracketTitle = '',
    this.matches = const [],
    this.targetPlayerName = '',
    this.targetChartTitle = '',
    this.targetUnit = '',
    this.targetThreshold = '8000',
    this.targetLabelsCsv = '',
    this.targetValuesCsv = '',
  });
}

/// Parsed clock item for the Mode 0 visualizer.
class ParsedClockVisual {
  final String rawInput;
  final int hours24;
  final int minutes;
  final String formatted12h;
  final String formatted24h;

  const ParsedClockVisual({
    required this.rawInput,
    required this.hours24,
    required this.minutes,
    required this.formatted12h,
    required this.formatted24h,
  });
}

/// Parsed station node for the Mode 1 Journey Track visualizer.
class ParsedStationVisual {
  final String name;
  final String arr24;
  final String dep24;
  final int? stopoverMins;
  final int? legMinsToNext;

  const ParsedStationVisual({
    required this.name,
    required this.arr24,
    required this.dep24,
    this.stopoverMins,
    this.legMinsToNext,
  });
}

/// Holds the complete evaluated results, visual data, workings, and steps.
class TimetableChartResult {
  final int topicMode; // 0: Clock, 1: Journey, 2: School, 3: Distance, 4: Bracket/Target
  final int subMode;
  final String title;

  // Mode 0 Visuals
  final List<ParsedClockVisual> clockVisuals;

  // Mode 1 Visuals
  final List<ParsedStationVisual> stationVisuals;
  final int selectedOriginIdx;
  final int selectedDestIdx;

  // Mode 2 Visuals
  final List<String> periodHeaders;
  final List<String> breakSummaries;
  final Map<String, int> subjectFrequencies;

  // Mode 3 Visuals
  final List<String> routeCities;
  final List<double> routeLegDistances;
  final double? directDistance;
  final double? viaDistance;
  final String? viaCityName;

  // Mode 4 Visuals
  final List<KnockoutMatchInput> bracketMatches;
  final String highlightedPlayer;
  final List<String> targetLabels;
  final List<double> targetValues;
  final double targetThreshold;
  final String targetUnit;

  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<TimetableChartStep> steps;

  final bool valid;
  final String? errorMessage;

  const TimetableChartResult({
    required this.topicMode,
    this.subMode = 0,
    required this.title,
    this.clockVisuals = const [],
    this.stationVisuals = const [],
    this.selectedOriginIdx = 0,
    this.selectedDestIdx = 0,
    this.periodHeaders = const [],
    this.breakSummaries = const [],
    this.subjectFrequencies = const {},
    this.routeCities = const [],
    this.routeLegDistances = const [],
    this.directDistance,
    this.viaDistance,
    this.viaCityName,
    this.bracketMatches = const [],
    this.highlightedPlayer = '',
    this.targetLabels = const [],
    this.targetValues = const [],
    this.targetThreshold = 0,
    this.targetUnit = '',
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });

  factory TimetableChartResult.error({
    required int topicMode,
    required String title,
    required String message,
  }) {
    return TimetableChartResult(
      topicMode: topicMode,
      title: title,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      valid: false,
      errorMessage: message,
    );
  }
}