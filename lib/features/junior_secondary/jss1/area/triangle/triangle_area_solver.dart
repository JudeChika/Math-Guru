import 'triangle_area_models.dart';

class TriangleAreaSolver {
  // Helper to format numbers cleanly (e.g., 5.0 -> 5, 5.25 -> 5.25)
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  static TriangleAreaResult solveForArea(String bInput, String hInput, String unit) {
    try {
      double b = double.parse(bInput.trim());
      double h = double.parse(hInput.trim());
      List<TriangleAreaStep> steps = [];

      double baseTimesHeight = b * h;
      double area = 0.5 * baseTimesHeight;

      String bStr = _format(b);
      String hStr = _format(h);
      String bhStr = _format(baseTimesHeight);
      String areaStr = _format(area);

      String u = "\\; \\text{$unit}";

      steps.add(TriangleAreaStep(
          workingLaTeX: "A = \\frac{1}{2} \\times b \\times h",
          explanation: "Start with the formula for the area of a triangle, where 'A' is area, 'b' is base, and 'h' is the perpendicular height."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "A = \\frac{1}{2} \\times $bStr$u \\times $hStr$u",
          explanation: "Substitute the given base ($bStr $unit) and height ($hStr $unit) into the formula."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "A = \\frac{1}{2} \\times $bhStr$u^2",
          explanation: "Multiply the base by the height."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "A = $areaStr$u^2",
          explanation: "Divide the result by 2 to find the final area. Area is always measured in square units.",
          isFinalAnswer: true
      ));

      return TriangleAreaResult(steps: steps, finalAnswerLaTeX: "A = $areaStr$u^2");
    } catch (_) {
      return TriangleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static TriangleAreaResult solveForBase(String areaInput, String hInput, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      double h = double.parse(hInput.trim());
      List<TriangleAreaStep> steps = [];

      double twoTimesArea = 2 * area;
      double b = twoTimesArea / h;

      String areaStr = _format(area);
      String hStr = _format(h);
      String twoAreaStr = _format(twoTimesArea);
      String bStr = _format(b);

      String u = "\\; \\text{$unit}";

      steps.add(TriangleAreaStep(
          workingLaTeX: "A = \\frac{1}{2} \\times b \\times h",
          explanation: "Start with the general formula for the area of a triangle."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "b = \\frac{2 \\times A}{h}",
          explanation: "Rearrange the formula to solve for the base 'b' by multiplying the area by 2 and dividing by the height."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "b = \\frac{2 \\times $areaStr$u^2}{$hStr$u}",
          explanation: "Substitute the given area ($areaStr $unit²) and height ($hStr $unit) into the formula."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "b = \\frac{$twoAreaStr$u^2}{$hStr$u}",
          explanation: "Multiply the area by 2."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "b = $bStr$u",
          explanation: "Divide by the height to calculate the final base 'b'.",
          isFinalAnswer: true
      ));

      return TriangleAreaResult(steps: steps, finalAnswerLaTeX: "b = $bStr$u");
    } catch (_) {
      return TriangleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static TriangleAreaResult solveForHeight(String areaInput, String bInput, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      double b = double.parse(bInput.trim());
      List<TriangleAreaStep> steps = [];

      double twoTimesArea = 2 * area;
      double h = twoTimesArea / b;

      String areaStr = _format(area);
      String bStr = _format(b);
      String twoAreaStr = _format(twoTimesArea);
      String hStr = _format(h);

      String u = "\\; \\text{$unit}";

      steps.add(TriangleAreaStep(
          workingLaTeX: "A = \\frac{1}{2} \\times b \\times h",
          explanation: "Start with the general formula for the area of a triangle."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "h = \\frac{2 \\times A}{b}",
          explanation: "Rearrange the formula to solve for the height 'h' by multiplying the area by 2 and dividing by the base."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "h = \\frac{2 \\times $areaStr$u^2}{$bStr$u}",
          explanation: "Substitute the given area ($areaStr $unit²) and base ($bStr $unit) into the formula."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "h = \\frac{$twoAreaStr$u^2}{$bStr$u}",
          explanation: "Multiply the area by 2."
      ));
      steps.add(TriangleAreaStep(
          workingLaTeX: "h = $hStr$u",
          explanation: "Divide by the base to calculate the final height 'h'.",
          isFinalAnswer: true
      ));

      return TriangleAreaResult(steps: steps, finalAnswerLaTeX: "h = $hStr$u");
    } catch (_) {
      return TriangleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}