import 'trapezium_area_models.dart';

class TrapeziumAreaSolver {
  // Helper to format numbers cleanly (e.g., 5.0 -> 5, 5.25 -> 5.25)
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  static TrapeziumAreaResult solveForArea(String aIn, String bIn, String hIn, String unit) {
    try {
      double a = double.parse(aIn.trim());
      double b = double.parse(bIn.trim());
      double h = double.parse(hIn.trim());

      double sumAB = a + b;
      double sumTimesHeight = sumAB * h;
      double area = 0.5 * sumTimesHeight;

      String aStr = _format(a);
      String bStr = _format(b);
      String hStr = _format(h);
      String sumStr = _format(sumAB);
      String sthStr = _format(sumTimesHeight);
      String areaStr = _format(area);
      String u = "\\; \\text{$unit}";

      List<TrapeziumAreaStep> steps = [
        TrapeziumAreaStep(
            workingLaTeX: "A = \\frac{1}{2}(a + b)h",
            explanation: "Start with the formula for the area of a trapezium, where 'a' and 'b' are the parallel sides, and 'h' is the height."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "A = \\frac{1}{2}($aStr$u + $bStr$u) \\times $hStr$u",
            explanation: "Substitute the given values into the formula."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "A = \\frac{1}{2}($sumStr$u) \\times $hStr$u",
            explanation: "First, add the parallel sides inside the bracket together (BODMAS)."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "A = \\frac{1}{2} \\times $sthStr$u^2",
            explanation: "Multiply the sum by the height."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "A = $areaStr$u^2",
            explanation: "Divide the result by 2 to find the final area. Area is measured in square units.",
            isFinalAnswer: true
        )
      ];

      return TrapeziumAreaResult(steps: steps, finalAnswerLaTeX: "A = $areaStr$u^2");
    } catch (_) {
      return TrapeziumAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static TrapeziumAreaResult solveForHeight(String areaIn, String aIn, String bIn, String unit) {
    try {
      double area = double.parse(areaIn.trim());
      double a = double.parse(aIn.trim());
      double b = double.parse(bIn.trim());

      double twoArea = 2 * area;
      double sumAB = a + b;
      double h = twoArea / sumAB;

      String areaStr = _format(area);
      String aStr = _format(a);
      String bStr = _format(b);
      String twoAreaStr = _format(twoArea);
      String sumStr = _format(sumAB);
      String hStr = _format(h);
      String u = "\\; \\text{$unit}";

      List<TrapeziumAreaStep> steps = [
        TrapeziumAreaStep(
            workingLaTeX: "A = \\frac{1}{2}(a + b)h",
            explanation: "Start with the general area formula."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "h = \\frac{2A}{(a + b)}",
            explanation: "Rearrange the formula to solve for the height 'h' by multiplying the area by 2 and dividing by the sum of the parallel sides."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "h = \\frac{2 \\times $areaStr$u^2}{($aStr$u + $bStr$u)}",
            explanation: "Substitute the given area ($areaStr $unit²) and parallel sides into the formula."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "h = \\frac{$twoAreaStr$u^2}{$sumStr$u}",
            explanation: "Multiply the area by 2 and add the parallel sides together."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "h = $hStr$u",
            explanation: "Divide to calculate the final height 'h'.",
            isFinalAnswer: true
        )
      ];

      return TrapeziumAreaResult(steps: steps, finalAnswerLaTeX: "h = $hStr$u");
    } catch (_) {
      return TrapeziumAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static TrapeziumAreaResult solveForSide(String areaIn, String knownSideIn, String hIn, String unit, bool isSolvingForA) {
    try {
      double area = double.parse(areaIn.trim());
      double knownSide = double.parse(knownSideIn.trim());
      double h = double.parse(hIn.trim());

      double twoArea = 2 * area;
      double divH = twoArea / h;
      double unknownSide = divH - knownSide;

      String areaStr = _format(area);
      String kStr = _format(knownSide);
      String hStr = _format(h);
      String twoAreaStr = _format(twoArea);
      String divHStr = _format(divH);
      String uStr = _format(unknownSide);
      String u = "\\; \\text{$unit}";

      String solveVar = isSolvingForA ? "a" : "b";
      String knownVar = isSolvingForA ? "b" : "a";

      List<TrapeziumAreaStep> steps = [
        TrapeziumAreaStep(
            workingLaTeX: "A = \\frac{1}{2}(a + b)h",
            explanation: "Start with the general area formula."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "$solveVar = \\frac{2A}{h} - $knownVar",
            explanation: "Rearrange the formula to solve for the unknown parallel side '$solveVar'."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "$solveVar = \\frac{2 \\times $areaStr$u^2}{$hStr$u} - $kStr$u",
            explanation: "Substitute the given area ($areaStr $unit²), height ($hStr $unit), and known side '$knownVar' ($kStr $unit)."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "$solveVar = \\frac{$twoAreaStr$u^2}{$hStr$u} - $kStr$u",
            explanation: "Multiply the area by 2."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "$solveVar = $divHStr$u - $kStr$u",
            explanation: "Divide the top result by the height."
        ),
        TrapeziumAreaStep(
            workingLaTeX: "$solveVar = $uStr$u",
            explanation: "Subtract the known side to find the final length of '$solveVar'.",
            isFinalAnswer: true
        )
      ];

      return TrapeziumAreaResult(steps: steps, finalAnswerLaTeX: "$solveVar = $uStr$u");
    } catch (_) {
      return TrapeziumAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}