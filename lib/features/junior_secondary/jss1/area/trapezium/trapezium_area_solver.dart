// lib/features/junior_secondary/jss1/area/trapezium/trapezium_area_solver.dart

import 'dart:math';
import 'trapezium_area_models.dart';

class TrapeziumAreaSolver {
  // Helper to format numbers cleanly
  static String _format(double n) {
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // ==========================================
  // STANDARD SOLVING METHODS
  // ==========================================

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
        TrapeziumAreaStep(workingLaTeX: "A = \\frac{1}{2}(a + b)h", explanation: "Start with the formula for the area of a trapezium, where 'a' and 'b' are the parallel sides, and 'h' is the height."),
        TrapeziumAreaStep(workingLaTeX: "A = \\frac{1}{2}($aStr$u + $bStr$u) \\times $hStr$u", explanation: "Substitute the given values into the formula."),
        TrapeziumAreaStep(workingLaTeX: "A = \\frac{1}{2}($sumStr$u) \\times $hStr$u", explanation: "First, add the parallel sides inside the bracket together (BODMAS)."),
        TrapeziumAreaStep(workingLaTeX: "A = \\frac{1}{2} \\times $sthStr$u^2", explanation: "Multiply the sum by the height."),
        TrapeziumAreaStep(workingLaTeX: "A = $areaStr$u^2", explanation: "Divide the result by 2 to find the final area. Area is measured in square units.", isFinalAnswer: true)
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
        TrapeziumAreaStep(workingLaTeX: "A = \\frac{1}{2}(a + b)h", explanation: "Start with the general area formula."),
        TrapeziumAreaStep(workingLaTeX: "h = \\frac{2A}{(a + b)}", explanation: "Rearrange the formula to solve for the height 'h' by multiplying the area by 2 and dividing by the sum of the parallel sides."),
        TrapeziumAreaStep(workingLaTeX: "h = \\frac{2 \\times $areaStr$u^2}{($aStr$u + $bStr$u)}", explanation: "Substitute the given area and parallel sides into the formula."),
        TrapeziumAreaStep(workingLaTeX: "h = \\frac{$twoAreaStr$u^2}{$sumStr$u}", explanation: "Multiply the area by 2 and add the parallel sides together."),
        TrapeziumAreaStep(workingLaTeX: "h = $hStr$u", explanation: "Divide to calculate the final height 'h'.", isFinalAnswer: true)
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
        TrapeziumAreaStep(workingLaTeX: "A = \\frac{1}{2}(a + b)h", explanation: "Start with the general area formula."),
        TrapeziumAreaStep(workingLaTeX: "$solveVar = \\frac{2A}{h} - $knownVar", explanation: "Rearrange the formula to solve for the unknown parallel side '$solveVar'."),
        TrapeziumAreaStep(workingLaTeX: "$solveVar = \\frac{2 \\times $areaStr$u^2}{$hStr$u} - $kStr$u", explanation: "Substitute the given area, height, and known side '$knownVar'."),
        TrapeziumAreaStep(workingLaTeX: "$solveVar = \\frac{$twoAreaStr$u^2}{$hStr$u} - $kStr$u", explanation: "Multiply the area by 2."),
        TrapeziumAreaStep(workingLaTeX: "$solveVar = $divHStr$u - $kStr$u", explanation: "Divide the top result by the height."),
        TrapeziumAreaStep(workingLaTeX: "$solveVar = $uStr$u", explanation: "Subtract the known side to find the final length of '$solveVar'.", isFinalAnswer: true)
      ];

