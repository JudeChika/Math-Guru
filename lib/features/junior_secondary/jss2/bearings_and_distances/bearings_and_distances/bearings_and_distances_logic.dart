import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bearings_and_distances_models.dart';

class BearingsAndDistancesLogic {
  // ===========================================================================
  // 13 TEXTBOOK PRESETS (Covers Examples 3–4, Ex 24f #1–5, Ex 24g #1–10 & Rev Test 24)
  // ===========================================================================
  static const List<BearingDistancePreset> textbookPresets = [
    BearingDistancePreset(
      chipLabel: "Ex 3 (Fig 24.29): 3 km East to B, then 5 km on 152° to C",
      mode: 0,
      unit: 'km',
      scaleStr: '1',
      pt1Name: 'A',
      pt2Name: 'B',
      pt3Name: 'C',
      dist1Str: '3',
      bearing1Str: 'East',
      dist2Str: '5',
      bearing2Str: '152°',
    ),
    BearingDistancePreset(
      chipLabel: "Ex 4 (Fig 24.30): Ibadan 116 km on 027° from Lagos",
      mode: 1,
      subMode: 0,
      unit: 'km',
      scaleStr: '20',
      pt1Name: 'Lagos',
      pt2Name: 'Ibadan',
      dist1Str: '116',
      bearing1Str: '027°',
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24f #1 (Fig 24.23): Classroom Block & Tree Survey",
      mode: 2,
      unit: 'm',
      scaleStr: '5',
      centerPointName: 'P',
      landmarks: [
        SurveyLandmarkInput(
            label: 'Corner 1', bearingStr: '030°', distanceStr: '18'),
        SurveyLandmarkInput(
            label: 'Corner 2', bearingStr: '070°', distanceStr: '30'),
        SurveyLandmarkInput(
            label: 'Tree', bearingStr: '118°', distanceStr: '15'),
      ],
      pairIdx1: 0,
      pairIdx2: 1,
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24f #2 (Fig 24.24): 3 Trees A(060°,30m), B(142°,25m), C(270°,32m)",
      mode: 2,
      unit: 'm',
      scaleStr: '10',
      centerPointName: 'P',
      landmarks: [
        SurveyLandmarkInput(label: 'A', bearingStr: '060°', distanceStr: '30'),
        SurveyLandmarkInput(label: 'B', bearingStr: '142°', distanceStr: '25'),
        SurveyLandmarkInput(label: 'C', bearingStr: '270°', distanceStr: '32'),
      ],
      pairIdx1: 2, // From C
      pairIdx2: 0, // Of A
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24f #3 (Fig 24.25): River Width (AB = 100 m, 000° & 290°)",
      mode: 3,
      unit: 'm',
      scaleStr: '20',
      pt1Name: 'A',
      pt2Name: 'B',
      pt3Name: 'Tree',
      dist1Str: '100',
      bearing1Str: '000°',
      bearing2Str: '290°',
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24f #4 (Fig 24.26): Road Survey A(135°,48m), B(090°,33m), C(072°,60m)",
      mode: 2,
      unit: 'm',
      scaleStr: '10',
      centerPointName: 'P',
      landmarks: [
        SurveyLandmarkInput(label: 'A', bearingStr: '135°', distanceStr: '48'),
        SurveyLandmarkInput(label: 'B', bearingStr: '090°', distanceStr: '33'),
        SurveyLandmarkInput(label: 'C', bearingStr: '072°', distanceStr: '60'),
      ],
      pairIdx1: 0, // From A
      pairIdx2: 1, // Of B
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24f #5 (Fig 24.27): Railway A(150°,200m), B(220°,550m) & Tower(190°,300m)",
      mode: 2,
      unit: 'm',
      scaleStr: '100',
      centerPointName: 'P',
      landmarks: [
        SurveyLandmarkInput(
            label: 'A', bearingStr: '150°', distanceStr: '200'),
        SurveyLandmarkInput(
            label: 'B', bearingStr: '220°', distanceStr: '550'),
        SurveyLandmarkInput(
            label: 'Water Tower', bearingStr: '190°', distanceStr: '300'),
      ],
      pairIdx1: 1, // From B
      pairIdx2: 0, // Of A
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24g #1: Walk 3 km East to B, then 4 km North to C",
      mode: 0,
      unit: 'km',
      scaleStr: '1',
      pt1Name: 'A',
      pt2Name: 'B',
      pt3Name: 'C',
      dist1Str: '3',
      bearing1Str: 'East',
      dist2Str: '4',
      bearing2Str: 'North',
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24g #4: Cycle 14 km East from A, then 10 km SE to B",
      mode: 0,
      unit: 'km',
      scaleStr: '2',
      pt1Name: 'A',
      pt2Name: 'Turn',
      pt3Name: 'B',
      dist1Str: '14',
      bearing1Str: 'East',
      dist2Str: '10',
      bearing2Str: 'SE',
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24g #6: Enugu 450 km South of Kaduna, Lagos on 225°",
      mode: 1,
      subMode: 1,
      unit: 'km',
      scaleStr: '50',
      pt1Name: 'Kaduna',
      pt2Name: 'Enugu',
      pt3Name: 'Lagos',
      dist1Str: '450',
      bearing1Str: '225°',
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24g #7: Banjul 2000 km on 295° from Accra",
      mode: 1,
      subMode: 0,
      unit: 'km',
      scaleStr: '250',
      pt1Name: 'Accra',
      pt2Name: 'Banjul',
      dist1Str: '2000',
      bearing1Str: '295°',
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24g #9: Two Ships from Harbour (3 km East & 3 km on 042°)",
      mode: 2,
      unit: 'km',
      scaleStr: '0.5',
      centerPointName: 'Harbour',
      landmarks: [
        SurveyLandmarkInput(
            label: 'Ship 1', bearingStr: 'East', distanceStr: '3'),
        SurveyLandmarkInput(
            label: 'Ship 2', bearingStr: '042°', distanceStr: '3'),
      ],
      pairIdx1: 0,
      pairIdx2: 1,
    ),
    BearingDistancePreset(
      chipLabel: "Ex 24g #10: Plane flies 200 km on 032°, then 350 km on 275°",
      mode: 0,
      unit: 'km',
      scaleStr: '50',
      pt1Name: 'Start',
      pt2Name: 'Turn',
      pt3Name: 'End',
      dist1Str: '200',
      bearing1Str: '032°',
      dist2Str: '350',
      bearing2Str: '275°',
    ),
  ];

  // ===========================================================================
  // REUSABLE FORMATTING, ROUNDING & BEARING PARSING HELPERS
  // ===========================================================================
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

  /// Rounds a positive number to 2 significant figures (matching Rev Test 24 #8)
  static String fmt2SF(double v) {
    if (v.abs() < 1e-9) return '0';
    final int d = (math.log(v.abs()) / math.ln10).floor();
    final int power = 1 - d;
    if (power >= 0) {
      final double scale = math.pow(10, power).toDouble();
      final double r = (v * scale).roundToDouble() / scale;
      return fmt(r, maxDecimals: power);
    } else {
      final double scale = math.pow(10, -power).toDouble();
      final double r = (v / scale).roundToDouble() * scale;
      return r.round().toString();
    }
  }

  static double normalizeAngle360(double deg) {
    if ((deg - 360.0).abs() < 1e-9) return 0.0;
    final double m = deg % 360.0;
    return m < 0 ? m + 360.0 : (m.abs() < 1e-9 ? 0.0 : m);
  }

  /// Formats a clockwise bearing (0° to 360°) as a 3-digit string with leading zeros (e.g. `027°`, `130°`)
  static String fmt3Fig(double deg, {bool withDegreeSymbol = true}) {
    final double norm = normalizeAngle360(deg);
    final int rounded = norm.round() % 360;
    final String padded = rounded.toString().padLeft(3, '0');
    return withDegreeSymbol ? '$padded°' : padded;
  }

  static String fmt3FigLaTeX(double deg) {
    return "${fmt3Fig(deg, withDegreeSymbol: false)}^\\circ";
  }

  static String fmtAcuteBearing(double rawDeg) {
    final double deg = normalizeAngle360(rawDeg);
    final int r = deg.round() % 360;
    if (r == 0) return 'Due North (000°)';
    if (r == 90) return 'Due East (090°)';
    if (r == 180) return 'Due South (180°)';
    if (r == 270) return 'Due West (270°)';
    if (r > 0 && r < 90) return 'N$r°E';
    if (r > 90 && r < 180) return 'S${180 - r}°E';
    if (r > 180 && r < 270) return 'S${r - 180}°W';
    return 'N${360 - r}°W';
  }

  static String cleanTex(String s) {
    return s
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('^', '')
        .replaceAll('&', ' and ')
        .replaceAll('_', ' ')
        .trim();
  }

