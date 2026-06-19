import 'dart:math';
import 'cuboid_volume_models.dart';

class CuboidVolumeSolver {
  static final Map<String, double> _lengthFactors = {
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

  // --- Core Normalization Engine ---
  // dimension: 1 = Length, 2 = Area, 3 = Volume
  static double _normalize(double val, String fromU, String toU, String varName, int dimension, List<CuboidVolumeStep> steps) {
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

    steps.add(CuboidVolumeStep(
        workingLaTeX: "$varName = ${_format(val)} \\text{ $fromU}$dimStr $op ${_format(conversionFactor)} = ${_format(res)} \\text{ $toU}$dimStr",
        explanation: "Normalize $typeStr: Convert $varName from $fromU to our target unit ($toU). Since 1 ${isMultiply ? fromU : toU} = ${_format(linearRatio)} ${isMultiply ? toU : fromU}, the conversion factor is ${_format(linearRatio)}$dimStr = ${_format(conversionFactor)}."
    ));

    return res;
  }

  // ==========================================
  // STANDARD MODE (L, B, H)
  // ==========================================

  static CuboidVolumeResult solveStandard(
      String lIn, String lU,
      String bIn, String bU,
      String hIn, String hU,
      String vIn, String vU,
      String targetU) {

    try {
      List<CuboidVolumeStep> steps = [];
      String ut = "\\text{ $targetU}";

      if (vIn.isEmpty) {
        // Solving for Volume
        steps.add(CuboidVolumeStep(workingLaTeX: "V = l \\times b \\times h", explanation: "Start with the formula for the volume of a cuboid. All sides must be in the same unit."));

        double l = _normalize(double.parse(lIn), lU, targetU, 'l', 1, steps);
        double b = _normalize(double.parse(bIn), bU, targetU, 'b', 1, steps);
        double h = _normalize(double.parse(hIn), hU, targetU, 'h', 1, steps);

        double v = l * b * h;

        steps.add(CuboidVolumeStep(workingLaTeX: "V = ${_format(l)}$ut \\times ${_format(b)}$ut \\times ${_format(h)}$ut", explanation: "Substitute the normalized values into the formula."));
        steps.add(CuboidVolumeStep(workingLaTeX: "V = ${_format(v)}$ut^3", explanation: "Multiply to find the final volume.", isFinalAnswer: true));

        return CuboidVolumeResult(steps: steps, finalAnswerLaTeX: "V = ${_format(v)} \\; \\text{$targetU}^3");

      } else {
        // Solving for a missing Side (l, b, or h)
        String missingVar = lIn.isEmpty ? 'l' : (bIn.isEmpty ? 'b' : 'h');
        String side1Name = lIn.isNotEmpty ? 'l' : 'b';
        String side2Name = hIn.isNotEmpty ? 'h' : 'b';

        String s1In = lIn.isNotEmpty ? lIn : bIn;
        String s1U = lIn.isNotEmpty ? lU : bU;
        String s2In = hIn.isNotEmpty ? hIn : bIn;

        steps.add(CuboidVolumeStep(workingLaTeX: "V = l \\times b \\times h", explanation: "Start with the volume formula."));
        steps.add(CuboidVolumeStep(workingLaTeX: "$missingVar = \\frac{V}{($side1Name \\times $side2Name)}", explanation: "Rearrange to solve for the missing side ($missingVar) by dividing Volume by the other two sides."));

        double v = _normalize(double.parse(vIn), vU, targetU, 'V', 3, steps);
        double s1 = _normalize(double.parse(s1In), s1U, targetU, side1Name, 1, steps);
        double s2 = _normalize(double.parse(s2In), hIn.isNotEmpty ? hU : bU, targetU, side2Name, 1, steps);

        double area = s1 * s2;
        steps.add(CuboidVolumeStep(workingLaTeX: "$side1Name \\times $side2Name = ${_format(s1)}$ut \\times ${_format(s2)}$ut = ${_format(area)}$ut^2", explanation: "Multiply the two known sides together."));

        double missingVal = v / area;
        steps.add(CuboidVolumeStep(workingLaTeX: "$missingVar = \\frac{${_format(v)}}{${_format(area)}}", explanation: "Divide the Volume by that result."));
        steps.add(CuboidVolumeStep(workingLaTeX: "$missingVar = ${_format(missingVal)}$ut", explanation: "Calculate to find the final length of $missingVar.", isFinalAnswer: true));

        return CuboidVolumeResult(steps: steps, finalAnswerLaTeX: "$missingVar = ${_format(missingVal)} \\; \\text{$targetU}");
      }
    } catch (_) {
      return CuboidVolumeResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  // ==========================================
  // BASE AREA MODE (Base Area, H)
  // ==========================================

  static CuboidVolumeResult solveBaseArea(
      String baIn, String baU,
      String hIn, String hU,
      String vIn, String vU,
      String targetU) {

    try {
      List<CuboidVolumeStep> steps = [];
      String ut = "\\text{ $targetU}";

      steps.add(CuboidVolumeStep(workingLaTeX: "V = \\text{Base Area} \\times h", explanation: "When the Base Area (Length × Breadth) is already known, the formula simplifies."));

      if (vIn.isEmpty) {
        // Solving for Volume
        double ba = _normalize(double.parse(baIn), baU, targetU, '\\text{Base Area}', 2, steps);
        double h = _normalize(double.parse(hIn), hU, targetU, 'h', 1, steps);

        double v = ba * h;

        steps.add(CuboidVolumeStep(workingLaTeX: "V = ${_format(ba)}$ut^2 \\times ${_format(h)}$ut", explanation: "Substitute the normalized values into the formula."));
        steps.add(CuboidVolumeStep(workingLaTeX: "V = ${_format(v)}$ut^3", explanation: "Multiply the base area by the height to find the volume.", isFinalAnswer: true));

        return CuboidVolumeResult(steps: steps, finalAnswerLaTeX: "V = ${_format(v)} \\; \\text{$targetU}^3");

      } else if (hIn.isEmpty) {
        // Solving for Height
        steps.add(CuboidVolumeStep(workingLaTeX: "h = \\frac{V}{\\text{Base Area}}", explanation: "Rearrange to solve for the height."));

        double v = _normalize(double.parse(vIn), vU, targetU, 'V', 3, steps);
        double ba = _normalize(double.parse(baIn), baU, targetU, '\\text{Base Area}', 2, steps);

        double h = v / ba;

        steps.add(CuboidVolumeStep(workingLaTeX: "h = \\frac{${_format(v)}}{${_format(ba)}}", explanation: "Substitute the normalized Volume and Base Area."));
        steps.add(CuboidVolumeStep(workingLaTeX: "h = ${_format(h)}$ut", explanation: "Divide to find the final height.", isFinalAnswer: true));

        return CuboidVolumeResult(steps: steps, finalAnswerLaTeX: "h = ${_format(h)} \\; \\text{$targetU}");

      } else {
        // Solving for Base Area
        steps.add(CuboidVolumeStep(workingLaTeX: "\\text{Base Area} = \\frac{V}{h}", explanation: "Rearrange to solve for the Base Area."));

        double v = _normalize(double.parse(vIn), vU, targetU, 'V', 3, steps);
        double h = _normalize(double.parse(hIn), hU, targetU, 'h', 1, steps);

        double ba = v / h;

        steps.add(CuboidVolumeStep(workingLaTeX: "\\text{Base Area} = \\frac{${_format(v)}}{${_format(h)}}", explanation: "Substitute the normalized Volume and Height."));
        steps.add(CuboidVolumeStep(workingLaTeX: "\\text{Base Area} = ${_format(ba)}$ut^2", explanation: "Divide to find the final Base Area.", isFinalAnswer: true));

        return CuboidVolumeResult(steps: steps, finalAnswerLaTeX: "\\text{Base Area} = ${_format(ba)} \\; \\text{$targetU}^2");
      }
    } catch (_) {
      return CuboidVolumeResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}