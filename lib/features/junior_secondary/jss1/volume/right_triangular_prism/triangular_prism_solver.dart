import 'dart:math';
import 'triangular_prism_models.dart';

class TriangularPrismSolver {
  static final Map<String, double> _lengthFactors = {
    'mm': 1, 'cm': 10, 'm': 1000, 'km': 1000000,
  };

  static String _format(double n) {
    if (n >= 1000 && n == n.truncateToDouble()) {
      RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return n.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
    }
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(6).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // --- Normalization Engine ---
  static double _normalize(double val, String fromU, String toU, String varName, int dimension, List<TriangularPrismStep> steps) {
    if (fromU == toU) return val;

    double fVal = _lengthFactors[fromU]!;
    double tVal = _lengthFactors[toU]!;
    bool isMultiply = fVal > tVal;

    double linearRatio = isMultiply ? (fVal / tVal) : (tVal / fVal);
    double conversionFactor = pow(linearRatio, dimension).toDouble();

    double res = isMultiply ? (val * conversionFactor) : (val / conversionFactor);

    String op = isMultiply ? "\\times" : "\\div";
    String dimStr = dimension == 1 ? "" : "^$dimension";
    String typeStr = dimension == 1 ? "Length" : (dimension == 2 ? "Area" : "Volume");

    steps.add(TriangularPrismStep(
        workingLaTeX: "$varName = ${_format(val)} \\text{ $fromU}$dimStr $op ${_format(conversionFactor)} = ${_format(res)} \\text{ $toU}$dimStr",
        explanation: "Normalize $typeStr: Convert $varName from $fromU to our target unit ($toU). The factor is ${_format(linearRatio)}$dimStr = ${_format(conversionFactor)}."
    ));

    return res;
  }

  // ==========================================
  // STANDARD MODE (Triangle Base, Triangle Height, Prism Length)
  // ==========================================

  static TriangularPrismResult solveStandard(
      String bIn, String bU,
      String hIn, String hU,
      String lIn, String lU,
      String vIn, String vU,
      String targetU) {

    try {
      List<TriangularPrismStep> steps = [];
      String ut = "\\text{ $targetU}";

      if (vIn.isEmpty) {
        // Solving for Volume
        steps.add(TriangularPrismStep(workingLaTeX: "V = \\frac{1}{2} \\times b \\times h \\times l", explanation: "Start with the formula for the volume of a triangular prism. The base area is a triangle (½ × b × h), multiplied by the prism's length (l)."));

        double b = _normalize(double.parse(bIn), bU, targetU, 'b', 1, steps);
        double h = _normalize(double.parse(hIn), hU, targetU, 'h', 1, steps);
        double l = _normalize(double.parse(lIn), lU, targetU, 'l', 1, steps);

        double baseArea = 0.5 * b * h;
        double v = baseArea * l;

        steps.add(TriangularPrismStep(workingLaTeX: "\\text{Base Area} = \\frac{1}{2} \\times ${_format(b)}$ut \\times ${_format(h)}$ut = ${_format(baseArea)}$ut^2", explanation: "First, calculate the area of the triangular face."));
        steps.add(TriangularPrismStep(workingLaTeX: "V = ${_format(baseArea)}$ut^2 \\times ${_format(l)}$ut", explanation: "Substitute the Base Area and the Prism Length into the volume formula."));
        steps.add(TriangularPrismStep(workingLaTeX: "V = ${_format(v)}$ut^3", explanation: "Multiply to find the final volume.", isFinalAnswer: true));

        return TriangularPrismResult(steps: steps, finalAnswerLaTeX: "V = ${_format(v)} \\; \\text{$targetU}^3");

      } else {
        // Solving for a missing Side (b, h, or l)
        String missingVar = bIn.isEmpty ? 'b' : (hIn.isEmpty ? 'h' : 'l');

        steps.add(TriangularPrismStep(workingLaTeX: "V = \\frac{1}{2} \\times b \\times h \\times l", explanation: "Start with the volume formula."));

        double v = _normalize(double.parse(vIn), vU, targetU, 'V', 3, steps);

        if (missingVar == 'l') {
          // Solving for Prism Length
          steps.add(TriangularPrismStep(workingLaTeX: "l = \\frac{V}{\\frac{1}{2} \\times b \\times h}", explanation: "Rearrange to solve for the Prism Length (l) by dividing Volume by the Triangular Base Area."));
          double b = _normalize(double.parse(bIn), bU, targetU, 'b', 1, steps);
          double h = _normalize(double.parse(hIn), hU, targetU, 'h', 1, steps);

          double baseArea = 0.5 * b * h;
          steps.add(TriangularPrismStep(workingLaTeX: "\\text{Base Area} = \\frac{1}{2} \\times ${_format(b)}$ut \\times ${_format(h)}$ut = ${_format(baseArea)}$ut^2", explanation: "Calculate the Triangular Base Area."));

          double finalL = v / baseArea;
          steps.add(TriangularPrismStep(workingLaTeX: "l = \\frac{${_format(v)}}{${_format(baseArea)}} = ${_format(finalL)}$ut", explanation: "Divide the Volume by the Base Area.", isFinalAnswer: true));
          return TriangularPrismResult(steps: steps, finalAnswerLaTeX: "l = ${_format(finalL)} \\; \\text{$targetU}");
        } else {
          // Solving for Triangle Base (b) or Triangle Height (h)
          String knownTriSide = missingVar == 'b' ? 'h' : 'b';
          String knownIn = missingVar == 'b' ? hIn : bIn;
          String knownU = missingVar == 'b' ? hU : bU;

          steps.add(TriangularPrismStep(workingLaTeX: "$missingVar = \\frac{2 \\times V}{$knownTriSide \\times l}", explanation: "Rearrange to solve for '$missingVar' by multiplying Volume by 2, then dividing by the other known sides."));

          double knownSide = _normalize(double.parse(knownIn), knownU, targetU, knownTriSide, 1, steps);
          double l = _normalize(double.parse(lIn), lU, targetU, 'l', 1, steps);

          double top = 2 * v;
          double bottom = knownSide * l;
          double finalAns = top / bottom;

          steps.add(TriangularPrismStep(workingLaTeX: "$missingVar = \\frac{2 \\times ${_format(v)}}{${_format(knownSide)} \\times ${_format(l)}}", explanation: "Substitute the normalized values."));
          steps.add(TriangularPrismStep(workingLaTeX: "$missingVar = \\frac{${_format(top)}}{${_format(bottom)}} = ${_format(finalAns)}$ut", explanation: "Simplify and divide to find the final length.", isFinalAnswer: true));

          return TriangularPrismResult(steps: steps, finalAnswerLaTeX: "$missingVar = ${_format(finalAns)} \\; \\text{$targetU}");
        }
      }
    } catch (_) {
      return TriangularPrismResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  // ==========================================
  // BASE AREA MODE (Base Area, Prism Length)
  // ==========================================

  static TriangularPrismResult solveBaseArea(
      String baIn, String baU,
      String lIn, String lU,
      String vIn, String vU,
      String targetU) {

    try {
      List<TriangularPrismStep> steps = [];
      String ut = "\\text{ $targetU}";

      steps.add(TriangularPrismStep(workingLaTeX: "V = \\text{Base Area} \\times l", explanation: "When the Triangular Base Area is already given, the formula simplifies to Base Area multiplied by the Prism Length (l)."));

      if (vIn.isEmpty) {
        // Solving for Volume
        double ba = _normalize(double.parse(baIn), baU, targetU, '\\text{Base Area}', 2, steps);
        double l = _normalize(double.parse(lIn), lU, targetU, 'l', 1, steps);

        double v = ba * l;

        steps.add(TriangularPrismStep(workingLaTeX: "V = ${_format(ba)}$ut^2 \\times ${_format(l)}$ut", explanation: "Substitute the normalized values into the formula."));
        steps.add(TriangularPrismStep(workingLaTeX: "V = ${_format(v)}$ut^3", explanation: "Multiply to find the final volume.", isFinalAnswer: true));

        return TriangularPrismResult(steps: steps, finalAnswerLaTeX: "V = ${_format(v)} \\; \\text{$targetU}^3");

      } else if (lIn.isEmpty) {
        // Solving for Prism Length
        steps.add(TriangularPrismStep(workingLaTeX: "l = \\frac{V}{\\text{Base Area}}", explanation: "Rearrange to solve for the Prism Length (l)."));

        double v = _normalize(double.parse(vIn), vU, targetU, 'V', 3, steps);
        double ba = _normalize(double.parse(baIn), baU, targetU, '\\text{Base Area}', 2, steps);

        double l = v / ba;

        steps.add(TriangularPrismStep(workingLaTeX: "l = \\frac{${_format(v)}}{${_format(ba)}} = ${_format(l)}$ut", explanation: "Divide Volume by Base Area to find the final Prism Length.", isFinalAnswer: true));

        return TriangularPrismResult(steps: steps, finalAnswerLaTeX: "l = ${_format(l)} \\; \\text{$targetU}");

      } else {
        // Solving for Base Area
        steps.add(TriangularPrismStep(workingLaTeX: "\\text{Base Area} = \\frac{V}{l}", explanation: "Rearrange to solve for the Base Area."));

        double v = _normalize(double.parse(vIn), vU, targetU, 'V', 3, steps);
        double l = _normalize(double.parse(lIn), lU, targetU, 'l', 1, steps);

        double ba = v / l;

        steps.add(TriangularPrismStep(workingLaTeX: "\\text{Base Area} = \\frac{${_format(v)}}{${_format(l)}} = ${_format(ba)}$ut^2", explanation: "Divide Volume by Prism Length to find the final Base Area.", isFinalAnswer: true));

        return TriangularPrismResult(steps: steps, finalAnswerLaTeX: "\\text{Base Area} = ${_format(ba)} \\; \\text{$targetU}^2");
      }
    } catch (_) {
      return TriangularPrismResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}