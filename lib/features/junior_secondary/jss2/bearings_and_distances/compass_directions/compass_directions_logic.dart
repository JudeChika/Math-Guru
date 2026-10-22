import 'compass_directions_models.dart';

class CompassDirectionsLogic {
  /// The 8 principal compass points (4 Main Cardinal + 4 Secondary Points — Figure 24.4)
  static const List<CompassPointInfo> eightPoints = [
    CompassPointInfo(
        code: 'N', fullName: 'North', angleDeg: 0.0, isMainCardinal: true),
    CompassPointInfo(
        code: 'NE', fullName: 'North-East', angleDeg: 45.0),
    CompassPointInfo(
        code: 'E', fullName: 'East', angleDeg: 90.0, isMainCardinal: true),
    CompassPointInfo(
        code: 'SE', fullName: 'South-East', angleDeg: 135.0),
    CompassPointInfo(
        code: 'S', fullName: 'South', angleDeg: 180.0, isMainCardinal: true),
    CompassPointInfo(
        code: 'SW', fullName: 'South-West', angleDeg: 225.0),
    CompassPointInfo(
        code: 'W', fullName: 'West', angleDeg: 270.0, isMainCardinal: true),
    CompassPointInfo(
        code: 'NW', fullName: 'North-West', angleDeg: 315.0),
  ];

  /// Full 16-point compass table (for 22.5° half-steps if entered by a student)
  static const List<CompassPointInfo> sixteenPoints = [
    CompassPointInfo(
        code: 'N', fullName: 'North', angleDeg: 0.0, isMainCardinal: true),
    CompassPointInfo(
        code: 'NNE', fullName: 'North-North-East', angleDeg: 22.5),
    CompassPointInfo(
        code: 'NE', fullName: 'North-East', angleDeg: 45.0),
    CompassPointInfo(
        code: 'ENE', fullName: 'East-North-East', angleDeg: 67.5),
    CompassPointInfo(
        code: 'E', fullName: 'East', angleDeg: 90.0, isMainCardinal: true),
    CompassPointInfo(
        code: 'ESE', fullName: 'East-South-East', angleDeg: 112.5),
    CompassPointInfo(
        code: 'SE', fullName: 'South-East', angleDeg: 135.0),
    CompassPointInfo(
        code: 'SSE', fullName: 'South-South-East', angleDeg: 157.5),
    CompassPointInfo(
        code: 'S', fullName: 'South', angleDeg: 180.0, isMainCardinal: true),
    CompassPointInfo(
        code: 'SSW', fullName: 'South-South-West', angleDeg: 202.5),
    CompassPointInfo(
        code: 'SW', fullName: 'South-West', angleDeg: 225.0),
    CompassPointInfo(
        code: 'WSW', fullName: 'West-South-West', angleDeg: 247.5),
    CompassPointInfo(
        code: 'W', fullName: 'West', angleDeg: 270.0, isMainCardinal: true),
    CompassPointInfo(
        code: 'WNW', fullName: 'West-North-West', angleDeg: 292.5),
    CompassPointInfo(
        code: 'NW', fullName: 'North-West', angleDeg: 315.0),
    CompassPointInfo(
        code: 'NNW', fullName: 'North-North-West', angleDeg: 337.5),
  ];

  // ===========================================================================
  // 13 TEXTBOOK PRESETS (Covers Figures 24.1–24.5, Exercise 24a #1–2 & Ex 24b)
  // ===========================================================================
  static const List<CompassDirectionPreset> textbookPresets = [
    CompassDirectionPreset(
      chipLabel: "Ex 24a #1a: Face East, turn 180°",
      mode: 0,
      startDir: 'East',
      turnClockwise: true,
      turnAngleStr: '180',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #1b: Face East, turn 45° right",
      mode: 0,
      startDir: 'East',
      turnClockwise: true,
      turnAngleStr: '45',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #1c: Face East, turn 90° right",
      mode: 0,
      startDir: 'East',
      turnClockwise: true,
      turnAngleStr: '90',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #1d: Face East, turn 90° left",
      mode: 0,
      startDir: 'East',
      turnClockwise: false,
      turnAngleStr: '90',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #2a: Angle between N and S",
      mode: 1,
      startDir: 'N',
      secondDir: 'S',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #2c: Angle between NE and E",
      mode: 1,
      startDir: 'NE',
      secondDir: 'E',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #2d: Angle between N and W",
      mode: 1,
      startDir: 'N',
      secondDir: 'W',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #2e: Angle between E and SW",
      mode: 1,
      startDir: 'E',
      secondDir: 'SW',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #2f: Angle between SW and W",
      mode: 1,
      startDir: 'SW',
      secondDir: 'W',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #2g: Angle between N and NW",
      mode: 1,
      startDir: 'N',
      secondDir: 'NW',
    ),
    CompassDirectionPreset(
      chipLabel: "Ex 24a #2h: Angle between NE and SW",
      mode: 1,
      startDir: 'NE',
      secondDir: 'SW',
    ),
    CompassDirectionPreset(
      chipLabel: "Fig 24.5: Bearing of B from A (NW) & A from B",
      mode: 2,
      pointAName: 'A',
      pointBName: 'B',
      dirBFromA: 'NW',
    ),
    CompassDirectionPreset(
      chipLabel: "Fig 24.1: Facing Sunrise (East) Orientation",
      mode: 3,
      startDir: 'Sunrise',
    ),
  ];

  static String fmt(double v, {int maxDecimals = 1}) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String cleanTex(String s) {
    return s
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('&', ' and ')
        .replaceAll('_', ' ')
        .trim();
  }

