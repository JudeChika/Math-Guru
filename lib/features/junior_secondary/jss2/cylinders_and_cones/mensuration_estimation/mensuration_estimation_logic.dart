import 'dart:math' as math;
import 'mensuration_estimation_models.dart';

class MensurationEstLogic {
  /// Pre-configured textbook presets for Section 19-3 (Example 8 & Exercise 19h)
  static const List<MensurationEstPreset> textbookPresets = [
    MensurationEstPreset(
      chipLabel: "Ex 19h #1a: Estimate 3.1 × 4.8 × 9.2",
      topicMode: 0,
      expression: "3.1 * 4.8 * 9.2",
    ),
    MensurationEstPreset(
      chipLabel: "Ex 19h #1d: Estimate (3.14 × 19²) / 3",
      topicMode: 0,
      expression: "(3.14 * 19 * 19) / 3",
    ),
    MensurationEstPreset(
      chipLabel: "Ex 19h #2: Round 384.62 (s.f. & d.p.)",
      topicMode: 1,
      expression: "384.62",
    ),
    MensurationEstPreset(
      chipLabel: "Ex 8: Basin of Rice (Cylinder + Cone)",
      topicMode: 2,
      shapeType: 'composite',
      dim1: '15', // radius 15 cm (diameter 30 cm)
      dim2: '8', // cylinder height 8 cm
      dim3: '6', // cone height 6 cm
      unit: 'cm',
    ),
    MensurationEstPreset(
      chipLabel: "Ex 19h: Estimate Cylinder Volume & TSA",
      topicMode: 2,
      shapeType: 'cylinder',
      dim1: '6.8',
      dim2: '10.4',
      unit: 'cm',
    ),
    MensurationEstPreset(
      chipLabel: "Ex 19h: Estimate Cone Volume & CSA",
      topicMode: 2,
      shapeType: 'cone',
      dim1: '5.2',
      dim2: '11.8',
      unit: 'cm',
    ),
  ];

