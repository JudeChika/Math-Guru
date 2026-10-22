import 'package:flutter/material.dart';
import 'bearings_models.dart';

class BearingsLogic {
  // ===========================================================================
  // 14 TEXTBOOK PRESETS (Covers Figures 24.8–24.21, Examples 1–2, Ex 24c & 24e)
  // ===========================================================================
  static const List<BearingPreset> textbookPresets = [
    BearingPreset(
      chipLabel: "Fig 24.8: Round House from A (N37°E → 037°)",
      mode: 0,
      subMode: 0,
      fromPoint: 'A',
      toPoint: 'Round House',
      bearingInputStr: 'N37°E',
    ),
    BearingPreset(
      chipLabel: "Fig 24.9: Flagpole from A (S66°W → 246°)",
      mode: 0,
      subMode: 0,
      fromPoint: 'A',
      toPoint: 'Flagpole',
      bearingInputStr: 'S66°W',
    ),
    BearingPreset(
      chipLabel: "Ex 24c #1 (Fig 24.10): 58° East of North (N58°E)",
      mode: 0,
      subMode: 1,
      fromPoint: 'B',
      toPoint: 'A',
      quadrantCode: 'NE',
      measuredFromNS: true,
      givenAngleStr: '58',
    ),
    BearingPreset(
      chipLabel: "Ex 24c #2 (Fig 24.10): 40° East of South (S40°E)",
      mode: 0,
      subMode: 1,
      fromPoint: 'B',
      toPoint: 'A',
      quadrantCode: 'SE',
      measuredFromNS: true,
      givenAngleStr: '40',
    ),
    BearingPreset(
      chipLabel: "Ex 24c #4 (Fig 24.10): 30° with West in SW (→ S60°W)",
      mode: 0,
      subMode: 1,
      fromPoint: 'B',
      toPoint: 'A',
      quadrantCode: 'SW',
      measuredFromNS: false,
      givenAngleStr: '30',
    ),
    BearingPreset(
      chipLabel: "Ex 24c #6 (Fig 24.10): 20° with West in NW (→ N70°W)",
      mode: 0,
      subMode: 1,
      fromPoint: 'B',
      toPoint: 'A',
      quadrantCode: 'NW',
      measuredFromNS: false,
      givenAngleStr: '20',
    ),
    BearingPreset(
      chipLabel: "Ex 24e #1c (Fig 24.18): 120° Clockwise from South",
      mode: 1,
      fromPoint: 'A',
      toPoint: 'B',
      sketchRefType: 'CW_S',
      givenAngleStr: '120',
    ),
    BearingPreset(
      chipLabel: "Ex 24e #1e (Fig 24.18): 33° Anticlockwise from North",
      mode: 1,
      fromPoint: 'A',
      toPoint: 'B',
      sketchRefType: 'ACW_N',
      givenAngleStr: '33',
    ),
    BearingPreset(
      chipLabel: "Ex 24e #1g (Fig 24.18): 47° Anticlockwise from South",
      mode: 1,
      fromPoint: 'A',
      toPoint: 'B',
      sketchRefType: 'ACW_S',
      givenAngleStr: '47',
    ),
    BearingPreset(
      chipLabel: "Example 1 (Fig 24.14): Bearings of A, B, C, D from X",
      mode: 2,
      centerPoint: 'X',
      multiRays: [
        MultiRayInput(
            pointLabel: 'A', givenAngleStr: '63', referenceType: 'E_of_N'),
        MultiRayInput(
            pointLabel: 'B', givenAngleStr: '35', referenceType: 'E_of_S'),
        MultiRayInput(
            pointLabel: 'C', givenAngleStr: '75', referenceType: 'W_of_S'),
        MultiRayInput(
            pointLabel: 'D', givenAngleStr: '52', referenceType: 'W_of_N'),
      ],
    ),
    BearingPreset(
      chipLabel: "Ex 24e #2 (Fig 24.19): Bearings of A, B, C, D from X",
      mode: 2,
      centerPoint: 'X',
      multiRays: [
        MultiRayInput(
            pointLabel: 'A', givenAngleStr: '40', referenceType: 'E_of_N'),
        MultiRayInput(
            pointLabel: 'B', givenAngleStr: '60', referenceType: 'E_of_S'),
        MultiRayInput(
            pointLabel: 'C', givenAngleStr: '50', referenceType: 'W_of_S'),
        MultiRayInput(
            pointLabel: 'D', givenAngleStr: '70', referenceType: 'W_of_N'),
      ],
    ),
    BearingPreset(
      chipLabel: "Ex 24e #3 (Fig 24.20): Bearings of U, V, X, Y, Z from O",
      mode: 2,
      centerPoint: 'O',
      multiRays: [
        MultiRayInput(
            pointLabel: 'U', givenAngleStr: '45', referenceType: 'E_of_N'),
        MultiRayInput(
            pointLabel: 'V',
            givenAngleStr: '83',
            referenceType: 'CW_from_Prev'),
        MultiRayInput(
            pointLabel: 'X', givenAngleStr: '72', referenceType: 'E_of_S'),
        MultiRayInput(
            pointLabel: 'Y', givenAngleStr: '49', referenceType: 'W_of_S'),
        MultiRayInput(
            pointLabel: 'Z', givenAngleStr: '54', referenceType: 'S_of_W'),
      ],
    ),
    BearingPreset(
      chipLabel: "Example 2 (Fig 24.17): X from Y is 247° → Find Y from X",
      mode: 3,
      point1Name: 'X',
      point2Name: 'Y',
      backGivenType: 0,
      givenAngleStr: '247',
    ),
    BearingPreset(
      chipLabel: "Ex 24e #5f (Fig 24.21f): Reflex 319° at B → A & B Bearings",
      mode: 3,
      point1Name: 'A',
      point2Name: 'B',
      backGivenType: 3,
      givenAngleStr: '319',
    ),
  ];

  // ===========================================================================
  // REUSABLE FORMATTING & BEARING CONVERSION HELPERS
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

  /// Formats a clockwise angle (0° to 360°) as a 3-digit string with leading zeros (e.g. `037°`, `008°`, `246°`)
  static String fmt3Fig(double deg, {bool withDegreeSymbol = true}) {
    final double norm = normalizeAngle360(deg);
    final String degSym = withDegreeSymbol ? '°' : '';
    if ((norm - norm.roundToDouble()).abs() < 1e-9) {
      final int rounded = norm.round();
      final String padded = rounded.toString().padLeft(3, '0');
      return '$padded$degSym';
    }
    final int whole = norm.floor();
    final String frac = fmt(norm - whole).substring(1); // ".5"
    final String paddedWhole = whole.toString().padLeft(3, '0');
    return '$paddedWhole$frac$degSym';
  }