  /// Normalizes any angle into [0, 360)
  static double normalizeAngle360(double deg) {
    final double m = deg % 360.0;
    return m < 0 ? m + 360.0 : (m.abs() < 1e-9 ? 0.0 : m);
  }

  /// Parses user direction input like "N", "North", "NE", "North-East", "Sunrise", "Sunset", or a numeric degree "135"
  static Map<String, dynamic> parseCompassDirection(String raw) {
    final String clean = raw.trim();
    if (clean.isEmpty) {
      throw const FormatException(
          "Please enter a compass direction (e.g. N, East, NE, SW, or Sunrise).");
    }

    final String upper = clean
        .toUpperCase()
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .replaceAll('.', '');

    String? sunNote;
    String lookupKey = upper;

    if (upper == 'SUNRISE' || upper == 'RISINGSUN' || upper == 'SUNUP') {
      lookupKey = 'E';
      sunNote =
      "Recall from Figure 24.1 that the sun rises in the East (E = 90°).";
    } else if (upper == 'SUNSET' || upper == 'SETTINGSUN' || upper == 'SUNDOWN') {
      lookupKey = 'W';
      sunNote =
      "Recall from Figure 24.1 that the sun sets in the West (W = 270°).";
    } else if (upper == 'MAGNETICNEEDLE' || upper == 'NORTHPOLE') {
      lookupKey = 'N';
      sunNote =
      "Recall from Figure 24.3 that the magnetic compass needle always points North (N = 0°).";
    }

    final Map<String, String> wordToCode = {
      'NORTH': 'N',
      'NORTHEAST': 'NE',
      'EAST': 'E',
      'SOUTHEAST': 'SE',
      'SOUTH': 'S',
      'SOUTHWEST': 'SW',
      'WEST': 'W',
      'NORTHWEST': 'NW',
      'NORTHNORTHEAST': 'NNE',
      'EASTNORTHEAST': 'ENE',
      'EASTSOUTHEAST': 'ESE',
      'SOUTHSOUTHEAST': 'SSE',
      'SOUTHSOUTHWEST': 'SSW',
      'WESTSOUTHWEST': 'WSW',
      'WESTNORTHWEST': 'WNW',
      'NORTHNORTHWEST': 'NNW',
    };

    if (wordToCode.containsKey(lookupKey)) {
      lookupKey = wordToCode[lookupKey]!;
    }

    for (final pt in sixteenPoints) {
      if (pt.code == lookupKey) {
        return {
          'point': pt,
          'sunNote': sunNote,
        };
      }
    }

    // Also allow entering an exact degree like "135" or "135°"
    final double? degVal =
    double.tryParse(clean.replaceAll('°', '').trim());
    if (degVal != null) {
      final double norm = normalizeAngle360(degVal);
      final CompassPointInfo resolved = angleToCompassPoint(norm);
      return {
        'point': resolved,
        'sunNote': null,
      };
    }

    throw FormatException(
        "Unrecognized direction '$clean'. Enter N, NE, E, SE, S, SW, W, NW (or full names like North-East, Sunrise, Sunset).");
  }

  /// Resolves an angle in [0, 360) to an exact 8-point or 16-point direction, or nearest compass description
  static CompassPointInfo angleToCompassPoint(double deg) {
    final double norm = normalizeAngle360(deg);
    for (final pt in sixteenPoints) {
      if ((pt.angleDeg - norm).abs() < 1e-4 ||
          (norm - 360.0 - pt.angleDeg).abs() < 1e-4) {
        return pt;
      }
    }
    return CompassPointInfo(
      code: "${fmt(norm)}°",
      fullName: "${fmt(norm)}° clockwise from North",
      angleDeg: norm,
    );
  }

  /// Parses turn angle inputs like "90", "45", "180", "1/4 turn", "half turn", "right angle"
  static double parseTurnAngle(String raw) {
    final String s = raw.trim().toLowerCase().replaceAll('°', '');
    if (s.isEmpty) {
      throw const FormatException(
          "Please enter a turn angle in degrees (e.g. 45, 90, 135, or 180).");
    }
    if (s.contains('quarter') || s == '1/4' || s.contains('right angle')) {
      return 90.0;
    }
    if (s.contains('half') || s == '1/2') {
      return 180.0;
    }
    if (s.contains('threequarter') || s.contains('3/4')) {
      return 270.0;
    }
    if (s.contains('full') || s.contains('complete')) {
      return 360.0;
    }
    final double? val = double.tryParse(s);
    if (val == null || val < 0) {
      throw FormatException(
          "Invalid turn angle '$raw'. Enter a positive angle in degrees (e.g. 45, 90, or 180).");
    }
    return val;
  }

  /// Generates the step-by-step 45° sector trace around the 8-point compass rose
  static List<String> _build45DegreeStepTrace(
      double startDeg,
      double turnDeg,
      bool isClockwise,
      ) {
    final List<String> trace = [];
    if (turnDeg <= 0 || turnDeg > 720 || (turnDeg % 45.0).abs() > 1e-4) {
      return trace;
    }
    final int numSteps = (turnDeg / 45.0).round();
    double curr = normalizeAngle360(startDeg);
    trace.add("${angleToCompassPoint(curr).code} (${fmt(curr)}^\\circ)");

    for (int i = 0; i < numSteps; i++) {
      curr = normalizeAngle360(curr + (isClockwise ? 45.0 : -45.0));
      final CompassPointInfo pt = angleToCompassPoint(curr);
      trace.add("${pt.code} (${fmt(curr)}^\\circ)");
    }
    return trace;
  }