  /// Parses any bearing/direction input: 3-figure ("152°", "027"), acute ("N45°E", "S38°E"), or compass ("East", "SE", "N")
  static Map<String, dynamic> parseFlexibleBearing(String raw) {
    final String clean = raw.trim();
    if (clean.isEmpty) {
      throw const FormatException(
          "Please enter a bearing or compass direction (e.g. 152°, 027°, East, SE, or N45°E).");
    }

    final String upper = clean
        .toUpperCase()
        .replaceAll('°', '')
        .replaceAll('DEG', '')
        .replaceAll('-', '')
        .replaceAll('NORTHEAST', 'NE')
        .replaceAll('SOUTHEAST', 'SE')
        .replaceAll('SOUTHWEST', 'SW')
        .replaceAll('NORTHWEST', 'NW')
        .replaceAll('NORTH', 'N')
        .replaceAll('SOUTH', 'S')
        .replaceAll('EAST', 'E')
        .replaceAll('WEST', 'W')
        .replaceAll('DUE', '')
        .replaceAll(' ', '');

    const Map<String, double> compassMap = {
      'N': 0.0,
      'NE': 45.0,
      'E': 90.0,
      'SE': 135.0,
      'S': 180.0,
      'SW': 225.0,
      'W': 270.0,
      'NW': 315.0,
    };

    if (compassMap.containsKey(upper)) {
      final double deg = compassMap[upper]!;
      return {
        'deg': deg,
        'threeFigStr': fmt3Fig(deg),
        'wasCompassWord': true,
        'origDesc': clean,
      };
    }

    final RegExp acuteReg = RegExp(r'^([NS])(\d+\.?\d*)([EW])$');
    final Match? am = acuteReg.firstMatch(upper);
    if (am != null) {
      final String ns = am.group(1)!;
      final double theta = double.parse(am.group(2)!);
      final String ew = am.group(3)!;
      if (theta < 0 || theta > 90) {
        throw const FormatException(
            "Acute-angle bearing must have an angle between 0° and 90°.");
      }
      double deg = 0.0;
      if (ns == 'N' && ew == 'E') deg = theta;
      if (ns == 'S' && ew == 'E') deg = 180.0 - theta;
      if (ns == 'S' && ew == 'W') deg = 180.0 + theta;
      if (ns == 'N' && ew == 'W') deg = 360.0 - theta;

      return {
        'deg': deg,
        'threeFigStr': fmt3Fig(deg),
        'wasCompassWord': true,
        'origDesc': clean,
      };
    }

    final double? numVal = double.tryParse(upper);
    if (numVal != null && numVal >= 0.0 && numVal <= 360.0) {
      final double norm = normalizeAngle360(numVal);
      return {
        'deg': norm,
        'threeFigStr': fmt3Fig(norm),
        'wasCompassWord': false,
        'origDesc': fmt3Fig(norm),
      };
    }

    throw FormatException(
        "Could not parse bearing '$clean'. Enter a 3-figure bearing (e.g. 152°), acute bearing (e.g. N45°E), or compass direction (e.g. East, SE).");
  }

  /// Auto-selects a sensible textbook scale (units per 1 cm on paper) so drawings are 4 cm to 10 cm long
  static double chooseSuitableScale(
      List<double> realDistances, {
        required bool autoScale,
        required String customScaleStr,
      }) {
    if (!autoScale) {
      final String s = customScaleStr.trim().toLowerCase();
      final Iterable<Match> matches = RegExp(r'\d+\.?\d*').allMatches(s);
      if (matches.isNotEmpty) {
        final double? parsed = double.tryParse(matches.last.group(0)!);
        if (parsed != null && parsed > 0) return parsed;
      }
    }

    final double maxD = realDistances.isEmpty
        ? 10.0
        : realDistances.reduce(math.max);
    if (maxD <= 6) return 1.0;
    if (maxD <= 15) return 2.0;
    if (maxD <= 35) return 5.0;
    if (maxD <= 80) return 10.0;
    if (maxD <= 160) return 20.0;
    if (maxD <= 400) return 50.0;
    if (maxD <= 800) return 100.0;
    if (maxD <= 1600) return 200.0;
    return 250.0;
  }

  /// Converts a bearing (0° = North/+Y, 90° = East/+X) and distance into (dx, dy)
  static Offset bearingToDeltaXY(double bearingDeg, double dist) {
    final double rad = bearingDeg * math.pi / 180.0;
    final double dx = dist * math.sin(rad); // East (+), West (-)
    final double dy = dist * math.cos(rad); // North (+), South (-)
    return Offset(dx, dy);
  }

  /// Computes the clockwise bearing (0° to 360°) from point 1 to point 2 given (dx, dy)
  static double deltaXYToBearingDeg(double dx, double dy) {
    final double rad = math.atan2(dx, dy); // atan2(East, North) gives clockwise angle from North!
    final double deg = rad * 180.0 / math.pi;
    return normalizeAngle360(deg);
  }

