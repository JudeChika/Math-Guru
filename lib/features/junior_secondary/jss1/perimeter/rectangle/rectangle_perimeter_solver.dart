import 'rectangle_perimeter_models.dart';

class RectanglePerimeterSolver {
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // ==========================================
  // STANDARD SOLVING METHODS
  // ==========================================

  static GeometryResult solveForPerimeter(String lIn, String bIn, String unit) {
    try {
      double l = double.parse(lIn.trim());
      double b = double.parse(bIn.trim());

      double sum = l + b;
      double perimeter = 2 * sum;

      String lStr = _format(l);
      String bStr = _format(b);
      String sumStr = _format(sum);
      String pStr = _format(perimeter);
      String u = "\\; \\text{$unit}";

      List<GeometrySolutionStep> steps = [
        GeometrySolutionStep(workingLaTeX: "P = 2(l + b)", explanation: "Start with the formula for the perimeter of a rectangle."),
        GeometrySolutionStep(workingLaTeX: "P = 2($lStr$u + $bStr$u)", explanation: "Substitute the given length and breadth into the formula."),
        GeometrySolutionStep(workingLaTeX: "P = 2($sumStr$u)", explanation: "Add the length and breadth inside the bracket (BODMAS)."),
        GeometrySolutionStep(workingLaTeX: "P = $pStr$u", explanation: "Multiply the sum by 2 to find the final perimeter.", isFinalAnswer: true)
      ];

      return GeometryResult(steps: steps, finalAnswerLaTeX: "P = $pStr$u");
    } catch (_) {
      return GeometryResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static GeometryResult solveForSide(String pIn, String knownSideIn, String unit, bool isSolvingForLength) {
    try {
      double p = double.parse(pIn.trim());
      double knownSide = double.parse(knownSideIn.trim());

      double pDiv2 = p / 2;
      double unknownSide = pDiv2 - knownSide;

      String pStr = _format(p);
      String kStr = _format(knownSide);
      String pDiv2Str = _format(pDiv2);
      String uStr = _format(unknownSide);
      String u = "\\; \\text{$unit}";

      String solveVar = isSolvingForLength ? "l" : "b";
      String knownVar = isSolvingForLength ? "b" : "l";

      List<GeometrySolutionStep> steps = [
        GeometrySolutionStep(workingLaTeX: "P = 2(l + b)", explanation: "Start with the general perimeter formula."),
        GeometrySolutionStep(workingLaTeX: "\\frac{P}{2} = l + b", explanation: "Divide both sides by 2 to remove the bracket."),
        GeometrySolutionStep(workingLaTeX: "$solveVar = \\frac{P}{2} - $knownVar", explanation: "Rearrange to solve for the unknown side '$solveVar'."),
        GeometrySolutionStep(workingLaTeX: "$solveVar = \\frac{$pStr$u}{2} - $kStr$u", explanation: "Substitute the given perimeter and known side '$knownVar'."),
        GeometrySolutionStep(workingLaTeX: "$solveVar = $pDiv2Str$u - $kStr$u", explanation: "Divide the perimeter by 2."),
        GeometrySolutionStep(workingLaTeX: "$solveVar = $uStr$u", explanation: "Subtract the known side to find the final length of '$solveVar'.", isFinalAnswer: true)
      ];

      return GeometryResult(steps: steps, finalAnswerLaTeX: "$solveVar = $uStr$u");
    } catch (_) {
      return GeometryResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  // ==========================================
  // WORD PROBLEM / RELATIONSHIP SOLVING METHOD
  // ==========================================

  static GeometryResult solveWithRelationship(String pIn, String multiplierIn, bool isLengthMultipleOfBreadth, String unit) {
    try {
      double p = double.parse(pIn.trim());
      double x = double.parse(multiplierIn.trim());

      List<GeometrySolutionStep> steps = [];
      String pStr = _format(p);
      String xStr = _format(x);
      String u = "\\; \\text{$unit}";

      // Math: P = 2(l + b). If l = xb -> P = 2(xb + b) = 2b(x + 1)
      double bracketSum = x + 1;
      double denominator = 2 * bracketSum;
      double solvedPrimary = p / denominator;
      double solvedSecondary = x * solvedPrimary;

      String sumStr = _format(bracketSum);
      String denStr = _format(denominator);

      steps.add(GeometrySolutionStep(workingLaTeX: "P = 2(l + b)", explanation: "Start with the general formula for the perimeter of a rectangle."));

      if (isLengthMultipleOfBreadth) {
        String bStr = _format(solvedPrimary); // Breadth
        String lStr = _format(solvedSecondary); // Length

        steps.add(GeometrySolutionStep(workingLaTeX: "l = $xStr \\times b", explanation: "From the word problem, we know the length is $xStr times the breadth. Substitute 'l' with '$xStr b'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2($xStr b + b)", explanation: "Substitute the known Perimeter ($pStr) and our expression for the length."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2(b($xStr + 1))", explanation: "Factor out 'b' inside the bracket."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2($sumStr b)", explanation: "Add the numbers inside the inner bracket."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = $denStr b", explanation: "Multiply the outer 2 by the inner sum to get '$denStr b'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "b = \\frac{$pStr}{$denStr}", explanation: "Rearrange to isolate 'b'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "b = $bStr$u", explanation: "Divide to find the final length of the Breadth (b)."));
        steps.add(GeometrySolutionStep(workingLaTeX: "l = $xStr \\times $bStr = $lStr$u", explanation: "Now multiply the Breadth by $xStr to find the Length (l).", isFinalAnswer: true));

        return GeometryResult(steps: steps, finalAnswerLaTeX: "\\text{Length } (l) = $lStr$u \\\\ \\text{Breadth } (b) = $bStr$u");
      } else {
        String lStr = _format(solvedPrimary); // Length
        String bStr = _format(solvedSecondary); // Breadth

        steps.add(GeometrySolutionStep(workingLaTeX: "b = $xStr \\times l", explanation: "From the word problem, we know the breadth is $xStr times the length. Substitute 'b' with '$xStr l'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2(l + $xStr l)", explanation: "Substitute the known Perimeter ($pStr) and our expression for the breadth."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2(l(1 + $xStr))", explanation: "Factor out 'l' inside the bracket."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2($sumStr l)", explanation: "Add the numbers inside the inner bracket."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = $denStr l", explanation: "Multiply the outer 2 by the inner sum to get '$denStr l'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "l = \\frac{$pStr}{$denStr}", explanation: "Rearrange to isolate 'l'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "l = $lStr$u", explanation: "Divide to find the final length of the Length (l)."));
        steps.add(GeometrySolutionStep(workingLaTeX: "b = $xStr \\times $lStr = $bStr$u", explanation: "Now multiply the Length by $xStr to find the Breadth (b).", isFinalAnswer: true));

        return GeometryResult(steps: steps, finalAnswerLaTeX: "\\text{Length } (l) = $lStr$u \\\\ \\text{Breadth } (b) = $bStr$u");
      }
    } catch (_) {
      return GeometryResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}