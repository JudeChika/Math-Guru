// lib/features/junior_secondary/jss1/area/circle/circle_area_solver.dart

import 'dart:math';
import 'circle_area_models.dart';

class CircleAreaSolver {
  // Helper to format numbers cleanly and round to 2 decimal places max
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // Constant string for Pi to use in explanations
  static const String _piStr = "3.142";

  static CircleAreaResult solveForAreaWithRadius(String rIn, String unit) {
    try {
      double r = double.parse(rIn.trim());
      double rSquared = r * r;
      double area = pi * rSquared;

      String rStr = _format(r);
      String rSqStr = _format(rSquared);
      String areaStr = _format(area);
      String u = "\\; \\text{$unit}";

      List<CircleAreaStep> steps = [
        CircleAreaStep(
            workingLaTeX: "A = \\pi r^2",
            explanation: "Start with the formula for the area of a circle, where 'A' is area, 'r' is the radius, and '\\pi' (pi) is a constant (approximately $_piStr)."
        ),
        CircleAreaStep(
            workingLaTeX: "A = $_piStr \\times ($rStr$u)^2",
            explanation: "Substitute the given radius ($rStr $unit) and the value of \\pi ($_piStr) into the formula."
        ),
        CircleAreaStep(
            workingLaTeX: "A = $_piStr \\times $rSqStr$u^2",
            explanation: "Square the radius by multiplying it by itself ($rStr \\times $rStr)."
        ),
        CircleAreaStep(
            workingLaTeX: "A = $areaStr$u^2",
            explanation: "Multiply the squared radius by $_piStr to find the final area. Area is measured in square units.",
            isFinalAnswer: true
        )
      ];

      return CircleAreaResult(steps: steps, finalAnswerLaTeX: "A = $areaStr$u^2");
    } catch (_) {
      return CircleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static CircleAreaResult solveForAreaWithDiameter(String dIn, String unit) {
    try {
      double d = double.parse(dIn.trim());
      double r = d / 2;
      double rSquared = r * r;
      double area = pi * rSquared;

      String dStr = _format(d);
      String rStr = _format(r);
      String rSqStr = _format(rSquared);
      String areaStr = _format(area);
      String u = "\\; \\text{$unit}";

      List<CircleAreaStep> steps = [
        CircleAreaStep(
            workingLaTeX: "r = \\frac{d}{2}",
            explanation: "The diameter (d) goes all the way across the circle. To use the area formula, we first need to find the radius (r), which is half of the diameter."
        ),
        CircleAreaStep(
            workingLaTeX: "r = \\frac{$dStr}{2} = $rStr$u",
            explanation: "Divide the diameter by 2 to get the radius."
        ),
        CircleAreaStep(
            workingLaTeX: "A = \\pi r^2",
            explanation: "Now, use the standard formula for the area of a circle. We will use $_piStr as the approximate value for \\pi."
        ),
        CircleAreaStep(
            workingLaTeX: "A = $_piStr \\times ($rStr$u)^2",
            explanation: "Substitute the radius ($rStr $unit) and \\pi ($_piStr) into the formula."
        ),
        CircleAreaStep(
            workingLaTeX: "A = $_piStr \\times $rSqStr$u^2",
            explanation: "Square the radius."
        ),
        CircleAreaStep(
            workingLaTeX: "A = $areaStr$u^2",
            explanation: "Multiply the squared radius by $_piStr to find the final area.",
            isFinalAnswer: true
        )
      ];

      return CircleAreaResult(steps: steps, finalAnswerLaTeX: "A = $areaStr$u^2");
    } catch (_) {
      return CircleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static CircleAreaResult solveForRadius(String areaIn, String unit) {
    try {
      double area = double.parse(areaIn.trim());
      double rSquared = area / pi;
      double r = sqrt(rSquared);

      String areaStr = _format(area);
      String rSqStr = _format(rSquared);
      String rStr = _format(r);
      String u = "\\; \\text{$unit}";

      List<CircleAreaStep> steps = [
        CircleAreaStep(
            workingLaTeX: "A = \\pi r^2",
            explanation: "Start with the general area formula, using $_piStr as the approximate value for \\pi."
        ),
        CircleAreaStep(
            workingLaTeX: "r^2 = \\frac{A}{\\pi}",
            explanation: "Rearrange the formula to isolate the squared radius (r²) by dividing both sides by \\pi."
        ),
        CircleAreaStep(
            workingLaTeX: "r = \\sqrt{\\frac{A}{\\pi}}",
            explanation: "To find the radius 'r', take the square root of both sides."
        ),
        CircleAreaStep(
            workingLaTeX: "r = \\sqrt{\\frac{$areaStr$u^2}{$_piStr}}",
            explanation: "Substitute the given area ($areaStr $unit²) and the value of \\pi ($_piStr) into the formula."
        ),
        CircleAreaStep(
            workingLaTeX: "r = \\sqrt{$rSqStr$u^2}",
            explanation: "Divide the area by $_piStr."
        ),
        CircleAreaStep(
            workingLaTeX: "r = $rStr$u",
            explanation: "Calculate the square root to find the final length of the radius.",
            isFinalAnswer: true
        )
      ];

      return CircleAreaResult(steps: steps, finalAnswerLaTeX: "r = $rStr$u");
    } catch (_) {
      return CircleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}