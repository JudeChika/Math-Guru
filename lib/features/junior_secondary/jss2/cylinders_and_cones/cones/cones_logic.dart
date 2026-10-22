import 'dart:math' as math;
import 'cones_models.dart';

class ConesLogic {
  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  /// Formats decimals neatly, dropping trailing .0
  static String fmt(double v, {int maxDecimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Formats a positive number to 2 significant figures (matching Exercise 19e #1)
  static String fmt2SF(double v) {
    if (v == 0 || v.abs() < 1e-12) return "0";
    final int d = (math.log(v.abs()) / math.ln10).floor();
    final double scale = math.pow(10, 1 - d).toDouble();
    final double rounded = (v * scale).roundToDouble() / scale;
    if (1 - d <= 0) return rounded.round().toString();
    String str = rounded.toStringAsFixed(1 - d);
    if (str.endsWith('.0')) str = str.substring(0, str.length - 2);
    return str;
  }

  /// Parses inputs that might be whole numbers, decimals, or mixed fractions ("3 1/2")
  static double? parseInput(String input) {
    final String s = input.trim();
    if (s.isEmpty) return null;
    try {
      if (s.contains('/')) {
        if (s.contains(RegExp(r'\s+'))) {
          final List<String> parts = s.split(RegExp(r'\s+'));
          final double whole = double.parse(parts[0]);
          final List<String> fParts = parts[1].split('/');
          final double n = double.parse(fParts[0]);
          final double d = double.parse(fParts[1]);
          return whole < 0 ? whole - (n / d) : whole + (n / d);
        } else {
          final List<String> parts = s.split('/');
          final double n = double.parse(parts[0]);
          final double d = double.parse(parts[1]);
          return n / d;
        }
      }
      return double.parse(s.replaceAll(RegExp(r'[^\d\.\-]'), ''));
    } catch (_) {
      return null;
    }
  }

  /// Returns multiplier to convert FROM a given unit TO a target unit
  static double getConversion(String from, String to) {
    if (from == to) return 1.0;
    if (from == 'mm' && to == 'cm') return 0.1;
    if (from == 'mm' && to == 'm') return 0.001;
    if (from == 'cm' && to == 'mm') return 10.0;
    if (from == 'cm' && to == 'm') return 0.01;
    if (from == 'm' && to == 'mm') return 1000.0;
    if (from == 'm' && to == 'cm') return 100.0;
    return 1.0;
  }

  static double _harmonize(
      String label,
      double val,
      String fromUnit,
      String toUnit,
      List<String> workings,
      List<ConeStep> steps,
      ) {
    if (fromUnit == toUnit) return val;
    final double conv = getConversion(fromUnit, toUnit);
    final double newVal = val * conv;
    final String op =
    conv < 1 ? "\\div ${(1 / conv).round()}" : "\\times ${conv.toInt()}";
    final String plainOp = conv < 1
        ? "divide by ${(1 / conv).round()}"
        : "multiply by ${conv.toInt()}";
    final String rel = conv < 1
        ? "1 $toUnit = ${(1 / conv).round()} $fromUnit"
        : "1 $fromUnit = ${conv.toInt()} $toUnit";

    if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
    workings.add("\\text{\\textbf{Unit Conversion ($label)}}");
    workings.add(
        "\\text{Convert $label from $fromUnit to $toUnit: } ${fmt(val)}\\text{ $fromUnit} $op = ${fmt(newVal)}\\text{ $toUnit}");

    steps.add(ConeStep(
      title: "Convert $label to Target Unit ($toUnit)",
      description:
      "Before substituting into any cone formula, all dimensions must be in the same unit ($toUnit).\n"
          "• Recall that $rel.\n"
          "• To convert ${fmt(val)} $fromUnit to $toUnit, we $plainOp:\n"
          "  ${fmt(val)} $fromUnit → ${fmt(newVal)} $toUnit.",
      mathLaTeX:
      "\\text{$label} = ${fmt(val)}\\text{ $fromUnit} $op = ${fmt(newVal)}\\text{ $toUnit}",
    ));
    return newVal;
  }

  static double _processRadius(
      bool isRadius,
      double inputVal,
      String unit,
      List<String> workings,
      List<ConeStep> steps,
      ) {
    if (isRadius) return inputVal;
    final double r = inputVal / 2.0;
    if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
    workings.add("\\text{\\textbf{Find Base Radius (r) from Diameter (d)}}");
    workings.add(
        "r = \\frac{d}{2} = \\frac{${fmt(inputVal)}\\text{ $unit}}{2} = ${fmt(r)}\\text{ $unit}");

    steps.add(ConeStep(
      title: "Find the Base Radius (r) from the Diameter (d)",
      description:
      "Every cone formula uses the radius (r) of the circular base, which is half of the diameter (d).\n"
          "• Given base diameter (d) = ${fmt(inputVal)} $unit.\n"
          "• Divide the diameter by 2 to find the radius:\n"
          "  r = ${fmt(inputVal)} ÷ 2 = ${fmt(r)} $unit.",
      mathLaTeX:
      "r = \\frac{d}{2} = \\frac{${fmt(inputVal)}}{2} = ${fmt(r)}\\text{ $unit}",
    ));
    return r;
  }

  // ===========================================================================
  // MODE 0: Surface Area & Pythagoras (r, h, l) — Example 5 & Ex 19e #1, 3, 5–7
  // ===========================================================================
  static ConeResult solveSurfaceAreaAndPythagoras({
    required ConePiConfig pi,
    required int givenPairMode, // 0: Given r/d & h, 1: Given r/d & l, 2: Given l & h
    required bool isRadius,
    required String dimStr,
    required String dimUnit,
    required String secondStr, // h (if mode 0), l (if mode 1), or l (if mode 2)
    required String secondUnit,
    required String thirdStr, // h (used when mode 2: Given l & h)
    required String thirdUnit,
    required String targetUnit,
  }) {
    try {
      final List<ConeStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      double r = 0;
      double h = 0;
      double l = 0;

      if (givenPairMode == 0) {
        // Case A: Given Base Radius/Diameter and Vertical Height (h) -> Find Slant Height (l)
        final double? rawDim = parseInput(dimStr);
        final double? rawH = parseInput(secondStr);
        if (rawDim == null || rawH == null || rawDim <= 0 || rawH <= 0) {
          throw const FormatException(
              "Enter positive values for the base and vertical height (h).");
        }

        final double dimHarm = _harmonize(
          isRadius ? "Base Radius" : "Base Diameter",
          rawDim,
          dimUnit,
          targetUnit,
          workings,
          steps,
        );
        h = _harmonize(
            "Vertical Height (h)", rawH, secondUnit, targetUnit, workings, steps);
        r = _processRadius(isRadius, dimHarm, targetUnit, workings, steps);

        final double rSq = r * r;
        final double hSq = h * h;
        final double lSq = rSq + hSq;
        l = math.sqrt(lSq);

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{Pythagoras' Rule: Find Slant Height (l)}}");
        workings.add("l^2 = r^2 + h^2");
        workings.add("l^2 = ${fmt(r)}^2 + ${fmt(h)}^2 = ${fmt(rSq)} + ${fmt(hSq)} = ${fmt(lSq)}");
        workings.add(
            "l = \\sqrt{${fmt(lSq)}} = ${fmt(l)}\\text{ $targetUnit}"
                "${(l - l.roundToDouble()).abs() > 1e-9 ? ' \\approx ${fmt2SF(l)}\\text{ $targetUnit (to 2 s.f.)}' : ''}");

        steps.add(ConeStep(
          title:
          "Use Pythagoras' Rule to Find the Slant Height (l) (Figure 19.19)",
          description:
          "Inside a cone, the base radius (r), the vertical height (h), and the slant height (l) form a right-angled triangle where the slant height (l) is the hypotenuse:\n"
              "1. State Pythagoras' rule: l² = r² + h².\n"
              "2. Substitute r = ${fmt(r)} $targetUnit and h = ${fmt(h)} $targetUnit:\n"
              "   l² = ${fmt(r)}² + ${fmt(h)}² = ${fmt(rSq)} + ${fmt(hSq)} = ${fmt(lSq)}.\n"
              "3. Take the square root of ${fmt(lSq)}:\n"
              "   l = √${fmt(lSq)} = ${fmt(l)} $targetUnit (or ${fmt2SF(l)} $targetUnit to 2 s.f.).",
          mathLaTeX:
          "l^2 = r^2 + h^2 = ${fmt(r)}^2 + ${fmt(h)}^2 = ${fmt(rSq)} + ${fmt(hSq)} = ${fmt(lSq)}\n"
              "l = \\sqrt{${fmt(lSq)}} = ${fmt(l)}\\text{ $targetUnit}",
        ));

        answers["Slant Height (l)"] = "${fmt(l)} $targetUnit";
        if ((l - l.roundToDouble()).abs() > 1e-9) {
          answers["Slant Height (2 s.f.)"] = "${fmt2SF(l)} $targetUnit";
        }
      } else if (givenPairMode == 1) {
        // Case B: Given Base Radius/Diameter and Slant Height (l) -> Also find Vertical Height (h)
        final double? rawDim = parseInput(dimStr);
        final double? rawL = parseInput(secondStr);
        if (rawDim == null || rawL == null || rawDim <= 0 || rawL <= 0) {
          throw const FormatException(
              "Enter positive values for the base and slant height (l).");
        }

        final double dimHarm = _harmonize(
          isRadius ? "Base Radius" : "Base Diameter",
          rawDim,
          dimUnit,
          targetUnit,
          workings,
          steps,
        );
        l = _harmonize(
            "Slant Height (l)", rawL, secondUnit, targetUnit, workings, steps);
        r = _processRadius(isRadius, dimHarm, targetUnit, workings, steps);

        if (l <= r) {
          throw FormatException(
              "The slant height l (${fmt(l)} $targetUnit) is the hypotenuse and must be longer than the base radius r (${fmt(r)} $targetUnit).");
        }

        final double lSq = l * l;
        final double rSq = r * r;
        final double hSq = lSq - rSq;
        h = math.sqrt(hSq);

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{Pythagoras' Rule: Vertical Height (h) Check}}");
        workings.add("r^2 + h^2 = l^2 \\implies h^2 = l^2 - r^2");
        workings.add(
            "h^2 = ${fmt(l)}^2 - ${fmt(r)}^2 = ${fmt(lSq)} - ${fmt(rSq)} = ${fmt(hSq)}");
        workings.add("h = \\sqrt{${fmt(hSq)}} = ${fmt(h)}\\text{ $targetUnit}");

        steps.add(ConeStep(
          title: "Identify Given r & l (and Check Vertical Height h)",
          description:
          "We are directly given the base radius r = ${fmt(r)} $targetUnit and the slant height l = ${fmt(l)} $targetUnit.\n"
              "• Note: If you also need the vertical height (h), use Pythagoras' rule in reverse:\n"
              "  h² = l² − r² = ${fmt(l)}² − ${fmt(r)}² = ${fmt(lSq)} − ${fmt(rSq)} = ${fmt(hSq)} → h = √${fmt(hSq)} = ${fmt(h)} $targetUnit.",
          mathLaTeX:
          "r = ${fmt(r)}\\text{ $targetUnit}, \\quad l = ${fmt(l)}\\text{ $targetUnit}\n"
              "h = \\sqrt{l^2 - r^2} = \\sqrt{${fmt(lSq)} - ${fmt(rSq)}} = \\sqrt{${fmt(hSq)}} = ${fmt(h)}\\text{ $targetUnit}",
        ));

        answers["Vertical Height (h)"] = "${fmt(h)} $targetUnit";
      } else {
        // Case C: Given Slant Height (l) and Vertical Height (h) -> Find Base Radius (r) first! (Ex 19e #7d)
        final double? rawL = parseInput(secondStr);
        final double? rawH = parseInput(thirdStr);
        if (rawL == null || rawH == null || rawL <= 0 || rawH <= 0) {
          throw const FormatException(
              "Enter positive values for the slant height (l) and vertical height (h).");
        }

        l = _harmonize(
            "Slant Height (l)", rawL, secondUnit, targetUnit, workings, steps);
        h = _harmonize(
            "Vertical Height (h)", rawH, thirdUnit, targetUnit, workings, steps);

        if (l <= h) {
          throw FormatException(
              "The slant height l (${fmt(l)} $targetUnit) is the hypotenuse and must be greater than the vertical height h (${fmt(h)} $targetUnit).");
        }

        final double lSq = l * l;
        final double hSq = h * h;
        final double rSq = lSq - hSq;
        r = math.sqrt(rSq);

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{Pythagoras' Rule: Find Base Radius (r) from l and h}}");
        workings.add("r^2 + h^2 = l^2 \\implies r^2 = l^2 - h^2");
        workings.add(
            "r^2 = ${fmt(l)}^2 - ${fmt(h)}^2 = ${fmt(lSq)} - ${fmt(hSq)} = ${fmt(rSq)}");
        workings.add("r = \\sqrt{${fmt(rSq)}} = ${fmt(r)}\\text{ $targetUnit}");

        steps.add(ConeStep(
          title:
          "Use Pythagoras' Rule to Find the Unknown Base Radius (r) (Ex 19e #7d)",
          description:
          "The surface area formulas require the base radius (r), which is not given directly. Since r, h, and l form a right-angled triangle with hypotenuse l:\n"
              "1. Start with Pythagoras' rule: r² + h² = l².\n"
              "2. Subtract h² from both sides to isolate r²: r² = l² − h².\n"
              "3. Substitute l = ${fmt(l)} $targetUnit and h = ${fmt(h)} $targetUnit:\n"
              "   r² = ${fmt(l)}² − ${fmt(h)}² = ${fmt(lSq)} − ${fmt(hSq)} = ${fmt(rSq)}.\n"
              "4. Take the square root: r = √${fmt(rSq)} = ${fmt(r)} $targetUnit.",
          mathLaTeX:
          "r^2 = l^2 - h^2 = ${fmt(l)}^2 - ${fmt(h)}^2 = ${fmt(lSq)} - ${fmt(hSq)} = ${fmt(rSq)}\n"
              "r = \\sqrt{${fmt(rSq)}} = ${fmt(r)}\\text{ $targetUnit}",
        ));

        answers["Base Radius (r)"] = "${fmt(r)} $targetUnit";
      }

      // Now compute Curved Surface Area (CSA = πrl) and Total Surface Area (TSA = πrl + πr²)
      final double rlCoeff = r * l;
      final double rSqCoeff = r * r;
      final double tsaCoeff = rlCoeff + rSqCoeff;

      final double csaNum = pi.value * rlCoeff;
      final double baseAreaNum = pi.value * rSqCoeff;
      final double tsaNum = csaNum + baseAreaNum;

      if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
      workings.add("\\text{\\textbf{Curved Surface Area of Cone (CSA)}}");
      workings.add("\\text{CSA} = \\pi r l");

      if (pi.isSymbolic) {
        workings.add(
            "= \\pi \\times ${fmt(r)} \\times ${fmt(l)} = ${fmt(rlCoeff)}\\pi\\text{ $targetUnit}^2");
      } else {
        workings.add(
            "= ${pi.latex} \\times ${fmt(r)} \\times ${fmt(l)} = ${pi.latex} \\times ${fmt(rlCoeff)} = ${fmt(csaNum)}\\text{ $targetUnit}^2"
                " \\quad (${fmt(rlCoeff)}\\pi\\text{ $targetUnit}^2)");
      }

      steps.add(ConeStep(
        title: "Calculate the Curved Surface Area (CSA = πrl)",
        description:
        "The curved surface of an open cone has area equal to π × base radius (r) × slant height (l):\n"
            "1. Write the formula: CSA = πrl.\n"
            "2. Multiply r × l: ${fmt(r)} × ${fmt(l)} = ${fmt(rlCoeff)} $targetUnit².\n"
            "3. In terms of π: CSA = ${fmt(rlCoeff)}π $targetUnit².\n"
            "${pi.isSymbolic ? '' : '4. Substitute π = ${pi.text}: CSA = ${pi.text} × ${fmt(rlCoeff)} = ${fmt(csaNum)} $targetUnit².'}",
        mathLaTeX: pi.isSymbolic
            ? "\\text{CSA} = \\pi r l = \\pi \\times ${fmt(r)} \\times ${fmt(l)} = ${fmt(rlCoeff)}\\pi\\text{ $targetUnit}^2"
            : "\\text{CSA} = \\pi r l = ${pi.latex} \\times ${fmt(r)} \\times ${fmt(l)} = ${fmt(csaNum)}\\text{ $targetUnit}^2 \\; (${fmt(rlCoeff)}\\pi\\text{ $targetUnit}^2)",
      ));

      if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
      workings.add("\\text{\\textbf{Area of Circular Base}}");
      workings.add("\\text{Base Area} = \\pi r^2");
      if (pi.isSymbolic) {
        workings.add(
            "= \\pi \\times ${fmt(r)}^2 = ${fmt(rSqCoeff)}\\pi\\text{ $targetUnit}^2");
      } else {
        workings.add(
            "= ${pi.latex} \\times ${fmt(r)} \\times ${fmt(r)} = ${pi.latex} \\times ${fmt(rSqCoeff)} = ${fmt(baseAreaNum)}\\text{ $targetUnit}^2"
                " \\quad (${fmt(rSqCoeff)}\\pi\\text{ $targetUnit}^2)");
      }

      steps.add(ConeStep(
        title: "Calculate the Area of the Circular Base (πr²)",
        description:
        "A solid (closed) cone has a flat circular base of radius r = ${fmt(r)} $targetUnit:\n"
            "1. Square the radius: r² = ${fmt(r)} × ${fmt(r)} = ${fmt(rSqCoeff)} $targetUnit².\n"
            "2. In terms of π: Base Area = ${fmt(rSqCoeff)}π $targetUnit².\n"
            "${pi.isSymbolic ? '' : '3. Substitute π = ${pi.text}: Base Area = ${pi.text} × ${fmt(rSqCoeff)} = ${fmt(baseAreaNum)} $targetUnit².'}",
        mathLaTeX: pi.isSymbolic
            ? "\\text{Base Area} = \\pi r^2 = \\pi \\times ${fmt(r)}^2 = ${fmt(rSqCoeff)}\\pi\\text{ $targetUnit}^2"
            : "\\text{Base Area} = \\pi r^2 = ${pi.latex} \\times ${fmt(rSqCoeff)} = ${fmt(baseAreaNum)}\\text{ $targetUnit}^2 \\; (${fmt(rSqCoeff)}\\pi\\text{ $targetUnit}^2)",
      ));

      if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
      workings.add("\\text{\\textbf{Total Surface Area of Solid Cone (TSA)}}");
      workings.add("\\text{TSA} = \\pi r l + \\pi r^2");
      if (pi.isSymbolic) {
        workings.add(
            "= ${fmt(rlCoeff)}\\pi + ${fmt(rSqCoeff)}\\pi = ${fmt(tsaCoeff)}\\pi\\text{ $targetUnit}^2");
      } else {
        workings.add(
            "= ${fmt(csaNum)} + ${fmt(baseAreaNum)} = ${fmt(tsaNum)}\\text{ $targetUnit}^2"
                " \\quad (${fmt(tsaCoeff)}\\pi\\text{ $targetUnit}^2)");
        workings.add(
            "\\approx ${tsaNum.round()}\\text{ $targetUnit}^2 \\text{ (to nearest $targetUnit}^2\\text{)}");
      }

      steps.add(ConeStep(
        title: "Add Curved Surface and Base for Total Surface Area (TSA)",
        description:
        "The total surface area of a solid cone is the sum of its curved surface area (πrl) and its circular base area (πr²):\n"
            "1. Formula: TSA = πrl + πr² (or factored as πr(l + r)).\n"
            "2. In terms of π (Example 5b): ${fmt(rlCoeff)}π + ${fmt(rSqCoeff)}π = ${fmt(tsaCoeff)}π $targetUnit².\n"
            "${pi.isSymbolic ? '' : '3. Using π = ${pi.text}: ${fmt(csaNum)} + ${fmt(baseAreaNum)} = ${fmt(tsaNum)} $targetUnit².\n4. Rounded to the nearest whole $targetUnit² (as in Ex 19e #7): ${tsaNum.round()} $targetUnit².'}",
        mathLaTeX: pi.isSymbolic
            ? "\\text{TSA} = \\pi r l + \\pi r^2 = ${fmt(rlCoeff)}\\pi + ${fmt(rSqCoeff)}\\pi = ${fmt(tsaCoeff)}\\pi\\text{ $targetUnit}^2"
            : "\\text{TSA} = ${fmt(csaNum)} + ${fmt(baseAreaNum)} = ${fmt(tsaNum)}\\text{ $targetUnit}^2 \\approx ${tsaNum.round()}\\text{ $targetUnit}^2",
      ));

      if (pi.isSymbolic) {
        answers["Curved Surface Area"] = "${fmt(rlCoeff)}π $targetUnit²";
        answers["Circular Base Area"] = "${fmt(rSqCoeff)}π $targetUnit²";
        answers["Total Surface Area"] = "${fmt(tsaCoeff)}π $targetUnit²";
      } else {
        answers["Curved Surface Area"] = "${fmt(csaNum)} $targetUnit²";
        answers["CSA (In terms of π)"] = "${fmt(rlCoeff)}π $targetUnit²";
        answers["Total Surface Area"] = "${fmt(tsaNum)} $targetUnit²";
        answers["TSA (Nearest $targetUnit²)"] = "${tsaNum.round()} $targetUnit²";
      }

      final double thetaDeg = (r / l) * 360.0;
      return ConeResult(
        mode: 0,
        subMode: givenPairMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        r: r,
        h: h,
        l: l,
        thetaDeg: thetaDeg,
        displayUnit: targetUnit,
      );
    } catch (e) {
      return ConeResult.error(
        mode: 0,
        subMode: givenPairMode,
        message: e is FormatException
            ? e.message
            : "Please check your cone dimensions and try again.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: Sector of a Circle <-> Cone Net (Example 6, Ex 19d, Ex 19e #2 & #4)
  // ===========================================================================
  static ConeResult solveSectorAndNet({
    required ConePiConfig pi,
    required int subMode, // 0: Fold Sector (R, θ) into Cone, 1: Unfold Cone (r, l) into Sector Net
    required String sectorRadiusStr, // R (= l) for subMode 0
    required String sectorAngleStr, // θ for subMode 0
    required bool isRadius,
    required String coneDimStr, // r or d for subMode 1
    required String coneSlantStr, // l for subMode 1
    required String unit,
  }) {
    try {
      final List<ConeStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      if (subMode == 0) {
        // Fold a Sector of radius R and central angle θ into a Cone
        final double? R = parseInput(sectorRadiusStr);
        final double? theta = parseInput(sectorAngleStr);
        if (R == null || theta == null || R <= 0 || theta <= 0 || theta >= 360) {
          throw const FormatException(
              "Enter a positive sector radius (R) and a sector angle (θ) between 1° and 359°.");
        }

        final double l = R;
        final double r = (theta / 360.0) * l;
        final double h = math.sqrt(math.max(0.0, l * l - r * r));

        // Simplify fraction θ / 360 if integer
        String simpFracLatex = "\\frac{${fmt(theta)}}{360}";
        String simpFracPlain = "${fmt(theta)}/360";
        if ((theta - theta.roundToDouble()).abs() < 1e-9) {
          final int g = _gcd(theta.round(), 360);
          if (g > 1) {
            simpFracLatex = "\\frac{${theta.round() ~/ g}}{${360 ~/ g}}";
            simpFracPlain = "${theta.round() ~/ g}/${360 ~/ g}";
          }
        }

        workings.add(
            "\\text{\\textbf{1. Slant Height of Cone from Sector Radius}}");
        workings.add(
            "\\text{Slant height of cone } (l) = \\text{Radius of sector } (R) = ${fmt(l)}\\text{ $unit}");

        steps.add(ConeStep(
          title: "Step 1: Identify the Slant Height (l) from the Sector Radius",
          description:
          "When a sector of a circle is bent to form the curved surface of an open cone (Figures 19.18 & 19.20):\n"
              "• The centre of the sector becomes the vertex (tip) of the cone.\n"
              "• The radius of the sector (${fmt(R)} $unit) becomes the slant height (l) of the cone:\n"
              "  l = ${fmt(l)} $unit.",
          mathLaTeX: "l = R = ${fmt(l)}\\text{ $unit}",
        ));

        workings.add("");
        workings.add(
            "\\text{\\textbf{2. Find Base Radius (r) by Equating Circumference and Arc Length}}");
        workings.add(
            "\\text{Circumference of cone's base} = \\text{Length of arc of sector}");
        workings.add(
            "2\\pi r = \\frac{\\theta}{360^\\circ} \\times 2\\pi l = \\frac{${fmt(theta)}^\\circ}{360^\\circ} \\times 2\\pi \\times ${fmt(l)}");
        workings.add("\\text{Divide both sides by } 2\\pi:");
        workings.add(
            "r = \\frac{${fmt(theta)}}{360} \\times ${fmt(l)} = $simpFracLatex \\times ${fmt(l)} = ${fmt(r)}\\text{ $unit}");

        steps.add(ConeStep(
          title:
          "Step 2: Equate Base Circumference to Sector Arc Length (Example 6a)",
          description:
          "The curved arc of the sector curls around to form the circular base perimeter of the cone:\n"
              "1. Circumference of cone base = 2πr.\n"
              "2. Length of sector arc = (θ / 360°) × 2πl = (${fmt(theta)}° / 360°) × 2π × ${fmt(l)}.\n"
              "3. Set them equal: 2πr = (${fmt(theta)} / 360) × 2π × ${fmt(l)}.\n"
              "4. Divide both sides by 2π so 2π cancels out cleanly:\n"
              "   r = (${fmt(theta)} / 360) × ${fmt(l)} = $simpFracPlain × ${fmt(l)} = ${fmt(r)} $unit.",
          mathLaTeX:
          "2\\pi r = \\frac{${fmt(theta)}^\\circ}{360^\\circ} \\times 2\\pi \\times ${fmt(l)}\n"
              "r = $simpFracLatex \\times ${fmt(l)} = ${fmt(r)}\\text{ $unit}",
        ));

        final double rlCoeff = r * l;
        final double rSqCoeff = r * r;
        final double tsaCoeff = rlCoeff + rSqCoeff;
        final double csaNum = pi.value * rlCoeff;
        final double tsaNum = pi.value * tsaCoeff;

        workings.add("");
        workings.add(
            "\\text{\\textbf{3. Curved Surface Area & Total Surface Area (Ex 19e \\#4)}}");
        workings.add(
            "\\text{Curved Surface Area (Open Cone)} = \\pi r l = \\pi \\times ${fmt(r)} \\times ${fmt(l)} = ${fmt(rlCoeff)}\\pi\\text{ $unit}^2");
        workings.add(
            "\\text{Base Circle Area} = \\pi r^2 = \\pi \\times ${fmt(r)}^2 = ${fmt(rSqCoeff)}\\pi\\text{ $unit}^2");
        workings.add(
            "\\text{Total Surface Area (Solid Cone)} = ${fmt(rlCoeff)}\\pi + ${fmt(rSqCoeff)}\\pi = ${fmt(tsaCoeff)}\\pi\\text{ $unit}^2");
        if (!pi.isSymbolic) {
          workings.add(
              "\\text{Using } \\pi = ${pi.latex}: \\quad \\text{CSA} = ${fmt(csaNum)}\\text{ $unit}^2, \\quad \\text{TSA} = ${fmt(tsaNum)}\\text{ $unit}^2");
        }

        steps.add(ConeStep(
          title:
          "Step 3: Calculate Curved Surface Area & Total Surface Area (Example 6b & Ex 19e #4)",
          description:
          "Now that we know the base radius r = ${fmt(r)} $unit and slant height l = ${fmt(l)} $unit:\n"
              "1. Curved Surface Area (CSA) = πrl = π × ${fmt(r)} × ${fmt(l)} = ${fmt(rlCoeff)}π $unit²"
              "${pi.isSymbolic ? '.' : ' (= ${fmt(csaNum)} $unit²).'}\n"
              "2. Notice that the sector area formula (θ / 360°) × πl² = ($simpFracPlain) × π × ${fmt(l * l)} also gives ${fmt(rlCoeff)}π $unit²!\n"
              "3. If a circular base (πr² = ${fmt(rSqCoeff)}π $unit²) is added to make a solid cone (Ex 19e #4):\n"
              "   Total Surface Area (TSA) = ${fmt(rlCoeff)}π + ${fmt(rSqCoeff)}π = ${fmt(tsaCoeff)}π $unit²"
              "${pi.isSymbolic ? '.' : ' (= ${fmt(tsaNum)} $unit²).'}",
          mathLaTeX:
          "\\text{CSA} = \\pi r l = \\pi \\times ${fmt(r)} \\times ${fmt(l)} = ${fmt(rlCoeff)}\\pi\\text{ $unit}^2\n"
              "\\text{TSA} = \\pi r l + \\pi r^2 = ${fmt(rlCoeff)}\\pi + ${fmt(rSqCoeff)}\\pi = ${fmt(tsaCoeff)}\\pi\\text{ $unit}^2",
        ));

        workings.add("");
        workings.add("\\text{\\textbf{4. Vertical Height (h) of the Formed Cone}}");
        workings.add(
            "h = \\sqrt{l^2 - r^2} = \\sqrt{${fmt(l)}^2 - ${fmt(r)}^2} = \\sqrt{${fmt(l * l - r * r)}} = ${fmt(h)}\\text{ $unit}");

        steps.add(ConeStep(
          title: "Step 4: Find the Vertical Height (h) Using Pythagoras' Rule",
          description:
          "Using Pythagoras' rule (h² = l² − r²) on the cone's right-angled triangle:\n"
              "• h = √(${fmt(l)}² − ${fmt(r)}²) = √(${fmt(l * l)} − ${fmt(r * r)}) = √${fmt(l * l - r * r)} = ${fmt(h)} $unit.",
          mathLaTeX:
          "h = \\sqrt{l^2 - r^2} = \\sqrt{${fmt(l * l)} - ${fmt(r * r)}} = ${fmt(h)}\\text{ $unit}",
        ));

        answers["Cone Slant Height (l)"] = "${fmt(l)} $unit";
        answers["Cone Base Radius (r)"] = "${fmt(r)} $unit";
        answers["Curved Surface Area"] = pi.isSymbolic
            ? "${fmt(rlCoeff)}π $unit²"
            : "${fmt(csaNum)} $unit² (${fmt(rlCoeff)}π)";
        answers["Total Surface Area"] = pi.isSymbolic
            ? "${fmt(tsaCoeff)}π $unit²"
            : "${fmt(tsaNum)} $unit² (${fmt(tsaCoeff)}π)";
        answers["Cone Vertical Height (h)"] = "${fmt(h)} $unit";

        return ConeResult(
          mode: 1,
          subMode: 0,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r,
          h: h,
          l: l,
          thetaDeg: theta,
          displayUnit: unit,
        );
      } else {
        // Unfold a Cone (given r/d and l) into its Sector Net
        final double? rawDim = parseInput(coneDimStr);
        final double? l = parseInput(coneSlantStr);
        if (rawDim == null || l == null || rawDim <= 0 || l <= 0) {
          throw const FormatException(
              "Enter positive values for the cone base and slant height (l).");
        }

        final double r = _processRadius(isRadius, rawDim, unit, workings, steps);
        if (r >= l) {
          throw FormatException(
              "The base radius r (${fmt(r)} $unit) must be smaller than the slant height l (${fmt(l)} $unit).");
        }

        final double theta = (r / l) * 360.0;
        final double h = math.sqrt(l * l - r * r);
        final double arcLen = 2 * pi.value * r;

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{1. Sector Radius (R) and Arc Length}}");
        workings.add("\\text{Sector Radius } (R) = \\text{Slant Height } (l) = ${fmt(l)}\\text{ $unit}");
        workings.add(
            "\\text{Arc Length} = 2\\pi r = 2 \\times ${pi.latex} \\times ${fmt(r)} = "
                "${pi.isSymbolic ? '${fmt(2 * r)}\\pi' : fmt(arcLen)}\\text{ $unit}");

        workings.add("");
        workings.add("\\text{\\textbf{2. Sector Central Angle (\\theta)}}");
        workings.add(
            "\\frac{\\theta}{360^\\circ} = \\frac{r}{l} \\implies \\theta = \\frac{${fmt(r)}}{${fmt(l)}} \\times 360^\\circ = ${fmt(theta, maxDecimals: 1)}^\\circ");

        steps.add(ConeStep(
          title: "Find the Sector Radius (R) and Central Angle (θ) of the Net",
          description:
          "When you cut open a cone of base radius r = ${fmt(r)} $unit and slant height l = ${fmt(l)} $unit to make its flat net (Figure 19.22):\n"
              "1. The radius of the sector is equal to the slant height: R = l = ${fmt(l)} $unit.\n"
              "2. Since r / l = θ / 360°, multiply (r ÷ l) by 360° to find the sector angle:\n"
              "   θ = (${fmt(r)} ÷ ${fmt(l)}) × 360° = ${fmt(theta, maxDecimals: 1)}°.",
          mathLaTeX:
          "R = l = ${fmt(l)}\\text{ $unit}\n"
              "\\theta = \\frac{r}{l} \\times 360^\\circ = \\frac{${fmt(r)}}{${fmt(l)}} \\times 360^\\circ = ${fmt(theta, maxDecimals: 1)}^\\circ",
        ));

        answers["Sector Radius (R = l)"] = "${fmt(l)} $unit";
        answers["Sector Angle (θ)"] = "${fmt(theta, maxDecimals: 1)}°";
        answers["Arc Length (2πr)"] =
        pi.isSymbolic ? "${fmt(2 * r)}π $unit" : "${fmt(arcLen)} $unit";

        return ConeResult(
          mode: 1,
          subMode: 1,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r,
          h: h,
          l: l,
          thetaDeg: theta,
          displayUnit: unit,
        );
      }
    } catch (e) {
      return ConeResult.error(
        mode: 1,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please check your sector and cone values.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: Volume, Capacity & Mass of a Cone (Fig 19.24 & Ex 19g #1–2)
  // ===========================================================================
  static ConeResult solveVolumeAndMass({
    required ConePiConfig pi,
    required bool isRadius,
    required String dimStr,
    required String dimUnit,
    required bool isVerticalHeight, // true: given h, false: given slant height l
    required String heightOrSlantStr,
    required String heightUnit,
    required String targetUnit,
    required String densityStr,
  }) {
    try {
      final double? rawDim = parseInput(dimStr);
      final double? rawHOrL = parseInput(heightOrSlantStr);
      if (rawDim == null || rawHOrL == null || rawDim <= 0 || rawHOrL <= 0) {
        throw const FormatException(
            "Enter positive values for the base and height.");
      }

      final List<ConeStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      final double dimHarm = _harmonize(
        isRadius ? "Base Radius" : "Base Diameter",
        rawDim,
        dimUnit,
        targetUnit,
        workings,
        steps,
      );
      final double hOrLHarm = _harmonize(
        isVerticalHeight ? "Vertical Height (h)" : "Slant Height (l)",
        rawHOrL,
        heightUnit,
        targetUnit,
        workings,
        steps,
      );
      final double r =
      _processRadius(isRadius, dimHarm, targetUnit, workings, steps);

      double h = hOrLHarm;
      double l = 0;

      if (!isVerticalHeight) {
        l = hOrLHarm;
        if (l <= r) {
          throw FormatException(
              "Slant height l (${fmt(l)} $targetUnit) must be greater than base radius r (${fmt(r)} $targetUnit).");
        }
        final double hSq = l * l - r * r;
        h = math.sqrt(hSq);

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{Find Vertical Height (h) Using Pythagoras' Rule}}");
        workings.add(
            "h^2 = l^2 - r^2 = ${fmt(l)}^2 - ${fmt(r)}^2 = ${fmt(l * l)} - ${fmt(r * r)} = ${fmt(hSq)}");
        workings.add("h = \\sqrt{${fmt(hSq)}} = ${fmt(h)}\\text{ $targetUnit}");

        steps.add(ConeStep(
          title: "Find Vertical Height (h) from Slant Height (l)",
          description:
          "The volume formula of a cone requires the perpendicular vertical height (h), not the slant height (l).\n"
              "• By Pythagoras' rule: h² = l² − r² = ${fmt(l)}² − ${fmt(r)}² = ${fmt(l * l)} − ${fmt(r * r)} = ${fmt(hSq)}.\n"
              "• h = √${fmt(hSq)} = ${fmt(h)} $targetUnit.",
          mathLaTeX:
          "h = \\sqrt{l^2 - r^2} = \\sqrt{${fmt(l * l)} - ${fmt(r * r)}} = ${fmt(h)}\\text{ $targetUnit}",
        ));
      } else {
        l = math.sqrt(r * r + h * h);
      }

      final double rSq = r * r;
      final double oneThirdR2H = (rSq * h) / 3.0;
      final double volNum = (1.0 / 3.0) * pi.value * rSq * h;

      if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
      workings.add("\\text{\\textbf{Volume of Cone Formula (Figure 19.24)}}");
      workings.add(
          "V = \\frac{1}{3} \\times \\text{Base Area} \\times \\text{Height} = \\frac{1}{3}\\pi r^2 h");

      if (pi.isSymbolic) {
        workings.add(
            "= \\frac{1}{3} \\times \\pi \\times ${fmt(r)} \\times ${fmt(r)} \\times ${fmt(h)}");
        workings.add(
            "= \\frac{1}{3} \\times ${fmt(rSq * h)}\\pi = ${fmt(oneThirdR2H)}\\pi\\text{ $targetUnit}^3");
      } else {
        workings.add(
            "= \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(r)} \\times ${fmt(r)} \\times ${fmt(h)}");
        workings.add(
            "= \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h)} = ${fmt(volNum)}\\text{ $targetUnit}^3");
      }

      steps.add(ConeStep(
        title: "Calculate the Volume of the Cone (V = ⅓πr²h)",
        description:
        "A cone is a pointed solid whose volume is exactly one-third (⅓) of the volume of a cylinder with the same base area and height (Exercise 19f #5):\n"
            "1. Formula: V = ⅓ × Base Area × Height = ⅓πr²h.\n"
            "2. Square the radius: r² = ${fmt(r)} × ${fmt(r)} = ${fmt(rSq)} $targetUnit².\n"
            "3. Multiply by h (${fmt(h)} $targetUnit) and divide by 3:\n"
            "   ⅓ × ${fmt(rSq)} × ${fmt(h)} = ${fmt(oneThirdR2H)}.\n"
            "4. Multiply by π (${pi.text}): Volume = ${pi.isSymbolic ? '${fmt(oneThirdR2H)}π' : fmt(volNum)} $targetUnit³.",
        mathLaTeX: pi.isSymbolic
            ? "V = \\frac{1}{3}\\pi r^2 h = \\frac{1}{3} \\times \\pi \\times ${fmt(rSq)} \\times ${fmt(h)} = ${fmt(oneThirdR2H)}\\pi\\text{ $targetUnit}^3"
            : "V = \\frac{1}{3}\\pi r^2 h = \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(r)} \\times ${fmt(r)} \\times ${fmt(h)} = ${fmt(volNum)}\\text{ $targetUnit}^3",
      ));

      if (pi.isSymbolic) {
        answers["Volume of Cone"] = "${fmt(oneThirdR2H)}π $targetUnit³";
        answers["Volume (Decimal)"] = "${fmt(volNum)} $targetUnit³";
      } else {
        answers["Volume of Cone"] = "${fmt(volNum)} $targetUnit³";
      }

      // Capacity in Litres
      if (!pi.isSymbolic && targetUnit == 'cm') {
        final double litres = volNum / 1000.0;
        workings.add("");
        workings.add("\\text{\\textbf{Capacity in Litres}}");
        workings.add(
            "\\text{Since } 1,000\\text{ cm}^3 = 1\\text{ litre } (\\ell): \\quad \\text{Capacity} = \\frac{${fmt(volNum)}}{1000} = ${fmt(litres, maxDecimals: 3)}\\text{ }\\ell");
        answers["Capacity (Litres)"] = "${fmt(litres, maxDecimals: 3)} ℓ";

        steps.add(ConeStep(
          title: "Convert Volume (cm³) to Capacity in Litres (ℓ)",
          description:
          "Since 1,000 cm³ = 1 litre (ℓ), divide the volume in cm³ by 1,000:\n"
              "• Capacity = ${fmt(volNum)} ÷ 1,000 = ${fmt(litres, maxDecimals: 3)} litres.",
          mathLaTeX:
          "\\text{Capacity} = \\frac{${fmt(volNum)}}{1000} = ${fmt(litres, maxDecimals: 3)}\\text{ }\\ell",
        ));
      }

      // Optional Mass from Density
      final double? density = parseInput(densityStr);
      if (density != null && density > 0) {
        final double massG = volNum * density;
        workings.add("");
        workings.add("\\text{\\textbf{Mass of Cone from Density}}");
        workings.add(
            "\\text{Mass} = \\text{Volume} \\times \\text{Density} = ${fmt(volNum)} \\times ${fmt(density)} = ${fmt(massG)}\\text{ g}");
        if (massG >= 1000) {
          final double massKg = massG / 1000.0;
          workings.add(
              "\\text{Convert grams to kilograms (}\\div 1,000\\text{): } \\frac{${fmt(massG)}}{1000} = ${fmt(massKg, maxDecimals: 3)}\\text{ kg}");
          answers["Mass (kg)"] = "${fmt(massKg, maxDecimals: 3)} kg";
        } else {
          answers["Mass (g)"] = "${fmt(massG)} g";
        }

        steps.add(ConeStep(
          title: "Calculate Mass from Density",
          description:
          "Multiply the volume (${fmt(volNum)} $targetUnit³) by the density (${fmt(density)} g/$targetUnit³):\n"
              "• Mass = ${fmt(volNum)} × ${fmt(density)} = ${fmt(massG)} g"
              "${massG >= 1000 ? ' = ${fmt(massG / 1000.0, maxDecimals: 3)} kg.' : '.'}",
          mathLaTeX:
          "\\text{Mass} = ${fmt(volNum)} \\times ${fmt(density)} = ${fmt(massG)}\\text{ g}"
              "${massG >= 1000 ? ' = ${fmt(massG / 1000.0, maxDecimals: 3)}\\text{ kg}' : ''}",
        ));
      }

      return ConeResult(
        mode: 2,
        subMode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        r: r,
        h: h,
        l: l,
        displayUnit: targetUnit,
      );
    } catch (e) {
      return ConeResult.error(
        mode: 2,
        subMode: 0,
        message: e is FormatException
            ? e.message
            : "Please check your volume dimensions.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: Composite Conical Solids (Examples 7 & 8, Ex 19g #4 & #5)
  // ===========================================================================
  static ConeResult solveCompositeSolid({
    required ConePiConfig pi,
    required int subMode,
    // 0: Double Cone Joined at Base (Example 7, Fig 19.25)
    // 1: Cylinder + Conical Mound on Top (Example 8 & Ex 19g #4, Figs 19.26 & 19.28)
    // 2: Cylinder with Cones at Both Ends (Sharpened Pencil, Ex 19g #5, Fig 19.27)
    required bool isRadius,
    required String dimStr,
    required String h1Str, // h1 (Cone 1 height OR Cylinder height/length)
    required String h2Str, // h2 (Cone 2 height OR Conical mound/tip height)
    required String unit,
    required String densityStr,
  }) {
    try {
      final double? rawDim = parseInput(dimStr);
      final double? h1 = parseInput(h1Str);
      final double? h2 = parseInput(h2Str);
      if (rawDim == null ||
          h1 == null ||
          h2 == null ||
          rawDim <= 0 ||
          h1 <= 0 ||
          h2 <= 0) {
        throw const FormatException(
            "Enter positive values for the base and both heights.");
      }

      final List<ConeStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      final double r = _processRadius(isRadius, rawDim, unit, workings, steps);
      final double rSq = r * r;
      double totalVol = 0;

      if (subMode == 0) {
        // Double Cone Joined at Base (Example 7: Machine Part, Fig 19.25)
        final double sumH = h1 + h2;
        final double v1 = (1.0 / 3.0) * pi.value * rSq * h1;
        final double v2 = (1.0 / 3.0) * pi.value * rSq * h2;
        totalVol = (1.0 / 3.0) * pi.value * rSq * sumH;

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{1. Volume of Double-Cone Solid (Factorisation Method — Example 7)}}");
        workings.add(
            "V_{\\text{total}} = \\frac{1}{3}\\pi r^2 h_1 + \\frac{1}{3}\\pi r^2 h_2");
        workings.add(
            "= \\frac{1}{3} \\times \\pi \\times ${fmt(r)}^2 \\times ${fmt(h1)} + \\frac{1}{3} \\times \\pi \\times ${fmt(r)}^2 \\times ${fmt(h2)}");
        workings.add(
            "\\text{Factor out } \\frac{1}{3}\\pi r^2 \\text{ to simplify the arithmetic:}");
        workings.add(
            "= \\frac{1}{3} \\times \\pi \\times ${fmt(rSq)}(${fmt(h1)} + ${fmt(h2)})");
        workings.add(
            "= \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(sumH)} = ${fmt(totalVol)}\\text{ $unit}^3");

        steps.add(ConeStep(
          title:
          "Add the Two Cones Using the Factorisation Shortcut (Example 7a)",
          description:
          "The machine part (Figure 19.25) is made of two cones sharing the same circular base of radius r = ${fmt(r)} $unit, with heights h₁ = ${fmt(h1)} $unit and h₂ = ${fmt(h2)} $unit:\n"
              "1. Formula: V = ⅓πr²h₁ + ⅓πr²h₂.\n"
              "2. Factorisation Shortcut (Example 7): Factor out ⅓πr² so you only multiply by π once!\n"
              "   V = ⅓πr²(h₁ + h₂) = ⅓ × ${pi.text} × ${fmt(r)}² × (${fmt(h1)} + ${fmt(h2)}).\n"
              "3. Simplify: ⅓ × ${pi.text} × ${fmt(rSq)} × ${fmt(sumH)} = ${fmt(totalVol)} $unit³.\n"
              "   (Individual cones: V₁ = ${fmt(v1)} $unit³, V₂ = ${fmt(v2)} $unit³).",
          mathLaTeX:
          "V = \\frac{1}{3}\\pi r^2 h_1 + \\frac{1}{3}\\pi r^2 h_2 = \\frac{1}{3}\\pi r^2(h_1 + h_2)\n"
              "= \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(rSq)} \\times (${fmt(h1)} + ${fmt(h2)})\n"
              "= \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(sumH)} = ${fmt(totalVol)}\\text{ $unit}^3",
        ));

        answers["Cone 1 Volume"] = "${fmt(v1)} $unit³";
        answers["Cone 2 Volume"] = "${fmt(v2)} $unit³";
        answers["Total Volume"] = "${fmt(totalVol)} $unit³";
      } else if (subMode == 1) {
        // Cylinder + Conical Mound on Top (Example 8 Basin of Rice & Ex 19g #4 Cup of Rice)
        final double vCyl = pi.value * rSq * h1;
        final double vCone = (1.0 / 3.0) * pi.value * rSq * h2;
        totalVol = vCyl + vCone;

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{1. Volume of Cylindrical Part (Cup / Basin)}}");
        workings.add(
            "V_{\\text{cylinder}} = \\pi r^2 h_{\\text{cyl}} = ${pi.latex} \\times ${fmt(r)}^2 \\times ${fmt(h1)}");
        workings.add(
            "= ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h1)} = ${fmt(vCyl)}\\text{ $unit}^3");

        steps.add(ConeStep(
          title: "Step 1: Calculate the Volume of the Cylindrical Base",
          description:
          "The lower container (cup or basin in Figures 19.26 & 19.28) is a cylinder of radius r = ${fmt(r)} $unit and height h = ${fmt(h1)} $unit:\n"
              "• V_cylinder = πr²h = ${pi.text} × ${fmt(r)}² × ${fmt(h1)} = ${pi.text} × ${fmt(rSq)} × ${fmt(h1)} = ${fmt(vCyl)} $unit³.",
          mathLaTeX:
          "V_{\\text{cylinder}} = \\pi r^2 h_{\\text{cyl}} = ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h1)} = ${fmt(vCyl)}\\text{ $unit}^3",
        ));

        workings.add("");
        workings.add(
            "\\text{\\textbf{2. Volume of Conical Mound on Top}}");
        workings.add(
            "V_{\\text{cone}} = \\frac{1}{3}\\pi r^2 h_{\\text{cone}} = \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h2)} = ${fmt(vCone)}\\text{ $unit}^3");

        steps.add(ConeStep(
          title: "Step 2: Calculate the Volume of the Conical Mound on Top",
          description:
          "The mound of rice on top is a cone with the same base radius r = ${fmt(r)} $unit and height h_cone = ${fmt(h2)} $unit:\n"
              "• V_cone = ⅓πr²h_cone = ⅓ × ${pi.text} × ${fmt(rSq)} × ${fmt(h2)} = ${fmt(vCone)} $unit³.",
          mathLaTeX:
          "V_{\\text{cone}} = \\frac{1}{3}\\pi r^2 h_{\\text{cone}} = \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h2)} = ${fmt(vCone)}\\text{ $unit}^3",
        ));

        workings.add("");
        workings.add(
            "\\text{\\textbf{3. Total Volume (Cylinder + Cone)}}");
        workings.add(
            "V_{\\text{total}} = V_{\\text{cylinder}} + V_{\\text{cone}} = ${fmt(vCyl)} + ${fmt(vCone)} = ${fmt(totalVol)}\\text{ $unit}^3");

        steps.add(ConeStep(
          title: "Step 3: Add Both Volumes Together",
          description:
          "Add the volume of the cylindrical container and the volume of the conical mound on top:\n"
              "• Total Volume = ${fmt(vCyl)} + ${fmt(vCone)} = ${fmt(totalVol)} $unit³.",
          mathLaTeX:
          "V_{\\text{total}} = ${fmt(vCyl)} + ${fmt(vCone)} = ${fmt(totalVol)}\\text{ $unit}^3",
        ));

        answers["Cylinder Volume"] = "${fmt(vCyl)} $unit³";
        answers["Cone Mound Volume"] = "${fmt(vCone)} $unit³";
        answers["Total Volume"] = "${fmt(totalVol)} $unit³";
      } else {
        // Cylinder with Cones at Both Ends (Sharpened Pencil, Ex 19g #5, Fig 19.27)
        final double vCyl = pi.value * rSq * h1;
        final double vOneCone = (1.0 / 3.0) * pi.value * rSq * h2;
        final double vTwoCones = 2.0 * vOneCone;
        totalVol = vCyl + vTwoCones;

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{1. Volume of Central Cylindrical Shaft}}");
        workings.add(
            "V_{\\text{cylinder}} = \\pi r^2 h_{\\text{cyl}} = ${pi.latex} \\times ${fmt(r)}^2 \\times ${fmt(h1)}");
        workings.add(
            "= ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h1)} = ${fmt(vCyl)}\\text{ $unit}^3");

        steps.add(ConeStep(
          title: "Step 1: Calculate the Volume of the Central Cylinder",
          description:
          "The unsharpened middle shaft of the pencil (Figure 19.27) is a cylinder of radius r = ${fmt(r)} $unit and length h_cyl = ${fmt(h1)} $unit:\n"
              "• V_cylinder = πr²h_cyl = ${pi.text} × ${fmt(rSq)} × ${fmt(h1)} = ${fmt(vCyl)} $unit³.",
          mathLaTeX:
          "V_{\\text{cylinder}} = \\pi r^2 h_{\\text{cyl}} = ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h1)} = ${fmt(vCyl)}\\text{ $unit}^3",
        ));

        workings.add("");
        workings.add(
            "\\text{\\textbf{2. Volume of the Two Sharpened Conical Ends}}");
        workings.add(
            "V_{\\text{1 cone}} = \\frac{1}{3}\\pi r^2 h_{\\text{cone}} = \\frac{1}{3} \\times ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h2)} = ${fmt(vOneCone)}\\text{ $unit}^3");
        workings.add(
            "V_{\\text{2 cones}} = 2 \\times ${fmt(vOneCone)} = ${fmt(vTwoCones)}\\text{ $unit}^3");

        steps.add(ConeStep(
          title: "Step 2: Calculate the Volume of the Two Conical Ends",
          description:
          "Because the pencil is sharpened to a cone shape at BOTH ends, there are 2 identical cones of radius r = ${fmt(r)} $unit and height h_cone = ${fmt(h2)} $unit:\n"
              "• Volume of 1 conical end = ⅓ × ${pi.text} × ${fmt(rSq)} × ${fmt(h2)} = ${fmt(vOneCone)} $unit³.\n"
              "• Volume of 2 conical ends = 2 × ${fmt(vOneCone)} = ${fmt(vTwoCones)} $unit³.",
          mathLaTeX:
          "V_{\\text{2 cones}} = 2 \\times \\left(\\frac{1}{3} \\times ${pi.latex} \\times ${fmt(rSq)} \\times ${fmt(h2)}\\right) = ${fmt(vTwoCones)}\\text{ $unit}^3",
        ));

        workings.add("");
        workings.add(
            "\\text{\\textbf{3. Total Volume of the Pencil}}");
        workings.add(
            "V_{\\text{total}} = V_{\\text{cylinder}} + V_{\\text{2 cones}} = ${fmt(vCyl)} + ${fmt(vTwoCones)} = ${fmt(totalVol)}\\text{ $unit}^3");

        steps.add(ConeStep(
          title: "Step 3: Add Cylinder and Both Conical Ends",
          description:
          "Add the volume of the central cylinder (${fmt(vCyl)} $unit³) and the two conical tips (${fmt(vTwoCones)} $unit³):\n"
              "• Total Volume = ${fmt(vCyl)} + ${fmt(vTwoCones)} = ${fmt(totalVol)} $unit³.",
          mathLaTeX:
          "V_{\\text{total}} = ${fmt(vCyl)} + ${fmt(vTwoCones)} = ${fmt(totalVol)}\\text{ $unit}^3",
        ));

        answers["Cylinder Volume"] = "${fmt(vCyl)} $unit³";
        answers["2 Conical Ends"] = "${fmt(vTwoCones)} $unit³";
        answers["Total Pencil Volume"] = "${fmt(totalVol)} $unit³";
      }

      // Optional Mass / Density (Matches Example 7b: 132 × 8 g = 1.056 kg)
      final double? density = parseInput(densityStr);
      if (density != null && density > 0) {
        final double massG = totalVol * density;
        final double massKg = massG / 1000.0;

        workings.add("");
        workings.add("\\text{\\textbf{Mass of Composite Solid (Example 7b)}}");
        workings.add(
            "\\text{Mass in grams} = \\text{Volume} \\times \\text{Density} = ${fmt(totalVol)} \\times ${fmt(density)}\\text{ g} = ${fmt(massG)}\\text{ g}");
        workings.add(
            "\\text{Mass in kilograms} = \\frac{${fmt(totalVol)} \\times ${fmt(density)}}{1,000}\\text{ kg} = \\frac{${fmt(massG)}}{1,000} = ${fmt(massKg, maxDecimals: 3)}\\text{ kg}");

        steps.add(ConeStep(
          title: "Calculate Mass and Convert Grams to Kilograms (Example 7b)",
          description:
          "1. Since 1 $unit³ has a mass of ${fmt(density)} g, multiply the total volume (${fmt(totalVol)} $unit³) by ${fmt(density)} g/$unit³:\n"
              "   Mass = ${fmt(totalVol)} × ${fmt(density)} = ${fmt(massG)} g.\n"
              "2. Divide by 1,000 (since 1,000 g = 1 kg) to express the mass in kilograms:\n"
              "   Mass = ${fmt(massG)} ÷ 1,000 = ${fmt(massKg, maxDecimals: 3)} kg.",
          mathLaTeX:
          "\\text{Mass} = \\frac{${fmt(totalVol)} \\times ${fmt(density)}}{1,000}\\text{ kg} = ${fmt(massKg, maxDecimals: 3)}\\text{ kg}",
        ));

        answers["Mass (g)"] = "${fmt(massG)} g";
        answers["Mass (kg)"] = "${fmt(massKg, maxDecimals: 3)} kg";
      }

      return ConeResult(
        mode: 3,
        subMode: subMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        r: r,
        h: h1,
        h2: h2,
        l: math.sqrt(r * r + h2 * h2),
        displayUnit: unit,
      );
    } catch (e) {
      return ConeResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please check your composite solid dimensions.",
      );
    }
  }

  // ===========================================================================
  // MODE 4: Cone vs Cylinder Comparison & Reverse Volume (Ex 19f #5 & Ex 19g #3)
  // ===========================================================================
  static ConeResult solveComparisonAndReverse({
    required ConePiConfig pi,
    required int subMode,
    // 0: Equal Volume & Equal Base (Given Cone Height -> Find Cylinder Height, Ex 19g #3)
    // 1: Reverse Volume Solver (Given Cone Volume & r/d -> Find Height h)
    // 2: Reverse Volume Solver (Given Cone Volume & h -> Find Radius r & Diameter d)
    required bool isRadius,
    required String dimStr,
    required String hStr,
    required String volStr,
    required String unit,
  }) {
    try {
      final List<ConeStep> steps = [];
      final List<String> workings = [];
      final Map<String, String> answers = {};

      if (subMode == 0) {
        final double? hCone = parseInput(hStr);
        if (hCone == null || hCone <= 0) {
          throw const FormatException("Enter a positive cone height.");
        }
        final double r = parseInput(dimStr) ?? 5.0;
        final double hCyl = hCone / 3.0;

        workings.add(
            "\\text{\\textbf{1. Cone vs. Cylinder Volume Relationship (Exercise 19f \\#4–5)}}");
        workings.add(
            "\\text{For the same base area } (\\pi r^2) \\text{ and height:}");
        workings.add(
            "V_{\\text{cone}} = \\frac{1}{3}V_{\\text{cylinder}} \\quad \\Longleftrightarrow \\quad V_{\\text{cylinder}} = 3 \\times V_{\\text{cone}}");
        workings.add(
            "\\text{(It takes exactly 3 full cones of sand/water to fill the cylinder!)}");

        workings.add("");
        workings.add(
            "\\text{\\textbf{2. Equal Volumes & Equal Bases (Exercise 19g \\#3)}}");
        workings.add("V_{\\text{cylinder}} = V_{\\text{cone}}");
        workings.add(
            "\\pi r^2 h_{\\text{cyl}} = \\frac{1}{3}\\pi r^2 h_{\\text{cone}}");
        workings.add("\\text{Divide both sides by the common base area } \\pi r^2:");
        workings.add(
            "h_{\\text{cyl}} = \\frac{1}{3}h_{\\text{cone}} = \\frac{${fmt(hCone)}}{3} = ${fmt(hCyl)}\\text{ $unit}");

        steps.add(ConeStep(
          title:
          "Step 1: Recall the 1 : 3 Cone-to-Cylinder Volume Ratio (Ex 19f #4–5)",
          description:
          "When a cone and a cylinder have the same base diameter and the same height:\n"
              "• The volume of the cone is ⅓ of the volume of the cylinder.\n"
              "• The volume of the cylinder is 3 times the volume of the cone (3 full cones fill 1 cylinder).",
          mathLaTeX:
          "V_{\\text{cone}} = \\frac{1}{3}\\pi r^2 h \\quad ; \\quad V_{\\text{cylinder}} = \\pi r^2 h",
        ));

        steps.add(ConeStep(
          title:
          "Step 2: Equate Volumes to Find the Cylinder's Height (Ex 19g #3)",
          description:
          "Here, the cone and the cylinder have EQUAL volumes and equal bases (so πr² is the same for both):\n"
              "1. Set their volume formulas equal: πr² × h_cyl = ⅓πr² × h_cone.\n"
              "2. Divide both sides by πr² so the base areas cancel out: h_cyl = ⅓ × h_cone.\n"
              "3. Substitute h_cone = ${fmt(hCone)} $unit:\n"
              "   h_cyl = ${fmt(hCone)} ÷ 3 = ${fmt(hCyl)} $unit.",
          mathLaTeX:
          "\\pi r^2 h_{\\text{cyl}} = \\frac{1}{3}\\pi r^2 h_{\\text{cone}}\n"
              "h_{\\text{cyl}} = \\frac{${fmt(hCone)}}{3} = ${fmt(hCyl)}\\text{ $unit}",
        ));

        answers["Cylinder Height (h_cyl)"] = "${fmt(hCyl)} $unit";
        answers["Cones to Fill Cylinder"] = "3 full cones";
        answers["Cone : Cylinder Ratio"] = "1 : 3 (or ⅓)";

        return ConeResult(
          mode: 4,
          subMode: 0,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r,
          h: hCone,
          h2: hCyl,
          l: math.sqrt(r * r + hCone * hCone),
          displayUnit: unit,
        );
      } else if (subMode == 1) {
        // Reverse Volume: Given V and r/d -> Find h
        final double? V = parseInput(volStr);
        final double? rawDim = parseInput(dimStr);
        if (V == null || rawDim == null || V <= 0 || rawDim <= 0) {
          throw const FormatException(
              "Enter positive values for the Volume (V) and Base Radius/Diameter.");
        }

        final double r = _processRadius(isRadius, rawDim, unit, workings, steps);
        final double rSq = r * r;
        final double h = (3.0 * V) / (pi.value * rSq);

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{Isolate Vertical Height (h) from Cone Volume}}");
        workings.add("\\frac{1}{3}\\pi r^2 h = V");
        workings.add(
            "\\frac{1}{3} \\times ${pi.latex} \\times ${fmt(r)}^2 \\times h = ${fmt(V)}");
        workings.add(
            "h = \\frac{3 \\times V}{\\pi r^2} = \\frac{3 \\times ${fmt(V)}}{${pi.latex} \\times ${fmt(rSq)}} = ${fmt(h)}\\text{ $unit}");

        steps.add(ConeStep(
          title: "Multiply by 3 and Divide by πr² to Find Height (h)",
          description:
          "1. Start with the cone volume formula: ⅓πr²h = V.\n"
              "2. Multiply both sides by 3 to clear the fraction: πr²h = 3 × ${fmt(V)} = ${fmt(3 * V)}.\n"
              "3. Divide by πr² (${pi.text} × ${fmt(rSq)} = ${fmt(pi.value * rSq)}):\n"
              "   h = ${fmt(3 * V)} ÷ ${fmt(pi.value * rSq)} = ${fmt(h)} $unit.",
          mathLaTeX:
          "\\frac{1}{3}\\pi r^2 h = ${fmt(V)} \\implies h = \\frac{3 \\times ${fmt(V)}}{${pi.latex} \\times ${fmt(rSq)}} = ${fmt(h)}\\text{ $unit}",
        ));

        answers["Cone Height (h)"] = "${fmt(h)} $unit";
        answers["Slant Height (l)"] =
        "${fmt(math.sqrt(rSq + h * h))} $unit";

        return ConeResult(
          mode: 4,
          subMode: 1,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r,
          h: h,
          l: math.sqrt(rSq + h * h),
          displayUnit: unit,
        );
      } else {
        // Reverse Volume: Given V and h -> Find r and d
        final double? V = parseInput(volStr);
        final double? h = parseInput(hStr);
        if (V == null || h == null || V <= 0 || h <= 0) {
          throw const FormatException(
              "Enter positive values for the Volume (V) and Height (h).");
        }

        final double rSq = (3.0 * V) / (pi.value * h);
        final double r = math.sqrt(rSq);
        final double d = 2.0 * r;

        workings.add(
            "\\text{\\textbf{Isolate Base Radius (r) from Cone Volume}}");
        workings.add("\\frac{1}{3}\\pi r^2 h = V");
        workings.add(
            "r^2 = \\frac{3 \\times V}{\\pi h} = \\frac{3 \\times ${fmt(V)}}{${pi.latex} \\times ${fmt(h)}} = ${fmt(rSq)}");
        workings.add(
            "r = \\sqrt{${fmt(rSq)}} = ${fmt(r)}\\text{ $unit} \\quad ; \\quad d = 2r = ${fmt(d)}\\text{ $unit}");

        steps.add(ConeStep(
          title: "Isolate r² First, Then Take the Square Root",
          description:
          "1. Start with ⅓πr²h = ${fmt(V)}.\n"
              "2. Multiply by 3 and divide by (π × h) to isolate r²:\n"
              "   r² = (3 × ${fmt(V)}) ÷ (${pi.text} × ${fmt(h)}) = ${fmt(rSq)}.\n"
              "3. Take the square root: r = √${fmt(rSq)} = ${fmt(r)} $unit.\n"
              "4. Double the radius for the diameter: d = 2 × ${fmt(r)} = ${fmt(d)} $unit.",
          mathLaTeX:
          "r^2 = \\frac{3 \\times ${fmt(V)}}{${pi.latex} \\times ${fmt(h)}} = ${fmt(rSq)} \\implies r = \\sqrt{${fmt(rSq)}} = ${fmt(r)}\\text{ $unit}",
        ));

        answers["Base Radius (r)"] = "${fmt(r)} $unit";
        answers["Base Diameter (d)"] = "${fmt(d)} $unit";

        return ConeResult(
          mode: 4,
          subMode: 2,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r,
          h: h,
          l: math.sqrt(rSq + h * h),
          displayUnit: unit,
        );
      }
    } catch (e) {
      return ConeResult.error(
        mode: 4,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please check your inputs for the reverse cone solver.",
      );
    }
  }
}