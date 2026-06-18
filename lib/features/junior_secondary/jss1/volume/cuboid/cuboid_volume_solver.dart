import 'dart:math';
import 'cuboid_volume_models.dart';

class CuboidVolumeSolver {
  // Base conversion logic (Relative to smallest unit 'mm')
  static final Map<String, double> _factors = {
    'mm': 1,
    'cm': 10,
    'm': 1000,
    'km': 1000000,
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
  // Converts linear units (like length) to the target unit and generates a teaching step if needed
  static double _normalizeLinear(double val, String fromU, String toU, String varName, List<CuboidVolumeStep> steps) {
    if (fromU == toU) return val;

    double fVal = _factors[fromU]!;
    double tVal = _factors[toU]!;
    bool isMultiply = fVal > tVal;

    double factor = isMultiply ? (fVal / tVal) : (tVal / fVal);
    double res = isMultiply ? (val * factor) : (val / factor);

    String op = isMultiply ? "\\times" : "\\div";
    steps.add(CuboidVolumeStep(
        workingLaTeX: "$varName = ${_format(val)} \\text{ $fromU} $op ${_format(factor)} = ${_format(res)} \\text{ $toU}",
        explanation: "Normalize units: Convert $varName to our target unit ($toU) before calculating."
    ));
    return res;
  }

  // Converts cubic volume units to the target unit and explains the cubic conversion factor
  static double _normalizeVolume(double val, String fromU, String toU, List<CuboidVolumeStep> steps) {
    if (fromU == toU) return val;

    double fVal = _factors[fromU]!;
    double tVal = _factors[toU]!;
    bool isMultiply = fVal > tVal;

    double linearFactor = isMultiply ? (fVal / tVal) : (tVal / fVal);
    double cubicFactor = pow(linearFactor, 3).toDouble();
    double res = isMultiply ? (val * cubicFactor) : (val / cubicFactor);

    String op = isMultiply ? "\\times" : "\\div";
    steps.add(CuboidVolumeStep(
        workingLaTeX: "V = ${_format(val)} \\text{ $fromU}^3 $op ${_format(cubicFactor)} = ${_format(res)} \\text{ $toU}^3",
        explanation: "Normalize units: Convert Volume to the target cubic unit ($toU³). Since 1 ${isMultiply ? fromU : toU} = ${_format(linearFactor)} ${isMultiply ? toU : fromU}, the cubic factor is ${_format(linearFactor)}³ = ${_format(cubicFactor)}."
    ));
    return res;
  }

  // ==========================================
  // SOLVERS
  // ==========================================

  static CuboidVolumeResult solveForVolume(String lIn, String lU, String bIn, String bU, String hIn, String hU, String targetU) {
    try {
      List<CuboidVolumeStep> steps = [];
      steps.add(CuboidVolumeStep(workingLaTeX: "V = l \\times b \\times h", explanation: "Start with the formula for the volume of a cuboid. All sides must be in the same unit."));

      double l = _normalizeLinear(double.parse(lIn.trim()), lU, targetU, 'l', steps);
      double b = _normalizeLinear(double.parse(bIn.trim()), bU, targetU, 'b', steps);
      double h = _normalizeLinear(double.parse(hIn.trim()), hU, targetU, 'h', steps);

      double v = l * b * h;
      String ut = "\\text{ $targetU}";

      steps.add(CuboidVolumeStep(workingLaTeX: "V = ${_format(l)}$ut \\times ${_format(b)}$ut \\times ${_format(h)}$ut", explanation: "Substitute the normalized values into the formula."));
      steps.add(CuboidVolumeStep(workingLaTeX: "V = ${_format(v)}$ut^3", explanation: "Multiply to find the final volume.", isFinalAnswer: true));

      return CuboidVolumeResult(steps: steps, finalAnswerLaTeX: "V = ${_format(v)} \\; \\text{$targetU}^3");
    } catch (_) {
      return CuboidVolumeResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static CuboidVolumeResult solveForSide(String vIn, String vU, String s1In, String s1U, String s2In, String s2U, String targetU, String missingVarName) {
    try {
      List<CuboidVolumeStep> steps = [];
      steps.add(CuboidVolumeStep(workingLaTeX: "V = l \\times b \\times h", explanation: "Start with the volume formula."));
      steps.add(CuboidVolumeStep(workingLaTeX: "$missingVarName = \\frac{V}{\\text{Other Two Sides}}", explanation: "Rearrange to solve for the missing side ($missingVarName) by dividing Volume by the area of the other two sides."));

      // Normalize everything to the Target Unit first
      double v = _normalizeVolume(double.parse(vIn.trim()), vU, targetU, steps);
      double s1 = _normalizeLinear(double.parse(s1In.trim()), s1U, targetU, 'Side 1', steps);
      double s2 = _normalizeLinear(double.parse(s2In.trim()), s2U, targetU, 'Side 2', steps);

      double area = s1 * s2;
      String ut = "\\text{ $targetU}";

      steps.add(CuboidVolumeStep(workingLaTeX: "\\text{Area} = ${_format(s1)}$ut \\times ${_format(s2)}$ut = ${_format(area)}$ut^2", explanation: "Multiply the two known sides together."));

      double missingVal = v / area;

      steps.add(CuboidVolumeStep(workingLaTeX: "$missingVarName = \\frac{${_format(v)}}{${_format(area)}}", explanation: "Divide the Volume by that area."));
      steps.add(CuboidVolumeStep(workingLaTeX: "$missingVarName = ${_format(missingVal)}$ut", explanation: "Calculate to find the final length of $missingVarName.", isFinalAnswer: true));

      return CuboidVolumeResult(steps: steps, finalAnswerLaTeX: "$missingVarName = ${_format(missingVal)} \\; \\text{$targetU}");
    } catch (_) {
      return CuboidVolumeResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}