  /// Swaps N<->S and E<->W letter-by-letter to show the textbook reciprocal rule
  static String swapOppositeLetters(String code) {
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < code.length; i++) {
      final String ch = code[i];
      if (ch == 'N') {
        buf.write('S');
      } else if (ch == 'S') {
        buf.write('N');
      } else if (ch == 'E') {
        buf.write('W');
      } else if (ch == 'W') {
        buf.write('E');
      } else {
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  // ===========================================================================
  // MODE 0: DIRECTION & TURNING SIMULATOR (Figure 24.1 & Exercise 24a #1a–d)
  // ===========================================================================
  static CompassDirectionResult solveDirectionTurn({
    required String startDirStr,
    required bool turnClockwise, // true: Right (Clockwise), false: Left (Anticlockwise)
    required String turnAngleStr,
    required String secondTurnAngleStr,
    required bool secondTurnClockwise,
  }) {
    try {
      final Map<String, dynamic> parsedStart =
      parseCompassDirection(startDirStr);
      final CompassPointInfo startPt =
      parsedStart['point'] as CompassPointInfo;
      final String? sunNote = parsedStart['sunNote'] as String?;

      final double turnDeg = parseTurnAngle(turnAngleStr);
      final String dirWord =
      turnClockwise ? "right (clockwise ↻)" : "left (anticlockwise ↺)";

      final List<String> workings = [];
      final List<CompassDirectionStep> steps = [];
      final Map<String, String> answers = {};

      // Step 1: Identify Starting Compass Point & Its Angle from North
      workings.add(
          "\\text{\\textbf{Step 1: Identify Starting Compass Direction and Angle from North}}");
      if (sunNote != null) {
        workings.add("\\text{Sunrise/Sunset Rule: } ${cleanTex(sunNote)}");
      }
      workings.add(
          "\\text{Starting Direction} = \\text{${startPt.fullName} (${startPt.code})} = ${fmt(startPt.angleDeg)}^\\circ \\text{ clockwise from North (N = } 0^\\circ\\text{)}");
      workings.add(
          "\\text{Compass Spacing Rule: Adjacent main points are } 90^\\circ \\text{ apart; adjacent 8-point directions are } 45^\\circ \\text{ apart.}");
      workings.add("");

      steps.add(CompassDirectionStep(
        title:
        "Step 1: Identify the Starting Direction (${startPt.fullName} — ${startPt.code})",
        description:
        "${sunNote != null ? '• $sunNote\n' : ''}"
            "• On the 8-point compass rose (Figure 24.4), directions are measured clockwise from North (N = 0°):\n"
            "  N = 0°, NE = 45°, E = 90°, SE = 135°, S = 180°, SW = 225°, W = 270°, NW = 315°.\n"
            "• You start facing ${startPt.fullName} (${startPt.code}), which is at ${fmt(startPt.angleDeg)}°.",
        mathLaTeX:
        "\\text{Start} = \\text{${startPt.fullName} (${startPt.code})} = ${fmt(startPt.angleDeg)}^\\circ",
      ));

      // Step 2: Convert Turn Angle into 45° / 90° Steps & Calculate New Angle
      final double rawNewAngle = turnClockwise
          ? (startPt.angleDeg + turnDeg)
          : (startPt.angleDeg - turnDeg);
      final double normNewAngle = normalizeAngle360(rawNewAngle);
      final CompassPointInfo finalPt1 = angleToCompassPoint(normNewAngle);

      final double steps45 = turnDeg / 45.0;
      final double steps90 = turnDeg / 90.0;

      workings.add(
          "\\text{\\textbf{Step 2: Turn Through }} ${fmt(turnDeg)}^\\circ \\text{\\textbf{ to Your ${turnClockwise ? 'Right (Clockwise)' : 'Left (Anticlockwise)'}}}");
      workings.add(
          "\\text{Number of } 45^\\circ \\text{ compass steps} = \\frac{${fmt(turnDeg)}^\\circ}{45^\\circ} = ${fmt(steps45)} \\text{ step(s)} \\quad \\left(\\frac{${fmt(turnDeg)}^\\circ}{90^\\circ} = ${fmt(steps90)} \\text{ right-angle quadrant(s)}\\right)");

      final String opSym = turnClockwise ? "+" : "-";
      workings.add(
          "\\text{Calculation: } ${fmt(startPt.angleDeg)}^\\circ $opSym ${fmt(turnDeg)}^\\circ = ${fmt(rawNewAngle)}^\\circ");

      String wrapExplain = "";
      if (rawNewAngle < 0) {
        workings.add(
            "\\text{Since } ${fmt(rawNewAngle)}^\\circ < 0^\\circ, \\text{ add a full turn } (+360^\\circ): \\quad ${fmt(rawNewAngle)}^\\circ + 360^\\circ = ${fmt(normNewAngle)}^\\circ");
        wrapExplain =
        "\n• Since ${fmt(rawNewAngle)}° is negative (passing North anticlockwise), add 360° (one full revolution): ${fmt(rawNewAngle)}° + 360° = ${fmt(normNewAngle)}°.";
      } else if (rawNewAngle >= 360.0) {
        workings.add(
            "\\text{Since } ${fmt(rawNewAngle)}^\\circ \\ge 360^\\circ, \\text{ subtract } 360^\\circ: \\quad ${fmt(rawNewAngle)}^\\circ - 360^\\circ = ${fmt(normNewAngle)}^\\circ");
        wrapExplain =
        "\n• Since ${fmt(rawNewAngle)}° is 360° or more (passing North clockwise), subtract 360°: ${fmt(rawNewAngle)}° − 360° = ${fmt(normNewAngle)}°.";
      }

      workings.add(
          "\\text{Direction at } ${fmt(normNewAngle)}^\\circ = \\mathbf{\\text{${finalPt1.fullName} (${finalPt1.code})}}");

      final List<String> trace1 = _build45DegreeStepTrace(
        startPt.angleDeg,
        turnDeg,
        turnClockwise,
      );
      if (trace1.length > 1) {
        final String arrow =
        turnClockwise ? "\\xrightarrow{+45^\\circ}" : "\\xrightarrow{-45^\\circ}";
        workings.add("\\text{Step-by-Step Compass Trace: } ${trace1.join(' $arrow ')}");
      }

      steps.add(CompassDirectionStep(
        title:
        "Step 2: Turn ${fmt(turnDeg)}° to the ${turnClockwise ? 'Right (Clockwise)' : 'Left (Anticlockwise)'}",
        description:
        "• Turning to your RIGHT moves CLOCKWISE around the compass (add the angle). Turning to your LEFT moves ANTICLOCKWISE (subtract the angle).\n"
            "• Since each adjacent 8-point direction is 45° apart (and each main direction is 90° apart), a turn of ${fmt(turnDeg)}° equals ${fmt(turnDeg)}° ÷ 45° = ${fmt(steps45)} compass step(s) of 45° (${fmt(steps90)} right-angle step(s) of 90°).\n"
            "• Angle calculation: ${fmt(startPt.angleDeg)}° $opSym ${fmt(turnDeg)}° = ${fmt(rawNewAngle)}°.$wrapExplain\n"
            "${trace1.length > 1 ? '• Visual trace around the compass: ${trace1.map((s) => s.replaceAll('^\\circ', '°')).join(' → ')}.\n' : ''}"
            "• At ${fmt(normNewAngle)}°, you are facing ${finalPt1.fullName} (${finalPt1.code})!",
        mathLaTeX:
        "${fmt(startPt.angleDeg)}^\\circ $opSym ${fmt(turnDeg)}^\\circ = ${fmt(normNewAngle)}^\\circ \\implies \\mathbf{\\text{${finalPt1.fullName} (${finalPt1.code})}}",
      ));

      answers["Starting Direction"] = "${startPt.fullName} (${startPt.code})";
      answers["Turn Applied"] = "${fmt(turnDeg)}° $dirWord";

      // Optional Second Turn (Multi-Step Exam Question)
      double? secondTurnSweep;
      double? finalAfterSecondDeg;
      String? finalAfterSecondLabel;

      if (secondTurnAngleStr.trim().isNotEmpty) {
        final double turn2Deg = parseTurnAngle(secondTurnAngleStr);
        final String dir2Word = secondTurnClockwise
            ? "right (clockwise ↻)"
            : "left (anticlockwise ↺)";
        final String op2Sym = secondTurnClockwise ? "+" : "-";

        final double rawAngle2 = secondTurnClockwise
            ? (normNewAngle + turn2Deg)
            : (normNewAngle - turn2Deg);
        final double normAngle2 = normalizeAngle360(rawAngle2);
        final CompassPointInfo finalPt2 = angleToCompassPoint(normAngle2);

        secondTurnSweep = secondTurnClockwise ? turn2Deg : -turn2Deg;
        finalAfterSecondDeg = normAngle2;
        finalAfterSecondLabel = "${finalPt2.code} (${fmt(normAngle2)}°)";

        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 3: Second Turn of }} ${fmt(turn2Deg)}^\\circ \\text{\\textbf{ to the ${secondTurnClockwise ? 'Right' : 'Left'}}}");
        workings.add(
            "${fmt(normNewAngle)}^\\circ $op2Sym ${fmt(turn2Deg)}^\\circ = ${fmt(rawAngle2)}^\\circ \\equiv ${fmt(normAngle2)}^\\circ \\implies \\mathbf{\\text{${finalPt2.fullName} (${finalPt2.code})}}");

        steps.add(CompassDirectionStep(
          title:
          "Step 3: Apply the Second Turn (${fmt(turn2Deg)}° $dir2Word)",
          description:
          "Starting from ${finalPt1.fullName} (${fmt(normNewAngle)}°), turn through ${fmt(turn2Deg)}° to the $dir2Word:\n"
              "• ${fmt(normNewAngle)}° $op2Sym ${fmt(turn2Deg)}° = ${fmt(normAngle2)}°.\n"
              "• Final Direction = ${finalPt2.fullName} (${finalPt2.code})!",
          mathLaTeX:
          "${fmt(normNewAngle)}^\\circ $op2Sym ${fmt(turn2Deg)}^\\circ = ${fmt(normAngle2)}^\\circ \\implies \\boxed{\\text{${finalPt2.fullName} (${finalPt2.code})}}",
        ));

        answers["After 1st Turn"] = "${finalPt1.fullName} (${finalPt1.code})";
        answers["Final Direction"] = "${finalPt2.fullName} (${finalPt2.code})";
      } else {
        answers["Final Direction"] = "${finalPt1.fullName} (${finalPt1.code})";
        answers["Final Angle from N"] = "${fmt(normNewAngle)}°";
      }

      return CompassDirectionResult(
        mode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CompassCanvasData(
          mode: 0,
          startAngleDeg: startPt.angleDeg,
          startLabel: "${startPt.code} (${fmt(startPt.angleDeg)}°)",
          endAngleDeg: normNewAngle,
          endLabel: "${finalPt1.code} (${fmt(normNewAngle)}°)",
          turnSweepDeg: turnClockwise ? turnDeg : -turnDeg,
          secondTurnSweepDeg: secondTurnSweep,
          finalAfterSecondTurnDeg: finalAfterSecondDeg,
          finalAfterSecondLabel: finalAfterSecondLabel,
          headerBadge:
          "Face ${startPt.code}, Turn ${fmt(turnDeg)}° ${turnClockwise ? 'Right (↻)' : 'Left (↺)'}  ➔  ${finalPt1.fullName} (${finalPt1.code})",
          subBadge:
          "Start = ${fmt(startPt.angleDeg)}°  |  Turn = ${turnClockwise ? '+' : '−'}${fmt(turnDeg)}°  |  Final = ${fmt(normNewAngle)}° (${finalPt1.code})",
        ),
      );
    } catch (e) {
      return CompassDirectionResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid starting direction (e.g. East) and turn angle (e.g. 90).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: ANGLE BETWEEN TWO COMPASS DIRECTIONS (Figure 24.4 & Exercise 24a #2a–h)
  // ===========================================================================
  static CompassDirectionResult solveAngleBetweenDirections({
    required String firstDirStr,
    required String secondDirStr,
  }) {
    try {
      final Map<String, dynamic> p1 = parseCompassDirection(firstDirStr);
      final Map<String, dynamic> p2 = parseCompassDirection(secondDirStr);
      final CompassPointInfo d1 = p1['point'] as CompassPointInfo;
      final CompassPointInfo d2 = p2['point'] as CompassPointInfo;

      final double a1 = d1.angleDeg;
      final double a2 = d2.angleDeg;
      final double absDiff = (a2 - a1).abs();
      final double smallerAngle =
      absDiff > 180.0 ? (360.0 - absDiff) : absDiff;
      final double reflexAngle = 360.0 - smallerAngle;

      // Determine shortest path direction (clockwise vs anticlockwise) from d1 to d2
      final double cwDiff = normalizeAngle360(a2 - a1);
      final bool shortestIsClockwise = cwDiff <= 180.0;
      final double signedSweep =
      shortestIsClockwise ? smallerAngle : -smallerAngle;

      final double steps45 = smallerAngle / 45.0;
      final int whole90s = (smallerAngle / 90.0).floor();
      final double remDeg = smallerAngle - (whole90s * 90.0);

      final List<String> trace = _build45DegreeStepTrace(
        a1,
        smallerAngle,
        shortestIsClockwise,
      );

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Recall the Compass Angle Rules (Page 212 \\& Figure 24.4)}}",
        "\\bullet \\text{ Angle between adjacent main directions (N and E, E and S, S and W, W and N)} = 90^\\circ.",
        "\\bullet \\text{ Secondary directions (NE, SE, SW, NW) lie mid-way between main directions: } \\frac{90^\\circ}{2} = 45^\\circ.",
        "",
        "\\text{\\textbf{Step 2: Method 1 — Counting }} 45^\\circ \\text{\\textbf{ and }} 90^\\circ \\text{\\textbf{ Steps Between ${d1.code} and ${d2.code}}}",
      ];

      if (trace.length > 1) {
        workings.add(
            "\\text{Shortest Path Around Compass: } ${trace.join(' \\xrightarrow{45^\\circ} ')}");
      }
      workings.add(
          "\\text{Number of } 45^\\circ \\text{ gaps} = ${fmt(steps45)} \\implies ${fmt(steps45)} \\times 45^\\circ = \\mathbf{${fmt(smallerAngle)}^\\circ}");

      if (whole90s > 0 && remDeg > 0) {
        workings.add(
            "\\text{Or by } 90^\\circ \\text{ quadrants + } 45^\\circ \\text{ half-quadrant: } ${whole90s * 90}^\\circ + ${fmt(remDeg)}^\\circ = \\mathbf{${fmt(smallerAngle)}^\\circ}");
      }

      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 3: Method 2 — Using Clockwise Angles from North (N = }} 0^\\circ\\text{\\textbf{)}}");
      workings.add(
          "\\text{${d1.fullName} (${d1.code})} = ${fmt(a1)}^\\circ, \\quad \\text{${d2.fullName} (${d2.code})} = ${fmt(a2)}^\\circ");
      workings.add(
          "\\text{Direct Difference} = |${fmt(a2)}^\\circ - ${fmt(a1)}^\\circ| = ${fmt(absDiff)}^\\circ");