  // ===========================================================================
  // MODE 0: MULTI-LEG JOURNEY SCALE DRAWING (A -> B -> C)
  // Matches Example 3 (Figures 24.28–24.29), Exercise 24g #1–5, #10 & Rev Test 24 #9–10
  // ===========================================================================
  static BearingsDistancesResult solveMultiLegJourney({
    required String pt1Name,
    required String pt2Name,
    required String pt3Name,
    required String dist1Str,
    required String bearing1Str,
    required String dist2Str,
    required String bearing2Str,
    required String unit,
    required bool autoScale,
    required String customScaleStr,
  }) {
    try {
      final String p1 = pt1Name.trim().isEmpty ? 'A' : pt1Name.trim();
      final String p2 = pt2Name.trim().isEmpty ? 'B' : pt2Name.trim();
      final String p3 = pt3Name.trim().isEmpty ? 'C' : pt3Name.trim();
      final String c1 = cleanTex(p1);
      final String c2 = cleanTex(p2);
      final String c3 = cleanTex(p3);

      final double? d1 = double.tryParse(dist1Str.trim());
      final double? d2 = double.tryParse(dist2Str.trim());
      if (d1 == null || d2 == null || d1 <= 0 || d2 <= 0) {
        throw const FormatException(
            "Please enter positive distances for both Leg 1 and Leg 2 (e.g. 3 and 5).");
      }

      final Map<String, dynamic> b1Data = parseFlexibleBearing(bearing1Str);
      final Map<String, dynamic> b2Data = parseFlexibleBearing(bearing2Str);
      final double b1Deg = b1Data['deg'] as double;
      final double b2Deg = b2Data['deg'] as double;
      final String b1Str = b1Data['threeFigStr'] as String;
      final String b2Str = b2Data['threeFigStr'] as String;

      final double scale = chooseSuitableScale(
        [d1, d2],
        autoScale: autoScale,
        customScaleStr: customScaleStr,
      );
      final String scaleText = "1 cm to ${fmt(scale)} $unit";

      // Convert real distances to paper cm
      final double leg1Cm = d1 / scale;
      final double leg2Cm = d2 / scale;

      // Coordinates in paper cm starting at A(0, 0)
      const Offset posA = Offset.zero;
      final Offset delta1Cm = bearingToDeltaXY(b1Deg, leg1Cm);
      final Offset posB = posA + delta1Cm;
      final Offset delta2Cm = bearingToDeltaXY(b2Deg, leg2Cm);
      final Offset posC = posB + delta2Cm;

      // Resultant vector AC in paper cm and real units
      final double dxCm = posC.dx - posA.dx;
      final double dyCm = posC.dy - posA.dy;
      final double exactPaperAC = math.sqrt(dxCm * dxCm + dyCm * dyCm);
      final double measuredPaperAC =
          (exactPaperAC * 10.0).roundToDouble() / 10.0; // Ruler measurement to 1 d.p. (mm)
      final double measuredRealAC = measuredPaperAC * scale;
      final double exactRealAC = exactPaperAC * scale;

      final double resultantBearing = deltaXYToBearingDeg(dxCm, dyCm);
      final int roundedBearing = resultantBearing.round() % 360;
      final String resBearing3Fig = fmt3Fig(roundedBearing.toDouble());
      final String resBearingAcute = fmtAcuteBearing(roundedBearing.toDouble());
      final double backBearing = (roundedBearing < 180)
          ? (roundedBearing + 180.0)
          : (roundedBearing - 180.0);

      // North/South and East/West components from Start Point A (for Ex 24g #10b & Rev Test 24 #10b)
      final double realEastWest = (dxCm * scale).abs();
      final String ewDir = dxCm >= 0 ? "East" : "West";
      final double realNorthSouth = (dyCm * scale).abs();
      final String nsDir = dyCm >= 0 ? "North" : "South";

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Make a Rough Sketch of the Journey (Figure 24.28)}}",
        "\\bullet \\text{ Leg 1 (\\text{$c1} to \\text{$c2}): Distance} = ${fmt(d1)}\\text{ $unit on bearing } ${fmt3FigLaTeX(b1Deg)}"
            "${(b1Data['wasCompassWord'] as bool) ? ' \\text{ (${cleanTex(b1Data['origDesc'] as String)})}' : ''}",
        "\\bullet \\text{ Leg 2 (\\text{$c2} to \\text{$c3}): Distance} = ${fmt(d2)}\\text{ $unit on bearing } ${fmt3FigLaTeX(b2Deg)}"
            "${(b2Data['wasCompassWord'] as bool) ? ' \\text{ (${cleanTex(b2Data['origDesc'] as String)})}' : ''}",
        "",
        "\\text{\\textbf{Step 2: Choose a Suitable Scale and Convert Distances to cm}}",
        "\\text{Scale: } 1\\text{ cm represents } ${fmt(scale)}\\text{ $unit}",
        "\\text{Paper length of Leg 1 (\\text{$c1$c2})} = \\frac{${fmt(d1)}\\text{ $unit}}{${fmt(scale)}} = \\mathbf{${fmt(leg1Cm, maxDecimals: 2)}\\text{ cm}}",
        "\\text{Paper length of Leg 2 (\\text{$c2$c3})} = \\frac{${fmt(d2)}\\text{ $unit}}{${fmt(scale)}} = \\mathbf{${fmt(leg2Cm, maxDecimals: 2)}\\text{ cm}}",
        "",
        "\\text{\\textbf{Step 3: Construct the Scale Drawing \\& Measure Resultant (Figure 24.29)}}",
        "\\text{Join \\text{$c1} to \\text{$c3} with a straight ruler line and measure length \\text{$c1$c3} on paper:}",
        "\\text{By measurement, } \\text{$c1$c3} \\approx ${fmt(measuredPaperAC)}\\text{ cm}",
        "\\text{Distance of \\text{$c3} from \\text{$c1}} \\approx ${fmt(measuredPaperAC)} \\times ${fmt(scale)}\\text{ $unit} = \\mathbf{${fmt(measuredRealAC)}\\text{ $unit}} \\quad \\left(\\text{Exact} = ${fmt(exactRealAC)}\\text{ $unit}\\right)",
        "",
        "\\text{\\textbf{Step 4: Measure the Bearing of \\text{$c3} from \\text{$c1} with a Protractor}}",
        "\\text{By measurement clockwise from North at \\text{$c1}: } \\text{N}\\hat{\\text{$c1}}\\text{$c3} \\approx ${roundedBearing}^\\circ",
        "\\text{Three-Figure Bearing of \\text{$c3} from \\text{$c1}} = \\mathbf{${fmt3FigLaTeX(roundedBearing.toDouble())}} \\quad \\left(\\text{Acute-angle: } \\text{$resBearingAcute}\\right)",
        "",
        "\\text{\\textbf{Step 5: North/South and East/West Displacement (Ex 24g \\#10b)}}",
        "\\text{\\text{$c3} is } \\mathbf{${fmt(realNorthSouth)}\\text{ $unit $nsDir}} \\text{ and } \\mathbf{${fmt(realEastWest)}\\text{ $unit $ewDir}} \\text{ of \\text{$c1}.}",
      ];

      final List<BearingDistanceStep> steps = [
        BearingDistanceStep(
          title:
          "Step 1: Make a Rough Sketch Showing North Lines N and N¹ (Figure 24.28)",
          description:
          "• Textbook Rule (Example 3): Always make a rough sketch of the journey first!\n"
              "• Mark the starting point '$p1' and draw a vertical arrow pointing North (N = 000°).\n"
              "• Leg 1 ($p1 → $p2): Draw a line on a bearing of $b1Str${(b1Data['wasCompassWord'] as bool) ? ' (${b1Data['origDesc']})' : ''} for a real distance of ${fmt(d1)} $unit to reach '$p2'.\n"
              "• Leg 2 ($p2 → $p3): At '$p2', draw a second vertical North arrow N¹ parallel to N. Measure a clockwise bearing of $b2Str${(b2Data['wasCompassWord'] as bool) ? ' (${b2Data['origDesc']})' : ''} for ${fmt(d2)} $unit to reach '$p3'.",
          mathLaTeX:
          "\\text{$c1} \\xrightarrow{${fmt3FigLaTeX(b1Deg)},\\; ${fmt(d1)}\\text{ $unit}} \\text{$c2} \\xrightarrow{${fmt3FigLaTeX(b2Deg)},\\; ${fmt(d2)}\\text{ $unit}} \\text{$c3}",
        ),
        BearingDistanceStep(
          title:
          "Step 2: Choose a Scale ($scaleText) and Convert Real Distances to cm",
          description:
          "Using the scale '$scaleText', divide each real-life distance by ${fmt(scale)} to find the exact length to draw on your paper:\n"
              "• Scale length of $p1$p2 = ${fmt(d1)} $unit ÷ ${fmt(scale)} = ${fmt(leg1Cm, maxDecimals: 2)} cm.\n"
              "• Scale length of $p2$p3 = ${fmt(d2)} $unit ÷ ${fmt(scale)} = ${fmt(leg2Cm, maxDecimals: 2)} cm.",
          mathLaTeX:
          "\\text{$c1$c2} = \\frac{${fmt(d1)}}{${fmt(scale)}} = ${fmt(leg1Cm, maxDecimals: 2)}\\text{ cm}, \\quad \\text{$c2$c3} = \\frac{${fmt(d2)}}{${fmt(scale)}} = ${fmt(leg2Cm, maxDecimals: 2)}\\text{ cm}",
        ),
        BearingDistanceStep(
          title:
          "Step 3: Construct the Scale Drawing & Measure Line $p1$p3 (Figure 24.29)",
          description:
          "1. At '$p1', draw North line N, use your protractor to measure $b1Str clockwise, and use your ruler to mark off $p1$p2 = ${fmt(leg1Cm, maxDecimals: 2)} cm.\n"
              "2. At '$p2', draw North line N¹ parallel to N, use your protractor to measure $b2Str clockwise, and mark off $p2$p3 = ${fmt(leg2Cm, maxDecimals: 2)} cm.\n"
              "3. Join '$p1' to '$p3' with a straight dashed line and measure $p1$p3 with your ruler:\n"
              "   • By measurement on paper, $p1$p3 ≈ ${fmt(measuredPaperAC)} cm.\n"
              "   • Multiply by the scale factor (${fmt(scale)} $unit per cm): ${fmt(measuredPaperAC)} × ${fmt(scale)} = ${fmt(measuredRealAC)} $unit (exact = ${fmt(exactRealAC)} $unit).",
          mathLaTeX:
          "\\text{$c1$c3} \\approx ${fmt(measuredPaperAC)}\\text{ cm} \\implies \\text{Distance} = ${fmt(measuredPaperAC)} \\times ${fmt(scale)} = \\boxed{${fmt(measuredRealAC)}\\text{ $unit}}",
        ),
        BearingDistanceStep(
          title:
          "Step 4: Measure the Bearing of $p3 from $p1 with a Protractor ($resBearing3Fig)",
          description:
          "• Place the centre of your protractor at the starting point '$p1' aligned with the North line N.\n"
              "• Measure the clockwise angle from North (000°) to the line $p1$p3:\n"
              "  N^$p1$p3 ≈ $roundedBearing° → Three-figure bearing of $p3 from $p1 is $resBearing3Fig (Acute-angle bearing: $resBearingAcute).\n"
              "• Bonus: From '$p1', '$p3' is ${fmt(realNorthSouth)} $unit $nsDir and ${fmt(realEastWest)} $unit $ewDir.",
          mathLaTeX:
          "\\text{Bearing of $c3 from $c1} = \\boxed{${fmt3FigLaTeX(roundedBearing.toDouble())}} \\quad (\\text{$resBearingAcute})",
        ),
      ];

      return BearingsDistancesResult(
        mode: 0,
        finalAnswers: {
          "Distance ($p3 from $p1)": "${fmt(measuredRealAC)} $unit",
          "Bearing ($p3 from $p1)": "$resBearing3Fig ($resBearingAcute)",
          "Measured $p1$p3 on Paper": "${fmt(measuredPaperAC)} cm",
          "$nsDir / $ewDir Offset":
          "${fmt(realNorthSouth)} $unit ${nsDir[0]}, ${fmt(realEastWest)} $unit ${ewDir[0]}",
          "Back Bearing ($p1 from $p3)": fmt3Fig(backBearing),
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BearingsDistancesCanvasData(
          mode: 0,
          unit: unit,
          scaleUnitsPerCm: scale,
          scaleBannerText: "Scale: $scaleText",
          pt1Name: p1,
          pt2Name: p2,
          pt3Name: p3,
          pt1Cm: posA,
          pt2Cm: posB,
          pt3Cm: posC,
          leg1BearingDeg: b1Deg,
          leg1BearingLabel: b1Str,
          leg1RealDist: d1,
          leg1PaperCm: leg1Cm,
          leg2BearingDeg: b2Deg,
          leg2BearingLabel: b2Str,
          leg2RealDist: d2,
          leg2PaperCm: leg2Cm,
          resultantBearingDeg: resultantBearing,
          resultantBearingLabel: resBearing3Fig,
          resultantRealDist: measuredRealAC,
          resultantPaperCm: measuredPaperAC,
          headerBadge:
          "$p3 from $p1:  Distance ≈ ${fmt(measuredRealAC)} $unit (${fmt(measuredPaperAC)} cm)  |  Bearing = $resBearing3Fig",
          subBadge:
          "Scale: $scaleText   |   Leg 1 ($p1$p2) = ${fmt(leg1Cm)} cm ($b1Str)   |   Leg 2 ($p2$p3) = ${fmt(leg2Cm)} cm ($b2Str)",
        ),
      );
    } catch (e) {
      return BearingsDistancesResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid distances and bearings for both legs.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: NORTH/SOUTH & EAST/WEST COMPONENTS OF A BEARING
  // Sub-Mode 0: Given Hypotenuse Distance & Bearing -> Find N/S & E/W Legs (Example 4, Ex 24g #7, #8)
  // Sub-Mode 1: Given N/S Leg & Bearing -> Find E/W Leg & Hypotenuse (Exercise 24g #6: Kaduna-Enugu-Lagos)
  // ===========================================================================
  static BearingsDistancesResult solveComponentsTriangle({
    required int subMode,
    required String pt1Name, // Origin (e.g. Lagos, Accra, Benin City, or Kaduna)
    required String pt2Name, // Target (e.g. Ibadan, Banjul, Owerri, or Enugu)
    required String pt3Name, // Third city for SubMode 1 (e.g. Lagos in Ex 24g #6)
    required String distStr,
    required String bearingStr,
    required String unit,
    required bool autoScale,
    required String customScaleStr,
  }) {
    try {
      final double? distVal = double.tryParse(distStr.trim());
      if (distVal == null || distVal <= 0) {
        throw const FormatException(
            "Please enter a positive distance (e.g. 116, 2000, 180, or 450).");
      }

      final Map<String, dynamic> bData = parseFlexibleBearing(bearingStr);
      final double bDeg = bData['deg'] as double;
      final String bStr = bData['threeFigStr'] as String;

      final double scale = chooseSuitableScale(
        [distVal],
        autoScale: autoScale,
        customScaleStr: customScaleStr,
      );
      final String scaleText = "1 cm to ${fmt(scale)} $unit";

      if (subMode == 0) {
        // Example 4 (Figure 24.30), Exercise 24g #7 & #8
        final String origin =
        pt1Name.trim().isEmpty ? 'Lagos' : pt1Name.trim();
        final String target =
        pt2Name.trim().isEmpty ? 'Ibadan' : pt2Name.trim();
        final String cOrig = cleanTex(origin);
        final String cTarg = cleanTex(target);
        final String lChar = origin[0].toUpperCase();
        final String iChar = target[0].toUpperCase();

        final double hypPaperCm = distVal / scale;
        final Offset deltaCm = bearingToDeltaXY(bDeg, hypPaperCm);
        final double ewPaperExact = deltaCm.dx.abs();
        final double nsPaperExact = deltaCm.dy.abs();

        // Ruler measurements on scale drawing (rounded to 1 decimal place = nearest mm, matching Example 4!)
        final double nsPaperMeasured =
            (nsPaperExact * 10.0).roundToDouble() / 10.0;
        final double ewPaperMeasured =
            (ewPaperExact * 10.0).roundToDouble() / 10.0;

        final double nsRealMeasured = nsPaperMeasured * scale;
        final double ewRealMeasured = ewPaperMeasured * scale;
        final double nsRealExact = nsPaperExact * scale;
        final double ewRealExact = ewPaperExact * scale;

        final String nsWord = deltaCm.dy >= 0 ? "North" : "South";
        final String oppNsWord = deltaCm.dy >= 0 ? "South" : "North";
        final String ewWord = deltaCm.dx >= 0 ? "East" : "West";
        final String oppEwWord = deltaCm.dx >= 0 ? "West" : "East";

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Choose Scale and Convert Distance to cm (Figure 24.30)}}",
          "\\text{Scale: } 1\\text{ cm to } ${fmt(scale)}\\text{ $unit}",
          "\\text{Scale length } \\text{$lChar$iChar} = \\frac{${fmt(distVal)}\\text{ $unit}}{${fmt(scale)}} = \\mathbf{${fmt(hypPaperCm, maxDecimals: 2)}\\text{ cm}}",
          "",
          "\\text{\\textbf{Step 2: Construct Right-Angled Triangle }} \\triangle \\text{${lChar}K$iChar}",
          "\\text{Let K be the point due $nsWord of $cOrig and due $oppEwWord of $cTarg } (\\angle \\text{${lChar}K$iChar} = 90^\\circ).",
          "",
          "\\text{\\textbf{Part (a): How Far $nsWord of $cOrig is $cTarg? (Vertical Line ${lChar}K)}}",
          "\\text{By measurement on scale drawing, } \\text{${lChar}K} \\approx ${fmt(nsPaperMeasured)}\\text{ cm}",
          "\\text{True distance } \\text{${lChar}K} \\approx ${fmt(nsPaperMeasured)} \\times ${fmt(scale)}\\text{ $unit} = \\mathbf{${fmt(nsRealMeasured)}\\text{ $unit}} \\quad \\left(\\text{Exact} = ${fmt(nsRealExact)}\\text{ $unit}\\right)",
          "",
          "\\text{\\textbf{Part (b): East/West Distance (Horizontal Line ${iChar}K)}}",
          "\\text{By measurement on scale drawing, } \\text{${iChar}K} \\approx ${fmt(ewPaperMeasured)}\\text{ cm}",
          "\\text{True distance } \\text{${iChar}K} \\approx ${fmt(ewPaperMeasured)} \\times ${fmt(scale)}\\text{ $unit} = \\mathbf{${fmt(ewRealMeasured)}\\text{ $unit}} \\quad \\left(\\text{Exact} = ${fmt(ewRealExact)}\\text{ $unit}\\right)",
          "\\therefore \\; \\text{$cTarg is } ${fmt(ewRealMeasured)}\\text{ $unit $ewWord of $cOrig (so $cOrig is } ${fmt(ewRealMeasured)}\\text{ $unit $oppEwWord of $cTarg).}",
        ];

        final List<BearingDistanceStep> steps = [
          BearingDistanceStep(
            title:
            "Step 1: Choose Scale ($scaleText) & Convert Distance to cm",
            description:
            "Using the scale '$scaleText', convert the direct distance of ${fmt(distVal)} $unit between $origin and $target into centimetres on paper:\n"
                "• Scale length $lChar$iChar = ${fmt(distVal)} $unit ÷ ${fmt(scale)} = ${fmt(hypPaperCm, maxDecimals: 2)} cm.",
            mathLaTeX:
            "\\text{$lChar$iChar} = \\frac{${fmt(distVal)}\\text{ $unit}}{${fmt(scale)}} = \\mathbf{${fmt(hypPaperCm, maxDecimals: 2)}\\text{ cm}}",
          ),
          BearingDistanceStep(
            title:
            "Step 2: Construct Right-Angled Projection Triangle △${lChar}K$iChar (Figure 24.30)",
            description:
            "1. Draw a vertical North–South line through $origin ($lChar).\n"
                "2. Place your protractor at $lChar, measure the clockwise bearing of $bStr, and draw line $lChar$iChar = ${fmt(hypPaperCm, maxDecimals: 2)} cm to locate $target ($iChar).\n"
                "3. From $iChar, use a set-square to drop a horizontal East–West perpendicular line (at 90°) to meet the North–South line at point K.",
            mathLaTeX:
            "\\angle \\text{N$lChar$iChar} = ${fmt3FigLaTeX(bDeg)}, \\quad \\angle \\text{${lChar}K$iChar} = 90^\\circ",
          ),
          BearingDistanceStep(
            title:
            "Step 3: Part (a) — Measure Vertical Line ${lChar}K ($nsWord / $oppNsWord Distance)",
            description:
            "• Line ${lChar}K represents the distance that $target is $nsWord of $origin.\n"
                "• By measurement with a ruler on the scale drawing: ${lChar}K ≈ ${fmt(nsPaperMeasured)} cm.\n"
                "• Multiply by the scale (${fmt(scale)} $unit per cm): ${fmt(nsPaperMeasured)} × ${fmt(scale)} = ${fmt(nsRealMeasured)} $unit (exact = ${fmt(nsRealExact)} $unit).",
            mathLaTeX:
            "\\text{${lChar}K} \\approx ${fmt(nsPaperMeasured)}\\text{ cm} \\implies ${fmt(nsPaperMeasured)} \\times ${fmt(scale)} = \\boxed{${fmt(nsRealMeasured)}\\text{ $unit $nsWord}}",
          ),
          BearingDistanceStep(
            title:
            "Step 4: Part (b) — Measure Horizontal Line ${iChar}K ($ewWord / $oppEwWord Distance)",
            description:
            "• Line ${iChar}K represents the East–West distance between $origin and $target.\n"
                "• By measurement with a ruler on the scale drawing: ${iChar}K ≈ ${fmt(ewPaperMeasured)} cm.\n"
                "• Multiply by the scale (${fmt(scale)} $unit per cm): ${fmt(ewPaperMeasured)} × ${fmt(scale)} = ${fmt(ewRealMeasured)} $unit (exact = ${fmt(ewRealExact)} $unit).\n"
                "• Note on Wording (Example 4b): $target is ${fmt(ewRealMeasured)} $unit $ewWord of $origin, which means $origin is ${fmt(ewRealMeasured)} $unit $oppEwWord of $target!",
            mathLaTeX:
            "\\text{${iChar}K} \\approx ${fmt(ewPaperMeasured)}\\text{ cm} \\implies ${fmt(ewPaperMeasured)} \\times ${fmt(scale)} = \\boxed{${fmt(ewRealMeasured)}\\text{ $unit}}",
          ),
        ];

        return BearingsDistancesResult(
          mode: 1,
          subMode: 0,
          finalAnswers: {
            "a) $target $nsWord of $origin": "${fmt(nsRealMeasured)} $unit",
            "b) $origin $oppEwWord of $target": "${fmt(ewRealMeasured)} $unit",
            "Measured ${lChar}K & ${iChar}K":
            "${fmt(nsPaperMeasured)} cm & ${fmt(ewPaperMeasured)} cm",
            "Exact Components":
            "${fmt(nsRealExact)} $unit ${nsWord[0]}, ${fmt(ewRealExact)} $unit ${ewWord[0]}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: BearingsDistancesCanvasData(
            mode: 1,
            subMode: 0,
            unit: unit,
            scaleUnitsPerCm: scale,
            scaleBannerText: "Scale: $scaleText",
            pt1Name: origin,
            pt2Name: 'K',
            pt3Name: target,
            pt1Cm: Offset.zero,
            pt2Cm: Offset(0, deltaCm.dy),
            pt3Cm: deltaCm,
            leg1BearingDeg: deltaCm.dy >= 0 ? 0.0 : 180.0,
            leg1BearingLabel: nsWord,
            leg1RealDist: nsRealMeasured,
            leg1PaperCm: nsPaperMeasured,
            leg2BearingDeg: deltaCm.dx >= 0 ? 90.0 : 270.0,
            leg2BearingLabel: ewWord,
            leg2RealDist: ewRealMeasured,
            leg2PaperCm: ewPaperMeasured,
            resultantBearingDeg: bDeg,
            resultantBearingLabel: bStr,
            resultantRealDist: distVal,
            resultantPaperCm: hypPaperCm,
            headerBadge:
            "a) $target is ${fmt(nsRealMeasured)} $unit $nsWord of $origin   |   b) $origin is ${fmt(ewRealMeasured)} $unit $oppEwWord of $target",
            subBadge:
            "Scale: $scaleText   |   $lChar$iChar = ${fmt(hypPaperCm)} cm ($bStr)   |   ${lChar}K ≈ ${fmt(nsPaperMeasured)} cm   |   ${iChar}K ≈ ${fmt(ewPaperMeasured)} cm",
          ),
        );
      } else {
        // Sub-Mode 1B: Exercise 24g #6 (Given N/S Leg KE = 450 km & Bearing of L from K = 225° -> Find EL & KL)
        final String pK = pt1Name.trim().isEmpty ? 'Kaduna' : pt1Name.trim();
        final String pE = pt2Name.trim().isEmpty ? 'Enugu' : pt2Name.trim();
        final String pL = pt3Name.trim().isEmpty ? 'Lagos' : pt3Name.trim();
        final String cK = cleanTex(pK);
        final String cE = cleanTex(pE);
        final String cL = cleanTex(pL);

        final double nsPaperCm = distVal / scale;
        // Acute angle with the North-South line
        final double radWithNS =
            ((bDeg - 180.0).abs().clamp(5.0, 85.0)) * math.pi / 180.0;
        final double ewPaperCm = nsPaperCm * math.tan(radWithNS);
        final double hypPaperCm = nsPaperCm / math.cos(radWithNS);

        final double measEW_Cm = (ewPaperCm * 10.0).roundToDouble() / 10.0;
        final double measHyp_Cm = (hypPaperCm * 10.0).roundToDouble() / 10.0;
        final double realEW = measEW_Cm * scale;
        final double realHyp = measHyp_Cm * scale;

        final double signY = (bDeg > 90 && bDeg < 270) ? -1.0 : 1.0;
        final double signX = (bDeg > 0 && bDeg < 180) ? 1.0 : -1.0;

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Convert Known North/South Distance ($cK to $cE) Using Scale}}",
          "\\text{Scale: } 1\\text{ cm to } ${fmt(scale)}\\text{ $unit} \\implies \\text{Paper length} = \\frac{${fmt(distVal)}}{${fmt(scale)}} = \\mathbf{${fmt(nsPaperCm, maxDecimals: 2)}\\text{ cm}}",
          "",
          "\\text{\\textbf{Step 2: Construct Right-Angled Triangle \\& Bearing Ray } (${fmt3FigLaTeX(bDeg)})}",
          "\\text{Draw vertical line from $cK to $cE } (${fmt(nsPaperCm)}\\text{ cm), horizontal line at } 90^\\circ \\text{ from $cE, and bearing } ${fmt3FigLaTeX(bDeg)} \\text{ from $cK to meet at $cL.}",
          "",
          "\\text{\\textbf{Step 3: Measure (a) $cL to $cE and (b) $cL to $cK on the Scale Drawing}}",
          "\\text{(a) By measurement, $cL to $cE} \\approx ${fmt(measEW_Cm)}\\text{ cm} \\implies ${fmt(measEW_Cm)} \\times ${fmt(scale)} = \\mathbf{${fmt(realEW)}\\text{ $unit}}",
          "\\text{(b) By measurement, $cL to $cK} \\approx ${fmt(measHyp_Cm)}\\text{ cm} \\implies ${fmt(measHyp_Cm)} \\times ${fmt(scale)} = \\mathbf{${fmt(realHyp)}\\text{ $unit}}",
        ];

        final List<BearingDistanceStep> steps = [
          BearingDistanceStep(
            title:
            "Step 1: Convert the North–South Distance ($pK to $pE) to cm",
            description:
            "Using the scale '$scaleText', convert the ${fmt(distVal)} $unit North–South distance between $pK and $pE into centimetres:\n"
                "• Scale length = ${fmt(distVal)} $unit ÷ ${fmt(scale)} = ${fmt(nsPaperCm, maxDecimals: 2)} cm.",
            mathLaTeX:
            "\\text{Scale length} = \\frac{${fmt(distVal)}}{${fmt(scale)}} = ${fmt(nsPaperCm, maxDecimals: 2)}\\text{ cm}",
          ),
          BearingDistanceStep(
            title:
            "Step 2: Construct the Right-Angled Triangle & $bStr Ray (Exercise 24g #6)",
            description:
            "1. Draw the vertical North–South line segment from $pK to $pE of length ${fmt(nsPaperCm, maxDecimals: 2)} cm.\n"
                "2. Since $pL is due West/East of $pE, use a set-square to draw a horizontal line (at 90°) from $pE.\n"
                "3. Place your protractor at $pK, measure the bearing of $bStr clockwise from North, and draw the ray until it meets the horizontal line from $pE at $pL.",
            mathLaTeX:
            "\\angle \\text{at $cE} = 90^\\circ, \\quad \\text{Bearing of $cL from $cK} = ${fmt3FigLaTeX(bDeg)}",
          ),
          BearingDistanceStep(
            title:
            "Step 3: Measure Both Unknown Distances on Paper and Multiply by Scale",
            description:
            "• (a) Distance between $pL and $pE: Measure the horizontal leg on paper ≈ ${fmt(measEW_Cm)} cm → ${fmt(measEW_Cm)} × ${fmt(scale)} = ${fmt(realEW)} $unit.\n"
                "• (b) Distance between $pL and $pK: Measure the slanted hypotenuse on paper ≈ ${fmt(measHyp_Cm)} cm → ${fmt(measHyp_Cm)} × ${fmt(scale)} = ${fmt(realHyp)} $unit.",
            mathLaTeX:
            "\\text{(a) $cL to $cE} = \\boxed{${fmt(realEW)}\\text{ $unit}}, \\quad \\text{(b) $cL to $cK} = \\boxed{${fmt(realHyp)}\\text{ $unit}}",
          ),
        ];

        return BearingsDistancesResult(
          mode: 1,
          subMode: 1,
          finalAnswers: {
            "a) $pL to $pE": "${fmt(realEW)} $unit (${fmt(measEW_Cm)} cm)",
            "b) $pL to $pK": "${fmt(realHyp)} $unit (${fmt(measHyp_Cm)} cm)",
            "Scale Used": scaleText,
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: BearingsDistancesCanvasData(
            mode: 1,
            subMode: 1,
            unit: unit,
            scaleUnitsPerCm: scale,
            scaleBannerText: "Scale: $scaleText",
            pt1Name: pK,
            pt2Name: pE,
            pt3Name: pL,
            pt1Cm: Offset.zero,
            pt2Cm: Offset(0, signY * nsPaperCm),
            pt3Cm: Offset(signX * ewPaperCm, signY * nsPaperCm),
            leg1RealDist: distVal,
            leg1PaperCm: nsPaperCm,
            leg2RealDist: realEW,
            leg2PaperCm: measEW_Cm,
            resultantBearingDeg: bDeg,
            resultantBearingLabel: bStr,
            resultantRealDist: realHyp,
            resultantPaperCm: measHyp_Cm,
            headerBadge:
            "a) $pL to $pE = ${fmt(realEW)} $unit   |   b) $pL to $pK ≈ ${fmt(realHyp)} $unit",
            subBadge:
            "Scale: $scaleText   |   $pK–$pE = ${fmt(nsPaperCm)} cm   |   $pE–$pL = ${fmt(measEW_Cm)} cm   |   $pK–$pL = ${fmt(measHyp_Cm)} cm",
          ),
        );
      }
    } catch (e) {
      return BearingsDistancesResult.error(
        mode: 1,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid distance and bearing.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: SURVEYING FROM A CENTRAL POINT P (RADIAL POLAR SURVEY)
  // Matches Figures 24.22–24.24, 24.26, 24.27, Exercise 24f #1, #2, #4, #5 & Ex 24g #9
  // ===========================================================================
  static BearingsDistancesResult solveRadialSurvey({
    required String centerPointName,
    required List<SurveyLandmarkInput> landmarkInputs,
    required int pairIdx1, // From Point Index
    required int pairIdx2, // To Point Index
    required String unit,
    required bool autoScale,
    required String customScaleStr,
  }) {
    try {
      final String pCenter =
      centerPointName.trim().isEmpty ? 'P' : centerPointName.trim();
      final String cleanP = cleanTex(pCenter);

      final List<SurveyLandmarkInput> validInputs = landmarkInputs
          .where((l) =>
      l.label.trim().isNotEmpty &&
          l.bearingStr.trim().isNotEmpty &&
          l.distanceStr.trim().isNotEmpty)
          .toList();

      if (validInputs.length < 2) {
        throw const FormatException(
            "Please enter at least 2 surveyed landmarks with their bearings and distances from P.");
      }

      final List<double> rawDists = [];
      for (final inp in validInputs) {
        final double? d = double.tryParse(inp.distanceStr.trim());
        if (d == null || d <= 0) {
          throw FormatException(
              "Invalid distance '${inp.distanceStr}' for landmark ${inp.label}.");
        }
        rawDists.add(d);
      }

      final double scale = chooseSuitableScale(
        rawDists,
        autoScale: autoScale,
        customScaleStr: customScaleStr,
      );
      final String scaleText = "1 cm represents ${fmt(scale)} $unit";

      const List<Color> palette = [
        Colors.deepPurple,
        Color(0xFF2E7D32),
        Color(0xFFE65100),
        Color(0xFF1565C0),
      ];

      final List<EvaluatedSurveyPoint> pts = [];
      final List<String> workings = [
        "\\text{\\textbf{Step 1: Polar Survey Coordinates from Central Point $cleanP (Page 218)}}",
        "\\text{In surveying, } (\\theta^\\circ, \\; d\\text{ $unit}) \\text{ means bearing } \\theta^\\circ \\text{ clockwise from North and distance } d\\text{ $unit from $cleanP.}",
        "\\text{Scale Chosen: } 1\\text{ cm represents } ${fmt(scale)}\\text{ $unit}",
        "",
        "\\text{\\textbf{Step 2: Convert Radial Survey Distances to Scale Lengths (cm)}}",
      ];

      final List<String> step1Lines = [];
      for (int i = 0; i < validInputs.length; i++) {
        final SurveyLandmarkInput inp = validInputs[i];
        final String lbl = inp.label.trim();
        final String cLbl = cleanTex(lbl);
        final Map<String, dynamic> bMap = parseFlexibleBearing(inp.bearingStr);
        final double bDeg = bMap['deg'] as double;
        final String bStr = bMap['threeFigStr'] as String;
        final double rDist = rawDists[i];
        final double pCm = rDist / scale;
        final Offset xyCm = bearingToDeltaXY(bDeg, pCm);

        pts.add(EvaluatedSurveyPoint(
          label: lbl,
          bearingDeg: bDeg,
          bearingFormatted: bStr,
          realDist: rDist,
          paperDistCm: pCm,
          xCm: xyCm.dx,
          yCm: xyCm.dy,
          color: palette[i % palette.length],
        ));

        workings.add(
            "\\bullet \\text{ $cLbl } (${fmt3FigLaTeX(bDeg)},\\; ${fmt(rDist)}\\text{ $unit}): \\quad \\text{Paper length } \\text{$cleanP$cLbl} = \\frac{${fmt(rDist)}}{${fmt(scale)}} = \\mathbf{${fmt(pCm, maxDecimals: 2)}\\text{ cm}}");
        step1Lines.add(
            "• $lbl ($bStr, ${fmt(rDist)} $unit): Draw ray at $bStr from $pCenter of length ${fmt(rDist)} ÷ ${fmt(scale)} = ${fmt(pCm, maxDecimals: 2)} cm.");
      }

      final int idxFrom = pairIdx1.clamp(0, pts.length - 1);
      final int idxTo = pairIdx2.clamp(0, pts.length - 1) == idxFrom
          ? ((idxFrom + 1) % pts.length)
          : pairIdx2.clamp(0, pts.length - 1);

      final EvaluatedSurveyPoint ptFrom = pts[idxFrom];
      final EvaluatedSurveyPoint ptTo = pts[idxTo];
      final String cFrom = cleanTex(ptFrom.label);
      final String cTo = cleanTex(ptTo.label);

      final double dxCm = ptTo.xCm - ptFrom.xCm;
      final double dyCm = ptTo.yCm - ptFrom.yCm;
      final double exactPairCm = math.sqrt(dxCm * dxCm + dyCm * dyCm);
      final double measPairCm = (exactPairCm * 10.0).roundToDouble() / 10.0;
      final double measPairReal = measPairCm * scale;
      final double exactPairReal = exactPairCm * scale;

      final double pairBearingDeg = deltaXYToBearingDeg(dxCm, dyCm);
      final int roundedPairBearing = pairBearingDeg.round() % 360;
      final String pairBearing3Fig = fmt3Fig(roundedPairBearing.toDouble());
      final double revPairBearing = roundedPairBearing < 180
          ? (roundedPairBearing + 180.0)
          : (roundedPairBearing - 180.0);

      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 3: Measure Distance and Bearing of $cTo from $cFrom}}");
      workings.add(
          "\\text{By measurement on scale drawing, line Segment} \\approx ${fmt(measPairCm)}\\text{ cm}");
      workings.add(
          "\\text{True Distance ($cFrom to $cTo)} \\approx ${fmt(measPairCm)} \\times ${fmt(scale)} = \\mathbf{${fmt(measPairReal)}\\text{ $unit}} \\quad \\left(\\text{Exact} = ${fmt(exactPairReal)}\\text{ $unit}\\right)");
      workings.add(
          "\\text{Bearing of $cTo from $cFrom (clockwise from N at $cFrom)} = \\mathbf{${fmt3FigLaTeX(roundedPairBearing.toDouble())}} \\quad \\left(\\text{$cFrom from $cTo} = ${fmt3FigLaTeX(revPairBearing)}\\right)");

      final List<BearingDistanceStep> steps = [
        BearingDistanceStep(
          title:
          "Step 1: Plot Radial Survey Lines from Central Point '$pCenter' (Figures 24.22 & 24.23)",
          description:
          "1. Mark surveyor point '$pCenter' and draw a vertical line $pCenter N pointing North (000°).\n"
              "2. Using the scale '$scaleText', use your protractor and ruler at '$pCenter' to plot each surveyed landmark:\n"
              "${step1Lines.join('\n')}",
          mathLaTeX:
          "\\text{Scale: } 1\\text{ cm to } ${fmt(scale)}\\text{ $unit}",
        ),
        BearingDistanceStep(
          title:
          "Step 2: Measure the Distance and Bearing of ${ptTo.label} from ${ptFrom.label}",
          description:
          "1. Join '${ptFrom.label}' to '${ptTo.label}' with a straight ruler line and measure its length in cm:\n"
              "   • Measured paper length ≈ ${fmt(measPairCm)} cm.\n"
              "   • Multiply by ${fmt(scale)} $unit: ${fmt(measPairCm)} × ${fmt(scale)} = ${fmt(measPairReal)} $unit (exact = ${fmt(exactPairReal)} $unit).\n"
              "2. Draw a vertical North line at '${ptFrom.label}' and measure the clockwise angle to '${ptTo.label}' with a protractor:\n"
              "   • Bearing of ${ptTo.label} from ${ptFrom.label} = $pairBearing3Fig (and bearing of ${ptFrom.label} from ${ptTo.label} = ${fmt3Fig(revPairBearing)}).",
          mathLaTeX:
          "\\text{Distance} = \\boxed{${fmt(measPairReal)}\\text{ $unit}}, \\quad \\text{Bearing ($cTo from $cFrom)} = \\boxed{${fmt3FigLaTeX(roundedPairBearing.toDouble())}}",
        ),
      ];

      final Map<String, String> answers = {
        "Distance (${ptFrom.label}–${ptTo.label})":
        "${fmt(measPairReal)} $unit (${fmt(measPairCm)} cm)",
        "Bearing (${ptTo.label} from ${ptFrom.label})": pairBearing3Fig,
        "Bearing (${ptFrom.label} from ${ptTo.label})": fmt3Fig(revPairBearing),
      };

      // If 3+ landmarks are entered, also compute the perpendicular distance from Landmark 3 to Line (Landmark 1 - Landmark 2)
      // This directly answers Exercise 24f #1b (Tree to Classroom Block) and Exercise 24f #5c (Water Tower to Railway Line)
      // AND if it's a 2-part road (Ex 24f #4: A -> B -> C), also shows the second leg B -> C!
      Offset? perpFootCm;
      double? perpPaperCm;
      double? perpRealDist;

      if (pts.length >= 3) {
        final EvaluatedSurveyPoint pA = pts[0];
        final EvaluatedSurveyPoint pB = pts[1];
        final EvaluatedSurveyPoint pC = pts[2];

        // 1. Check leg B -> C (for Ex 24f #4 Road Survey: bearing of B from A and bearing of C from B)
        final double dxBC = pC.xCm - pB.xCm;
        final double dyBC = pC.yCm - pB.yCm;
        final double distBC_Cm = math.sqrt(dxBC * dxBC + dyBC * dyBC);
        final double bearingCFromB = deltaXYToBearingDeg(dxBC, dyBC);

        // 2. Perpendicular distance from 3rd point (pC) to line through pA and pB (Ex 24f #1b & #5c)
        final double abX = pB.xCm - pA.xCm;
        final double abY = pB.yCm - pA.yCm;
        final double abLenSq = abX * abX + abY * abY;
        if (abLenSq > 1e-6) {
          final double tProj =
              ((pC.xCm - pA.xCm) * abX + (pC.yCm - pA.yCm) * abY) / abLenSq;
          final Offset foot = Offset(pA.xCm + tProj * abX, pA.yCm + tProj * abY);
          final double pDistCm =
              (Offset(pC.xCm, pC.yCm) - foot).distance;
          final double measPerpCm = (pDistCm * 10.0).roundToDouble() / 10.0;
          final double realPerp = measPerpCm * scale;

          perpFootCm = foot;
          perpPaperCm = measPerpCm;
          perpRealDist = realPerp;

          final String cA = cleanTex(pA.label);
          final String cB = cleanTex(pB.label);
          final String cC = cleanTex(pC.label);

          workings.add("");
          workings.add(
              "\\text{\\textbf{Step 4: Additional Survey Measurements (Perpendicular Offset \\& Next Leg)}}");
          workings.add(
              "\\bullet \\text{ Perpendicular distance of $cC from line $cA$cB} \\approx ${fmt(measPerpCm)}\\text{ cm} \\times ${fmt(scale)} = \\mathbf{${fmt(realPerp)}\\text{ $unit}}");
          workings.add(
              "\\bullet \\text{ Bearing of $cC from $cB} = \\mathbf{${fmt3FigLaTeX(bearingCFromB)}} \\quad \\left(\\text{Distance $cB$cC} \\approx ${fmt(distBC_Cm * scale)}\\text{ $unit}\\right)");

          steps.add(BearingDistanceStep(
            title:
            "Step 3: Perpendicular Distance of ${pC.label} from Line ${pA.label}${pB.label} & Second Leg (${pB.label} → ${pC.label})",
            description:
            "• Perpendicular Offset (Ex 24f #1b & #5c): Drop a perpendicular line (at 90°) from '${pC.label}' to the line joining '${pA.label}' and '${pB.label}'. On paper, this measures ≈ ${fmt(measPerpCm)} cm, which is ${fmt(measPerpCm)} × ${fmt(scale)} = ${fmt(realPerp)} $unit.\n"
                "• Second Road Leg (Ex 24f #4): From '${pB.label}' to '${pC.label}', the bearing of ${pC.label} from ${pB.label} is ${fmt3Fig(bearingCFromB)} and the distance is ${fmt(distBC_Cm * scale)} $unit.",
            mathLaTeX:
            "\\text{Perp. Distance} = \\boxed{${fmt(realPerp)}\\text{ $unit}}, \\quad \\text{Bearing ($cC from $cB)} = \\boxed{${fmt3FigLaTeX(bearingCFromB)}}",
          ));

          answers["Perp. Dist (${pC.label} to ${pA.label}${pB.label})"] =
          "${fmt(realPerp)} $unit (${fmt(measPerpCm)} cm)";
          answers["Bearing (${pC.label} from ${pB.label})"] =
              fmt3Fig(bearingCFromB);
        }
      }

      return BearingsDistancesResult(
        mode: 2,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BearingsDistancesCanvasData(
          mode: 2,
          unit: unit,
          scaleUnitsPerCm: scale,
          scaleBannerText: "Scale: $scaleText",
          centerPointName: pCenter,
          surveyPoints: pts,
          targetIdx1: idxFrom,
          targetIdx2: idxTo,
          perpFootCm: perpFootCm,
          perpPaperCm: perpPaperCm,
          perpRealDist: perpRealDist,
          headerBadge:
          "${ptTo.label} from ${ptFrom.label}:  Distance ≈ ${fmt(measPairReal)} $unit (${fmt(measPairCm)} cm)  |  Bearing = $pairBearing3Fig",
          subBadge:
          "Scale: $scaleText   |   Surveyed from Central Point $pCenter",
        ),
      );
    } catch (e) {
      return BearingsDistancesResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please check your surveyed landmarks, bearings, and distances.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: TWO-POINT BEARING INTERSECTION / RIVER WIDTH TRIANGULATION
  // Matches Exercise 24f #3 (Figure 24.25: AB = 100 m) & Revision Test 24 #8 (AB = 80 m)
  // ===========================================================================
  static BearingsDistancesResult solveRiverTriangulation({
    required String ptAName,
    required String ptBName,
    required String targetName,
    required String baselineABStr,
    required String bearingFromAStr,
    required String bearingFromBStr,
    required String unit,
    required bool autoScale,
    required String customScaleStr,
  }) {
    try {
      final String pA = ptAName.trim().isEmpty ? 'A' : ptAName.trim();
      final String pB = ptBName.trim().isEmpty ? 'B' : ptBName.trim();
      final String pT = targetName.trim().isEmpty ? 'Tree' : targetName.trim();
      final String cA = cleanTex(pA);
      final String cB = cleanTex(pB);
      final String cT = cleanTex(pT);

      final double? distAB = double.tryParse(baselineABStr.trim());
      if (distAB == null || distAB <= 0) {
        throw const FormatException(
            "Please enter a positive distance for baseline AB (e.g. 100 or 80).");
      }

      final Map<String, dynamic> bAData = parseFlexibleBearing(bearingFromAStr);
      final Map<String, dynamic> bBData = parseFlexibleBearing(bearingFromBStr);
      final double bADeg = bAData['deg'] as double;
      final double bBDeg = bBData['deg'] as double;
      final String bAStr = bAData['threeFigStr'] as String;
      final String bBStr = bBData['threeFigStr'] as String;

      final double scale = chooseSuitableScale(
        [distAB],
        autoScale: autoScale,
        customScaleStr: customScaleStr,
      );
      final String scaleText = "1 cm to ${fmt(scale)} $unit";
      final double abPaperCm = distAB / scale;

      // A is at (0, 0) and B is due East of A at (abPaperCm, 0) as in Figure 24.25
      const Offset posA = Offset.zero;
      final Offset posB = Offset(abPaperCm, 0.0);

      // Intersect ray from A (direction uA = (sin bA, cos bA)) and ray from B (direction uB = (sin bB, cos bB))
      final double radA = bADeg * math.pi / 180.0;
      final double radB = bBDeg * math.pi / 180.0;
      final double uxA = math.sin(radA), uyA = math.cos(radA);
      final double uxB = math.sin(radB), uyB = math.cos(radB);

      // Solve: tA * uxA - tB * uxB = abPaperCm  and  tA * uyA - tB * uyB = 0
      final double det = -uxA * uyB + uyA * uxB;
      if (det.abs() < 1e-6) {
        throw const FormatException(
            "The two bearing sight-lines are parallel and do not intersect.");
      }

      final double tA = (-abPaperCm * uyB) / det;
      final double tB = (-abPaperCm * uyA) / det;
      if (tA <= 0 || tB <= 0) {
        throw const FormatException(
            "With these bearings, the two sight-lines diverge instead of intersecting across the river. (Try 000° from A and 290° or 300° from B).");
      }

      final Offset posT = Offset(tA * uxA, tA * uyA);
      final double widthPaperExact = posT.dy.abs(); // Perpendicular river width
      final double widthPaperMeasured =
          (widthPaperExact * 10.0).roundToDouble() / 10.0;
      final double widthRealMeasured = widthPaperMeasured * scale;
      final double widthRealExact = widthPaperExact * scale;
      final String width2SF = fmt2SF(widthRealExact);

      final double angleFromWestDeg = (bBDeg - 270.0).abs();

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Choose Scale and Convert Baseline $cA$cB to cm (Figure 24.25)}}",
        "\\text{Scale: } 1\\text{ cm represents } ${fmt(scale)}\\text{ $unit}",
        "\\text{Baseline } \\text{$cA$cB} = \\frac{${fmt(distAB)}\\text{ $unit}}{${fmt(scale)}} = \\mathbf{${fmt(abPaperCm, maxDecimals: 2)}\\text{ cm}}",
        "",
        "\\text{\\textbf{Step 2: Construct Intersecting Bearing Sight-Lines from $cA and $cB}}",
        "\\bullet \\text{ At $cA: Draw sight-line on bearing } ${fmt3FigLaTeX(bADeg)} \\text{ towards the $cT.}",
        "\\bullet \\text{ At $cB: Draw parallel North line and measure bearing } ${fmt3FigLaTeX(bBDeg)} \\text{ clockwise}",
        "\\quad \\left(\\text{which makes } ${fmt(angleFromWestDeg)}^\\circ \\text{ above the horizontal line $cB$cA, or } ${fmt(360.0 - bBDeg)}^\\circ \\text{ West of North}\\right).",
        "",
        "\\text{\\textbf{Step 3: Measure the Perpendicular River Width on the Scale Drawing}}",
        "\\text{By measurement, River Width} \\approx ${fmt(widthPaperMeasured)}\\text{ cm}",
        "\\text{Approximate Width of River} = ${fmt(widthPaperMeasured)} \\times ${fmt(scale)}\\text{ $unit} = \\mathbf{${fmt(widthRealMeasured)}\\text{ $unit}}",
        "\\text{Width rounded to 2 significant figures (Rev Test 24 \\#8)} = \\mathbf{$width2SF\\text{ $unit}}",
      ];

      final List<BearingDistanceStep> steps = [
        BearingDistanceStep(
          title:
          "Step 1: Convert Baseline $pA$pB Using the Scale ($scaleText)",
          description:
          "Points $pA and $pB lie on the lower bank of the river ${fmt(distAB)} $unit apart (Figure 24.25). Using the scale '$scaleText':\n"
              "• Scale baseline $pA$pB = ${fmt(distAB)} $unit ÷ ${fmt(scale)} = ${fmt(abPaperCm, maxDecimals: 2)} cm.",
          mathLaTeX:
          "\\text{$cA$cB} = \\frac{${fmt(distAB)}}{${fmt(scale)}} = \\mathbf{${fmt(abPaperCm, maxDecimals: 2)}\\text{ cm}}",
        ),
        BearingDistanceStep(
          title:
          "Step 2: Draw the Bearing Rays from $pA ($bAStr) and $pB ($bBStr) to Locate the $pT",
          description:
          "1. Draw horizontal baseline $pA$pB = ${fmt(abPaperCm, maxDecimals: 2)} cm (since $pB is due East of $pA).\n"
              "2. At $pA, draw the sight-line on bearing $bAStr (straight up North).\n"
              "3. At $pB, draw a vertical North arrow and use your protractor to measure the clockwise bearing $bBStr (note: $bBStr is ${fmt(360.0 - bBDeg)}° anticlockwise from North, or ${fmt(angleFromWestDeg)}° above the horizontal baseline $pB$pA).\n"
              "4. Mark the point where the two sight-lines cross on the opposite bank as the $pT!",
          mathLaTeX:
          "\\text{Ray from $cA} = ${fmt3FigLaTeX(bADeg)}, \\quad \\text{Ray from $cB} = ${fmt3FigLaTeX(bBDeg)}",
        ),
        BearingDistanceStep(
          title:
          "Step 3: Measure the River Width in cm and Convert to Metres (2 s.f.)",
          description:
          "1. Use your ruler to measure the perpendicular width of the river (from $pA straight across to the $pT) on your scale drawing:\n"
              "   • Measured width on paper ≈ ${fmt(widthPaperMeasured)} cm.\n"
              "2. Multiply by the scale factor (${fmt(scale)} $unit per cm):\n"
              "   • River Width ≈ ${fmt(widthPaperMeasured)} × ${fmt(scale)} = ${fmt(widthRealMeasured)} $unit (exact = ${fmt(widthRealExact)} $unit).\n"
              "3. Rounded to 2 significant figures (as required in Revision Test 24 #8): $width2SF $unit.",
          mathLaTeX:
          "\\text{River Width} \\approx ${fmt(widthPaperMeasured)} \\times ${fmt(scale)} = \\boxed{${fmt(widthRealMeasured)}\\text{ $unit}} \\; (\\mathbf{$width2SF\\text{ $unit}} \\text{ to 2 s.f.})",
        ),
      ];

      return BearingsDistancesResult(
        mode: 3,
        finalAnswers: {
          "River Width (Scale)": "${fmt(widthRealMeasured)} $unit",
          "Width (to 2 s.f.)": "$width2SF $unit",
          "Measured Width on Paper": "${fmt(widthPaperMeasured)} cm",
          "Scale Baseline ($pA$pB)": "${fmt(abPaperCm)} cm",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BearingsDistancesCanvasData(
          mode: 3,
          unit: unit,
          scaleUnitsPerCm: scale,
          scaleBannerText: "Scale: $scaleText",
          pt1Name: pA,
          pt2Name: pB,
          pt3Name: pT,
          pt1Cm: posA,
          pt2Cm: posB,
          pt3Cm: posT,
          leg1BearingDeg: bADeg,
          leg1BearingLabel: bAStr,
          leg1RealDist: distAB,
          leg1PaperCm: abPaperCm,
          leg2BearingDeg: bBDeg,
          leg2BearingLabel: bBStr,
          leg2RealDist: tB * scale,
          leg2PaperCm: tB,
          resultantRealDist: widthRealMeasured,
          resultantPaperCm: widthPaperMeasured,
          headerBadge:
          "River Width ≈ ${fmt(widthRealMeasured)} $unit ($width2SF $unit to 2 s.f.)   |   Measured = ${fmt(widthPaperMeasured)} cm",
          subBadge:
          "Scale: $scaleText   |   Baseline $pA$pB = ${fmt(abPaperCm)} cm (${fmt(distAB)} $unit)   |   Sight-lines: $bAStr & $bBStr",
        ),
      );
    } catch (e) {
      return BearingsDistancesResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter a valid baseline distance and intersecting bearings.",
      );
    }
  }
}