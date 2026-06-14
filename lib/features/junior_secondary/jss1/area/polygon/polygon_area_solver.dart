import 'polygon_area_models.dart';

class PolygonAreaSolver {
  // Helper to format numbers cleanly (e.g., 5.0 -> 5, 5.25 -> 5.25)
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  static PolygonAreaResult solveForArea(String nIn, String lIn, String aIn, String unit) {
    try {
      double n = double.parse(nIn.trim());
      double l = double.parse(lIn.trim());
      double apothem = double.parse(aIn.trim());

      double product = n * l * apothem;
      double area = 0.5 * product;

      String nStr = _format(n);
      String lStr = _format(l);
      String aStr = _format(apothem);
      String pStr = _format(product);
      String areaStr = _format(area);
      String u = "\\; \\text{$unit}";

      List<PolygonAreaStep> steps = [
        PolygonAreaStep(
            workingLaTeX: "A = \\frac{1}{2} \\times n \\times l \\times a",
            explanation: "Start with the formula for the area of a regular polygon, where 'n' is the number of sides, 'l' is side length, and 'a' is the apothem."
        ),
        PolygonAreaStep(
            workingLaTeX: "A = \\frac{1}{2} \\times $nStr \\times $lStr$u \\times $aStr$u",
            explanation: "Substitute the given values into the formula."
        ),
        PolygonAreaStep(
            workingLaTeX: "A = \\frac{1}{2} \\times $pStr$u^2",
            explanation: "Multiply the number of sides, the side length, and the apothem together."
        ),
        PolygonAreaStep(
            workingLaTeX: "A = $areaStr$u^2",
            explanation: "Divide the result by 2 to find the final area.",
            isFinalAnswer: true
        )
      ];

      return PolygonAreaResult(steps: steps, finalAnswerLaTeX: "A = $areaStr$u^2");
    } catch (_) {
      return PolygonAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static PolygonAreaResult solveForSideLength(String areaIn, String nIn, String aIn, String unit) {
    try {
      double area = double.parse(areaIn.trim());
      double n = double.parse(nIn.trim());
      double apothem = double.parse(aIn.trim());

      double twoArea = 2 * area;
      double na = n * apothem;
      double l = twoArea / na;

      String areaStr = _format(area);
      String nStr = _format(n);
      String aStr = _format(apothem);
      String twoAreaStr = _format(twoArea);
      String naStr = _format(na);
      String lStr = _format(l);
      String u = "\\; \\text{$unit}";

      List<PolygonAreaStep> steps = [
        PolygonAreaStep(
            workingLaTeX: "A = \\frac{1}{2} \\times n \\times l \\times a",
            explanation: "Start with the general area formula."
        ),
        PolygonAreaStep(
            workingLaTeX: "l = \\frac{2 \\times A}{n \\times a}",
            explanation: "Rearrange the formula to solve for the side length 'l'."
        ),
        PolygonAreaStep(
            workingLaTeX: "l = \\frac{2 \\times $areaStr$u^2}{$nStr \\times $aStr$u}",
            explanation: "Substitute the given area ($areaStr $unit²), sides ($nStr), and apothem ($aStr $unit) into the formula."
        ),
        PolygonAreaStep(
            workingLaTeX: "l = \\frac{$twoAreaStr$u^2}{$naStr$u}",
            explanation: "Multiply the numerator values and denominator values."
        ),
        PolygonAreaStep(
            workingLaTeX: "l = $lStr$u",
            explanation: "Divide to calculate the final side length 'l'.",
            isFinalAnswer: true
        )
      ];

      return PolygonAreaResult(steps: steps, finalAnswerLaTeX: "l = $lStr$u");
    } catch (_) {
      return PolygonAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static PolygonAreaResult solveForApothem(String areaIn, String nIn, String lIn, String unit) {
    try {
      double area = double.parse(areaIn.trim());
      double n = double.parse(nIn.trim());
      double l = double.parse(lIn.trim());

      double twoArea = 2 * area;
      double nl = n * l;
      double apothem = twoArea / nl;

      String areaStr = _format(area);
      String nStr = _format(n);
      String lStr = _format(l);
      String twoAreaStr = _format(twoArea);
      String nlStr = _format(nl);
      String aStr = _format(apothem);
      String u = "\\; \\text{$unit}";

      List<PolygonAreaStep> steps = [
        PolygonAreaStep(
            workingLaTeX: "A = \\frac{1}{2} \\times n \\times l \\times a",
            explanation: "Start with the general area formula."
        ),
        PolygonAreaStep(
            workingLaTeX: "a = \\frac{2 \\times A}{n \\times l}",
            explanation: "Rearrange the formula to solve for the apothem 'a'."
        ),
        PolygonAreaStep(
            workingLaTeX: "a = \\frac{2 \\times $areaStr$u^2}{$nStr \\times $lStr$u}",
            explanation: "Substitute the given area, sides, and side length into the formula."
        ),
        PolygonAreaStep(
            workingLaTeX: "a = \\frac{$twoAreaStr$u^2}{$nlStr$u}",
            explanation: "Simplify the numerator and the denominator."
        ),
        PolygonAreaStep(
            workingLaTeX: "a = $aStr$u",
            explanation: "Divide to calculate the final apothem 'a'.",
            isFinalAnswer: true
        )
      ];

      return PolygonAreaResult(steps: steps, finalAnswerLaTeX: "a = $aStr$u");
    } catch (_) {
      return PolygonAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static PolygonAreaResult solveForSides(String areaIn, String lIn, String aIn, String unit) {
    try {
      double area = double.parse(areaIn.trim());
      double l = double.parse(lIn.trim());
      double apothem = double.parse(aIn.trim());

      double twoArea = 2 * area;
      double la = l * apothem;
      double n = twoArea / la;

      String areaStr = _format(area);
      String lStr = _format(l);
      String aStr = _format(apothem);
      String twoAreaStr = _format(twoArea);
      String laStr = _format(la);
      String nStr = _format(n);
      String u = "\\; \\text{$unit}";

      List<PolygonAreaStep> steps = [
        PolygonAreaStep(
            workingLaTeX: "A = \\frac{1}{2} \\times n \\times l \\times a",
            explanation: "Start with the general area formula."
        ),
        PolygonAreaStep(
            workingLaTeX: "n = \\frac{2 \\times A}{l \\times a}",
            explanation: "Rearrange the formula to solve for the number of sides 'n'."
        ),
        PolygonAreaStep(
            workingLaTeX: "n = \\frac{2 \\times $areaStr$u^2}{$lStr$u \\times $aStr$u}",
            explanation: "Substitute the given area, side length, and apothem."
        ),
        PolygonAreaStep(
            workingLaTeX: "n = \\frac{$twoAreaStr$u^2}{$laStr$u^2}",
            explanation: "Simplify the values."
        ),
        PolygonAreaStep(
            workingLaTeX: "n = $nStr",
            explanation: "Divide to calculate the total number of sides. (Note: sides have no unit).",
            isFinalAnswer: true
        )
      ];

      return PolygonAreaResult(steps: steps, finalAnswerLaTeX: "n = $nStr");
    } catch (_) {
      return PolygonAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}