      if (absDiff > 180.0) {
        workings.add(
            "\\text{Since } ${fmt(absDiff)}^\\circ > 180^\\circ, \\text{ subtract from } 360^\\circ \\text{ for the direct interior angle:}");
        workings.add(
            "\\text{Angle between ${d1.code} and ${d2.code}} = 360^\\circ - ${fmt(absDiff)}^\\circ = \\mathbf{${fmt(smallerAngle)}^\\circ}");
      } else {
        workings.add(
            "\\therefore \\; \\text{Angle between ${d1.code} and ${d2.code}} = \\mathbf{${fmt(smallerAngle)}^\\circ}");
      }

      final List<CompassDirectionStep> steps = [
        const CompassDirectionStep(
          title: "Step 1: Recall the 90° and 45° Compass Spacing Rules (Figure 24.4)",
          description:
          "• On a compass rose, the angle between any two adjacent main cardinal directions (N to E, E to S, S to W, W to N) is a right angle (90°).\n"
              "• Each secondary direction (NE, SE, SW, NW) is exactly mid-way between two main directions, so the angle between any two adjacent 8-point directions is 90° ÷ 2 = 45°.",
          mathLaTeX:
          "\\text{Main gap} = 90^\\circ, \\quad \\text{Adjacent 8-point gap} = \\frac{90^\\circ}{2} = 45^\\circ",
        ),
        CompassDirectionStep(
          title:
          "Step 2: Count the 45° Compass Sectors Between ${d1.code} and ${d2.code}",
          description:
          "Trace the shortest path around the compass rose from ${d1.fullName} (${d1.code}) to ${d2.fullName} (${d2.code}):\n"
              "${trace.length > 1 ? '• Path: ${trace.map((s) => s.replaceAll('^\\circ', '°')).join(' → ')}.\n' : ''}"
              "• This spans ${fmt(steps45)} sector(s) of 45°: ${fmt(steps45)} × 45° = ${fmt(smallerAngle)}°."
              "${whole90s > 0 && remDeg > 0 ? '\n• You can also add the 90° right-angle quadrant(s) and the 45° half-quadrant: ${whole90s * 90}° + ${fmt(remDeg)}° = ${fmt(smallerAngle)}°.' : ''}",
          mathLaTeX:
          "${fmt(steps45)} \\times 45^\\circ = \\mathbf{${fmt(smallerAngle)}^\\circ}",
        ),
        CompassDirectionStep(
          title:
          "Step 3: Verify Using Clockwise Angles from North (0° to 360°)",
          description:
          "• ${d1.fullName} (${d1.code}) is at ${fmt(a1)}° clockwise from North.\n"
              "• ${d2.fullName} (${d2.code}) is at ${fmt(a2)}° clockwise from North.\n"
              "• Absolute difference = |${fmt(a2)}° − ${fmt(a1)}°| = ${fmt(absDiff)}°.\n"
              "${absDiff > 180.0 ? '• Because ${fmt(absDiff)}° goes the long way around the compass (> 180°), subtract from a full 360° circle to get the direct angle between them: 360° − ${fmt(absDiff)}° = ${fmt(smallerAngle)}°.' : '• Therefore, the angle between ${d1.code} and ${d2.code} is ${fmt(smallerAngle)}° (and the reflex angle the long way around is ${fmt(reflexAngle)}°).'}",
          mathLaTeX: absDiff > 180.0
              ? "360^\\circ - |${fmt(a2)}^\\circ - ${fmt(a1)}^\\circ| = 360^\\circ - ${fmt(absDiff)}^\\circ = \\boxed{${fmt(smallerAngle)}^\\circ}"
              : "|${fmt(a2)}^\\circ - ${fmt(a1)}^\\circ| = \\boxed{${fmt(smallerAngle)}^\\circ}",
        ),
      ];