  static String fmt3FigLaTeX(double deg) {
    return "${fmt3Fig(deg, withDegreeSymbol: false)}^\\circ";
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

  static double normalizeAngle360(double deg) {
    if ((deg - 360.0).abs() < 1e-9) return 360.0;
    final double m = deg % 360.0;
    return m < 0 ? m + 360.0 : (m.abs() < 1e-9 ? 0.0 : m);
  }

  /// Decomposes any clockwise angle [0, 360] into its quadrant, acute angle with N/S, and formatted strings
  static Map<String, dynamic> decomposeThreeFigAngle(double rawDeg) {
    final double deg = normalizeAngle360(rawDeg);
    final double eff = (deg - 360.0).abs() < 1e-9 ? 0.0 : deg;

    if (eff.abs() < 1e-9) {
      return {
        'threeFigDeg': deg,
        'threeFigStr': deg == 360.0 ? '360° (or 000°)' : '000° (or 360°)',
        'threeFigTex': deg == 360.0 ? '360^\\circ \\text{ (or } 000^\\circ\\text{)}' : '000^\\circ \\text{ (or } 360^\\circ\\text{)}',
        'acuteWithNS': 0.0,
        'isFromNorth': true,
        'isTowardsEast': true,
        'acuteStr': 'Due North (N)',
        'acuteTex': '\\text{Due North (N)}',
        'quadrantName': 'Due North (000° / 360°)',
        'calcFromNSTex': '000^\\circ',
        'calcToNSTex': '0^\\circ \\text{ with North}',
      };
    }
    if ((eff - 90.0).abs() < 1e-9) {
      return {
        'threeFigDeg': 90.0,
        'threeFigStr': '090°',
        'threeFigTex': '090^\\circ',
        'acuteWithNS': 90.0,
        'isFromNorth': true,
        'isTowardsEast': true,
        'acuteStr': 'Due East (E / N90°E)',
        'acuteTex': '\\text{Due East (E)}',
        'quadrantName': 'Due East (090°)',
        'calcFromNSTex': '000^\\circ + 90^\\circ = 090^\\circ',
        'calcToNSTex': '90^\\circ \\text{ East of North}',
      };
    }
    if ((eff - 180.0).abs() < 1e-9) {
      return {
        'threeFigDeg': 180.0,
        'threeFigStr': '180°',
        'threeFigTex': '180^\\circ',
        'acuteWithNS': 0.0,
        'isFromNorth': false,
        'isTowardsEast': true,
        'acuteStr': 'Due South (S)',
        'acuteTex': '\\text{Due South (S)}',
        'quadrantName': 'Due South (180°)',
        'calcFromNSTex': '180^\\circ',
        'calcToNSTex': '0^\\circ \\text{ with South}',
      };
    }
    if ((eff - 270.0).abs() < 1e-9) {
      return {
        'threeFigDeg': 270.0,
        'threeFigStr': '270°',
        'threeFigTex': '270^\\circ',
        'acuteWithNS': 90.0,
        'isFromNorth': false,
        'isTowardsEast': false,
        'acuteStr': 'Due West (W / S90°W)',
        'acuteTex': '\\text{Due West (W)}',
        'quadrantName': 'Due West (270°)',
        'calcFromNSTex': '270^\\circ',
        'calcToNSTex': '90^\\circ \\text{ West of North/South}',
      };
    }

    if (eff > 0.0 && eff < 90.0) {
      final double ac = eff;
      return {
        'threeFigDeg': eff,
        'threeFigStr': fmt3Fig(eff),
        'threeFigTex': fmt3FigLaTeX(eff),
        'acuteWithNS': ac,
        'isFromNorth': true,
        'isTowardsEast': true,
        'acuteStr': 'N${fmt(ac)}°E',
        'acuteTex': '\\text{N}${fmt(ac)}^\\circ\\text{E}',
        'quadrantName': 'North-East (NE) Quadrant (000° to 090°)',
        'calcFromNSTex': '000^\\circ + ${fmt(ac)}^\\circ = ${fmt3FigLaTeX(eff)}',
        'calcToNSTex': '\\text{Angle with North (towards East)} = ${fmt(ac)}^\\circ \\implies \\text{N}${fmt(ac)}^\\circ\\text{E}',
      };
    } else if (eff > 90.0 && eff < 180.0) {
      final double ac = 180.0 - eff;
      return {
        'threeFigDeg': eff,
        'threeFigStr': fmt3Fig(eff),
        'threeFigTex': fmt3FigLaTeX(eff),
        'acuteWithNS': ac,
        'isFromNorth': false,
        'isTowardsEast': true,
        'acuteStr': 'S${fmt(ac)}°E',
        'acuteTex': '\\text{S}${fmt(ac)}^\\circ\\text{E}',
        'quadrantName': 'South-East (SE) Quadrant (090° to 180°)',
        'calcFromNSTex': '180^\\circ - ${fmt(ac)}^\\circ = ${fmt3FigLaTeX(eff)}',
        'calcToNSTex': '180^\\circ - ${fmt(eff)}^\\circ = ${fmt(ac)}^\\circ \\text{ East of South} \\implies \\text{S}${fmt(ac)}^\\circ\\text{E}',
      };
    } else if (eff > 180.0 && eff < 270.0) {
      final double ac = eff - 180.0;
      return {
        'threeFigDeg': eff,
        'threeFigStr': fmt3Fig(eff),
        'threeFigTex': fmt3FigLaTeX(eff),
        'acuteWithNS': ac,
        'isFromNorth': false,
        'isTowardsEast': false,
        'acuteStr': 'S${fmt(ac)}°W',
        'acuteTex': '\\text{S}${fmt(ac)}^\\circ\\text{W}',
        'quadrantName': 'South-West (SW) Quadrant (180° to 270°)',
        'calcFromNSTex': '180^\\circ + ${fmt(ac)}^\\circ = ${fmt3FigLaTeX(eff)}',
        'calcToNSTex': '${fmt(eff)}^\\circ - 180^\\circ = ${fmt(ac)}^\\circ \\text{ West of South} \\implies \\text{S}${fmt(ac)}^\\circ\\text{W}',
      };
    } else {
      final double ac = 360.0 - eff;
      return {
        'threeFigDeg': eff,
        'threeFigStr': fmt3Fig(eff),
        'threeFigTex': fmt3FigLaTeX(eff),
        'acuteWithNS': ac,
        'isFromNorth': true,
        'isTowardsEast': false,
        'acuteStr': 'N${fmt(ac)}°W',
        'acuteTex': '\\text{N}${fmt(ac)}^\\circ\\text{W}',
        'quadrantName': 'North-West (NW) Quadrant (270° to 360°)',
        'calcFromNSTex': '360^\\circ - ${fmt(ac)}^\\circ = ${fmt3FigLaTeX(eff)}',
        'calcToNSTex': '360^\\circ - ${fmt(eff)}^\\circ = ${fmt(ac)}^\\circ \\text{ West of North} \\implies \\text{N}${fmt(ac)}^\\circ\\text{W}',
      };
    }
  }

  /// Parses any bearing string: Acute-Angle ("N37°E", "S 66 W", "North 37 East"),
  /// Three-Figure ("037", "246°"), or Compass Point ("NE", "SW", "N", "E")
  static Map<String, dynamic> parseAnyBearingString(String raw) {
    final String clean = raw.trim();
    if (clean.isEmpty) {
      throw const FormatException(
          "Please enter a bearing (e.g. N37°E, S66°W, 037°, or 246°).");
    }

    final String upper = clean
        .toUpperCase()
        .replaceAll('°', '')
        .replaceAll('DEG', '')
        .replaceAll('NORTH', 'N')
        .replaceAll('SOUTH', 'S')
        .replaceAll('EAST', 'E')
        .replaceAll('WEST', 'W')
        .replaceAll(' ', '');

    // 1. Check Acute-Angle Bearing format: N/S + angle + E/W (e.g. N37E, S66W)
    final RegExp acuteReg = RegExp(r'^([NS])(\d+\.?\d*)([EW])$');
    final Match? am = acuteReg.firstMatch(upper);
    if (am != null) {
      final String ns = am.group(1)!;
      final double theta = double.parse(am.group(2)!);
      final String ew = am.group(3)!;

      if (theta < 0 || theta > 90) {
        throw FormatException(
            "In an acute-angle bearing ($clean), the angle must be between 0° and 90°.");
      }

      double threeFig = 0.0;
      if (ns == 'N' && ew == 'E') threeFig = theta;
      if (ns == 'S' && ew == 'E') threeFig = 180.0 - theta;
      if (ns == 'S' && ew == 'W') threeFig = 180.0 + theta;
      if (ns == 'N' && ew == 'W') threeFig = 360.0 - theta;

      return {
        'inputType': 'acute',
        'threeFigDeg': threeFig,
      };
    }

    // 2. Check Mistaken E/W-first input (e.g. W30S or E20N) and helpfully convert it!
    final RegExp ewFirstReg = RegExp(r'^([EW])(\d+\.?\d*)([NS])$');
    final Match? ewm = ewFirstReg.firstMatch(upper);
    if (ewm != null) {
      final String ew = ewm.group(1)!;
      final double thetaEW = double.parse(ewm.group(2)!);
      final String ns = ewm.group(3)!;
      if (thetaEW < 0 || thetaEW > 90) {
        throw const FormatException("Angle must be between 0° and 90°.");
      }
      final double thetaNS = 90.0 - thetaEW;
      double threeFig = 0.0;
      if (ns == 'N' && ew == 'E') threeFig = thetaNS;
      if (ns == 'S' && ew == 'E') threeFig = 180.0 - thetaNS;
      if (ns == 'S' && ew == 'W') threeFig = 180.0 + thetaNS;
      if (ns == 'N' && ew == 'W') threeFig = 360.0 - thetaNS;

      return {
        'inputType': 'ew_complement',
        'threeFigDeg': threeFig,
        'thetaEW': thetaEW,
        'ewAxis': ew,
      };
    }

    // 3. Check 8-Point Compass Codes
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
      return {
        'inputType': 'compass',
        'threeFigDeg': compassMap[upper]!,
      };
    }

    // 4. Numeric Three-Figure Bearing (0 to 360)
    final double? degVal = double.tryParse(upper);
    if (degVal != null && degVal >= 0.0 && degVal <= 360.0) {
      return {
        'inputType': 'three_figure',
        'threeFigDeg': degVal,
      };
    }

    throw FormatException(
        "Could not parse '$clean'. Enter an acute-angle bearing (e.g. N37°E, S66°W) or a 3-figure bearing (e.g. 037°, 246°).");
  }

