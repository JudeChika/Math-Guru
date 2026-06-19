import 'dart:math';
import 'capacity_models.dart';

class CapacitySolver {
  // Base normalization mappings relative to 'mm' (absolute smallest base)
  static final Map<String, double> _lenToMm = {
    'mm': 1, 'cm': 10, 'm': 1000, 'km': 1000000
  };

  static final Map<String, double> _areaToMm2 = {
    'mm²': 1, 'cm²': 100, 'm²': 1000000, 'km²': 1000000000000
  };

  // Base 'mm³'. 1 cm³ = 1 ml = 1000 mm³. 1 Litre = 1,000,000 mm³.
  static final Map<String, double> _volToMm3 = {
    'mm³': 1, 'cm³': 1000, 'm³': 1000000000,
    'ml': 1000, 'cl': 10000, 'l': 1000000
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

  // --- Pedagogical Normalizers ---

  static double _normalizeLinear(double val, String fromU, String toU, String varName, List<CapacityStep> steps) {
    if (fromU == toU) return val;
    double fVal = _lenToMm[fromU]!;
    double tVal = _lenToMm[toU]!;
    bool isMult = fVal > tVal;
    double factor = isMult ? (fVal / tVal) : (tVal / fVal);
    double res = isMult ? (val * factor) : (val / factor);

    String op = isMult ? "\\times" : "\\div";
    steps.add(CapacityStep(
        workingLaTeX: "$varName = ${_format(val)} \\text{ $fromU} $op ${_format(factor)} = ${_format(res)} \\text{ $toU}",
        explanation: "Normalize units: Convert $varName to our target calculation unit ($toU)."
    ));
    return res;
  }

  static double _normalizeArea(double val, String fromU, String toU, String varName, List<CapacityStep> steps) {
    if (fromU == toU) return val;
    double fVal = _areaToMm2[fromU]!;
    double tVal = _areaToMm2[toU]!;
    bool isMult = fVal > tVal;
    double factor = isMult ? (fVal / tVal) : (tVal / fVal);
    double res = isMult ? (val * factor) : (val / factor);

    String op = isMult ? "\\times" : "\\div";
    steps.add(CapacityStep(
        workingLaTeX: "$varName = ${_format(val)} \\text{ $fromU} $op ${_format(factor)} = ${_format(res)} \\text{ $toU}",
        explanation: "Normalize units: Convert Area to the target unit ($toU)."
    ));
    return res;
  }

  static double _bridgeCapacity(double val, String fromU, String toU, String varName, List<CapacityStep> steps) {
    if (fromU == toU) return val;
    double fVal = _volToMm3[fromU]!;
    double tVal = _volToMm3[toU]!;
    bool isMult = fVal > tVal;
    double factor = isMult ? (fVal / tVal) : (tVal / fVal);
    double res = isMult ? (val * factor) : (val / factor);

    String op = isMult ? "\\times" : "\\div";
    String rule = isMult ? "1 \\text{ $fromU} = ${_format(factor)} \\text{ $toU}" : "1 \\text{ $toU} = ${_format(factor)} \\text{ $fromU}";

    steps.add(CapacityStep(
        workingLaTeX: "$varName = ${_format(val)} \\text{ $fromU} $op ${_format(factor)} = ${_format(res)} \\text{ $toU}",
        explanation: "The Capacity Bridge: Convert $fromU to $toU. Golden Rule: $rule."
    ));
    return res;
  }

  // Maps target volume/capacity unit to the best linear unit for initial calculation
  static String _getBestLinearUnit(String capUnit) {
    if (capUnit == 'm³') return 'm';
    if (capUnit == 'mm³') return 'mm';
    return 'cm'; // cm is the universal bridge for ml, cl, l, and cm³
  }

  // ==========================================
  // SOLVERS
  // ==========================================

  static CapacityResult solveForCapacity(
      String lIn, String lU, String bIn, String bU, String hIn, String hU,
      String baIn, String baU, bool isBaseAreaMode, String targetCapU) {
    try {
      List<CapacityStep> steps = [];
      String baseLinU = _getBestLinearUnit(targetCapU);
      String baseAreaU = "$baseLinU²";
      String baseVolU = "$baseLinU³";

      double volumeBaseU = 0;

      if (isBaseAreaMode) {
        steps.add(CapacityStep(workingLaTeX: "V = \\text{Base Area} \\times h", explanation: "Start with the formula for Volume."));
        double ba = _normalizeArea(double.parse(baIn), baU, baseAreaU, '\\text{Base Area}', steps);
        double h = _normalizeLinear(double.parse(hIn), hU, baseLinU, 'h', steps);
        volumeBaseU = ba * h;
        steps.add(CapacityStep(workingLaTeX: "V = ${_format(ba)} \\times ${_format(h)} = ${_format(volumeBaseU)} \\text{ $baseVolU}", explanation: "Multiply to find the Volume in $baseVolU."));
      } else {
        steps.add(CapacityStep(workingLaTeX: "V = l \\times b \\times h", explanation: "Start with the formula for the Volume of a container."));
        double l = _normalizeLinear(double.parse(lIn), lU, baseLinU, 'l', steps);
        double b = _normalizeLinear(double.parse(bIn), bU, baseLinU, 'b', steps);
        double h = _normalizeLinear(double.parse(hIn), hU, baseLinU, 'h', steps);
        volumeBaseU = l * b * h;
        steps.add(CapacityStep(workingLaTeX: "V = ${_format(l)} \\times ${_format(b)} \\times ${_format(h)} = ${_format(volumeBaseU)} \\text{ $baseVolU}", explanation: "Multiply to find the Volume in $baseVolU."));
      }

      // Final Bridge to Target Capacity Unit
      double finalCap = _bridgeCapacity(volumeBaseU, baseVolU, targetCapU, 'Capacity', steps);
      steps.add(CapacityStep(workingLaTeX: "\\text{Capacity} = ${_format(finalCap)} \\text{ $targetCapU}", explanation: "Final Answer calculated.", isFinalAnswer: true));

      return CapacityResult(steps: steps, finalAnswerLaTeX: "\\text{C} = ${_format(finalCap)} \\; \\text{$targetCapU}");
    } catch (_) {
      return CapacityResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static CapacityResult solveForSide(
      String capIn, String capU, String lIn, String lU, String bIn, String bU,
      String hIn, String hU, String baIn, String baU, bool isBaseAreaMode,
      String targetLinearU, String missingVarName) {
    try {
      List<CapacityStep> steps = [];
      String targetVolU = "$targetLinearU³";
      String targetAreaU = "$targetLinearU²";

      // Bridge Capacity to Cubic Target Unit First
      double volBase = _bridgeCapacity(double.parse(capIn), capU, targetVolU, 'V', steps);

      double missingVal = 0;

      if (isBaseAreaMode) {
        if (baIn.isEmpty) { // Solving for Base Area
          steps.add(CapacityStep(workingLaTeX: "\\text{Base Area} = \\frac{V}{h}", explanation: "Rearrange the formula to solve for Base Area."));
          double h = _normalizeLinear(double.parse(hIn), hU, targetLinearU, 'h', steps);
          missingVal = volBase / h;
          steps.add(CapacityStep(workingLaTeX: "\\text{Base Area} = \\frac{${_format(volBase)}}{${_format(h)}} = ${_format(missingVal)} \\text{ $targetAreaU}", explanation: "Divide to find final Base Area.", isFinalAnswer: true));
          return CapacityResult(steps: steps, finalAnswerLaTeX: "\\text{Base Area} = ${_format(missingVal)} \\; \\text{$targetAreaU}");
        } else { // Solving for Height
          steps.add(CapacityStep(workingLaTeX: "h = \\frac{V}{\\text{Base Area}}", explanation: "Rearrange the formula to solve for Height."));
          double ba = _normalizeArea(double.parse(baIn), baU, targetAreaU, '\\text{Base Area}', steps);
          missingVal = volBase / ba;
          steps.add(CapacityStep(workingLaTeX: "h = \\frac{${_format(volBase)}}{${_format(ba)}} = ${_format(missingVal)} \\text{ $targetLinearU}", explanation: "Divide to find final Height.", isFinalAnswer: true));
        }
      } else {
        // Standard Mode - missing l, b, or h
        steps.add(CapacityStep(workingLaTeX: "$missingVarName = \\frac{V}{\\text{Other Sides Area}}", explanation: "Rearrange formula to divide Volume by known sides."));

        String s1Name = lIn.isNotEmpty ? 'l' : 'b';
        String s2Name = hIn.isNotEmpty ? 'h' : 'b';
        double s1 = _normalizeLinear(double.parse(lIn.isNotEmpty ? lIn : bIn), lIn.isNotEmpty ? lU : bU, targetLinearU, s1Name, steps);
        double s2 = _normalizeLinear(double.parse(hIn.isNotEmpty ? hIn : bIn), hIn.isNotEmpty ? hU : bU, targetLinearU, s2Name, steps);

        double area = s1 * s2;
        steps.add(CapacityStep(workingLaTeX: "\\text{Area} = ${_format(s1)} \\times ${_format(s2)} = ${_format(area)} \\text{ $targetAreaU}", explanation: "Multiply the known sides."));

        missingVal = volBase / area;
        steps.add(CapacityStep(workingLaTeX: "$missingVarName = \\frac{${_format(volBase)}}{${_format(area)}} = ${_format(missingVal)} \\text{ $targetLinearU}", explanation: "Divide to find the final missing side.", isFinalAnswer: true));
      }

      return CapacityResult(steps: steps, finalAnswerLaTeX: "$missingVarName = ${_format(missingVal)} \\; \\text{$targetLinearU}");
    } catch (_) {
      return CapacityResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}