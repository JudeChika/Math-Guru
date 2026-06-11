import 'dart:math' as math;
import 'circle_perimeter_models.dart';

class CirclePerimeterSolver {

  // Case 1: Given Radius (r), find Circumference (C)
  static GeometryResult solveForCircumference(double r) {
    double c = 2 * math.pi * r;
    String cFormatted = c.toStringAsFixed(2); // Rounding for clean UI

    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "C = 2\\pi r", explanation: "Start with the formula for the circumference (perimeter) of a circle, where 'C' is circumference and 'r' is the radius."),
      GeometrySolutionStep(workingLaTeX: "C = 2 \\times \\pi \\times $r", explanation: "Substitute the value of the radius (r = $r) into the formula."),
      GeometrySolutionStep(workingLaTeX: "C \\approx 2 \\times 3.142 \\times $r", explanation: "Use the approximate value of pi (\\pi \\approx 3.142) for calculation."),
      GeometrySolutionStep(workingLaTeX: "C \\approx $cFormatted", explanation: "Multiply to find the final circumference.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "C \\approx $cFormatted");
  }

  // Case 2: Given Circumference (C), find Radius (r)
  static GeometryResult solveForRadius(double c) {
    double r = c / (2 * math.pi);
    String rFormatted = r.toStringAsFixed(2);

    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "C = 2\\pi r", explanation: "Start with the formula for the circumference of a circle."),
      GeometrySolutionStep(workingLaTeX: "r = \\frac{C}{2\\pi}", explanation: "Rearrange the formula to solve for the radius 'r'."),
      GeometrySolutionStep(workingLaTeX: "r = \\frac{$c}{2\\pi}", explanation: "Substitute the circumference (C = $c) into the formula."),
      GeometrySolutionStep(workingLaTeX: "r \\approx \\frac{$c}{2 \\times 3.142}", explanation: "Use the approximate value of pi (\\pi \\approx 3.142)."),
      GeometrySolutionStep(workingLaTeX: "r \\approx $rFormatted", explanation: "Divide to calculate the final radius.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "r \\approx $rFormatted");
  }
}