      return TrapeziumAreaResult(steps: steps, finalAnswerLaTeX: "$solveVar = $uStr$u");
    } catch (_) {
      return TrapeziumAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  // ==========================================
  // WORD PROBLEM / RELATIONSHIP SOLVING METHOD
  // ==========================================

  static TrapeziumAreaResult solveWithRelationship(String areaInput, String heightInput, String multiplierInput, bool isAMultipleOfB, String unit) {
    try {
      double area = double.parse(areaInput.trim());
      double h = double.parse(heightInput.trim());
      double x = double.parse(multiplierInput.trim());

      List<TrapeziumAreaStep> steps = [];
      String areaStr = _format(area);
      String hStr = _format(h);
      String xStr = _format(x);
      String u = "\\; \\text{$unit}";

      // The math: Area = 0.5 * (a + b) * h
      // If a = xb, then Area = 0.5 * (xb + b) * h = 0.5 * b(x + 1) * h
      // b = (2 * Area) / (h * (x + 1))
      double sumFactor = x + 1;
      double twoArea = 2 * area;
      double denominator = h * sumFactor;
      double solvedPrimary = twoArea / denominator;
      double solvedSecondary = x * solvedPrimary;

      String sFStr = _format(sumFactor);
      String denStr = _format(denominator);

      steps.add(TrapeziumAreaStep(workingLaTeX: "A = \\frac{1}{2}(a + b)h", explanation: "Start with the general formula for the area of a trapezium."));

      if (isAMultipleOfB) {
        // a = xb
        String bStr = _format(solvedPrimary); // Side b
        String aStr = _format(solvedSecondary); // Side a

        steps.add(TrapeziumAreaStep(workingLaTeX: "a = $xStr \\times b", explanation: "From the word problem, we know side 'a' is $xStr times side 'b'. Substitute 'a' with '$xStr b'."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "$areaStr = \\frac{1}{2}($xStr b + b) \\times $hStr", explanation: "Substitute the known Area, Height ($hStr), and our expression for 'a'."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "$areaStr = \\frac{1}{2}(b($xStr + 1)) \\times $hStr", explanation: "Factor out the common 'b' inside the bracket."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "$areaStr = \\frac{1}{2}($sFStr b) \\times $hStr", explanation: "Add the numbers inside the bracket."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "b = \\frac{2 \\times $areaStr}{$hStr \\times $sFStr}", explanation: "Rearrange the equation to isolate 'b'."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "b = \\frac{${_format(twoArea)}}{$denStr}", explanation: "Simplify the top and bottom."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "b = $bStr$u", explanation: "Divide to find the final length of Side 'b'."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "a = $xStr \\times $bStr = $aStr$u", explanation: "Now multiply Side 'b' by $xStr to find Side 'a'.", isFinalAnswer: true));

        return TrapeziumAreaResult(steps: steps, finalAnswerLaTeX: "\\text{Side } (a) = $aStr$u \\\\ \\text{Side } (b) = $bStr$u");

      } else {
        // b = xa
        String aStr = _format(solvedPrimary); // Side a
        String bStr = _format(solvedSecondary); // Side b

        steps.add(TrapeziumAreaStep(workingLaTeX: "b = $xStr \\times a", explanation: "From the problem, we know side 'b' is $xStr times side 'a'. Substitute 'b' with '$xStr a'."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "$areaStr = \\frac{1}{2}(a + $xStr a) \\times $hStr", explanation: "Substitute the known Area, Height ($hStr), and our expression for 'b'."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "$areaStr = \\frac{1}{2}(a(1 + $xStr)) \\times $hStr", explanation: "Factor out the common 'a' inside the bracket."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "$areaStr = \\frac{1}{2}($sFStr a) \\times $hStr", explanation: "Add the numbers inside the bracket."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "a = \\frac{2 \\times $areaStr}{$hStr \\times $sFStr}", explanation: "Rearrange the equation to isolate 'a'."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "a = \\frac{${_format(twoArea)}}{$denStr}", explanation: "Simplify the top and bottom."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "a = $aStr$u", explanation: "Divide to find the final length of Side 'a'."));
        steps.add(TrapeziumAreaStep(workingLaTeX: "b = $xStr \\times $aStr = $bStr$u", explanation: "Now multiply Side 'a' by $xStr to find Side 'b'.", isFinalAnswer: true));

        return TrapeziumAreaResult(steps: steps, finalAnswerLaTeX: "\\text{Side } (a) = $aStr$u \\\\ \\text{Side } (b) = $bStr$u");
      }
    } catch (_) {
      return TrapeziumAreaResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}