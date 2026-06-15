import 'dart:math';
import 'parallelogram_area_models.dart';

class ParallelogramAreaSolver {
  // Helper to format numbers cleanly
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // ==========================================
  // STANDARD SOLVING METHODS
  // ==========================================

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
        ParallelogramAreaStep(workingLaTeX: "A = b \\times h", explanation: "Start with the general area formula."),
        ParallelogramAreaStep(workingLaTeX: "b = \\frac{A}{h}", explanation: "Rearrange the formula to solve for the base 'b' by dividing the area by the height."),
        ParallelogramAreaStep(workingLaTeX: "b = \\frac{$areaStr$u^2}{$hStr$u}", explanation: "Substitute the given area and height into the formula."),
        ParallelogramAreaStep(workingLaTeX: "b = $bStr$u", explanation: "Divide to calculate the final base 'b'.", isFinalAnswer: true)
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
        ParallelogramAreaStep(workingLaTeX: "A = b \\times h", explanation: "Start with the general area formula."),
        ParallelogramAreaStep(workingLaTeX: "h = \\frac{A}{b}", explanation: "Rearrange the formula to solve for the height 'h' by dividing the area by the base."),
        ParallelogramAreaStep(workingLaTeX: "h = \\frac{$areaStr$u^2}{$bStr$u}", explanation: "Substitute the given area and base into the formula."),
        ParallelogramAreaStep(workingLaTeX: "h = $hStr$u", explanation: "Divide to calculate the final height 'h'.", isFinalAnswer: true)
      ];

      return ParallelogramAreaResult(steps: steps, finalAnswerLaTeX: "h = $hStr$u");
    } catch (_) {
      return ParallelogramAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  // ==========================================
  // WORD PROBLEM / RELATIONSHIP SOLVING METHOD
  // ==========================================

  static ParallelogramAreaResult solveWithRelationship(String areaInput, String multiplierInput, bool isBaseMultipleOfHeight, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      double x = double.parse(multiplierInput.trim());

      List<ParallelogramAreaStep> steps = [];
      String areaStr = _format(area);
      String xStr = _format(x);
      String u = "\\; \\text{$unit}";

      double knownSquared = area / x;
      double solvedPrimary = sqrt(knownSquared);
      double solvedSecondary = x * solvedPrimary;

      String kSqStr = _format(knownSquared);

      steps.add(ParallelogramAreaStep(workingLaTeX: "A = b \\times h", explanation: "Start with the general formula for the area of a parallelogram."));

      if (isBaseMultipleOfHeight) {
        String hStr = _format(solvedPrimary); // Height
        String bStr = _format(solvedSecondary); // Base

        steps.add(ParallelogramAreaStep(workingLaTeX: "b = $xStr \\times h", explanation: "From the word problem, we know the base is $xStr times the height. Substitute 'b' with '$xStr h' in our formula."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "$areaStr = ($xStr h) \\times h", explanation: "Substitute the known Area ($areaStr) and our expression for the base."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "$areaStr = $xStr h^2", explanation: "Multiply '$xStr h' by 'h' to get '$xStr h²'."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "h^2 = \\frac{$areaStr}{$xStr}", explanation: "Rearrange to isolate h² by dividing the Area by $xStr."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "h^2 = $kSqStr", explanation: "Calculate the value of h²."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "h = \\sqrt{$kSqStr} = $hStr$u", explanation: "Take the square root of $kSqStr to find the final Height (h)."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "b = $xStr \\times $hStr = $bStr$u", explanation: "Now multiply the Height by $xStr to find the Base (b).", isFinalAnswer: true));

        return ParallelogramAreaResult(steps: steps, finalAnswerLaTeX: "\\text{Base } (b) = $bStr$u \\\\ \\text{Height } (h) = $hStr$u");

      } else {
        String bStr = _format(solvedPrimary); // Base
        String hStr = _format(solvedSecondary); // Height

        steps.add(ParallelogramAreaStep(workingLaTeX: "h = $xStr \\times b", explanation: "From the problem, we know the height is $xStr times the base. Substitute 'h' with '$xStr b'."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "$areaStr = b \\times ($xStr b)", explanation: "Substitute the known Area ($areaStr) and our expression for the height."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "$areaStr = $xStr b^2", explanation: "Multiply 'b' by '$xStr b' to get '$xStr b²'."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "b^2 = \\frac{$areaStr}{$xStr}", explanation: "Rearrange to isolate b² by dividing the Area by $xStr."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "b^2 = $kSqStr", explanation: "Calculate the value of b²."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "b = \\sqrt{$kSqStr} = $bStr$u", explanation: "Take the square root of $kSqStr to find the final Base (b)."));
        steps.add(ParallelogramAreaStep(workingLaTeX: "h = $xStr \\times $bStr = $hStr$u", explanation: "Now multiply the Base by $xStr to find the Height (h).", isFinalAnswer: true));

        return ParallelogramAreaResult(steps: steps, finalAnswerLaTeX: "\\text{Base } (b) = $bStr$u \\\\ \\text{Height } (h) = $hStr$u");
      }
    } catch (_) {
      return ParallelogramAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}