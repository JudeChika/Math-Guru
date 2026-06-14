// lib/features/junior_secondary/jss1/area/square/square_area_solver.dart

import 'dart:math';
import 'square_area_models.dart';

class SquareAreaSolver {
  // Helper to format numbers cleanly (e.g., 5.0 -> 5, 5.25 -> 5.25)
  static String _format(double n) {
    return n == n.truncateToDouble() ? n.toInt().toString() : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  static AreaResult solveForArea(String aInput, String unit) {
    try {
      double a = double.parse(aInput.trim());
      List<AreaSolutionStep> steps = [];
      double area = a * a;

      String aStr = _format(a);
      String areaStr = _format(area);

      // LaTeX space and text formatting for the unit
      String u = "\\; \\text{$unit}";

      steps.add(AreaSolutionStep(
          workingLaTeX: "A = a^2",
          explanation: "Start with the formula for the area of a square, where 'A' is area and 'a' is the length of one side."
      ));
      steps.add(AreaSolutionStep(
          workingLaTeX: "A = ($aStr$u)^2",
          explanation: "Substitute the side length 'a' ($aStr $unit) into the formula."
      ));
      steps.add(AreaSolutionStep(
          workingLaTeX: "A = $aStr \\times $aStr",
          explanation: "Square the side length by multiplying the value by itself."
      ));
      steps.add(AreaSolutionStep(
          workingLaTeX: "A = $areaStr$u^2",
          explanation: "Calculate the final area. Area is always measured in square units.",
          isFinalAnswer: true
      ));

      return AreaResult(steps: steps, finalAnswerLaTeX: "A = $areaStr$u^2", isSolvingForArea: true);
    } catch (_) {
      return AreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid side length.", isSolvingForArea: true);
    }
  }

  static AreaResult solveForSide(String areaInput, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      List<AreaSolutionStep> steps = [];
      double a = sqrt(area);

      String areaStr = _format(area);
      String aStr = _format(a);

      String u = "\\; \\text{$unit}";

      steps.add(AreaSolutionStep(
          workingLaTeX: "A = a^2",
          explanation: "Start with the formula for the area of a square, where 'A' is area and 'a' is the length of one side."
      ));
      steps.add(AreaSolutionStep(
          workingLaTeX: "a = \\sqrt{A}",
          explanation: "Rearrange the formula to solve for side length 'a' by finding the square root of the area."
      ));
      steps.add(AreaSolutionStep(
          workingLaTeX: "a = \\sqrt{$areaStr$u^2}",
          explanation: "Substitute the given area ($areaStr $unit²) into the formula."
      ));
      steps.add(AreaSolutionStep(
          workingLaTeX: "a = $aStr$u",
          explanation: "Calculate the final side length 'a'.",
          isFinalAnswer: true
      ));

      return AreaResult(steps: steps, finalAnswerLaTeX: "a = $aStr$u", isSolvingForArea: false);
    } catch (_) {
      return AreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid area.", isSolvingForArea: false);
    }
  }
}