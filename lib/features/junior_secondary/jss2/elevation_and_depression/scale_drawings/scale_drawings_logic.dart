import 'dart:math' as math;
import 'scale_drawings_models.dart';

class ScaleDrawingsLogic {
  /// Formats a double cleanly without trailing .0
  static String fmt(double v, {int maxDecimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Parses scale strings like "1 cm to 2 m", "1 cm to 200 m", "1 cm to 0.5 m", or a raw number "2".
  /// Returns the number of real-life metres represented by 1 cm on the scale drawing.
  static double parseMetresPerCm(String scaleStr) {
    final String s = scaleStr.trim().toLowerCase();
    if (s.isEmpty) return 2.0;

    // If format is "1 cm to X cm" (e.g. 1 cm to 50 cm)
    final RegExp cmToCm = RegExp(r'1\s*cm\s*(?:to|represents|=|:)\s*(\d+\.?\d*)\s*cm');
    final Match? mCm = cmToCm.firstMatch(s);
    if (mCm != null) {
      final double cmVal = double.tryParse(mCm.group(1)!) ?? 50.0;
      return cmVal / 100.0;
    }

    // Standard "1 cm to X m"
    final RegExp cmToM = RegExp(r'1\s*cm\s*(?:to|represents|=|:)\s*(\d+\.?\d*)');
    final Match? mM = cmToM.firstMatch(s);
    if (mM != null) {
      final double val = double.tryParse(mM.group(1)!) ?? 2.0;
      return val > 0 ? val : 2.0;
    }

    // Fallback: extract last numeric token
    final Iterable<Match> allNums = RegExp(r'\d+\.?\d*').allMatches(s);
    if (allNums.isNotEmpty) {
      final double val = double.tryParse(allNums.last.group(0)!) ?? 2.0;
      return val > 0 ? val : 2.0;
    }
    return 2.0;
  }

  /// Applies textbook rounding rules ('metre', 'half_metre', '10_cm', '5_metre', '100_metre')
  static Map<String, String> applyRoundingRule(double exactMetres, String roundRule) {
    switch (roundRule) {
      case 'half_metre':
        final double rounded = (exactMetres * 2.0).round() / 2.0;
        final int whole = rounded.floor();
        final bool hasHalf = (rounded - whole).abs() > 0.1;
        final String display = hasHalf ? "$whole.5 m (or $whole ½ m)" : "$whole m";
        final String latex = hasHalf ? "$whole\\frac{1}{2}\\text{ m } ($whole.5\\text{ m})" : "$whole\\text{ m}";
        return {
          'ruleName': 'to the nearest ½ m (0.5 m)',
          'display': display,
          'latex': latex,
        };
      case '10_cm':
        final double exactCm = exactMetres * 100.0;
        final int roundedCm = ((exactCm / 10.0).round()) * 10;
        final double roundedM = roundedCm / 100.0;
        return {
          'ruleName': 'to the nearest 10 cm (0.1 m)',
          'display': "$roundedCm cm (${fmt(roundedM)} m)",
          'latex': "$roundedCm\\text{ cm } (${fmt(roundedM)}\\text{ m})",
        };
      case '5_metre':
        final int rounded5 = ((exactMetres / 5.0).round()) * 5;
        return {
          'ruleName': 'to the nearest 5 m',
          'display': "$rounded5 m",
          'latex': "$rounded5\\text{ m}",
        };
      case '100_metre':
        final int rounded100 = ((exactMetres / 100.0).round()) * 100;
        return {
          'ruleName': 'to the nearest 100 m',
          'display': "$rounded100 m",
          'latex': "$rounded100\\text{ m}",
        };
      case 'metre':
      default:
        final int roundedM = exactMetres.round();
        return {
          'ruleName': 'to the nearest metre',
          'display': "$roundedM m",
          'latex': "$roundedM\\text{ m}",
        };
    }
  }

  /// Main entry point for solving all 4 Scale Drawing archetypes in Section 20-3.
  static ScaleDrawingResult solveScaleDrawing({
    required int mode, // 0: Elevation, 1: Depression, 2: Two-Point, 3: Reverse Angle
    required int subMode, // 0 or 1
    required double realDistOrHeight,
    required double angleDeg,
    required double observerEyeHeight,
    required double secondAngleDeg,
    required double baselineSeparation,
    required String scaleStr,
    required String roundRule,
  }) {
    try {
      final double mPerCm = parseMetresPerCm(scaleStr);
      final double cmPerM = 1.0 / mPerCm;
      final String cleanScaleText = "1 cm represents ${fmt(mPerCm)} m";

      if (mode == 0) {
        return _solveElevation(
          subMode: subMode,
          realDistOrHeight: realDistOrHeight,
          angleDeg: angleDeg,
          eyeH: observerEyeHeight,
          mPerCm: mPerCm,
          cmPerM: cmPerM,
          scaleText: cleanScaleText,
          roundRule: roundRule,
        );
      } else if (mode == 1) {
        return _solveDepression(
          subMode: subMode,
          realDistOrHeight: realDistOrHeight,
          angleDeg: angleDeg,
          mPerCm: mPerCm,
          cmPerM: cmPerM,
          scaleText: cleanScaleText,
          roundRule: roundRule,
        );
      } else if (mode == 2) {
        return _solveTwoPointSighting(
          theta1: angleDeg,
          theta2: secondAngleDeg,
          separationM: baselineSeparation,
          mPerCm: mPerCm,
          cmPerM: cmPerM,
          scaleText: cleanScaleText,
          roundRule: roundRule,
        );
      } else {
        return _solveReverseAngle(
          verticalHeightM: realDistOrHeight,
          horizontalDistM: observerEyeHeight > 0 ? observerEyeHeight : 40.0,
          mPerCm: mPerCm,
          cmPerM: cmPerM,
          scaleText: cleanScaleText,
        );
      }
    } catch (e) {
      return ScaleDrawingResult.error(
        mode: mode,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please check your dimensions and angles (angles must be between 1° and 89°).",
      );
    }
  }

  // ===========================================================================
  // MODE 0: ANGLE OF ELEVATION (Ground Level & Clinometer with Eye Height)
  // Matches Example 1, Ex 20d #1, #3, #5, #7 & Rev Test 20 #7, #8, #9
  // ===========================================================================
  static ScaleDrawingResult _solveElevation({
    required int subMode, // 0: Given Horiz Dist -> Find Height, 1: Given Height -> Find Shadow/Dist
    required double realDistOrHeight,
    required double angleDeg,
    required double eyeH,
    required double mPerCm,
    required double cmPerM,
    required String scaleText,
    required String roundRule,
  }) {
    if (realDistOrHeight <= 0) {
      throw const FormatException("Distance or height must be greater than 0.");
    }
    if (angleDeg <= 0 || angleDeg >= 89) {
      throw const FormatException("Angle of elevation must be between 1° and 88°.");
    }

    final double rad = angleDeg * math.pi / 180.0;
    final List<String> workings = [];
    final List<ScaleDrawingStep> steps = [];
    final Map<String, String> answers = {};

    if (subMode == 0) {
      // Given Horizontal Distance -> Find Vertical Height
      final double horizM = realDistOrHeight;
      final double horizCm = horizM * cmPerM;
      final double vertAboveEyeCm = horizCm * math.tan(rad);
      final double vertAboveEyeM = vertAboveEyeCm * mPerCm;

      if (eyeH > 0) {
        // Clinometer Observation with Observer's Eye Height (Example 1 & Ex 20d #3)
        final double eyeCm = eyeH * cmPerM;
        final double totalHeightCm = vertAboveEyeCm + eyeCm;
        final double totalHeightM = totalHeightCm * mPerCm;
        final Map<String, String> rounded = applyRoundingRule(totalHeightM, roundRule);

        workings.add("\\text{\\textbf{Step 1: Choose Scale and Convert Real Distances to cm}}");
        workings.add("\\text{Scale: } 1\\text{ cm represents } ${fmt(mPerCm)}\\text{ m}");
        workings.add(
            "\\text{Horizontal ground distance } (GH) = \\frac{${fmt(horizM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(horizCm)}\\text{ cm}");
        workings.add(
            "\\text{Observer's eye height } (EG) = \\frac{${fmt(eyeH)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(eyeCm)}\\text{ cm}");
        workings.add("");

        workings.add("\\text{\\textbf{Step 2: Method 1 — Full Scale Drawing (Figure 20.14)}}");
        workings.add(
            "\\text{1. Draw horizontal ground } GH = ${fmt(horizCm)}\\text{ cm and vertical eye height } GE = ${fmt(eyeCm)}\\text{ cm (at } 90^\\circ\\text{).}");
        workings.add(
            "\\text{2. Draw horizontal eye-level line } EB = ${fmt(horizCm)}\\text{ cm parallel to } GH.");
        workings.add(
            "\\text{3. At eye } E, \\text{ use a protractor to measure } \\angle TEB = ${fmt(angleDeg)}^\\circ \\text{ upwards and meet vertical } HB \\text{ at } T.");
        workings.add(
            "\\text{4. Measure full height } HT \\text{ on the drawing: } HT = ${fmt(totalHeightCm)}\\text{ cm}.");
        workings.add(
            "\\text{Actual Height} = ${fmt(totalHeightCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(totalHeightM)}\\text{ m} \\approx ${rounded['latex']}");
        workings.add("");

        workings.add("\\text{\\textbf{Step 3: Method 2 — Construct Triangle }} \\triangle TEB \\text{\\textbf{ Only (HT = BT + EG)}}");
        workings.add(
            "\\text{Measure vertical side } BT \\text{ of right-angled } \\triangle TEB: \\quad BT = ${fmt(vertAboveEyeCm)}\\text{ cm}");
        workings.add(
            "\\text{Real height above eye level } (BT) = ${fmt(vertAboveEyeCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(vertAboveEyeM)}\\text{ m}");
        workings.add(
            "\\text{Total Height } (HT) = BT + EG = ${fmt(vertAboveEyeM)}\\text{ m} + ${fmt(eyeH)}\\text{ m} = ${fmt(totalHeightM)}\\text{ m} \\approx ${rounded['latex']}");

        steps.add(ScaleDrawingStep(
          title: "Step 1: Convert Real-Life Measurements into Scale Lengths (cm)",
          description:
          "Using the scale '$scaleText', divide each real-life measurement in metres by ${fmt(mPerCm)} to find how many centimetres to draw on your paper:\n"
              "• Horizontal distance GH = ${fmt(horizM)} m ÷ ${fmt(mPerCm)} = ${fmt(horizCm)} cm.\n"
              "• Observer's eye height above the ground EG = ${fmt(eyeH)} m ÷ ${fmt(mPerCm)} = ${fmt(eyeCm)} cm.",
          mathLaTeX:
          "GH = \\frac{${fmt(horizM)}}{${fmt(mPerCm)}} = ${fmt(horizCm)}\\text{ cm}, \\quad EG = \\frac{${fmt(eyeH)}}{${fmt(mPerCm)}} = ${fmt(eyeCm)}\\text{ cm}",
        ));

        steps.add(ScaleDrawingStep(
          title: "Step 2: Construct the Scale Drawing with Ruler, Set-Square & Protractor",
          description:
          "1. Use a ruler to draw the horizontal ground line GH = ${fmt(horizCm)} cm.\n"
              "2. At G, use a set-square (90°) to draw a vertical line upwards for the observer's eye height GE = ${fmt(eyeCm)} cm.\n"
              "3. From eye E, draw the horizontal sight-line EB = ${fmt(horizCm)} cm parallel to GH, and draw a vertical line upwards from H through B.\n"
              "4. Place the centre of your protractor at E, align the baseline with horizontal EB, mark an angle of elevation of ${fmt(angleDeg)}° upwards, and draw the sight-line to cut the vertical line at T.",
          mathLaTeX:
          "\\angle G = 90^\\circ, \\quad \\angle H = 90^\\circ, \\quad \\angle TEB = ${fmt(angleDeg)}^\\circ",
        ));

        steps.add(ScaleDrawingStep(
          title: "Step 3: Measure on Paper & Convert Back to Metres (Method 1 & Method 2)",
          description:
          "As taught in Example 1 (Figure 20.14), you can find the final height in two ways:\n"
              "• Method 1 (Full Drawing): Measure the entire vertical segment HT with your ruler → HT = ${fmt(totalHeightCm)} cm. Multiply by ${fmt(mPerCm)} m: ${fmt(totalHeightCm)} × ${fmt(mPerCm)} = ${fmt(totalHeightM)} m.\n"
              "• Method 2 (Triangle TEB + Eye Height): Measure BT = ${fmt(vertAboveEyeCm)} cm → ${fmt(vertAboveEyeCm)} × ${fmt(mPerCm)} = ${fmt(vertAboveEyeM)} m above eye level. Then add the observer's eye height EG (${fmt(eyeH)} m): ${fmt(vertAboveEyeM)} + ${fmt(eyeH)} = ${fmt(totalHeightM)} m.\n"
              "• Rounding ${rounded['ruleName']} gives ${rounded['display']} (because there are small errors in drawing and measuring, rounding is more sensible).",
          mathLaTeX:
          "HT = ${fmt(totalHeightCm)}\\text{ cm} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(totalHeightM)}\\text{ m}\n"
              "\\text{Or } HT = BT + EG = ${fmt(vertAboveEyeM)} + ${fmt(eyeH)} = ${fmt(totalHeightM)}\\text{ m} \\approx ${rounded['latex']}",
        ));

        answers["Scale Base (GH)"] = "${fmt(horizCm)} cm";
        answers["Measured HT (Paper)"] = "${fmt(totalHeightCm)} cm";
        answers["Unrounded Height"] = "${fmt(totalHeightM)} m";
        answers["Final Height (Rounded)"] = rounded['display']!;

        return ScaleDrawingResult(
          mode: 0,
          subMode: 0,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          scaleFactorCmPerUnit: cmPerM,
          scaleText: scaleText,
          realHorizontal: horizM,
          realVertical: totalHeightM,
          realEyeHeight: eyeH,
          angleDeg: angleDeg,
          roundRule: roundRule,
        );
      } else {
        // Ground-Level Elevation Observation (eyeH == 0: Ex 20d #1, #5, #7, Rev Test #7, #9)
        final Map<String, String> rounded = applyRoundingRule(vertAboveEyeM, roundRule);

        workings.add("\\text{\\textbf{Step 1: Choose Scale and Convert Horizontal Distance to cm}}");
        workings.add("\\text{Scale: } 1\\text{ cm represents } ${fmt(mPerCm)}\\text{ m}");
        workings.add(
            "\\text{Scale base length } (GH) = \\frac{${fmt(horizM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(horizCm)}\\text{ cm}");
        workings.add("");

        workings.add("\\text{\\textbf{Step 2: Construct Right-Angled Triangle }} \\triangle TGH");
        workings.add(
            "\\text{1. Draw horizontal baseline } GH = ${fmt(horizCm)}\\text{ cm.}");
        workings.add(
            "\\text{2. At } H, \\text{ use a set-square to draw a perpendicular vertical line } (90^\\circ)\\text{ upwards.}");
        workings.add(
            "\\text{3. At } G, \\text{ use a protractor to measure the angle of elevation } e^\\circ = ${fmt(angleDeg)}^\\circ \\text{ upwards to meet the vertical at } T.");
        workings.add("");

        workings.add("\\text{\\textbf{Step 3: Measure Vertical Height }} HT \\text{\\textbf{ and Multiply by Scale}}");
        workings.add("\\text{Measured vertical height on paper } (HT) = ${fmt(vertAboveEyeCm)}\\text{ cm}");
        workings.add(
            "\\text{Actual Height} = ${fmt(vertAboveEyeCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(vertAboveEyeM)}\\text{ m}");
        workings.add("\\text{Rounded (${rounded['ruleName']})} = ${rounded['latex']}");

        steps.add(ScaleDrawingStep(
          title: "Step 1: Convert Horizontal Ground Distance to Scale Length (cm)",
          description:
          "Using the scale '$scaleText', every ${fmt(mPerCm)} m in real life is drawn as 1 cm on paper:\n"
              "• Scale base length GH = ${fmt(horizM)} m ÷ ${fmt(mPerCm)} = ${fmt(horizCm)} cm.",
          mathLaTeX:
          "\\text{Scale Base } (GH) = \\frac{${fmt(horizM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(horizCm)}\\text{ cm}",
        ));

        steps.add(ScaleDrawingStep(
          title: "Step 2: Construct the Right-Angled Triangle Using Ruler & Protractor",
          description:
          "1. Use a ruler to draw a horizontal line segment GH = ${fmt(horizCm)} cm.\n"
              "2. At point H (the foot of the object), use a set-square to draw a vertical line straight up at 90°.\n"
              "3. Place your protractor at G, measure an angle of elevation of ${fmt(angleDeg)}° rising from the horizontal ground GH, and draw a straight line until it crosses the vertical line at T.",
          mathLaTeX:
          "GH = ${fmt(horizCm)}\\text{ cm}, \\quad \\angle GHT = 90^\\circ, \\quad \\angle HGT = ${fmt(angleDeg)}^\\circ",
        ));

        steps.add(ScaleDrawingStep(
          title: "Step 3: Measure Height HT in cm and Convert to Real-Life Metres",
          description:
          "1. Use your ruler to measure the vertical line HT on your scale drawing: HT = ${fmt(vertAboveEyeCm)} cm.\n"
              "2. Multiply by the scale factor (${fmt(mPerCm)} m per cm): ${fmt(vertAboveEyeCm)} × ${fmt(mPerCm)} = ${fmt(vertAboveEyeM)} m.\n"
              "3. Round ${rounded['ruleName']}: ${rounded['display']}.",
          mathLaTeX:
          "HT = ${fmt(vertAboveEyeCm)}\\text{ cm} \\implies \\text{Height} = ${fmt(vertAboveEyeCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(vertAboveEyeM)}\\text{ m} \\approx ${rounded['latex']}",
        ));

        answers["Scale Base (GH)"] = "${fmt(horizCm)} cm";
        answers["Measured Height (cm)"] = "${fmt(vertAboveEyeCm)} cm";
        answers["Exact Height"] = "${fmt(vertAboveEyeM)} m";
        answers["Rounded Height"] = rounded['display']!;

        return ScaleDrawingResult(
          mode: 0,
          subMode: 0,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          scaleFactorCmPerUnit: cmPerM,
          scaleText: scaleText,
          realHorizontal: horizM,
          realVertical: vertAboveEyeM,
          realEyeHeight: 0.0,
          angleDeg: angleDeg,
          roundRule: roundRule,
        );
      }
    } else {
      // Sub-Mode 0B: Given Vertical Height & Angle of Elevation -> Find Horizontal Distance / Shadow Length (Rev Test 20 #8)
      final double vertM = realDistOrHeight;
      final double vertCm = vertM * cmPerM;
      final double horizCm = vertCm / math.tan(rad);
      final double horizM = horizCm * mPerCm;
      final Map<String, String> rounded = applyRoundingRule(horizM, roundRule);

      workings.add("\\text{\\textbf{Step 1: Choose Scale and Convert Vertical Height to cm}}");
      workings.add("\\text{Scale: } 1\\text{ cm represents } ${fmt(mPerCm)}\\text{ m}");
      workings.add(
          "\\text{Vertical height on drawing } (HT) = \\frac{${fmt(vertM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(vertCm)}\\text{ cm}");
      workings.add("");

      workings.add("\\text{\\textbf{Step 2: Construct Vertical Object & Sun's Ray / Sight Line}}");
      workings.add(
          "\\text{1. Draw horizontal ground line and erect vertical height } HT = ${fmt(vertCm)}\\text{ cm at } 90^\\circ.");
      workings.add(
          "\\text{2. Since the angle of elevation at the ground is } e^\\circ = ${fmt(angleDeg)}^\\circ, \\text{ the complementary angle at the top } T \\text{ inside } \\triangle TGH \\text{ is } 90^\\circ - ${fmt(angleDeg)}^\\circ = ${fmt(90 - angleDeg)}^\\circ.");
      workings.add(
          "\\text{3. Draw the ray from } T \\text{ down to meet the horizontal ground at } G \\text{ (making } \\angle HGT = ${fmt(angleDeg)}^\\circ\\text{).}");
      workings.add("");

      workings.add("\\text{\\textbf{Step 3: Measure Shadow / Horizontal Distance }} GH \\text{\\textbf{ and Convert}}");
      workings.add("\\text{Measured base length on paper } (GH) = ${fmt(horizCm)}\\text{ cm}");
      workings.add(
          "\\text{Real Horizontal Distance / Shadow} = ${fmt(horizCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(horizM)}\\text{ m}");
      workings.add("\\text{Rounded (${rounded['ruleName']})} = ${rounded['latex']}");

      steps.add(ScaleDrawingStep(
        title: "Step 1: Convert Known Vertical Height to Scale Length (cm)",
        description:
        "Using the scale '$scaleText', convert the vertical height (${fmt(vertM)} m = ${fmt(vertM * 100)} cm) into a scale drawing height:\n"
            "• Vertical line HT = ${fmt(vertM)} m ÷ ${fmt(mPerCm)} = ${fmt(vertCm)} cm.",
        mathLaTeX:
        "HT = \\frac{${fmt(vertM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(vertCm)}\\text{ cm}",
      ));

      steps.add(ScaleDrawingStep(
        title: "Step 2: Construct the Right-Angled Triangle on Graph Paper",
        description:
        "1. Draw a long horizontal line for the ground and mark point H.\n"
            "2. At H, use a set-square (90°) to draw the vertical object HT = ${fmt(vertCm)} cm.\n"
            "3. Because the angle at H is 90° and the angle of elevation at G is ${fmt(angleDeg)}°, the angle at the top T is 90° − ${fmt(angleDeg)}° = ${fmt(90 - angleDeg)}° (or draw a horizontal line at T and measure ${fmt(angleDeg)}° downwards). Draw the line from T to meet the ground at G.",
        mathLaTeX:
        "\\angle GHT = 90^\\circ, \\quad \\angle HGT = ${fmt(angleDeg)}^\\circ, \\quad \\angle HTG = 90^\\circ - ${fmt(angleDeg)}^\\circ = ${fmt(90 - angleDeg)}^\\circ",
      ));

      steps.add(ScaleDrawingStep(
        title: "Step 3: Measure Shadow / Base GH in cm and Multiply by Scale",
        description:
        "1. Measure the horizontal shadow/distance GH on your scale drawing: GH = ${fmt(horizCm)} cm.\n"
            "2. Multiply by ${fmt(mPerCm)} m: ${fmt(horizCm)} × ${fmt(mPerCm)} = ${fmt(horizM)} m (${fmt(horizM * 100)} cm).\n"
            "3. Round ${rounded['ruleName']}: ${rounded['display']}.",
        mathLaTeX:
        "GH = ${fmt(horizCm)}\\text{ cm} \\implies \\text{Distance} = ${fmt(horizCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(horizM)}\\text{ m} \\approx ${rounded['latex']}",
      ));

      answers["Scale Height (HT)"] = "${fmt(vertCm)} cm";
      answers["Measured Base (GH)"] = "${fmt(horizCm)} cm";
      answers["Exact Distance/Shadow"] = "${fmt(horizM)} m";
      answers["Rounded Answer"] = rounded['display']!;

      return ScaleDrawingResult(
        mode: 0,
        subMode: 1,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        scaleFactorCmPerUnit: cmPerM,
        scaleText: scaleText,
        realHorizontal: horizM,
        realVertical: vertM,
        realEyeHeight: 0.0,
        angleDeg: angleDeg,
        roundRule: roundRule,
      );
    }
  }

  // ===========================================================================
  // MODE 1: ANGLE OF DEPRESSION (Ex 20d #2, #4, #6, #8)
  // ===========================================================================
  static ScaleDrawingResult _solveDepression({
    required int subMode, // 0: Given Horiz Dist -> Find Height, 1: Given Height -> Find Horiz Dist / River Width
    required double realDistOrHeight,
    required double angleDeg,
    required double mPerCm,
    required double cmPerM,
    required String scaleText,
    required String roundRule,
  }) {
    if (realDistOrHeight <= 0) {
      throw const FormatException("Distance or height must be greater than 0.");
    }
    if (angleDeg <= 0 || angleDeg >= 89) {
      throw const FormatException("Angle of depression must be between 1° and 88°.");
    }

    final double rad = angleDeg * math.pi / 180.0;
    final List<String> workings = [];
    final List<ScaleDrawingStep> steps = [];
    final Map<String, String> answers = {};

    if (subMode == 0) {
      // Given Horizontal Distance & Angle of Depression -> Find Height (Ex 20d #2 Control Tower, #6 Building)
      final double horizM = realDistOrHeight;
      final double horizCm = horizM * cmPerM;
      final double vertCm = horizCm * math.tan(rad);
      final double vertM = vertCm * mPerCm;
      final Map<String, String> rounded = applyRoundingRule(vertM, roundRule);

      workings.add("\\text{\\textbf{Step 1: Angle of Depression Rule & Scale Conversion}}");
      workings.add(
          "\\text{An angle of depression } (d^\\circ = ${fmt(angleDeg)}^\\circ) \\text{ is measured DOWNWARDS from the horizontal line at the top.}");
      workings.add(
          "\\text{By alternate angles between parallel horizontal lines: } e^\\circ = d^\\circ = ${fmt(angleDeg)}^\\circ.");
      workings.add(
          "\\text{Scale: } 1\\text{ cm to } ${fmt(mPerCm)}\\text{ m} \\implies \\text{Horizontal distance } = \\frac{${fmt(horizM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(horizCm)}\\text{ cm}");
      workings.add("");

      workings.add("\\text{\\textbf{Step 2: Construct the Scale Drawing}}");
      workings.add(
          "\\text{1. Draw horizontal line } GH = ${fmt(horizCm)}\\text{ cm and perpendicular vertical tower/building wall at } H \\text{ (}90^\\circ\\text{).}");
      workings.add(
          "\\text{2. Measure } ${fmt(angleDeg)}^\\circ \\text{ at } G \\text{ (or from the top horizontal downwards) to locate the top } T.");
      workings.add("");

      workings.add("\\text{\\textbf{Step 3: Measure Vertical Height }} HT \\text{\\textbf{ and Convert to Metres}}");
      workings.add("\\text{Measured vertical height } (HT) = ${fmt(vertCm)}\\text{ cm}");
      workings.add(
          "\\text{Real Height} = ${fmt(vertCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(vertM)}\\text{ m} \\approx ${rounded['latex']}");

      steps.add(ScaleDrawingStep(
        title: "Step 1: Understand the Angle of Depression & Convert Distance to cm",
        description:
        "• Crucial Rule: The angle of depression (${fmt(angleDeg)}°) is ALWAYS measured downwards from the horizontal line at the top (never from the vertical wall!). Because the top horizontal line and the ground are parallel, alternate angles are equal, so the angle at the bottom G is also ${fmt(angleDeg)}°.\n"
            "• Using '$scaleText', convert the horizontal distance: ${fmt(horizM)} m ÷ ${fmt(mPerCm)} = ${fmt(horizCm)} cm.",
        mathLaTeX:
        "d^\\circ = e^\\circ = ${fmt(angleDeg)}^\\circ, \\quad GH = \\frac{${fmt(horizM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(horizCm)}\\text{ cm}",
      ));

      steps.add(ScaleDrawingStep(
        title: "Step 2: Construct the Scale Drawing with Ruler, Set-Square & Protractor",
        description:
        "1. Draw horizontal baseline GH = ${fmt(horizCm)} cm.\n"
            "2. At H, use a set-square to draw a vertical line upwards at 90°.\n"
            "3. At G, use a protractor to measure ${fmt(angleDeg)}° upwards (which matches the ${fmt(angleDeg)}° angle of depression from the top horizontal) and draw the sight-line to meet the vertical wall at T.",
        mathLaTeX:
        "GH = ${fmt(horizCm)}\\text{ cm}, \\quad \\angle GHT = 90^\\circ, \\quad d^\\circ = ${fmt(angleDeg)}^\\circ",
      ));

      steps.add(ScaleDrawingStep(
        title: "Step 3: Measure Vertical Height HT and Multiply by Scale",
        description:
        "1. Measure the vertical height HT on the scale drawing: HT = ${fmt(vertCm)} cm.\n"
            "2. Multiply by ${fmt(mPerCm)} m: ${fmt(vertCm)} × ${fmt(mPerCm)} = ${fmt(vertM)} m.\n"
            "3. Round ${rounded['ruleName']}: ${rounded['display']}.",
        mathLaTeX:
        "HT = ${fmt(vertCm)}\\text{ cm} \\implies \\text{Height} = ${fmt(vertCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(vertM)}\\text{ m} \\approx ${rounded['latex']}",
      ));

      answers["Scale Base (GH)"] = "${fmt(horizCm)} cm";
      answers["Measured Height (HT)"] = "${fmt(vertCm)} cm";
      answers["Exact Height"] = "${fmt(vertM)} m";
      answers["Rounded Height"] = rounded['display']!;

      return ScaleDrawingResult(
        mode: 1,
        subMode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        scaleFactorCmPerUnit: cmPerM,
        scaleText: scaleText,
        realHorizontal: horizM,
        realVertical: vertM,
        realEyeHeight: 0.0,
        angleDeg: angleDeg,
        roundRule: roundRule,
      );
    } else {
      // Sub-Mode 1B: Given Height & Angle of Depression -> Find Horizontal Distance / River Width (Ex 20d #4, #8)
      final double vertM = realDistOrHeight;
      final double vertCm = vertM * cmPerM;
      final double horizCm = vertCm / math.tan(rad);
      final double horizM = horizCm * mPerCm;
      final Map<String, String> rounded = applyRoundingRule(horizM, roundRule);

      workings.add("\\text{\\textbf{Step 1: Convert Vertical Height to Scale Length in cm}}");
      workings.add("\\text{Scale: } 1\\text{ cm represents } ${fmt(mPerCm)}\\text{ m}");
      workings.add(
          "\\text{Vertical height on paper } (HT) = \\frac{${fmt(vertM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(vertCm)}\\text{ cm}");
      workings.add("");

      workings.add("\\text{\\textbf{Step 2: Construct Angle of Depression }} d^\\circ = ${fmt(angleDeg)}^\\circ \\text{\\textbf{ from Top Horizontal}}");
      workings.add(
          "\\text{1. Draw vertical height } HT = ${fmt(vertCm)}\\text{ cm and horizontal ground line from } H \\text{ at } 90^\\circ.");
      workings.add(
          "\\text{2. At the top } T, \\text{ draw a horizontal sight-line parallel to the ground.}");
      workings.add(
          "\\text{3. Use a protractor at } T \\text{ to measure } d^\\circ = ${fmt(angleDeg)}^\\circ \\text{ DOWNWARDS from the top horizontal (or } 90^\\circ - ${fmt(angleDeg)}^\\circ = ${fmt(90 - angleDeg)}^\\circ \\text{ from vertical } TH\\text{) to meet the ground/river bank at } G.");
      workings.add("");

      workings.add("\\text{\\textbf{Step 3: Measure Horizontal Distance / River Width }} GH \\text{\\textbf{ and Convert}}");
      workings.add("\\text{Measured horizontal width on paper } (GH) = ${fmt(horizCm)}\\text{ cm}");
      workings.add(
          "\\text{Real Horizontal Distance / Width} = ${fmt(horizCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(horizM)}\\text{ m} \\approx ${rounded['latex']}");

      steps.add(ScaleDrawingStep(
        title: "Step 1: Convert Known Height into Scale Drawing Length (cm)",
        description:
        "Using the scale '$scaleText', divide the vertical height (${fmt(vertM)} m) by ${fmt(mPerCm)}:\n"
            "• Scale vertical height HT = ${fmt(vertM)} m ÷ ${fmt(mPerCm)} = ${fmt(vertCm)} cm.",
        mathLaTeX:
        "HT = \\frac{${fmt(vertM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(vertCm)}\\text{ cm}",
      ));

      steps.add(ScaleDrawingStep(
        title: "Step 2: Measure the Angle of Depression (${fmt(angleDeg)}°) Downwards from the Top Horizontal",
        description:
        "1. Draw the vertical line HT = ${fmt(vertCm)} cm and a long horizontal baseline from H at 90°.\n"
            "2. At the top T, draw a dashed horizontal line parallel to the ground.\n"
            "3. Place your protractor at T and measure the angle of depression d° = ${fmt(angleDeg)}° downwards from that top horizontal line (note: the interior angle ∠HTG inside the triangle is 90° − ${fmt(angleDeg)}° = ${fmt(90 - angleDeg)}°).\n"
            "4. Draw the straight sight-line from T until it hits the horizontal baseline at G.",
        mathLaTeX:
        "d^\\circ = ${fmt(angleDeg)}^\\circ \\implies \\angle HTG = 90^\\circ - ${fmt(angleDeg)}^\\circ = ${fmt(90 - angleDeg)}^\\circ",
      ));

      steps.add(ScaleDrawingStep(
        title: "Step 3: Measure Horizontal Distance GH in cm and Multiply by Scale",
        description:
        "1. Use your ruler to measure the horizontal distance GH on your scale drawing: GH = ${fmt(horizCm)} cm.\n"
            "2. Multiply by ${fmt(mPerCm)} m: ${fmt(horizCm)} × ${fmt(mPerCm)} = ${fmt(horizM)} m.\n"
            "3. Round ${rounded['ruleName']}: ${rounded['display']}.",
        mathLaTeX:
        "GH = ${fmt(horizCm)}\\text{ cm} \\implies \\text{Distance} = ${fmt(horizCm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(horizM)}\\text{ m} \\approx ${rounded['latex']}",
      ));

      answers["Scale Height (HT)"] = "${fmt(vertCm)} cm";
      answers["Measured Width (GH)"] = "${fmt(horizCm)} cm";
      answers["Exact Distance/Width"] = "${fmt(horizM)} m";
      answers["Rounded Distance"] = rounded['display']!;

      return ScaleDrawingResult(
        mode: 1,
        subMode: 1,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        scaleFactorCmPerUnit: cmPerM,
        scaleText: scaleText,
        realHorizontal: horizM,
        realVertical: vertM,
        realEyeHeight: 0.0,
        angleDeg: angleDeg,
        roundRule: roundRule,
      );
    }
  }

  // ===========================================================================
  // MODE 2: TWO-POINT ELEVATION SIGHTING (Rev Test 20 #10 / Fig 20.23 Aircraft)
  // ===========================================================================
  static ScaleDrawingResult _solveTwoPointSighting({
    required double theta1,
    required double theta2,
    required double separationM,
    required double mPerCm,
    required double cmPerM,
    required String scaleText,
    required String roundRule,
  }) {
    if (separationM <= 0) {
      throw const FormatException("Baseline separation AB must be greater than 0.");
    }
    if (theta1 <= 0 || theta2 <= 0 || theta1 >= 89 || theta2 >= 89) {
      throw const FormatException("Both angles of elevation must be between 1° and 88°.");
    }
    if ((theta2 - theta1).abs() < 1.0) {
      throw const FormatException(
          "The closer angle θ₂ must be larger than the farther angle θ₁ so the two sight-lines intersect.");
    }

    final double farAngle = math.min(theta1, theta2);
    final double closeAngle = math.max(theta1, theta2);
    final double rad1 = farAngle * math.pi / 180.0;
    final double rad2 = closeAngle * math.pi / 180.0;

    final double paperAB_Cm = separationM * cmPerM;
    // Exact geometry for the intersection point P and perpendicular drop PN
    final double paperAN_Cm =
        (paperAB_Cm * math.tan(rad2)) / (math.tan(rad2) - math.tan(rad1));
    final double paperBN_Cm = paperAN_Cm - paperAB_Cm;
    final double paperPN_Cm = paperAN_Cm * math.tan(rad1);

    final double realHeightM = paperPN_Cm * mPerCm;
    final double realBN_M = paperBN_Cm * mPerCm;
    final Map<String, String> rounded = applyRoundingRule(realHeightM, roundRule);

    final List<String> workings = [
      "\\text{\\textbf{Step 1: Convert Separation Distance }} AB \\text{\\textbf{ Using Scale}}",
      "\\text{Scale: } 1\\text{ cm represents } ${fmt(mPerCm)}\\text{ m}",
      "\\text{Baseline segment } AB = \\frac{${fmt(separationM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(paperAB_Cm)}\\text{ cm}",
      "",
      "\\text{\\textbf{Step 2: Construct the Two Sight-Lines from }} A \\text{\\textbf{ and }} B",
      "\\text{1. Draw horizontal ground line starting at } A, \\text{ mark } B \\text{ at } AB = ${fmt(paperAB_Cm)}\\text{ cm, and extend the line to the right.}",
      "\\text{2. At point } A, \\text{ use a protractor to draw a sight-line at } \\theta_1 = ${fmt(farAngle)}^\\circ \\text{ above the horizontal.}",
      "\\text{3. At point } B, \\text{ use a protractor to draw a second sight-line in the same direction at } \\theta_2 = ${fmt(closeAngle)}^\\circ.",
      "\\text{4. Mark the point where the two sight-lines cross as the aircraft } P.",
      "",
      "\\text{\\textbf{Step 3: Drop Perpendicular }} PN \\text{\\textbf{ and Measure in cm}}",
      "\\text{From } P, \\text{ use a set-square to drop a vertical line } (90^\\circ) \\text{ straight down to the extended baseline at } N.",
      "\\text{Measured vertical height on paper } (PN) = ${fmt(paperPN_Cm)}\\text{ cm}",
      "\\text{Actual Height above Ground} = ${fmt(paperPN_Cm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(realHeightM)}\\text{ m}",
      "\\text{Rounded (${rounded['ruleName']})} = ${rounded['latex']}",
    ];

    final List<ScaleDrawingStep> steps = [
      ScaleDrawingStep(
        title: "Step 1: Convert the Ground Separation Distance AB to cm",
        description:
        "The two observation points A and B are ${fmt(separationM)} m apart on level ground (Figure 20.23). Using the scale '$scaleText':\n"
            "• Scale baseline AB = ${fmt(separationM)} m ÷ ${fmt(mPerCm)} = ${fmt(paperAB_Cm)} cm.",
        mathLaTeX:
        "AB = \\frac{${fmt(separationM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(paperAB_Cm)}\\text{ cm}",
      ),
      ScaleDrawingStep(
        title: "Step 2: Draw Both Angles of Elevation (${fmt(farAngle)}° and ${fmt(closeAngle)}°) to Locate P",
        description:
        "1. Draw a long horizontal ground line. Mark point A on the left and measure AB = ${fmt(paperAB_Cm)} cm to mark point B (keep the line extended to the right of B).\n"
            "2. Place your protractor at A and draw a long straight sight-line rising at ${fmt(farAngle)}°.\n"
            "3. Move your protractor to B and draw a second sight-line rising in the same direction at ${fmt(closeAngle)}°.\n"
            "4. The exact point where the two sight-lines intersect is the aircraft P!",
        mathLaTeX:
        "\\angle PAN = ${fmt(farAngle)}^\\circ, \\quad \\angle PBN = ${fmt(closeAngle)}^\\circ",
      ),
      ScaleDrawingStep(
        title: "Step 3: Drop Perpendicular PN, Measure with a Ruler & Convert",
        description:
        "1. Use a set-square to drop a perpendicular vertical line (90°) from P straight down to meet the extended ground line at N.\n"
            "2. Measure the vertical height PN on your scale drawing: PN = ${fmt(paperPN_Cm)} cm (and horizontal distance BN = ${fmt(paperBN_Cm)} cm = ${fmt(realBN_M)} m).\n"
            "3. Multiply PN by ${fmt(mPerCm)} m: ${fmt(paperPN_Cm)} × ${fmt(mPerCm)} = ${fmt(realHeightM)} m.\n"
            "4. Round ${rounded['ruleName']}: ${rounded['display']}.",
        mathLaTeX:
        "PN = ${fmt(paperPN_Cm)}\\text{ cm} \\implies \\text{Height} = ${fmt(paperPN_Cm)} \\times ${fmt(mPerCm)}\\text{ m} = ${fmt(realHeightM)}\\text{ m} \\approx ${rounded['latex']}",
      ),
    ];

    final Map<String, String> answers = {
      "Scale Baseline (AB)": "${fmt(paperAB_Cm)} cm",
      "Measured Height (PN)": "${fmt(paperPN_Cm)} cm",
      "Exact Aircraft Height": "${fmt(realHeightM)} m",
      "Height (Rounded)": rounded['display']!,
    };

    return ScaleDrawingResult(
      mode: 2,
      subMode: 0,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
      scaleFactorCmPerUnit: cmPerM,
      scaleText: scaleText,
      realHorizontal: separationM + realBN_M,
      realVertical: realHeightM,
      realEyeHeight: 0.0,
      angleDeg: farAngle,
      secondAngleDeg: closeAngle,
      baselineSeparation: separationM,
      roundRule: roundRule,
    );
  }

  // ===========================================================================
  // MODE 3: REVERSE SCALE DRAWING — FIND UNKNOWN ANGLE (Rev Test 20 #5 & #6)
  // ===========================================================================
  static ScaleDrawingResult _solveReverseAngle({
    required double verticalHeightM,
    required double horizontalDistM,
    required double mPerCm,
    required double cmPerM,
    required String scaleText,
  }) {
    if (verticalHeightM <= 0 || horizontalDistM <= 0) {
      throw const FormatException(
          "Both vertical height and horizontal distance must be greater than 0.");
    }

    final double horizCm = horizontalDistM * cmPerM;
    final double vertCm = verticalHeightM * cmPerM;
    final double angleRad = math.atan2(verticalHeightM, horizontalDistM);
    final double angleDeg = angleRad * 180.0 / math.pi;
    final int roundedDeg = angleDeg.round();

    final List<String> workings = [
      "\\text{\\textbf{Step 1: Convert Both Real Dimensions to Scale Lengths in cm}}",
      "\\text{Scale: } 1\\text{ cm represents } ${fmt(mPerCm)}\\text{ m}",
      "\\text{Horizontal base } (GH) = \\frac{${fmt(horizontalDistM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(horizCm)}\\text{ cm}",
      "\\text{Vertical height } (HT) = \\frac{${fmt(verticalHeightM)}\\text{ m}}{${fmt(mPerCm)}} = ${fmt(vertCm)}\\text{ cm}",
      "",
      "\\text{\\textbf{Step 2: Construct Right-Angled Triangle and Measure Angles with Protractor}}",
      "\\text{1. Draw horizontal base } GH = ${fmt(horizCm)}\\text{ cm and perpendicular vertical height } HT = ${fmt(vertCm)}\\text{ cm at } 90^\\circ.",
      "\\text{2. Join } G \\text{ to } T \\text{ with a straight ruler line (the line of sight).}",
      "\\text{3. Place your protractor at } G \\text{ to measure the Angle of Elevation } (e^\\circ), \\text{ and at } T \\text{ from the top horizontal to measure the Angle of Depression } (d^\\circ):",
      "e^\\circ = d^\\circ = ${fmt(angleDeg, maxDecimals: 1)}^\\circ \\approx $roundedDeg^\\circ \\text{ (to the nearest degree)}",
    ];

    final List<ScaleDrawingStep> steps = [
      ScaleDrawingStep(
        title: "Step 1: Convert Both Known Distances to Scale Lengths (cm)",
        description:
        "Using the scale '$scaleText', convert both the horizontal distance and vertical height into centimetres:\n"
            "• Horizontal base GH = ${fmt(horizontalDistM)} m ÷ ${fmt(mPerCm)} = ${fmt(horizCm)} cm.\n"
            "• Vertical height HT = ${fmt(verticalHeightM)} m ÷ ${fmt(mPerCm)} = ${fmt(vertCm)} cm.",
        mathLaTeX:
        "GH = ${fmt(horizCm)}\\text{ cm}, \\quad HT = ${fmt(vertCm)}\\text{ cm}",
      ),
      ScaleDrawingStep(
        title: "Step 2: Construct the Right-Angled Triangle Using Ruler & Set-Square",
        description:
        "1. Use your ruler to draw horizontal base GH = ${fmt(horizCm)} cm.\n"
            "2. At H, use a set-square (90°) to draw vertical height HT = ${fmt(vertCm)} cm.\n"
            "3. Use your ruler to join G to T to form the slanted line of sight.",
        mathLaTeX:
        "\\angle GHT = 90^\\circ, \\quad \\text{Join } G \\text{ to } T",
      ),
      ScaleDrawingStep(
        title: "Step 3: Measure the Angle of Elevation (e°) & Depression (d°) with a Protractor",
        description:
        "• Place the centre of your protractor at G (ground observer) and read the angle between horizontal GH and line of sight GT: Angle of Elevation e° = ${fmt(angleDeg, maxDecimals: 1)}° (≈ $roundedDeg° to the nearest degree).\n"
            "• Place your protractor on the horizontal line at the top T and read the angle downwards to GT: Angle of Depression d° = ${fmt(angleDeg, maxDecimals: 1)}° (≈ $roundedDeg°).",
        mathLaTeX:
        "e^\\circ = d^\\circ = ${fmt(angleDeg, maxDecimals: 1)}^\\circ \\approx $roundedDeg^\\circ",
      ),
    ];

    final Map<String, String> answers = {
      "Scale Base (GH)": "${fmt(horizCm)} cm",
      "Scale Height (HT)": "${fmt(vertCm)} cm",
      "Angle of Elevation (e°)": "$roundedDeg° (${fmt(angleDeg, maxDecimals: 1)}°)",
      "Angle of Depression (d°)": "$roundedDeg° (${fmt(angleDeg, maxDecimals: 1)}°)",
    };

    return ScaleDrawingResult(
      mode: 3,
      subMode: 0,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
      scaleFactorCmPerUnit: cmPerM,
      scaleText: scaleText,
      realHorizontal: horizontalDistM,
      realVertical: verticalHeightM,
      realEyeHeight: 0.0,
      angleDeg: angleDeg,
      roundRule: 'metre',
    );
  }
}