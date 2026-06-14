import 'parallelogram_area_models.dart';

class ParallelogramAreaSolver {
  // Helper to format numbers cleanly (e.g., 5.0 -> 5, 5.25 -> 5.25)
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  static ParallelogramAreaResult solveForArea(String bIn, String hIn, String unit) {
    try {
      double b = double.parse(bIn.trim());
      double h = double.parse(hIn.trim());

      double area = b * h;

      String bStr = _format(b);
      String hStr = _format(h);
      String areaStr = _format(area);
      String u = "\\; \\text{$unit}";

      List<ParallelogramAreaStep> steps = [
        ParallelogramAreaStep(
            workingLaTeX: "A = b \\times h",
            explanation: "Start with the formula for the area of a parallelogram, where 'A' is area, 'b' is the base, and 'h' is the perpendicular height."
        ),
        ParallelogramAreaStep(
            workingLaTeX: "A = $bStr$u \\times $hStr$u",
            explanation: "Substitute the given base ($bStr $unit) and height ($hStr $unit) into the formula."
        ),
        ParallelogramAreaStep(
            workingLaTeX: "A = $areaStr$u^2",
            explanation: "Multiply the base by the height to find the final area. Area is always measured in square units.",
            isFinalAnswer: true
        )
      ];

      return ParallelogramAreaResult(steps: steps, finalAnswerLaTeX: "A = $areaStr$u^2");
    } catch (_) {
      return ParallelogramAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static ParallelogramAreaResult solveForBase(String areaIn, String hIn, String unit) {
    try {
      double area = double.parse(areaIn.trim());
      double h = double.parse(hIn.trim());

      double b = area / h;

      String areaStr = _format(area);
      String hStr = _format(h);
      String bStr = _format(b);
      String u = "\\; \\text{$unit}";

      List<ParallelogramAreaStep> steps = [
        ParallelogramAreaStep(
            workingLaTeX: "A = b \\times h",
            explanation: "Start with the general area formula."
        ),
        ParallelogramAreaStep(
            workingLaTeX: "b = \\frac{A}{h}",
            explanation: "Rearrange the formula to solve for the base 'b' by dividing the area by the height."
        ),
        ParallelogramAreaStep(
            workingLaTeX: "b = \\frac{$areaStr$u^2}{$hStr$u}",
            explanation: "Substitute the given area ($areaStr $unit²) and height ($hStr $unit) into the formula."
        ),
        ParallelogramAreaStep(
            workingLaTeX: "b = $bStr$u",
            explanation: "Divide to calculate the final base 'b'.",
            isFinalAnswer: true
        )
      ];

      return ParallelogramAreaResult(steps: steps, finalAnswerLaTeX: "b = $bStr$u");
    } catch (_) {
      return ParallelogramAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static ParallelogramAreaResult solveForHeight(String areaIn, String bIn, String unit) {
    try {
      double area = double.parse(areaIn.trim());
      double b = double.parse(bIn.trim());

      double h = area / b;

      String areaStr = _format(area);
      String bStr = _format(b);
      String hStr = _format(h);
      String u = "\\; \\text{$unit}";

      List<ParallelogramAreaStep> steps = [
        ParallelogramAreaStep(
            workingLaTeX: "A = b \\times h",
            explanation: "Start with the general area formula."
        ),
        ParallelogramAreaStep(
            workingLaTeX: "h = \\frac{A}{b}",
            explanation: "Rearrange the formula to solve for the height 'h' by dividing the area by the base."
        ),
        ParallelogramAreaStep(
            workingLaTeX: "h = \\frac{$areaStr$u^2}{$bStr$u}",
            explanation: "Substitute the given area ($areaStr $unit²) and base ($bStr $unit) into the formula."
        ),
        ParallelogramAreaStep(
            workingLaTeX: "h = $hStr$u",
            explanation: "Divide to calculate the final height 'h'.",
            isFinalAnswer: true
        )
      ];

      return ParallelogramAreaResult(steps: steps, finalAnswerLaTeX: "h = $hStr$u");
    } catch (_) {
      return ParallelogramAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}