      return CompassDirectionResult(
        mode: 1,
        finalAnswers: {
          "Angle Between ${d1.code} & ${d2.code}": "${fmt(smallerAngle)}°",
          "Number of 45° Steps": "${fmt(steps45)} step(s)",
          "${d1.code} & ${d2.code} Angles": "${fmt(a1)}° & ${fmt(a2)}°",
          "Reflex Angle (Long Way)": "${fmt(reflexAngle)}°",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CompassCanvasData(
          mode: 1,
          startAngleDeg: a1,
          startLabel: "${d1.code} (${fmt(a1)}°)",
          endAngleDeg: a2,
          endLabel: "${d2.code} (${fmt(a2)}°)",
          turnSweepDeg: signedSweep,
          headerBadge:
          "Angle Between  ${d1.fullName} (${d1.code})  and  ${d2.fullName} (${d2.code})  =  ${fmt(smallerAngle)}°",
          subBadge:
          "${fmt(steps45)} × 45° sectors = ${fmt(smallerAngle)}°   (Reflex angle = ${fmt(reflexAngle)}°)",
        ),
      );
    } catch (e) {
      return CompassDirectionResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter two valid compass directions (e.g. E and SW).",
      );
    }
  }

  // ===========================================================================
  // MODE 2: RELATIVE COMPASS BEARING BETWEEN TWO POINTS (Figure 24.5 & Ex 24b)
  // ===========================================================================
  static CompassDirectionResult solveRelativeCompassBearing({
    required String pointAName,
    required String pointBName,
    required String dirBFromAStr,
  }) {
    try {
      final String nameA =
      pointAName.trim().isEmpty ? 'A' : pointAName.trim();
      final String nameB =
      pointBName.trim().isEmpty ? 'B' : pointBName.trim();

      final Map<String, dynamic> parsedDir =
      parseCompassDirection(dirBFromAStr);
      final CompassPointInfo dirBFromA =
      parsedDir['point'] as CompassPointInfo;

      final double angleBFromA = dirBFromA.angleDeg;
      final double angleAFromB = normalizeAngle360(angleBFromA + 180.0);
      final CompassPointInfo dirAFromB = angleToCompassPoint(angleAFromB);

      final String swappedCode = swapOppositeLetters(dirBFromA.code);
      final String cleanA = cleanTex(nameA);
      final String cleanB = cleanTex(nameB);

      final String addOrSub180 = angleBFromA < 180.0
          ? "${fmt(angleBFromA)}^\\circ + 180^\\circ = ${fmt(angleAFromB)}^\\circ"
          : "${fmt(angleBFromA)}^\\circ - 180^\\circ = ${fmt(angleAFromB)}^\\circ";

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Bearing of $cleanB from $cleanA (Standing at $cleanA)}}",
        "\\text{Rule: 'From $cleanA' means stand at $cleanA with your magnetic compass needle pointing North (N).}",
        "\\text{Looking from $cleanA towards $cleanB, the compass direction is:}",
        "\\text{Bearing of $cleanB from $cleanA} = \\mathbf{\\text{${dirBFromA.fullName} (${dirBFromA.code})}} \\quad (${fmt(angleBFromA)}^\\circ \\text{ from N})",
        "",
        "\\text{\\textbf{Step 2: Reciprocal Bearing of $cleanA from $cleanB (Standing at $cleanB — Figure 24.5)}}",
        "\\text{Now stand at $cleanB with a compass pointing North (N) and look back along the same line towards $cleanA.}",
        "\\bullet \\text{ Method 1 (Opposite Cardinal Letters): Swap } \\text{N}\\leftrightarrow\\text{S} \\text{ and } \\text{E}\\leftrightarrow\\text{W}:",
        "\\quad \\text{Opposite of ${dirBFromA.code}} = \\mathbf{\\text{$swappedCode (${dirAFromB.fullName})}}",
        "\\bullet \\text{ Method 2 (Half-Turn }} 180^\\circ \\text{ Rule): Looking back along the exact same line is a } 180^\\circ \\text{ reversal:}",
        "\\quad $addOrSub180 \\implies \\mathbf{\\text{${dirAFromB.fullName} (${dirAFromB.code})}}",
      ];

      final List<CompassDirectionStep> steps = [
        CompassDirectionStep(
          title:
          "Step 1: Interpret 'The Bearing of $nameB from $nameA' (Stand at $nameA)",
          description:
          "• Textbook Rule (page 212): We use the word 'bearing' for directions between two points. The word 'FROM' tells you where to stand with your compass!\n"
              "• For 'the bearing of $nameB FROM $nameA', place the compass at $nameA with its pointer pointing Northwards (N).\n"
              "• Point $nameB lies in the direction ${dirBFromA.fullName} (${dirBFromA.code}) of $nameA (${fmt(angleBFromA)}° clockwise from North).",
          mathLaTeX:
          "\\text{Bearing of $cleanB from $cleanA} = \\mathbf{\\text{${dirBFromA.code}}} \\; (${fmt(angleBFromA)}^\\circ)",
        ),
        CompassDirectionStep(
          title:
          "Step 2: Find the Bearing of $nameA from $nameB by Reversing Direction (Figure 24.5)",
          description:
          "To find the bearing of $nameA FROM $nameB, move to point $nameB (with the compass pointer at $nameB also pointing North) and look back along the exact same line towards $nameA:\n"
              "1. Opposite Cardinal Letters Method: Since North (N) is opposite South (S), and East (E) is opposite West (W), replace each letter in '${dirBFromA.code}' with its opposite:\n"
              "   ${dirBFromA.code}  ➔  $swappedCode (${dirAFromB.fullName}).\n"
              "2. 180° Half-Turn Method: Looking back along the same straight line is a 180° turn:\n"
              "   ${angleBFromA < 180 ? '${fmt(angleBFromA)}° + 180°' : '${fmt(angleBFromA)}° − 180°'} = ${fmt(angleAFromB)}° = ${dirAFromB.fullName} (${dirAFromB.code})!",
          mathLaTeX:
          "\\text{Bearing of $cleanA from $cleanB} = \\boxed{\\text{${dirAFromB.fullName} (${dirAFromB.code})}} \\; (${fmt(angleAFromB)}^\\circ)",
        ),
      ];

      return CompassDirectionResult(
        mode: 2,
        finalAnswers: {
          "a) Bearing of $nameB from $nameA":
          "${dirBFromA.fullName} (${dirBFromA.code})",
          "b) Bearing of $nameA from $nameB":
          "${dirAFromB.fullName} (${dirAFromB.code})",
          "Angle at $nameA (from N)": "${fmt(angleBFromA)}°",
          "Angle at $nameB (from N)": "${fmt(angleAFromB)}°",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CompassCanvasData(
          mode: 2,
          startAngleDeg: angleBFromA,
          startLabel: dirBFromA.code,
          endAngleDeg: angleAFromB,
          endLabel: dirAFromB.code,
          pointAName: nameA,
          pointBName: nameB,
          dirBFromACode: dirBFromA.code,
          dirAFromBCode: dirAFromB.code,
          headerBadge:
          "Figure 24.5:  $nameB from $nameA = ${dirBFromA.code}   |   $nameA from $nameB = ${dirAFromB.code}",
          subBadge:
          "Both compass pointers point North (N) — Opposite directions differ by 180°",
        ),
      );
    } catch (e) {
      return CompassDirectionResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter a valid compass direction for B from A (e.g. NW, NE, N, SE).",
      );
    }
  }

  // ===========================================================================
  // MODE 3: SUNRISE, SUNSET & MAGNETIC COMPASS ORIENTATION EXPLORER (Figs 24.1 & 24.3)
  // ===========================================================================
  static CompassDirectionResult solveOrientationExplorer({
    required String facingDirStr,
  }) {
    try {
      final Map<String, dynamic> parsed = parseCompassDirection(facingDirStr);
      final CompassPointInfo frontPt = parsed['point'] as CompassPointInfo;
      final String? sunNote = parsed['sunNote'] as String?;

      final double fDeg = frontPt.angleDeg;
      final CompassPointInfo rightPt =
      angleToCompassPoint(normalizeAngle360(fDeg + 90.0));
      final CompassPointInfo backPt =
      angleToCompassPoint(normalizeAngle360(fDeg + 180.0));
      final CompassPointInfo leftPt =
      angleToCompassPoint(normalizeAngle360(fDeg - 90.0));
      final CompassPointInfo halfRightPt =
      angleToCompassPoint(normalizeAngle360(fDeg + 45.0));
      final CompassPointInfo halfLeftPt =
      angleToCompassPoint(normalizeAngle360(fDeg - 45.0));

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Sunrise, Sunset \\& Magnetic Compass Rules (Figures 24.1 \\& 24.3)}}",
        "\\bullet \\text{ The sun rises in the \\textbf{East (E = }} 90^\\circ\\text{\\textbf{)} and sets in the \\textbf{West (W = }} 270^\\circ\\text{\\textbf{)}.}",
        "\\bullet \\text{ A magnetic compass needle always points \\textbf{North (N = }} 0^\\circ\\text{\\textbf{)}.}",
        if (sunNote != null) "\\bullet \\text{ ${cleanTex(sunNote)}}",
        "",
        "\\text{\\textbf{Step 2: Complete }} 360^\\circ \\text{\\textbf{ Orientation Breakdown When Facing ${frontPt.fullName} (${frontPt.code})}}",
        "1.\\; \\text{In Front of You } (0^\\circ \\text{ turn}): \\quad \\mathbf{\\text{${frontPt.fullName} (${frontPt.code})}} \\; (${fmt(fDeg)}^\\circ)",
        "2.\\; \\text{To Your Right } (+90^\\circ \\text{ clockwise}): \\quad ${fmt(fDeg)}^\\circ + 90^\\circ = ${fmt(rightPt.angleDeg)}^\\circ \\implies \\mathbf{\\text{${rightPt.fullName} (${rightPt.code})}}",
        "3.\\; \\text{Behind You / Opposite } (+180^\\circ \\text{ half-turn}): \\quad ${fmt(fDeg)}^\\circ + 180^\\circ \\equiv ${fmt(backPt.angleDeg)}^\\circ \\implies \\mathbf{\\text{${backPt.fullName} (${backPt.code})}}",
        "4.\\; \\text{To Your Left } (-90^\\circ \\text{ anticlockwise}): \\quad ${fmt(fDeg)}^\\circ - 90^\\circ \\equiv ${fmt(leftPt.angleDeg)}^\\circ \\implies \\mathbf{\\text{${leftPt.fullName} (${leftPt.code})}}",
        "5.\\; \\text{Half-Right } (+45^\\circ) = \\mathbf{\\text{${halfRightPt.code}}} \\quad ; \\quad \\text{Half-Left } (-45^\\circ) = \\mathbf{\\text{${halfLeftPt.code}}}",
      ];

      final List<CompassDirectionStep> steps = [
        CompassDirectionStep(
          title:
          "Step 1: Recall Sunrise, Sunset & Magnetic Compass Rules (Page 211)",
          description:
          "• Figure 24.1 Rule: The sun always rises in the East (E = 90°) and sets in the West (W = 270°).\n"
              "• Figure 24.3 Rule: A magnetic compass has a magnetic needle that always points in the direction North (N = 0°).\n"
              "${sunNote != null ? '• $sunNote\n' : ''}"
              "• You are currently facing ${frontPt.fullName} (${frontPt.code} = ${fmt(fDeg)}°).",
          mathLaTeX:
          "\\text{Facing} = \\text{${frontPt.fullName} (${frontPt.code})} = ${fmt(fDeg)}^\\circ",
        ),
        CompassDirectionStep(
          title:
          "Step 2: Find What Lies to Your Right (+90°), Behind You (+180°), and to Your Left (−90°)",
          description:
          "Starting from ${frontPt.fullName} (${fmt(fDeg)}°):\n"
              "• To Your Right (90° clockwise): Add 90° → ${fmt(fDeg)}° + 90° ≡ ${fmt(rightPt.angleDeg)}° = ${rightPt.fullName} (${rightPt.code}).\n"
              "• Behind You / Opposite (180° half-turn): Add 180° → ${fmt(fDeg)}° + 180° ≡ ${fmt(backPt.angleDeg)}° = ${backPt.fullName} (${backPt.code}).\n"
              "• To Your Left (90° anticlockwise): Subtract 90° → ${fmt(fDeg)}° − 90° ≡ ${fmt(leftPt.angleDeg)}° = ${leftPt.fullName} (${leftPt.code}).\n"
              "• Secondary 45° Diagonals: 45° to your right is ${halfRightPt.fullName} (${halfRightPt.code}); 45° to your left is ${halfLeftPt.fullName} (${halfLeftPt.code}).",
          mathLaTeX:
          "\\text{Right } (+90^\\circ) = \\text{${rightPt.code}}, \\quad \\text{Behind } (+180^\\circ) = \\text{${backPt.code}}, \\quad \\text{Left } (-90^\\circ) = \\text{${leftPt.code}}",
        ),
      ];

      return CompassDirectionResult(
        mode: 3,
        finalAnswers: {
          "Facing (0°)": "${frontPt.fullName} (${frontPt.code})",
          "To Your Right (+90°)": "${rightPt.fullName} (${rightPt.code})",
          "To Your Left (−90°)": "${leftPt.fullName} (${leftPt.code})",
          "Behind You (180°)": "${backPt.fullName} (${backPt.code})",
          "45° Right / 45° Left": "${halfRightPt.code}  /  ${halfLeftPt.code}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CompassCanvasData(
          mode: 3,
          startAngleDeg: fDeg,
          startLabel: "Facing ${frontPt.code}",
          endAngleDeg: rightPt.angleDeg,
          endLabel: "Right: ${rightPt.code}",
          turnSweepDeg: 90.0,
          secondTurnSweepDeg: -90.0,
          finalAfterSecondTurnDeg: leftPt.angleDeg,
          finalAfterSecondLabel: "Left: ${leftPt.code}",
          headerBadge:
          "Facing ${frontPt.fullName} (${frontPt.code}):   Left = ${leftPt.code}  |  Right = ${rightPt.code}  |  Behind = ${backPt.code}",
          subBadge:
          "Sunrise = East (E)   |   Sunset = West (W)   |   Magnetic Needle = North (N)",
        ),
      );
    } catch (e) {
      return CompassDirectionResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter a valid compass direction (e.g. East, North, NE, or Sunrise).",
      );
    }
  }
}