  // ===========================================================================
  // MODE 0: ACUTE-ANGLE BEARING <-> THREE-FIGURE BEARING CONVERTER & SKETCHER
  // Matches Figures 24.7–24.10, Exercise 24c #1–8 & Exercise 24e #4a–e
  // ===========================================================================
  static BearingsResult solveBearingConverterAndQuadrant({
    required int subMode, // 0: Enter Bearing String, 1: Read from Quadrant Sketch (Fig 24.10)
    required String fromPointName,
    required String toPointName,
    required String bearingInputStr,
    required String quadrantCode, // 'NE', 'SE', 'SW', 'NW'
    required bool measuredFromNS, // true: from N or S, false: from E or W
    required String givenAngleStr,
  }) {
    try {
      final String fromPt =
      fromPointName.trim().isEmpty ? 'B' : fromPointName.trim();
      final String toPt =
      toPointName.trim().isEmpty ? 'A' : toPointName.trim();
      final String cleanFrom = cleanTex(fromPt);
      final String cleanTo = cleanTex(toPt);

      final List<String> workings = [];
      final List<BearingStep> steps = [];
      final Map<String, String> answers = {};

      double threeFigDeg = 0.0;
      double? givenAngleWithEW;
      String? givenEWLabel;

      if (subMode == 0) {
        final Map<String, dynamic> parsed =
        parseAnyBearingString(bearingInputStr);
        threeFigDeg = parsed['threeFigDeg'] as double;
        final String inputType = parsed['inputType'] as String;
        final Map<String, dynamic> dec = decomposeThreeFigAngle(threeFigDeg);

        final bool needsLeadingZero =
            threeFigDeg < 100.0 && threeFigDeg >= 0.0;

        workings.add(
            "\\text{\\textbf{Step 1: Identify Observer Point ('From $cleanFrom') and Quadrant}}");
        workings.add(
            "\\text{Rule: 'Bearing of $cleanTo from $cleanFrom' means stand at \\textbf{$cleanFrom} and look towards \\textbf{$cleanTo}.}");
        workings.add(
            "\\text{Quadrant / Sector: \\textbf{${dec['quadrantName']}}}");
        workings.add("");

        steps.add(BearingStep(
          title:
          "Step 1: Stand at Point '$fromPt' and Locate the Quadrant",
          description:
          "• Textbook Rule: For 'the bearing of $toPt FROM $fromPt', always draw the North–South and East–West crosshairs at the starting point $fromPt.\n"
              "• The direction from $fromPt to $toPt lies in the ${dec['quadrantName']}.",
          mathLaTeX:
          "\\text{Observer at $cleanFrom} \\longrightarrow \\text{Target $cleanTo}",
        ));

        if (inputType == 'acute' || inputType == 'ew_complement') {
          if (inputType == 'ew_complement') {
            final double tEW = parsed['thetaEW'] as double;
            final String ewAx = parsed['ewAxis'] as String;
            givenAngleWithEW = tEW;
            givenEWLabel = "${fmt(tEW)}° with $ewAx";

            workings.add(
                "\\text{\\textbf{Step 2: Convert Angle with $ewAx to Acute Angle with North/South}}");
            workings.add(
                "\\text{Rule: Acute-angle bearings MUST start from North (N) or South (S), never from East or West!}");
            workings.add(
                "\\text{Angle with N/S} = 90^\\circ - ${fmt(tEW)}^\\circ = ${fmt(90.0 - tEW)}^\\circ \\implies \\mathbf{${dec['acuteTex']}}");
            workings.add("");
          }

          workings.add(
              "\\text{\\textbf{Step 2: Convert Acute-Angle Bearing (${dec['acuteStr']}) to Three-Figure Bearing}}");
          workings.add(
              "\\text{Rule (Page 215): A three-figure bearing is measured CLOCKWISE from North } (000^\\circ) \\text{ using 3 digits.}");
          workings.add(
              "\\text{Clockwise angle from North} = ${dec['calcFromNSTex']}");
          if (needsLeadingZero) {
            workings.add(
                "\\text{Three-Figure Padding Rule: Since } ${fmt(threeFigDeg)}^\\circ < 100^\\circ, \\text{ place leading zero(s) in front to make 3 digits: } \\mathbf{${dec['threeFigTex']}}");
          }

          steps.add(BearingStep(
            title:
            "Step 2: Convert Acute-Angle Bearing (${dec['acuteStr']}) to Three-Figure Bearing",
            description:
            "• An acute-angle bearing (${dec['acuteStr']}) measures the acute angle from North (N) or South (S) towards East (E) or West (W).\n"
                "• A three-figure bearing measures the angle CLOCKWISE from North (000°):\n"
                "  – In NE (Nθ°E): Clockwise from N = 000° + θ.\n"
                "  – In SE (Sθ°E): Clockwise from N = 180° − θ.\n"
                "  – In SW (Sθ°W): Clockwise from N = 180° + θ (Figure 24.9).\n"
                "  – In NW (Nθ°W): Clockwise from N = 360° − θ.\n"
                "• Calculation: ${dec['calcFromNSTex'].toString().replaceAll('^\\circ', '°')}."
                "${needsLeadingZero ? '\n• 3-Digit Rule (page 215): Because ${fmt(threeFigDeg)}° is less than 100°, place zero(s) in front so it has three digits: ${dec['threeFigStr']}!' : ''}",
            mathLaTeX:
            "${dec['acuteTex']} \\implies ${dec['calcFromNSTex']} \\implies \\boxed{${dec['threeFigTex']}}",
          ));
        } else {
          workings.add(
              "\\text{\\textbf{Step 2: Format Three-Figure Bearing and Convert to Acute-Angle Bearing}}");
          if (needsLeadingZero) {
            workings.add(
                "\\text{Three-Figure Rule: Place zero(s) in front of angles } < 100^\\circ \\text{ to always use 3 digits: } \\mathbf{${dec['threeFigTex']}}");
          } else {
            workings.add(
                "\\text{Three-Figure Bearing} = \\mathbf{${dec['threeFigTex']}}");
          }
          workings.add(
              "\\text{Acute-Angle Bearing (measured from N or S): } ${dec['calcToNSTex']}");

          steps.add(BearingStep(
            title:
            "Step 2: Find Both the 3-Digit Three-Figure Bearing and the Acute-Angle Bearing",
            description:
            "${needsLeadingZero ? '• 3-Digit Rule (page 215): For angles less than 100°, place zeros in front so the bearing has 3 digits: ${dec['threeFigStr']}.\n' : ''}"
                "• To write ${dec['threeFigStr']} as an acute-angle bearing, find the acute angle (between 0° and 90°) that the ray makes with the vertical North–South line:\n"
                "  ${dec['calcToNSTex'].toString().replaceAll('^\\circ', '°').replaceAll('\\text{', '').replaceAll('}', '').replaceAll('\\implies', '→')}.",
            mathLaTeX:
            "\\text{Three-Figure} = \\mathbf{${dec['threeFigTex']}}, \\quad \\text{Acute-Angle} = \\mathbf{${dec['acuteTex']}}",
          ));
        }
      } else {
        // Sub-Mode 0B: Read from a Quadrant Sketch (Figure 24.10 / Exercise 24c #1–8)
        final double? givenTheta =
        double.tryParse(givenAngleStr.trim().replaceAll('°', ''));
        if (givenTheta == null || givenTheta < 0 || givenTheta > 90) {
          throw const FormatException(
              "Please enter a valid acute angle between 0° and 90° (e.g. 58, 40, 18, or 30).");
        }

        final String q = quadrantCode.toUpperCase();
        final String nsLetter = q.startsWith('N') ? 'N' : 'S';
        final String ewLetter = q.endsWith('E') ? 'E' : 'W';
        final String nsFull = nsLetter == 'N' ? 'North (N)' : 'South (S)';
        final String ewFull = ewLetter == 'E' ? 'East (E)' : 'West (W)';

        double thetaWithNS = givenTheta;

        workings.add(
            "\\text{\\textbf{Step 1: Inspect the Diagram at Observer Point $cleanFrom (Figure 24.10)}}");
        workings.add(
            "\\text{Ray } $cleanFrom$cleanTo \\text{ lies in the \\textbf{$q} quadrant (between $nsFull and $ewFull).}");

        if (measuredFromNS) {
          workings.add(
              "\\text{The given angle } ${fmt(givenTheta)}^\\circ \\text{ is measured directly from the vertical \\textbf{$nsFull} line towards \\textbf{$ewFull}.}");
          workings.add("");

          steps.add(BearingStep(
            title:
            "Step 1: Check Which Axis the Given Angle (${fmt(givenTheta)}°) Touches",
            description:
            "• Look closely at the arc for ${fmt(givenTheta)}° at point $fromPt:\n"
                "• The ray $fromPt$toPt is in the $q quadrant, and the ${fmt(givenTheta)}° angle is measured directly from the vertical $nsFull line towards $ewFull.\n"
                "• Because acute-angle bearings are always measured from North (N) or South (S), we can use ${fmt(givenTheta)}° directly!",
            mathLaTeX:
            "\\text{Angle with $nsFull} = ${fmt(givenTheta)}^\\circ \\text{ towards $ewFull}",
          ));
        } else {
          // Measured from East or West horizontal line (Exercise 24c #4, #6, #7, #8!)
          thetaWithNS = 90.0 - givenTheta;
          givenAngleWithEW = givenTheta;
          givenEWLabel = "${fmt(givenTheta)}° with $ewFull";

          workings.add(
              "\\text{The given angle } ${fmt(givenTheta)}^\\circ \\text{ is measured from the horizontal \\textbf{$ewFull} line!}");
          workings.add("");
          workings.add(
              "\\text{\\textbf{Step 2: Subtract from }} 90^\\circ \\text{\\textbf{ to Find the Angle with $nsFull}}");
          workings.add(
              "\\text{Crucial Rule: Acute-angle bearings MUST start with N or S (never E or W)!}");
          workings.add(
              "\\text{Since the angle between $nsFull and $ewFull is } 90^\\circ:");
          workings.add(
              "\\text{Angle with $nsFull} = 90^\\circ - ${fmt(givenTheta)}^\\circ = \\mathbf{${fmt(thetaWithNS)}^\\circ}");

          steps.add(BearingStep(
            title:
            "Step 1: Watch Out! The ${fmt(givenTheta)}° Angle is Measured from $ewFull (Figure 24.10 Trap)",
            description:
            "• Look carefully at the diagram: the ${fmt(givenTheta)}° arc touches the horizontal $ewFull line, NOT the vertical $nsFull line!\n"
                "• Textbook Rule (page 214): Acute-angle bearings are ALWAYS measured from North (N) or South (S)—never from East or West.\n"
                "• Since the angle between $nsFull and $ewFull is a right angle (90°), subtract ${fmt(givenTheta)}° from 90° first:\n"
                "  Angle with $nsFull = 90° − ${fmt(givenTheta)}° = ${fmt(thetaWithNS)}°.",
            mathLaTeX:
            "\\text{Angle with $nsFull} = 90^\\circ - ${fmt(givenTheta)}^\\circ = \\mathbf{${fmt(thetaWithNS)}^\\circ}",
          ));
        }

        if (q == 'NE') threeFigDeg = thetaWithNS;
        if (q == 'SE') threeFigDeg = 180.0 - thetaWithNS;
        if (q == 'SW') threeFigDeg = 180.0 + thetaWithNS;
        if (q == 'NW') threeFigDeg = 360.0 - thetaWithNS;

        final Map<String, dynamic> dec = decomposeThreeFigAngle(threeFigDeg);
        final int nextStepNum = measuredFromNS ? 2 : 3;

        workings.add("");
        workings.add(
            "\\text{\\textbf{Step $nextStepNum: Write the Acute-Angle Bearing and Three-Figure Bearing}}");
        workings.add(
            "\\bullet \\text{ Acute-angle bearing of $cleanTo from $cleanFrom} = \\mathbf{${dec['acuteTex']}}");
        workings.add(
            "\\bullet \\text{ Three-figure bearing (clockwise from N): } ${dec['calcFromNSTex']} = \\mathbf{${dec['threeFigTex']}}");

        steps.add(BearingStep(
          title:
          "Step $nextStepNum: Write the Acute-Angle Bearing (${dec['acuteStr']}) & Three-Figure Bearing (${dec['threeFigStr']})",
          description:
          "1. Acute-Angle Bearing: Start with '$nsLetter' ($nsFull), write the acute angle ${fmt(thetaWithNS)}°, and end with '$ewLetter' ($ewFull) → ${dec['acuteStr']}.\n"
              "2. Three-Figure Bearing (clockwise from North): ${dec['calcFromNSTex'].toString().replaceAll('^\\circ', '°')} → ${dec['threeFigStr']}.",
          mathLaTeX:
          "\\text{Acute-Angle Bearing} = \\boxed{${dec['acuteTex']}}, \\quad \\text{Three-Figure Bearing} = \\boxed{${dec['threeFigTex']}}",
        ));
      }

      // Add Step for Reciprocal / Back Bearing (of FromPt from ToPt)
      final Map<String, dynamic> decMain = decomposeThreeFigAngle(threeFigDeg);
      final double backDeg = threeFigDeg < 180.0
          ? (threeFigDeg + 180.0)
          : (threeFigDeg - 180.0);
      final Map<String, dynamic> decBack = decomposeThreeFigAngle(backDeg);

      answers["Acute-Angle ($toPt from $fromPt)"] = decMain['acuteStr'] as String;
      answers["Three-Figure ($toPt from $fromPt)"] =
      decMain['threeFigStr'] as String;
      answers["Quadrant / Sector"] =
          (decMain['quadrantName'] as String).split(' (').first;
      answers["Back Bearing ($fromPt from $toPt)"] =
      "${decBack['threeFigStr']} (${decBack['acuteStr']})";

      return BearingsResult(
        mode: 0,
        subMode: subMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BearingsCanvasData(
          mode: 0,
          fromPointName: fromPt,
          toPointName: toPt,
          threeFigAngleDeg: threeFigDeg,
          threeFigLabel: decMain['threeFigStr'] as String,
          acuteAngleWithNS: decMain['acuteWithNS'] as double,
          acuteIsFromNorth: decMain['isFromNorth'] as bool,
          acuteIsTowardsEast: decMain['isTowardsEast'] as bool,
          acuteBearingLabel: decMain['acuteStr'] as String,
          givenAngleWithEW: givenAngleWithEW,
          givenEWLabel: givenEWLabel,
          headerBadge:
          "Bearing of $toPt from $fromPt:   Acute = ${decMain['acuteStr']}   |   Three-Figure = ${decMain['threeFigStr']}",
          subBadge: givenEWLabel != null
              ? "Given $givenEWLabel  ➔  Complement with N/S = 90° − ${fmt(givenAngleWithEW!)}° = ${fmt(decMain['acuteWithNS'] as double)}°"
              : "Green Arc = Acute Angle with N/S (${fmt(decMain['acuteWithNS'] as double)}°)   |   Purple Arc = Clockwise from North (${decMain['threeFigStr']})",
        ),
      );
    } catch (e) {
      return BearingsResult.error(
        mode: 0,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid bearing or acute angle.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: SINGLE-RAY THREE-FIGURE BEARING SKETCH SOLVER (Exercise 24e #1a–h)
  // ===========================================================================
  static BearingsResult solveSingleRaySketch({
    required String fromPointName,
    required String toPointName,
    required String sketchRefType,
    // 'CW_N': Clockwise from North (Fig 24.18a, b)
    // 'ACW_N': Anticlockwise from North (Fig 24.18e: 33° West of North)
    // 'CW_S': Clockwise from South (Fig 24.18c: 120° clockwise from South)
    // 'ACW_S': Anticlockwise from South (Fig 24.18g: 47° East of South)
    // 'DUE_E': Right angle (90°) East of North (Fig 24.18f)
    // 'DUE_W': Right angle (90°) West of North (Fig 24.18d)
    // 'DUE_S': Straight down South from North (Fig 24.18h)
    required String givenAngleStr,
  }) {
    try {
      final String fromPt =
      fromPointName.trim().isEmpty ? 'A' : fromPointName.trim();
      final String toPt =
      toPointName.trim().isEmpty ? 'B' : toPointName.trim();
      final String cleanFrom = cleanTex(fromPt);
      final String cleanTo = cleanTex(toPt);

      double theta = 0.0;
      if (!['DUE_E', 'DUE_W', 'DUE_S'].contains(sketchRefType)) {
        final double? parsed =
        double.tryParse(givenAngleStr.trim().replaceAll('°', ''));
        if (parsed == null || parsed < 0 || parsed > 360) {
          throw const FormatException(
              "Please enter the angle shown in the sketch (e.g. 56, 120, 33, or 47).");
        }
        theta = parsed;
      }

      double threeFig = 0.0;
      String step1Explain = "";
      String step2Math = "";
      String step2Explain = "";

      switch (sketchRefType) {
        case 'CW_N':
          threeFig = theta;
          step1Explain =
          "The sketch gives an angle of ${fmt(theta)}° measured directly CLOCKWISE from the North arrow (N) at $fromPt.";
          step2Math =
          "\\text{Bearing of $cleanTo from $cleanFrom} = 000^\\circ + ${fmt(theta)}^\\circ = \\mathbf{${fmt3FigLaTeX(threeFig)}}";
          step2Explain =
          "Because a three-figure bearing is defined as the clockwise angle from North, the bearing is simply ${fmt(theta)}°, written with three digits as ${fmt3Fig(threeFig)}.";
          break;
        case 'ACW_N':
          threeFig = 360.0 - theta;
          step1Explain =
          "The sketch gives an angle of ${fmt(theta)}° measured ANTICLOCKWISE (to the West/left) from the North arrow (N) at $fromPt (like Figure 24.18e).";
          step2Math =
          "\\text{Clockwise angle from N} = 360^\\circ - ${fmt(theta)}^\\circ = \\mathbf{${fmt3FigLaTeX(threeFig)}}";
          step2Explain =
          "Since a full turn around point $fromPt is 360°, subtract the anticlockwise angle (${fmt(theta)}°) from 360° to find the clockwise angle from North:\n"
              "• 360° − ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
          break;
        case 'CW_S':
          threeFig = normalizeAngle360(180.0 + theta);
          step1Explain =
          "The sketch shows the vertical North line extended straight down to South (180°), and an angle of ${fmt(theta)}° measured CLOCKWISE from the South line (like Figure 24.18c).";
          step2Math =
          "\\text{Clockwise angle from N} = 180^\\circ + ${fmt(theta)}^\\circ = \\mathbf{${fmt3FigLaTeX(threeFig)}}";
          step2Explain =
          "1. From North (N) clockwise to the South extension line is a straight line (180°).\n"
              "2. Add the extra ${fmt(theta)}° clockwise turn from South:\n"
              "   180° + ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
          break;
        case 'ACW_S':
          threeFig = normalizeAngle360(180.0 - theta);
          step1Explain =
          "The sketch shows the vertical North line extended straight down to South (180°), and an angle of ${fmt(theta)}° measured ANTICLOCKWISE (towards East) from the South line (like Figure 24.18g).";
          step2Math =
          "\\text{Clockwise angle from N} = 180^\\circ - ${fmt(theta)}^\\circ = \\mathbf{${fmt3FigLaTeX(threeFig)}}";
          step2Explain =
          "1. A straight line from North (N) to South (S) is 180°.\n"
              "2. Since the ray $fromPt$toPt is ${fmt(theta)}° short of reaching the South line, subtract ${fmt(theta)}° from 180°:\n"
              "   180° − ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
          break;
        case 'DUE_E':
          threeFig = 90.0;
          step1Explain =
          "The sketch shows a right-angle symbol (90°) pointing to the right (East) of the North line at $fromPt (Figure 24.18f).";
          step2Math =
          "\\text{Bearing of $cleanTo from $cleanFrom} = \\mathbf{090^\\circ}";
          step2Explain =
          "A right angle clockwise from North is 90°. Using three digits (page 215 rule), write 090°.";
          break;
        case 'DUE_W':
          threeFig = 270.0;
          step1Explain =
          "The sketch shows a right-angle symbol (90°) pointing to the left (West) of the North line at $fromPt (Figure 24.18d).";
          step2Math =
          "\\text{Clockwise angle from N} = 360^\\circ - 90^\\circ = \\mathbf{270^\\circ}";
          step2Explain =
          "Going clockwise from North through East (90°) and South (180°) to West is 3 × 90° = 270° (or 360° − 90° = 270°).";
          break;
        case 'DUE_S':
        default:
          threeFig = 180.0;
          step1Explain =
          "The sketch shows point $toPt directly opposite the North arrow (straight down / Due South) from $fromPt (Figure 24.18h).";
          step2Math =
          "\\text{Bearing of $cleanTo from $cleanFrom} = \\mathbf{180^\\circ}";
          step2Explain =
          "Angles on a straight line add up to 180°, so Due South is a three-figure bearing of 180°.";
          break;
      }

      final Map<String, dynamic> dec = decomposeThreeFigAngle(threeFig);

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Read the Given Angle in the Sketch (Figure 24.18)}}",
        "\\text{${cleanTex(step1Explain)}}",
        "",
        "\\text{\\textbf{Step 2: Calculate the Clockwise Angle from North (000°)}}",
        step2Math,
        "\\text{Equivalent Acute-Angle Bearing} = \\mathbf{${dec['acuteTex']}}",
      ];

      final List<BearingStep> steps = [
        BearingStep(
          title: "Step 1: Inspect the Reference Angle at '$fromPt'",
          description: step1Explain,
          mathLaTeX: "\\text{Standpoint} = \\text{$cleanFrom}, \\quad \\text{Target} = \\text{$cleanTo}",
        ),
        BearingStep(
          title:
          "Step 2: Calculate the Clockwise Three-Figure Bearing from North",
          description:
          "$step2Explain\n"
              "• Equivalent Acute-Angle Bearing: ${dec['acuteStr']}.",
          mathLaTeX: step2Math,
        ),
      ];

      return BearingsResult(
        mode: 1,
        finalAnswers: {
          "3-Figure Bearing ($toPt from $fromPt)": dec['threeFigStr'] as String,
          "Acute-Angle Bearing": dec['acuteStr'] as String,
          "Quadrant": (dec['quadrantName'] as String).split(' (').first,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BearingsCanvasData(
          mode: 1,
          fromPointName: fromPt,
          toPointName: toPt,
          threeFigAngleDeg: threeFig,
          threeFigLabel: dec['threeFigStr'] as String,
          acuteAngleWithNS: dec['acuteWithNS'] as double,
          acuteIsFromNorth: dec['isFromNorth'] as bool,
          acuteIsTowardsEast: dec['isTowardsEast'] as bool,
          acuteBearingLabel: dec['acuteStr'] as String,
          headerBadge:
          "Figure 24.18 Sketch:  Bearing of $toPt from $fromPt = ${dec['threeFigStr']} (${dec['acuteStr']})",
          subBadge:
          "Always measure three-figure bearings CLOCKWISE from North (N = 000°)",
        ),
      );
    } catch (e) {
      return BearingsResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter a valid angle for the sketch.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: MULTI-RAY BEARINGS FROM A CENTRAL POINT (Example 1 & Ex 24e #2, #3)
  // Matches Figure 24.14 (Example 1), Figure 24.19 (Ex 24e #2) & Figure 24.20 (Ex 24e #3)
  // ===========================================================================
  static BearingsResult solveMultiRayBearings({
    required String centerPointName,
    required List<MultiRayInput> rayInputs,
  }) {
    try {
      final String centerPt =
      centerPointName.trim().isEmpty ? 'X' : centerPointName.trim();
      final String cleanCenter = cleanTex(centerPt);

      final List<MultiRayInput> validInputs = rayInputs
          .where((r) =>
      r.pointLabel.trim().isNotEmpty &&
          r.givenAngleStr.trim().isNotEmpty)
          .toList();

      if (validInputs.isEmpty) {
        throw const FormatException(
            "Please enter at least one target ray (e.g. Point A with angle 63°).");
      }

      const List<Color> rayColors = [
        Colors.deepPurple,
        Color(0xFF2E7D32),
        Color(0xFFE65100),
        Color(0xFF1565C0),
        Color(0xFFAD1457),
      ];

      final List<String> workings = [
        "\\text{\\textbf{Calculating Three-Figure Bearings from Central Point $cleanCenter (Example 1 Method)}}",
        "\\text{Rule: The arrow N shows the direction North } (000^\\circ). \\text{ Measure every bearing CLOCKWISE from N.}",
        "",
      ];
      final List<BearingStep> steps = [];
      final Map<String, String> answers = {};
      final List<EvaluatedRayItem> evaluatedRays = [];

      double prevRayThreeFig = 0.0;
      String prevRayLabel = 'N';

      for (int i = 0; i < validInputs.length; i++) {
        final MultiRayInput inp = validInputs[i];
        final String ptLbl = inp.pointLabel.trim();
        final String cleanPt = cleanTex(ptLbl);
        final double? theta =
        double.tryParse(inp.givenAngleStr.trim().replaceAll('°', ''));
        if (theta == null || theta < 0 || theta > 360) {
          throw FormatException(
              "Invalid angle '${inp.givenAngleStr}' for point $ptLbl.");
        }

        double threeFig = 0.0;
        String formulaTex = "";
        String formulaDesc = "";
        String refShortLabel = "";

        switch (inp.referenceType) {
          case 'E_of_N':
            threeFig = theta;
            refShortLabel = "${fmt(theta)}° E of N";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt = ${fmt(theta)}^\\circ \\implies \\text{Bearing of $cleanPt from $cleanCenter is } \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "Ray $centerPt$ptLbl is in the North-East sector making ${fmt(theta)}° clockwise with North:\n"
                "• N^$centerPt$ptLbl = ${fmt(theta)}° → Three-figure bearing = ${fmt3Fig(threeFig)}.";
            break;
          case 'E_of_S':
            threeFig = 180.0 - theta;
            refShortLabel = "${fmt(theta)}° E of S";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt = 180^\\circ - ${fmt(theta)}^\\circ = ${fmt(threeFig)}^\\circ \\implies \\text{Bearing of $cleanPt from $cleanCenter is } \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "Ray $centerPt$ptLbl is in the South-East sector making ${fmt(theta)}° with the South line (180°):\n"
                "• Subtract ${fmt(theta)}° from 180° (straight line N–$centerPt–S): 180° − ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
            break;
          case 'W_of_S':
            threeFig = 180.0 + theta;
            refShortLabel = "${fmt(theta)}° W of S";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt \\text{ clockwise} = 180^\\circ + ${fmt(theta)}^\\circ = ${fmt(threeFig)}^\\circ \\implies \\text{Bearing of $cleanPt from $cleanCenter is } \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "Ray $centerPt$ptLbl is in the South-West sector making ${fmt(theta)}° past the South line (180°):\n"
                "• Add ${fmt(theta)}° to 180°: 180° + ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
            break;
          case 'W_of_N':
            threeFig = 360.0 - theta;
            refShortLabel = "${fmt(theta)}° W of N";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt \\text{ clockwise} = 360^\\circ - ${fmt(theta)}^\\circ = ${fmt(threeFig)}^\\circ \\implies \\text{Bearing of $cleanPt from $cleanCenter is } \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "Ray $centerPt$ptLbl is in the North-West sector making ${fmt(theta)}° anticlockwise from North:\n"
                "• Subtract ${fmt(theta)}° from a full 360° turn: 360° − ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
            break;
          case 'N_of_E':
            threeFig = 90.0 - theta;
            refShortLabel = "${fmt(theta)}° N of E";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt = 90^\\circ - ${fmt(theta)}^\\circ = ${fmt(threeFig)}^\\circ \\implies \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "Ray $centerPt$ptLbl makes ${fmt(theta)}° above the East line (090°):\n"
                "• Subtract ${fmt(theta)}° from 90°: 90° − ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
            break;
          case 'S_of_E':
            threeFig = 90.0 + theta;
            refShortLabel = "${fmt(theta)}° S of E";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt = 90^\\circ + ${fmt(theta)}^\\circ = ${fmt(threeFig)}^\\circ \\implies \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "Ray $centerPt$ptLbl makes ${fmt(theta)}° clockwise past the East line (090°):\n"
                "• Add ${fmt(theta)}° to 90°: 90° + ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
            break;
          case 'S_of_W':
            threeFig = 270.0 - theta;
            refShortLabel = "${fmt(theta)}° S of W";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt \\text{ clockwise} = 270^\\circ - ${fmt(theta)}^\\circ = ${fmt(threeFig)}^\\circ \\implies \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "Ray $centerPt$ptLbl makes ${fmt(theta)}° anticlockwise (Southwards) from the West line (270°, as in Figure 24.20 ray OZ):\n"
                "• Subtract ${fmt(theta)}° from 270° (or add 180° + (90° − ${fmt(theta)}°)): 270° − ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
            break;
          case 'N_of_W':
            threeFig = 270.0 + theta;
            refShortLabel = "${fmt(theta)}° N of W";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt \\text{ clockwise} = 270^\\circ + ${fmt(theta)}^\\circ = ${fmt(threeFig)}^\\circ \\implies \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "Ray $centerPt$ptLbl makes ${fmt(theta)}° clockwise (Northwards) from the West line (270°):\n"
                "• Add ${fmt(theta)}° to 270°: 270° + ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
            break;
          case 'CW_from_Prev':
          default:
            threeFig = normalizeAngle360(prevRayThreeFig + theta);
            refShortLabel = "+${fmt(theta)}° from $prevRayLabel";
            formulaTex =
            "\\text{N}\\hat{$cleanCenter}$cleanPt = \\text{Bearing of $prevRayLabel } (${fmt(prevRayThreeFig)}^\\circ) + ${fmt(theta)}^\\circ = ${fmt(threeFig)}^\\circ \\implies \\mathbf{${fmt3FigLaTeX(threeFig)}}";
            formulaDesc =
            "The diagram gives the angle between the previous ray ($centerPt$prevRayLabel at ${fmt3Fig(prevRayThreeFig)}) and ray $centerPt$ptLbl as ${fmt(theta)}° clockwise (like ∠UOV = 83° in Figure 24.20):\n"
                "• Add ${fmt(theta)}° to the clockwise angle of $prevRayLabel (${fmt(prevRayThreeFig)}°): ${fmt(prevRayThreeFig)}° + ${fmt(theta)}° = ${fmt3Fig(threeFig)}.";
            break;
        }

        final Map<String, dynamic> dec = decomposeThreeFigAngle(threeFig);
        final String letterPrefix = String.fromCharCode(97 + i); // a, b, c, d...

        workings.add("\\text{\\textbf{($letterPrefix) Bearing of $cleanPt from $cleanCenter:}}");
        workings.add(formulaTex);
        workings.add(
            "\\quad \\left(\\text{Acute-angle bearing} = ${dec['acuteTex']}\\right)");
        if (i < validInputs.length - 1) workings.add("");

        steps.add(BearingStep(
          title:
          "Step ${i + 1}: Find the Bearing of $ptLbl from $centerPt (${dec['threeFigStr']})",
          description:
          "$formulaDesc\n"
              "• Equivalent Acute-Angle Bearing: ${dec['acuteStr']}.",
          mathLaTeX: formulaTex,
        ));

        answers["$ptLbl from $centerPt"] =
        "${dec['threeFigStr']} (${dec['acuteStr']})";

        evaluatedRays.add(EvaluatedRayItem(
          pointLabel: ptLbl,
          givenAngleDeg: theta,
          referenceLabel: refShortLabel,
          threeFigDeg: threeFig,
          threeFigFormatted: dec['threeFigStr'] as String,
          acuteBearingFormatted: dec['acuteStr'] as String,
          color: rayColors[i % rayColors.length],
        ));

        prevRayThreeFig = threeFig;
        prevRayLabel = ptLbl;
      }

      return BearingsResult(
        mode: 2,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BearingsCanvasData(
          mode: 2,
          centerPointName: centerPt,
          rays: evaluatedRays,
          headerBadge:
          "Multi-Ray Bearings from $centerPt:  ${evaluatedRays.map((r) => '${r.pointLabel}=${r.threeFigFormatted}').join(' , ')}",
          subBadge:
          "Every three-figure bearing is measured CLOCKWISE from North (N = 000°)",
        ),
      );
    } catch (e) {
      return BearingsResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please check your ray labels and angles.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: BACK BEARINGS / RECIPROCAL BEARINGS USING PARALLEL NORTH LINES
  // Matches Example 2 (Figures 24.15–24.17) & Exercise 24e #5a–g (Figure 24.21)
  // ===========================================================================
  static BearingsResult solveBackBearings({
    required String point1Name, // e.g., 'X' or 'A'
    required String point2Name, // e.g., 'Y' or 'B'
    required int backGivenType,
    // 0: 3-Figure Bearing of Point 1 from Point 2 (e.g. X from Y = 247°, or A from B = 250° in Fig 24.21a,b)
    // 1: 3-Figure Bearing of Point 2 from Point 1 (e.g. B from A = 195° in Fig 24.21g)
    // 2: Interior Acute Angle at Point 2 between North and Ray (e.g. 57° East of N in Fig 24.21c)
    // 3: Anticlockwise Reflex Angle at Point 2 from North to Ray (e.g. 319° in Fig 24.21f)
    // 4: Cardinal Alignment (0° Due North, 90° Due East, 180° Due South, 270° Due West — Fig 24.21d,e)
    required String givenAngleStr,
  }) {
    try {
      final String p1 = point1Name.trim().isEmpty ? 'A' : point1Name.trim();
      final String p2 = point2Name.trim().isEmpty ? 'B' : point2Name.trim();
      final String c1 = cleanTex(p1);
      final String c2 = cleanTex(p2);

      final double? rawAngle =
      double.tryParse(givenAngleStr.trim().replaceAll('°', ''));
      if (rawAngle == null || rawAngle < 0 || rawAngle > 360) {
        throw const FormatException(
            "Please enter a valid angle between 0° and 360° (e.g. 247, 250, 150, 57, 319, or 195).");
      }

      final List<String> workings = [];
      final List<BearingStep> steps = [];

      // Determine the forward bearing (p1 from p2) and back bearing (p2 from p1)
      double bearingP1FromP2 = 0.0;
      String step1Title = "";
      String step1Desc = "";
      String step1Math = "";

      if (backGivenType == 0 || backGivenType == 2 || backGivenType == 4) {
        bearingP1FromP2 = normalizeAngle360(rawAngle);
        step1Title =
        "Step 1: Find the Bearing of $p1 from $p2 (Standing at $p2)";
        step1Desc =
        "• At point $p2, the North line $p2 N₁ points straight up (000°).\n"
            "• The clockwise angle from North at $p2 to the line $p2$p1 is ${fmt(bearingP1FromP2)}°.\n"
            "• Therefore, the three-figure bearing of $p1 from $p2 is ${fmt3Fig(bearingP1FromP2)}.";
        step1Math =
        "\\text{Bearing of $c1 from $c2} = \\mathbf{${fmt3FigLaTeX(bearingP1FromP2)}}";
      } else if (backGivenType == 3) {
        // Fig 24.21f: Anticlockwise reflex angle at B (e.g. 319°)
        bearingP1FromP2 = normalizeAngle360(360.0 - rawAngle);
        step1Title =
        "Step 1: Subtract the Anticlockwise Angle (${fmt(rawAngle)}°) from 360° at $p2 (Figure 24.21f)";
        step1Desc =
        "• Look carefully at the arc at point $p2: the ${fmt(rawAngle)}° angle is measured ANTICLOCKWISE from North ($p2 N₁) to the line $p2$p1!\n"
            "• Since angles around a point add up to 360°, subtract ${fmt(rawAngle)}° from 360° to get the clockwise bearing of $p1 from $p2:\n"
            "  360° − ${fmt(rawAngle)}° = ${fmt(bearingP1FromP2)}° = ${fmt3Fig(bearingP1FromP2)}.";
        step1Math =
        "\\text{Bearing of $c1 from $c2} = 360^\\circ - ${fmt(rawAngle)}^\\circ = \\mathbf{${fmt3FigLaTeX(bearingP1FromP2)}}";
      } else {
        // backGivenType == 1 (Fig 24.21g: Given bearing of P2 from P1 = 195° at A)
        final double bearingP2FromP1Given = normalizeAngle360(rawAngle);
        bearingP1FromP2 = bearingP2FromP1Given < 180.0
            ? (bearingP2FromP1Given + 180.0)
            : (bearingP2FromP1Given - 180.0);
        step1Title =
        "Step 1: Read the Given Bearing of $p2 from $p1 at $p1 (Figure 24.21g)";
        step1Desc =
        "• In this diagram, the clockwise angle of ${fmt(bearingP2FromP1Given)}° is given at point $p1 (from the North line at $p1 to ray $p1$p2).\n"
            "• Therefore, the bearing of $p2 from $p1 is ${fmt3Fig(bearingP2FromP1Given)}.";
        step1Math =
        "\\text{Bearing of $c2 from $c1} = \\mathbf{${fmt3FigLaTeX(bearingP2FromP1Given)}}";
      }

      final double bearingP2FromP1 = bearingP1FromP2 < 180.0
          ? (bearingP1FromP2 + 180.0)
          : (bearingP1FromP2 - 180.0);

      final Map<String, dynamic> dec1From2 =
      decomposeThreeFigAngle(bearingP1FromP2);
      final Map<String, dynamic> dec2From1 =
      decomposeThreeFigAngle(bearingP2FromP1);
      final double altAcute = dec1From2['acuteWithNS'] as double;

      workings.add("\\text{\\textbf{$step1Title}}");
      workings.add(step1Math);
      workings.add(
          "\\text{Acute-angle form ($c1 from $c2)} = ${dec1From2['acuteTex']}");
      workings.add("");

      steps.add(BearingStep(
        title: step1Title,
        description: step1Desc,
        mathLaTeX: step1Math,
      ));

      // Step 2: Textbook Example 2 Method (a) — Extending North Line + Alternate Angles Between Parallel North Lines
      workings.add(
          "\\text{\\textbf{Step 2: Method (a) — Parallel North Lines \\& Alternate Angles (Figure 24.17a)}}");
      workings.add(
          "\\text{The two North lines } $c2\\text{N}_1 \\text{ and } $c1\\text{N}_2 \\text{ are \\textbf{parallel} } ($c2\\text{N}_1 \\parallel $c1\\text{N}_2).");

      String methodADesc = "";
      String methodAMath = "";

      if (bearingP1FromP2 >= 180.0 && bearingP1FromP2 < 270.0) {
        // SW Quadrant (Exact match for Example 2: 247° = 180° + 67°)
        methodAMath =
        "\\text{Acute angle with South at $c2} = ${fmt(bearingP1FromP2)}^\\circ - 180^\\circ = ${fmt(altAcute)}^\\circ\n"
            "\\text{By alternate angles } (\\text{N}_1 \\parallel \\text{N}_2): \\quad \\text{N}_2\\hat{$c1}$c2 = ${fmt(altAcute)}^\\circ \\implies \\text{Bearing of $c2 from $c1} = \\mathbf{${fmt3FigLaTeX(bearingP2FromP1)}}";
        methodADesc =
        "1. Extend the North line at $p2 straight downwards (South = 180°).\n"
            "2. The acute angle between this South line and line $p2$p1 is ${fmt(bearingP1FromP2)}° − 180° = ${fmt(altAcute)}°.\n"
            "3. Because the two North–South lines at $p2 and $p1 are parallel, the alternate angle ∠N₂$p1$p2 at $p1 is also equal to ${fmt(altAcute)}°!\n"
            "4. Therefore, the three-figure bearing of $p2 from $p1 is ${fmt3Fig(bearingP2FromP1)}.";
      } else if (bearingP1FromP2 > 0.0 && bearingP1FromP2 < 90.0) {
        // NE Quadrant (e.g. Fig 24.21c: 57° or Fig 24.21f: 41°)
        methodAMath =
        "\\text{By alternate angles } (\\text{N}_1 \\parallel \\text{N}_2): \\quad \\text{Angle with South at $c1} = ${fmt(altAcute)}^\\circ\n"
            "\\text{Clockwise from North at $c1} = 180^\\circ + ${fmt(altAcute)}^\\circ = \\mathbf{${fmt3FigLaTeX(bearingP2FromP1)}}";
        methodADesc =
        "1. At $p2, the acute angle between North and $p2$p1 is ${fmt(altAcute)}°.\n"
            "2. Extend the North line at $p1 straight downwards (South = 180°). By alternate angles between the parallel North–South lines, the angle between the South line at $p1 and $p1$p2 is also ${fmt(altAcute)}°.\n"
            "3. Add 180° (from North to South at $p1) + ${fmt(altAcute)}° = ${fmt3Fig(bearingP2FromP1)}!";
      } else if (bearingP1FromP2 >= 90.0 && bearingP1FromP2 < 180.0) {
        // SE Quadrant (e.g. Fig 24.21b: 150°)
        methodAMath =
        "\\text{Acute angle with South at $c2} = 180^\\circ - ${fmt(bearingP1FromP2)}^\\circ = ${fmt(altAcute)}^\\circ\n"
            "\\text{By alternate angles at $c1: } 360^\\circ - ${fmt(altAcute)}^\\circ = \\mathbf{${fmt3FigLaTeX(bearingP2FromP1)}}";
        methodADesc =
        "1. Extend the North line at $p2 downwards to South (180°). The acute angle with South is 180° − ${fmt(bearingP1FromP2)}° = ${fmt(altAcute)}°.\n"
            "2. By alternate angles between the parallel North lines, the anticlockwise angle from North at $p1 to $p1$p2 is also ${fmt(altAcute)}°.\n"
            "3. Subtract from 360° for the clockwise bearing at $p1: 360° − ${fmt(altAcute)}° = ${fmt3Fig(bearingP2FromP1)}.";
      } else {
        // NW Quadrant (270° to 360°)
        methodAMath =
        "\\text{Acute angle with North at $c2} = 360^\\circ - ${fmt(bearingP1FromP2)}^\\circ = ${fmt(altAcute)}^\\circ\n"
            "\\text{By alternate angles with South at $c1: } 180^\\circ - ${fmt(altAcute)}^\\circ = \\mathbf{${fmt3FigLaTeX(bearingP2FromP1)}}";
        methodADesc =
        "1. At $p2, the acute angle West of North is 360° − ${fmt(bearingP1FromP2)}° = ${fmt(altAcute)}°.\n"
            "2. By alternate angles between parallel North–South lines, the acute angle East of South at $p1 is also ${fmt(altAcute)}°.\n"
            "3. Subtract from 180° for the clockwise bearing at $p1: 180° − ${fmt(altAcute)}° = ${fmt3Fig(bearingP2FromP1)}.";
      }

      workings.addAll(methodAMath.split('\n'));
      workings.add("");

      steps.add(BearingStep(
        title:
        "Step 2: Textbook Method (a) — Parallel North Lines & Alternate Angles (Figure 24.17a)",
        description: methodADesc,
        mathLaTeX: methodAMath,
      ));

      // Step 3: Textbook Example 2 Method (b) — The 180° Half-Turn / Co-Interior Angle Rule
      final bool isLess180 = bearingP1FromP2 < 180.0;
      final String op180 = isLess180 ? "+" : "-";
      final String rule180Math =
          "${fmt(bearingP1FromP2)}^\\circ $op180 180^\\circ = \\mathbf{${fmt3FigLaTeX(bearingP2FromP1)}}";

      workings.add(
          "\\text{\\textbf{Step 3: Method (b) — The }} 180^\\circ \\text{\\textbf{ Back-Bearing Rule (Figure 24.17b)}}");
      workings.add(
          "\\text{Rule: Since looking from $c1 to $c2 is the exact opposite direction of looking from $c2 to $c1 (a } 180^\\circ \\text{ half-turn):}");
      workings.add(
          "\\bullet \\text{ If forward bearing } < 180^\\circ, \\text{ ADD } 180^\\circ. \\quad \\bullet \\text{ If forward bearing } \\ge 180^\\circ, \\text{ SUBTRACT } 180^\\circ.");
      workings.add(
          "\\text{Bearing of $c2 from $c1} = $rule180Math \\quad \\left(\\text{Acute-angle: } ${dec2From1['acuteTex']}\\right)");

      steps.add(BearingStep(
        title:
        "Step 3: Textbook Method (b) — The ±180° Back-Bearing Rule (Figure 24.17b)",
        description:
        "Because the North lines at $p1 and $p2 are parallel, the bearing of $p2 from $p1 and the bearing of $p1 from $p2 always differ by exactly 180° (a half-turn):\n"
            "• Since the bearing of $p1 from $p2 (${fmt3Fig(bearingP1FromP2)}) is ${isLess180 ? 'less than 180°, ADD 180°' : '180° or more, SUBTRACT 180°'}:\n"
            "  ${fmt(bearingP1FromP2)}° $op180 180° = ${fmt3Fig(bearingP2FromP1)} (Acute-angle bearing: ${dec2From1['acuteStr']}).",
        mathLaTeX:
        "\\text{Bearing of $c2 from $c1} = $rule180Math",
      ));

      return BearingsResult(
        mode: 3,
        finalAnswers: {
          "i) Bearing of $p1 from $p2":
          "${dec1From2['threeFigStr']} (${dec1From2['acuteStr']})",
          "ii) Bearing of $p2 from $p1":
          "${dec2From1['threeFigStr']} (${dec2From1['acuteStr']})",
          "Alternate Angle (z-angle)": "${fmt(altAcute)}°",
          "Difference Between Bearings": "180°",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BearingsCanvasData(
          mode: 3,
          fromPointName: p2, // Observer 1 (Y or B)
          toPointName: p1, // Target 1 (X or A)
          threeFigAngleDeg: bearingP1FromP2,
          threeFigLabel: dec1From2['threeFigStr'] as String,
          acuteAngleWithNS: altAcute,
          acuteIsFromNorth: dec1From2['isFromNorth'] as bool,
          acuteIsTowardsEast: dec1From2['isTowardsEast'] as bool,
          acuteBearingLabel: dec1From2['acuteStr'] as String,
          backBearingDeg: bearingP2FromP1,
          backBearingThreeFigLabel: dec2From1['threeFigStr'] as String,
          backBearingAcuteLabel: dec2From1['acuteStr'] as String,
          alternateAcuteDeg: altAcute,
          headerBadge:
          "i) $p1 from $p2 = ${dec1From2['threeFigStr']}   |   ii) $p2 from $p1 = ${dec2From1['threeFigStr']}",
          subBadge:
          "Parallel North Lines (N₁ ∥ N₂)  ➔  Alternate Angles = ${fmt(altAcute)}°  |  Back Bearing differs by 180°",
        ),
      );
    } catch (e) {
      return BearingsResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter a valid angle in degrees.",
      );
    }
  }
}