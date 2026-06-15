// lib/features/junior_secondary/jss1/area/triangle/triangle_area_solver.dart

import 'dart:math'; // Required for sqrt()
import 'triangle_area_models.dart'; // Required for TriangleAreaResult and TriangleAreaStep

class TriangleAreaSolver {
  // Helper to format numbers cleanly (e.g., 5.0 -> 5, 5.25 -> 5.25)
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // ==========================================
  // STANDARD SOLVING METHODS
  // ==========================================

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

  // ==========================================
  // WORD PROBLEM / RELATIONSHIP SOLVING METHOD
  // ==========================================

  static TriangleAreaResult solveWithRelationship(String areaInput, String multiplierInput, bool isHeightMultipleOfBase, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      double x = double.parse(multiplierInput.trim());

      List<TriangleAreaStep> steps = [];
      String areaStr = _format(area);
      String xStr = _format(x);
      String u = "\\; \\text{$unit}";

      double knownSquared;
      double solvedPrimary;
      double solvedSecondary;

      steps.add(TriangleAreaStep(
          workingLaTeX: "A = \\frac{1}{2} \\times b \\times h",
          explanation: "Start with the general formula for the area of a triangle."
      ));

      if (isHeightMultipleOfBase) {
        // Height is x times Base (h = xb)
        knownSquared = (2 * area) / x;
        solvedPrimary = sqrt(knownSquared); // This is Base
        solvedSecondary = x * solvedPrimary; // This is Height

        String kSqStr = _format(knownSquared);
        String bStr = _format(solvedPrimary);
        String hStr = _format(solvedSecondary);

        steps.add(TriangleAreaStep(
            workingLaTeX: "h = $xStr \\times b",
            explanation: "From the word problem, we know the height is $xStr times the base. We substitute 'h' with '$xStr b' in our formula."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "$areaStr = \\frac{1}{2} \\times b \\times ($xStr b)",
            explanation: "Substitute the known Area ($areaStr) and our new expression for height into the formula."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "$areaStr = \\frac{$xStr}{2}b^2",
            explanation: "Multiply 'b' by '$xStr b' to get '$xStr b²'."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "b^2 = \\frac{2 \\times $areaStr}{$xStr}",
            explanation: "Rearrange the equation to isolate b² by multiplying the Area by 2 and dividing by $xStr."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "b^2 = $kSqStr",
            explanation: "Calculate the value of b²."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "b = \\sqrt{$kSqStr} = $bStr$u",
            explanation: "Take the square root of $kSqStr to find the final length of the Base (b)."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "h = $xStr \\times $bStr = $hStr$u",
            explanation: "Now multiply the Base by $xStr to find the Height (h).",
            isFinalAnswer: true
        ));

        return TriangleAreaResult(steps: steps, finalAnswerLaTeX: "\\text{Base } (b) = $bStr$u \\\\ \\text{Height } (h) = $hStr$u");

      } else {
        // Base is x times Height (b = xh)
        knownSquared = (2 * area) / x;
        solvedPrimary = sqrt(knownSquared); // This is Height
        solvedSecondary = x * solvedPrimary; // This is Base

        String kSqStr = _format(knownSquared);
        String hStr = _format(solvedPrimary);
        String bStr = _format(solvedSecondary);

        steps.add(TriangleAreaStep(
            workingLaTeX: "b = $xStr \\times h",
            explanation: "From the problem, we know the base is $xStr times the height. We substitute 'b' with '$xStr h'."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "$areaStr = \\frac{1}{2} \\times ($xStr h) \\times h",
            explanation: "Substitute the known Area ($areaStr) and our new expression for base into the formula."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "$areaStr = \\frac{$xStr}{2}h^2",
            explanation: "Multiply '$xStr h' by 'h' to get '$xStr h²'."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "h^2 = \\frac{2 \\times $areaStr}{$xStr}",
            explanation: "Rearrange the equation to isolate h² by multiplying the Area by 2 and dividing by $xStr."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "h^2 = $kSqStr",
            explanation: "Calculate the value of h²."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "h = \\sqrt{$kSqStr} = $hStr$u",
            explanation: "Take the square root of $kSqStr to find the final length of the Height (h)."
        ));
        steps.add(TriangleAreaStep(
            workingLaTeX: "b = $xStr \\times $hStr = $bStr$u",
            explanation: "Now multiply the Height by $xStr to find the Base (b).",
            isFinalAnswer: true
        ));

        return TriangleAreaResult(steps: steps, finalAnswerLaTeX: "\\text{Base } (b) = $bStr$u \\\\ \\text{Height } (h) = $hStr$u");
      }
    } catch (_) {
      return TriangleAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}