  /// Formats a number cleanly, dropping trailing .0
  static String fmt(double v, {int maxDecimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Rounds a number to [sf] significant figures
  static double roundToSF(double v, int sf) {
    if (v == 0 || v.abs() < 1e-12 || sf < 1) return 0;
    final int d = (math.log(v.abs()) / math.ln10).floor();
    final int power = sf - 1 - d;
    if (power >= 0) {
      final double scale = math.pow(10, power).toDouble();
      return (v * scale).roundToDouble() / scale;
    } else {
      final double scale = math.pow(10, -power).toDouble();
      return (v / scale).roundToDouble() * scale;
    }
  }

  /// Formats a number to [sf] significant figures as a string
  static String fmtSF(double v, int sf) {
    if (v == 0 || v.abs() < 1e-12) return "0";
    final int d = (math.log(v.abs()) / math.ln10).floor();
    final int power = sf - 1 - d;
    final double rounded = roundToSF(v, sf);
    if (power <= 0) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(power);
  }

  /// Formats a number to [dp] decimal places
  static String fmtDP(double v, int dp) {
    return v.toStringAsFixed(dp);
  }

  // ===========================================================================
  // MODE 0: Estimation by Rounding Each Number to 1 Significant Figure
  // ===========================================================================
  static MensurationEstResult solveOneSFEstimation({
    required String expressionStr,
  }) {
    try {
      final String clean = expressionStr
          .trim()
          .replaceAll('×', '*')
          .replaceAll('÷', '/');
      if (clean.isEmpty) {
        throw const FormatException(
            "Please enter a multiplication or division expression to estimate.");
      }

      // Extract all numeric tokens from the expression
      final RegExp numReg = RegExp(r'\d+\.?\d*');
      final List<Match> matches = numReg.allMatches(clean).toList();
      if (matches.isEmpty) {
        throw const FormatException(
            "No valid numbers found in the expression.");
      }

      final List<double> rawNums = [];
      final List<double> rounded1SFNums = [];
      final List<String> roundingMappingsLatex = [];
      final List<String> roundingMappingsPlain = [];

      for (final m in matches) {
        final String token = m.group(0)!;
        final double val = double.parse(token);
        final double r1 = roundToSF(val, 1);
        rawNums.add(val);
        rounded1SFNums.add(r1);
        roundingMappingsLatex
            .add("${fmt(val, maxDecimals: 4)} \\approx ${fmt(r1)}");
        roundingMappingsPlain
            .add("• ${fmt(val, maxDecimals: 4)} rounds to ${fmt(r1)} (1 s.f.)");
      }

      // Evaluate exact and estimated values for standard product / quotient expressions
      final bool hasDiv = clean.contains('/');
      double exactResult = 1.0;
      double estResult = 1.0;
      String exactLatex = "";
      String estLatex = "";

      if (hasDiv) {
        final List<String> divParts = clean.split('/');
        final List<double> numRaw = numReg
            .allMatches(divParts[0])
            .map((m) => double.parse(m.group(0)!))
            .toList();
        final List<double> denRaw = divParts.length > 1
            ? numReg
            .allMatches(divParts[1])
            .map((m) => double.parse(m.group(0)!))
            .toList()
            : [1.0];

        if (numRaw.isEmpty || denRaw.isEmpty) {
          throw const FormatException("Invalid division expression.");
        }

        final double exactTop = numRaw.fold(1.0, (a, b) => a * b);
        final double exactBot = denRaw.fold(1.0, (a, b) => a * b);
        exactResult = exactTop / exactBot;

        final List<double> numEst =
        numRaw.map((v) => roundToSF(v, 1)).toList();
        final List<double> denEst =
        denRaw.map((v) => roundToSF(v, 1)).toList();
        final double estTop = numEst.fold(1.0, (a, b) => a * b);
        final double estBot = denEst.fold(1.0, (a, b) => a * b);
        estResult = estTop / estBot;

        exactLatex =
        "\\frac{${numRaw.map((v) => fmt(v, maxDecimals: 3)).join(' \\times ')}}{${denRaw.map((v) => fmt(v, maxDecimals: 3)).join(' \\times ')}}";
        estLatex =
        "\\frac{${numEst.map(fmt).join(' \\times ')}}{${denEst.map(fmt).join(' \\times ')}} = \\frac{${fmt(estTop)}}{${fmt(estBot)}}";
      } else {
        exactResult = rawNums.fold(1.0, (a, b) => a * b);
        estResult = rounded1SFNums.fold(1.0, (a, b) => a * b);
        exactLatex =
            rawNums.map((v) => fmt(v, maxDecimals: 3)).join(' \\times ');
        estLatex = rounded1SFNums.map(fmt).join(' \\times ');
      }

      final double diff = (exactResult - estResult).abs();
      final double pctDiff =
      exactResult.abs() > 1e-9 ? (diff / exactResult.abs()) * 100.0 : 0.0;

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Round Every Number to 1 Significant Figure (1 s.f.)}}",
        roundingMappingsLatex.join(", \\quad "),
        "",
        "\\text{\\textbf{Step 2: Calculate the Rough Estimate}}",
        "\\text{Estimate} \\approx $estLatex = ${fmt(estResult)}",
        "",
        "\\text{\\textbf{Step 3: Exact Calculation and Reasonableness Check}}",
        "\\text{Exact Value} = $exactLatex = ${fmt(exactResult, maxDecimals: 2)}",
        "\\text{Exact Value (to 2 s.f.)} = ${fmtSF(exactResult, 2)}",
      ];

      final List<MensurationEstStep> steps = [
        MensurationEstStep(
          title: "Step 1: Round Each Number to 1 Significant Figure (1 s.f.)",
          description:
          "When estimating a mensuration calculation without a calculator, first round every number in the expression to 1 significant figure (keep only the first non-zero digit and look at the next digit to round up or down):\n"
              "${roundingMappingsPlain.join('\n')}",
          mathLaTeX: roundingMappingsLatex.join(" \\quad ; \\quad "),
        ),
        MensurationEstStep(
          title: "Step 2: Multiply / Divide the Rounded Numbers",
          description:
          "Substitute the 1 s.f. rounded numbers into the expression to get a quick mental estimate:\n"
              "• Rough Estimate ≈ ${fmt(estResult)}.",
          mathLaTeX: "\\text{Estimate} \\approx $estLatex = ${fmt(estResult)}",
        ),
        MensurationEstStep(
          title: "Step 3: Compare Estimate with the Exact Answer",
          description:
          "Now compute the exact answer and compare it with our rough estimate to check that the answer is reasonable (no misplaced decimal points!):\n"
              "• Exact Calculation = ${fmt(exactResult, maxDecimals: 2)}.\n"
              "• Rounded to 2 significant figures = ${fmtSF(exactResult, 2)}.\n"
              "• Difference = ${fmt(diff, maxDecimals: 2)} (${fmt(pctDiff, maxDecimals: 1)}% error — the estimate confirms our exact answer is in the right ballpark!).",
          mathLaTeX:
          "\\text{Exact} = $exactLatex = ${fmt(exactResult, maxDecimals: 2)} \\approx ${fmtSF(exactResult, 2)}\\text{ (to 2 s.f.)}",
        ),
      ];

      return MensurationEstResult(
        topicMode: 0,
        finalAnswers: {
          "1 s.f. Rough Estimate": fmt(estResult),
          "Exact Value": fmt(exactResult, maxDecimals: 2),
          "Exact (to 2 s.f.)": fmtSF(exactResult, 2),
          "Exact (to 3 s.f.)": fmtSF(exactResult, 3),
        },
        workingsLaTeX: workings,
        steps: steps,
      );
    } catch (e) {
      return MensurationEstResult.error(
        topicMode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid numeric expression (e.g. 3.1 * 4.8 * 9.2).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: Rounding Master (1 s.f., 2 s.f., 3 s.f., Nearest Whole, 1 d.p., 2 d.p.)
  // ===========================================================================
  static MensurationEstResult solveRoundingMaster({
    required String numberStr,
    required String unit,
  }) {
    try {
      final double? val =
      double.tryParse(numberStr.trim().replaceAll(',', ''));
      if (val == null) {
        throw const FormatException("Please enter a valid number to round.");
      }

      final String u = unit.trim().isEmpty ? "" : " ${unit.trim()}";
      final String texU =
      unit.trim().isEmpty ? "" : "\\text{ ${unit.trim()}}";

      final String sf1 = fmtSF(val, 1);
      final String sf2 = fmtSF(val, 2);
      final String sf3 = fmtSF(val, 3);
      final String dp0 = val.round().toString();
      final String dp1 = fmtDP(val, 1);
      final String dp2 = fmtDP(val, 2);

      final List<String> workings = [
        "\\text{\\textbf{Original Measurement: }} ${fmt(val, maxDecimals: 6)}$texU",
        "",
        "\\text{\\textbf{1. Rounding to Significant Figures (s.f.)}}",
        "\\bullet \\text{ To 1 significant figure (1 s.f.): } $sf1$texU",
        "\\bullet \\text{ To 2 significant figures (2 s.f.): } $sf2$texU",
        "\\bullet \\text{ To 3 significant figures (3 s.f.): } $sf3$texU",
        "",
        "\\text{\\textbf{2. Rounding to Decimal Places (d.p.) and Nearest Whole}}",
        "\\bullet \\text{ To nearest whole number: } $dp0$texU",
        "\\bullet \\text{ To 1 decimal place (1 d.p.): } $dp1$texU",
        "\\bullet \\text{ To 2 decimal places (2 d.p.): } $dp2$texU",
      ];

      final List<MensurationEstStep> steps = [
        MensurationEstStep(
          title: "Step 1: How to Round to Significant Figures (1 s.f., 2 s.f., 3 s.f.)",
          description:
          "Count from the FIRST non-zero digit on the left:\n"
              "• 1 s.f.: Keep the 1st significant digit and check the 2nd digit (if 5 or more, round up) → $sf1$u.\n"
              "• 2 s.f.: Keep the first 2 significant digits and check the 3rd digit → $sf2$u.\n"
              "• 3 s.f.: Keep the first 3 significant digits and check the 4th digit → $sf3$u.",
          mathLaTeX:
          "1\\text{ s.f.} = $sf1$texU, \\quad 2\\text{ s.f.} = $sf2$texU, \\quad 3\\text{ s.f.} = $sf3$texU",
        ),
        MensurationEstStep(
          title: "Step 2: How to Round to Decimal Places (Nearest Whole, 1 d.p., 2 d.p.)",
          description:
          "Count digits to the RIGHT of the decimal point:\n"
              "• Nearest whole number (0 d.p.): Look at the tenths digit → $dp0$u.\n"
              "• 1 decimal place (1 d.p.): Keep 1 digit after the decimal point → $dp1$u.\n"
              "• 2 decimal places (2 d.p.): Keep 2 digits after the decimal point → $dp2$u.",
          mathLaTeX:
          "\\text{Nearest Whole} = $dp0$texU, \\quad 1\\text{ d.p.} = $dp1$texU, \\quad 2\\text{ d.p.} = $dp2$texU",
        ),
      ];

      return MensurationEstResult(
        topicMode: 1,
        finalAnswers: {
          "1 s.f.": "$sf1$u",
          "2 s.f.": "$sf2$u",
          "3 s.f.": "$sf3$u",
          "Nearest Whole": "$dp0$u",
          "1 d.p.": "$dp1$u",
          "2 d.p.": "$dp2$u",
        },
        workingsLaTeX: workings,
        steps: steps,
        displayUnit: unit,
      );
    } catch (e) {
      return MensurationEstResult.error(
        topicMode: 1,
        message: "Please enter a valid number to round.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: Mensuration & Estimation Comparison (Cylinder, Cone, Composite)
  // Matches Example 8 (Basin of Rice) & Exercise 19h Mensuration Estimation
  // ===========================================================================
  static MensurationEstResult solveMensurationEstimation({
    required String shapeType, // 'cylinder', 'cone', 'composite'
    required String rStr,
    required String h1Str,
    required String h2Str,
    required String unit,
  }) {
    try {
      final double? r = double.tryParse(rStr.trim());
      final double? h1 = double.tryParse(h1Str.trim());
      if (r == null || h1 == null || r <= 0 || h1 <= 0) {
        throw const FormatException(
            "Enter positive numbers for the radius (r) and height (h).");
      }

      final double rEst = roundToSF(r, 1);
      final double h1Est = roundToSF(h1, 1);
      const double piEst = 3.0; // 1 s.f. approximation of pi used in Chapter 19 estimation
      const double piExact = 22.0 / 7.0;

      final List<String> workings = [];
      final List<MensurationEstStep> steps = [];
      final Map<String, String> answers = {};

      if (shapeType == 'cylinder') {
        final double volEst = piEst * rEst * rEst * h1Est;
        final double volExact = piExact * r * r * h1;

        final double tsaEst =
            (2 * piEst * rEst * rEst) + (2 * piEst * rEst * h1Est);
        final double tsaExact =
            (2 * piExact * r * r) + (2 * piExact * r * h1);

        workings.add(
            "\\text{\\textbf{1. Rough Estimate Using }} \\pi \\approx 3 \\text{\\textbf{ and 1 s.f. Dimensions}}");
        workings.add(
            "r = ${fmt(r)}\\text{ $unit} \\approx ${fmt(rEst)}\\text{ $unit}, \\quad h = ${fmt(h1)}\\text{ $unit} \\approx ${fmt(h1Est)}\\text{ $unit}, \\quad \\pi \\approx 3");
        workings.add(
            "V_{\\text{est}} = \\pi r^2 h \\approx 3 \\times ${fmt(rEst)}^2 \\times ${fmt(h1Est)} = 3 \\times ${fmt(rEst * rEst)} \\times ${fmt(h1Est)} = ${fmt(volEst)}\\text{ $unit}^3");
        workings.add(
            "\\text{TSA}_{\\text{est}} = 2\\pi r^2 + 2\\pi rh \\approx 2(3)(${fmt(rEst)}^2) + 2(3)(${fmt(rEst)})(${fmt(h1Est)}) = ${fmt(tsaEst)}\\text{ $unit}^2");
        workings.add("");
        workings.add(
            "\\text{\\textbf{2. Exact Calculation Using }} \\pi = \\frac{22}{7}");
        workings.add(
            "V_{\\text{exact}} = \\frac{22}{7} \\times ${fmt(r)}^2 \\times ${fmt(h1)} = ${fmt(volExact)}\\text{ $unit}^3 \\approx ${fmtSF(volExact, 2)}\\text{ $unit}^3 \\text{ (to 2 s.f.)}");
        workings.add(
            "\\text{TSA}_{\\text{exact}} = 2 \\times \\frac{22}{7} \\times ${fmt(r)}^2 + 2 \\times \\frac{22}{7} \\times ${fmt(r)} \\times ${fmt(h1)} = ${fmt(tsaExact)}\\text{ $unit}^2 \\approx ${fmtSF(tsaExact, 2)}\\text{ $unit}^2 \\text{ (to 2 s.f.)}");

        steps.add(MensurationEstStep(
          title: "Step 1: Estimate by Rounding π to 3 and Dimensions to 1 s.f.",
          description:
          "To quickly estimate the volume and surface area of the cylinder:\n"
              "1. Round π to 3, radius r = ${fmt(r)} $unit to ${fmt(rEst)} $unit (1 s.f.), and height h = ${fmt(h1)} $unit to ${fmt(h1Est)} $unit (1 s.f.).\n"
              "2. Estimated Volume ≈ 3 × ${fmt(rEst)}² × ${fmt(h1Est)} = ${fmt(volEst)} $unit³.\n"
              "3. Estimated Closed Surface Area ≈ 2(3)(${fmt(rEst)}²) + 2(3)(${fmt(rEst)})(${fmt(h1Est)}) = ${fmt(tsaEst)} $unit².",
          mathLaTeX:
          "V_{\\text{est}} \\approx 3 \\times ${fmt(rEst)}^2 \\times ${fmt(h1Est)} = ${fmt(volEst)}\\text{ $unit}^3\n"
              "\\text{TSA}_{\\text{est}} \\approx ${fmt(tsaEst)}\\text{ $unit}^2",
        ));

        steps.add(MensurationEstStep(
          title: "Step 2: Calculate Exact Values (π = 22/7) and Round to 2 s.f.",
          description:
          "Using the exact dimensions and π = 22/7:\n"
              "• Exact Volume = (22/7) × ${fmt(r)}² × ${fmt(h1)} = ${fmt(volExact)} $unit³ (or ${fmtSF(volExact, 2)} $unit³ to 2 s.f.).\n"
              "• Exact Total Surface Area = ${fmt(tsaExact)} $unit² (or ${fmtSF(tsaExact, 2)} $unit² to 2 s.f.).",
          mathLaTeX:
          "V_{\\text{exact}} = ${fmt(volExact)}\\text{ $unit}^3 \\approx ${fmtSF(volExact, 2)}\\text{ $unit}^3\\text{ (2 s.f.)}\n"
              "\\text{TSA}_{\\text{exact}} = ${fmt(tsaExact)}\\text{ $unit}^2 \\approx ${fmtSF(tsaExact, 2)}\\text{ $unit}^2\\text{ (2 s.f.)}",
        ));

        answers["Estimated Volume (π≈3)"] = "${fmt(volEst)} $unit³";
        answers["Exact Volume (π=22/7)"] = "${fmt(volExact)} $unit³";
        answers["Volume (to 2 s.f.)"] = "${fmtSF(volExact, 2)} $unit³";
        answers["Estimated TSA (π≈3)"] = "${fmt(tsaEst)} $unit²";
        answers["Exact TSA (to 2 s.f.)"] = "${fmtSF(tsaExact, 2)} $unit²";

        return MensurationEstResult(
          topicMode: 2,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          shapeType: 'cylinder',
          dim1Val: r,
          dim2Val: h1,
          displayUnit: unit,
        );
      } else if (shapeType == 'cone') {
        final double volEst = (1.0 / 3.0) * piEst * rEst * rEst * h1Est;
        final double volExact = (1.0 / 3.0) * piExact * r * r * h1;
        final double lExact = math.sqrt(r * r + h1 * h1);
        final double lEst = roundToSF(lExact, 1);
        final double csaEst = piEst * rEst * lEst;
        final double csaExact = piExact * r * lExact;

        workings.add(
            "\\text{\\textbf{1. Rough Estimate of Cone Using }} \\pi \\approx 3 \\text{\\textbf{ and 1 s.f.}}");
        workings.add(
            "r \\approx ${fmt(rEst)}\\text{ $unit}, \\quad h \\approx ${fmt(h1Est)}\\text{ $unit}, \\quad \\pi \\approx 3");
        workings.add(
            "V_{\\text{est}} = \\frac{1}{3}\\pi r^2 h \\approx \\frac{1}{3} \\times 3 \\times ${fmt(rEst)}^2 \\times ${fmt(h1Est)} = ${fmt(rEst * rEst)} \\times ${fmt(h1Est)} = ${fmt(volEst)}\\text{ $unit}^3");
        workings.add("");
        workings.add(
            "\\text{\\textbf{2. Exact Cone Volume and Curved Surface Area}}");
        workings.add(
            "V_{\\text{exact}} = \\frac{1}{3} \\times \\frac{22}{7} \\times ${fmt(r)}^2 \\times ${fmt(h1)} = ${fmt(volExact)}\\text{ $unit}^3 \\approx ${fmtSF(volExact, 2)}\\text{ $unit}^3 \\text{ (to 2 s.f.)}");
        workings.add(
            "l = \\sqrt{r^2 + h^2} = \\sqrt{${fmt(r * r + h1 * h1)}} = ${fmt(lExact)}\\text{ $unit} \\implies \\text{CSA} = \\pi r l = ${fmt(csaExact)}\\text{ $unit}^2");

        steps.add(MensurationEstStep(
          title: "Step 1: Notice How ⅓ and π ≈ 3 Cancel Out in Cone Estimation!",
          description:
          "When estimating the volume of a cone (V = ⅓πr²h) using π ≈ 3:\n"
              "1. Multiply ⅓ × 3 = 1! That means the rough volume of a cone is simply r² × h.\n"
              "2. Using 1 s.f. dimensions (r ≈ ${fmt(rEst)} $unit, h ≈ ${fmt(h1Est)} $unit):\n"
              "   Estimated Volume ≈ ${fmt(rEst)}² × ${fmt(h1Est)} = ${fmt(volEst)} $unit³.",
          mathLaTeX:
          "V_{\\text{est}} \\approx \\frac{1}{3} \\times 3 \\times ${fmt(rEst)}^2 \\times ${fmt(h1Est)} = ${fmt(volEst)}\\text{ $unit}^3",
        ));

        steps.add(MensurationEstStep(
          title: "Step 2: Calculate Exact Cone Volume & Slant Surface Area",
          description:
          "• Exact Volume (π = 22/7) = ${fmt(volExact)} $unit³ (or ${fmtSF(volExact, 2)} $unit³ to 2 s.f.).\n"
              "• Slant height l = √(${fmt(r)}² + ${fmt(h1)}²) = ${fmt(lExact)} $unit.\n"
              "• Exact Curved Surface Area = πrl = ${fmt(csaExact)} $unit² (Estimate ≈ ${fmt(csaEst)} $unit²).",
          mathLaTeX:
          "V_{\\text{exact}} = ${fmt(volExact)}\\text{ $unit}^3 \\approx ${fmtSF(volExact, 2)}\\text{ $unit}^3\\text{ (2 s.f.)}",
        ));

        answers["Estimated Volume (π≈3)"] = "${fmt(volEst)} $unit³";
        answers["Exact Volume (π=22/7)"] = "${fmt(volExact)} $unit³";
        answers["Volume (to 2 s.f.)"] = "${fmtSF(volExact, 2)} $unit³";
        answers["Exact CSA (πrl)"] = "${fmt(csaExact)} $unit²";

        return MensurationEstResult(
          topicMode: 2,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          shapeType: 'cone',
          dim1Val: r,
          dim2Val: h1,
          displayUnit: unit,
        );
      } else {
        // Composite Basin + Conical Mound (Example 8: r=15, h_cyl=8, h_cone=6)
        final double h2 = double.tryParse(h2Str.trim()) ?? 6.0;
        final double vCylPi3 = 3.0 * r * r * h1;
        final double vConePi3 = (1.0 / 3.0) * 3.0 * r * r * h2;
        final double totalPi3 = vCylPi3 + vConePi3;

        final double vCyl31 = 3.1 * r * r * h1;
        final double vCone31 = (1.0 / 3.0) * 3.1 * r * r * h2;
        final double total31 = vCyl31 + vCone31;

        workings.add(
            "\\text{\\textbf{1. Volume of Cylindrical Basin and Conical Mound (Example 8)}}");
        workings.add(
            "V_{\\text{basin (cylinder)}} = \\pi r^2 h_1 = \\pi \\times ${fmt(r)}^2 \\times ${fmt(h1)} = ${fmt(r * r * h1)}\\pi\\text{ $unit}^3");
        workings.add(
            "V_{\\text{mound (cone)}} = \\frac{1}{3}\\pi r^2 h_2 = \\frac{1}{3} \\times \\pi \\times ${fmt(r)}^2 \\times ${fmt(h2)} = ${fmt((r * r * h2) / 3.0)}\\pi\\text{ $unit}^3");
        workings.add(
            "V_{\\text{total}} = ${fmt(r * r * h1)}\\pi + ${fmt((r * r * h2) / 3.0)}\\pi = ${fmt(r * r * h1 + (r * r * h2) / 3.0)}\\pi\\text{ $unit}^3");
        workings.add("");
        workings.add(
            "\\text{\\textbf{2. Estimate Using }} \\pi \\approx 3 \\text{\\textbf{ vs. }} \\pi \\approx 3.1");
        workings.add(
            "\\bullet \\text{ Using } \\pi \\approx 3: \\quad V \\approx ${fmt(vCylPi3)} + ${fmt(vConePi3)} = ${fmt(totalPi3)}\\text{ $unit}^3");
        workings.add(
            "\\bullet \\text{ Using } \\pi \\approx 3.1: \\quad V \\approx ${fmt(total31)}\\text{ $unit}^3 \\approx ${fmtSF(total31, 2)}\\text{ $unit}^3 \\text{ (to 2 s.f.)}");

        steps.add(MensurationEstStep(
          title: "Step 1: Express Cylinder and Cone Volumes in Terms of π (Example 8)",
          description:
          "In Example 8 (Figure 19.28), the basin is a cylinder of radius r = ${fmt(r)} $unit and height h₁ = ${fmt(h1)} $unit, topped with a cone of height h₂ = ${fmt(h2)} $unit:\n"
              "• Volume of cylindrical basin = π × ${fmt(r)}² × ${fmt(h1)} = ${fmt(r * r * h1)}π $unit³.\n"
              "• Volume of conical mound = ⅓ × π × ${fmt(r)}² × ${fmt(h2)} = ${fmt((r * r * h2) / 3.0)}π $unit³.\n"
              "• Total Volume = ${fmt(r * r * h1)}π + ${fmt((r * r * h2) / 3.0)}π = ${fmt(r * r * h1 + (r * r * h2) / 3.0)}π $unit³.",
          mathLaTeX:
          "V_{\\text{total}} = ${fmt(r * r * h1)}\\pi + ${fmt((r * r * h2) / 3.0)}\\pi = ${fmt(r * r * h1 + (r * r * h2) / 3.0)}\\pi\\text{ $unit}^3",
        ));

        steps.add(MensurationEstStep(
          title: "Step 2: Substitute Approximate Values of π and Round to 2 s.f.",
          description:
          "Because the measurements of a mound of rice are approximate:\n"
              "• Using π ≈ 3 gives: ${fmt(r * r * h1 + (r * r * h2) / 3.0)} × 3 = ${fmt(totalPi3)} $unit³.\n"
              "• Using π ≈ 3.1 (as in Example 8) gives: ${fmt(r * r * h1 + (r * r * h2) / 3.0)} × 3.1 = ${fmt(total31)} $unit³ ≈ ${fmtSF(total31, 2)} $unit³ (to 2 s.f.).",
          mathLaTeX:
          "\\text{With } \\pi \\approx 3: \\; V \\approx ${fmt(totalPi3)}\\text{ $unit}^3\n"
              "\\text{With } \\pi \\approx 3.1: \\; V \\approx ${fmt(total31)}\\text{ $unit}^3 \\approx ${fmtSF(total31, 2)}\\text{ $unit}^3\\text{ (2 s.f.)}",
        ));

        answers["In Terms of π"] =
        "${fmt(r * r * h1 + (r * r * h2) / 3.0)}π $unit³";
        answers["Estimate (π ≈ 3)"] = "${fmt(totalPi3)} $unit³";
        answers["Estimate (π ≈ 3.1)"] = "${fmt(total31)} $unit³";
        answers["Rounded (to 2 s.f.)"] = "${fmtSF(total31, 2)} $unit³";

        return MensurationEstResult(
          topicMode: 2,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          shapeType: 'composite',
          dim1Val: r,
          dim2Val: h1,
          dim3Val: h2,
          displayUnit: unit,
        );
      }
    } catch (e) {
      return MensurationEstResult.error(
        topicMode: 2,
        message: e is FormatException
            ? e.message
            : "Please check your dimensions and try again.",
      );
    }
  }
}