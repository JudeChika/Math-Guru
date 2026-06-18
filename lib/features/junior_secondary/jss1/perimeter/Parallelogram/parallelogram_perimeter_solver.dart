import 'parallelogram_perimeter_models.dart';

class ParallelogramPerimeterSolver {
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // ==========================================
  // STANDARD SOLVING METHODS
  // ==========================================

  static GeometryResult solveForPerimeter(String aIn, String bIn, String unit) {
    try {
      double a = double.parse(aIn.trim());
      double b = double.parse(bIn.trim());

      double sum = a + b;
      double perimeter = 2 * sum;

      String aStr = _format(a);
      String bStr = _format(b);
      String sumStr = _format(sum);
      String pStr = _format(perimeter);
      String u = "\\; \\text{$unit}";

      List<GeometrySolutionStep> steps = [
        GeometrySolutionStep(workingLaTeX: "P = 2(a + b)", explanation: "Start with the formula for the perimeter of a parallelogram (where 'a' and 'b' are adjacent sides)."),
        GeometrySolutionStep(workingLaTeX: "P = 2($aStr$u + $bStr$u)", explanation: "Substitute the given sides into the formula."),
        GeometrySolutionStep(workingLaTeX: "P = 2($sumStr$u)", explanation: "Add the sides inside the bracket together."),
        GeometrySolutionStep(workingLaTeX: "P = $pStr$u", explanation: "Multiply the sum by 2 to find the final perimeter.", isFinalAnswer: true)
      ];

      return GeometryResult(steps: steps, finalAnswerLaTeX: "P = $pStr$u");
    } catch (_) {
      return GeometryResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static GeometryResult solveForSide(String pIn, String knownSideIn, String unit, bool isSolvingForA) {
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

      String solveVar = isSolvingForA ? "a" : "b";
      String knownVar = isSolvingForA ? "b" : "a";

      List<GeometrySolutionStep> steps = [
        GeometrySolutionStep(workingLaTeX: "P = 2(a + b)", explanation: "Start with the general perimeter formula."),
        GeometrySolutionStep(workingLaTeX: "\\frac{P}{2} = a + b", explanation: "Divide both sides by 2 to remove the bracket."),
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

  static GeometryResult solveWithRelationship(String pIn, String multiplierIn, bool isAMultipleOfB, String unit) {
    try {
      double p = double.parse(pIn.trim());
      double x = double.parse(multiplierIn.trim());

      List<GeometrySolutionStep> steps = [];
      String pStr = _format(p);
      String xStr = _format(x);
      String u = "\\; \\text{$unit}";

      double bracketSum = x + 1;
      double denominator = 2 * bracketSum;
      double solvedPrimary = p / denominator;
      double solvedSecondary = x * solvedPrimary;

      String sumStr = _format(bracketSum);
      String denStr = _format(denominator);

      steps.add(GeometrySolutionStep(workingLaTeX: "P = 2(a + b)", explanation: "Start with the general formula for the perimeter of a parallelogram."));

      if (isAMultipleOfB) {
        String bStr = _format(solvedPrimary); // Side b
        String aStr = _format(solvedSecondary); // Side a

        steps.add(GeometrySolutionStep(workingLaTeX: "a = $xStr \\times b", explanation: "From the word problem, we know side 'a' is $xStr times side 'b'. Substitute 'a' with '$xStr b'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2($xStr b + b)", explanation: "Substitute the known Perimeter ($pStr) and our expression for side 'a'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2(b($xStr + 1))", explanation: "Factor out 'b' inside the bracket."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2($sumStr b)", explanation: "Add the numbers inside the inner bracket."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = $denStr b", explanation: "Multiply the outer 2 by the inner sum to get '$denStr b'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "b = \\frac{$pStr}{$denStr}", explanation: "Rearrange to isolate 'b'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "b = $bStr$u", explanation: "Divide to find the final length of Side 'b'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "a = $xStr \\times $bStr = $aStr$u", explanation: "Now multiply Side 'b' by $xStr to find Side 'a'.", isFinalAnswer: true));

        return GeometryResult(steps: steps, finalAnswerLaTeX: "\\text{Side } (a) = $aStr$u \\\\ \\text{Side } (b) = $bStr$u");
      } else {
        String aStr = _format(solvedPrimary); // Side a
        String bStr = _format(solvedSecondary); // Side b

        steps.add(GeometrySolutionStep(workingLaTeX: "b = $xStr \\times a", explanation: "From the problem, we know side 'b' is $xStr times side 'a'. Substitute 'b' with '$xStr a'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2(a + $xStr a)", explanation: "Substitute the known Perimeter ($pStr) and our expression for side 'b'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2(a(1 + $xStr))", explanation: "Factor out 'a' inside the bracket."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = 2($sumStr a)", explanation: "Add the numbers inside the inner bracket."));
        steps.add(GeometrySolutionStep(workingLaTeX: "$pStr = $denStr a", explanation: "Multiply the outer 2 by the inner sum to get '$denStr a'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "a = \\frac{$pStr}{$denStr}", explanation: "Rearrange to isolate 'a'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "a = $aStr$u", explanation: "Divide to find the final length of Side 'a'."));
        steps.add(GeometrySolutionStep(workingLaTeX: "b = $xStr \\times $aStr = $bStr$u", explanation: "Now multiply Side 'a' by $xStr to find Side 'b'.", isFinalAnswer: true));

        return GeometryResult(steps: steps, finalAnswerLaTeX: "\\text{Side } (a) = $aStr$u \\\\ \\text{Side } (b) = $bStr$u");
      }
    } catch (_) {
      return GeometryResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}