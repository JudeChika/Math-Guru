import 'dart:math';
import 'rectangle_area_models.dart';

class RectangleAreaSolver {
  // Helper to format numbers cleanly (e.g., 5.0 -> 5, 5.25 -> 5.25)
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // ==========================================
  // STANDARD SOLVING METHODS
  // ==========================================

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

  // ==========================================
  // WORD PROBLEM / RELATIONSHIP SOLVING METHOD
  // ==========================================

  static RectangleAreaResult solveWithRelationship(String areaInput, String multiplierInput, bool isLengthMultipleOfBreadth, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      double x = double.parse(multiplierInput.trim());

      List<RectangleAreaStep> steps = [];
      String areaStr = _format(area);
      String xStr = _format(x);
      String u = "\\; \\text{$unit}";

      double knownSquared = area / x;
      double solvedPrimary = sqrt(knownSquared);
      double solvedSecondary = x * solvedPrimary;

      String kSqStr = _format(knownSquared);

      steps.add(RectangleAreaStep(
          workingLaTeX: "A = l \\times b",
          explanation: "Start with the general formula for the area of a rectangle."
      ));

      if (isLengthMultipleOfBreadth) {
        // Length is x times Breadth (l = xb)
        String bStr = _format(solvedPrimary); // This is Breadth
        String lStr = _format(solvedSecondary); // This is Length

        steps.add(RectangleAreaStep(
            workingLaTeX: "l = $xStr \\times b",
            explanation: "From the word problem, we know the length is $xStr times the breadth. We substitute 'l' with '$xStr b' in our formula."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "$areaStr = ($xStr b) \\times b",
            explanation: "Substitute the known Area ($areaStr) and our new expression for length into the formula."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "$areaStr = $xStr b^2",
            explanation: "Multiply '$xStr b' by 'b' to get '$xStr b²'."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "b^2 = \\frac{$areaStr}{$xStr}",
            explanation: "Rearrange the equation to isolate b² by dividing the Area by $xStr."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "b^2 = $kSqStr",
            explanation: "Calculate the value of b²."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "b = \\sqrt{$kSqStr} = $bStr$u",
            explanation: "Take the square root of $kSqStr to find the final length of the Breadth (b)."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "l = $xStr \\times $bStr = $lStr$u",
            explanation: "Now multiply the Breadth by $xStr to find the Length (l).",
            isFinalAnswer: true
        ));

        return RectangleAreaResult(steps: steps, finalAnswerLaTeX: "\\text{Length } (l) = $lStr$u \\\\ \\text{Breadth } (b) = $bStr$u");

      } else {
        // Breadth is x times Length (b = xl)
        String lStr = _format(solvedPrimary); // This is Length
        String bStr = _format(solvedSecondary); // This is Breadth

        steps.add(RectangleAreaStep(
            workingLaTeX: "b = $xStr \\times l",
            explanation: "From the problem, we know the breadth is $xStr times the length. We substitute 'b' with '$xStr l'."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "$areaStr = l \\times ($xStr l)",
            explanation: "Substitute the known Area ($areaStr) and our new expression for breadth into the formula."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "$areaStr = $xStr l^2",
            explanation: "Multiply 'l' by '$xStr l' to get '$xStr l²'."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "l^2 = \\frac{$areaStr}{$xStr}",
            explanation: "Rearrange the equation to isolate l² by dividing the Area by $xStr."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "l^2 = $kSqStr",
            explanation: "Calculate the value of l²."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "l = \\sqrt{$kSqStr} = $lStr$u",
            explanation: "Take the square root of $kSqStr to find the final length of the Length (l)."
        ));
        steps.add(RectangleAreaStep(
            workingLaTeX: "b = $xStr \\times $lStr = $bStr$u",
            explanation: "Now multiply the Length by $xStr to find the Breadth (b).",
            isFinalAnswer: true
        ));

        return RectangleAreaResult(steps: steps, finalAnswerLaTeX: "\\text{Length } (l) = $lStr$u \\\\ \\text{Breadth } (b) = $bStr$u");
      }
    } catch (_) {
      return RectangleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}