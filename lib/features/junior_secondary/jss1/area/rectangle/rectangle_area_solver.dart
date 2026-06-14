import 'rectangle_area_models.dart';

class RectangleAreaSolver {
  // Helper to format numbers cleanly (e.g., 5.0 -> 5, 5.25 -> 5.25)
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  static RectangleAreaResult solveForArea(String lInput, String bInput, String unit) {
    try {
      double l = double.parse(lInput.trim());
      double b = double.parse(bInput.trim());
      List<RectangleAreaStep> steps = [];
      double area = l * b;

      String lStr = _format(l);
      String bStr = _format(b);
      String areaStr = _format(area);

      String u = "\\; \\text{$unit}";

      steps.add(RectangleAreaStep(
          workingLaTeX: "A = l \\times b",
          explanation: "Start with the formula for the area of a rectangle, where 'A' is area, 'l' is length, and 'b' is breadth (or width)."
      ));
      steps.add(RectangleAreaStep(
          workingLaTeX: "A = $lStr$u \\times $bStr$u",
          explanation: "Substitute the given length ($lStr $unit) and breadth ($bStr $unit) into the formula."
      ));
      steps.add(RectangleAreaStep(
          workingLaTeX: "A = $areaStr$u^2",
          explanation: "Multiply the length by the breadth to find the final area. Area is always measured in square units.",
          isFinalAnswer: true
      ));

      return RectangleAreaResult(steps: steps, finalAnswerLaTeX: "A = $areaStr$u^2");
    } catch (_) {
      return RectangleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static RectangleAreaResult solveForLength(String areaInput, String bInput, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      double b = double.parse(bInput.trim());
      List<RectangleAreaStep> steps = [];
      double l = area / b;

      String areaStr = _format(area);
      String bStr = _format(b);
      String lStr = _format(l);

      String u = "\\; \\text{$unit}";

      steps.add(RectangleAreaStep(
          workingLaTeX: "A = l \\times b",
          explanation: "Start with the formula for the area of a rectangle."
      ));
      steps.add(RectangleAreaStep(
          workingLaTeX: "l = \\frac{A}{b}",
          explanation: "Rearrange the formula to solve for length 'l' by dividing the area by the breadth."
      ));
      steps.add(RectangleAreaStep(
          workingLaTeX: "l = \\frac{$areaStr$u^2}{$bStr$u}",
          explanation: "Substitute the given area ($areaStr $unit²) and breadth ($bStr $unit) into the formula."
      ));
      steps.add(RectangleAreaStep(
          workingLaTeX: "l = $lStr$u",
          explanation: "Divide to calculate the final length 'l'.",
          isFinalAnswer: true
      ));

      return RectangleAreaResult(steps: steps, finalAnswerLaTeX: "l = $lStr$u");
    } catch (_) {
      return RectangleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static RectangleAreaResult solveForBreadth(String areaInput, String lInput, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      double l = double.parse(lInput.trim());
      List<RectangleAreaStep> steps = [];
      double b = area / l;

      String areaStr = _format(area);
      String lStr = _format(l);
      String bStr = _format(b);

      String u = "\\; \\text{$unit}";

      steps.add(RectangleAreaStep(
          workingLaTeX: "A = l \\times b",
          explanation: "Start with the formula for the area of a rectangle."
      ));
      steps.add(RectangleAreaStep(
          workingLaTeX: "b = \\frac{A}{l}",
          explanation: "Rearrange the formula to solve for breadth 'b' by dividing the area by the length."
      ));
      steps.add(RectangleAreaStep(
          workingLaTeX: "b = \\frac{$areaStr$u^2}{$lStr$u}",
          explanation: "Substitute the given area ($areaStr $unit²) and length ($lStr $unit) into the formula."
      ));
      steps.add(RectangleAreaStep(
          workingLaTeX: "b = $bStr$u",
          explanation: "Divide to calculate the final breadth 'b'.",
          isFinalAnswer: true
      ));

      return RectangleAreaResult(steps: steps, finalAnswerLaTeX: "b = $bStr$u");
    } catch (_) {
      return RectangleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}