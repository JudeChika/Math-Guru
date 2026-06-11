import 'quadrant_perimeter_models.dart';

class QuadrantPerimeterSolver {
  static const double piApprox = 3.142; // Standard JSS1 approximation

  // Case 1: Given Radius (r), find Perimeter (P)
  static GeometryResult solveForPerimeter(double r) {
    double arcLength = (1/4) * 2 * piApprox * r;
    double p = arcLength + r + r;
    String pFormatted = p.toStringAsFixed(2);

    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = \\left(\\frac{1}{4} \\times 2\\pi r\\right) + a + b", explanation: "Start with the formula. A quadrant has a curved arc (1/4 of a circle) and two straight edges ('a' and 'b')."),
      GeometrySolutionStep(workingLaTeX: "a = r, \\; b = r", explanation: "Because a quadrant is cut from the center of a circle, the two straight edges 'a' and 'b' are exactly equal to the radius (r)."),
      GeometrySolutionStep(workingLaTeX: "P = \\left(\\frac{1}{4} \\times 2 \\times \\pi \\times $r\\right) + $r + $r", explanation: "Substitute the value of the radius (r = $r) into the formula."),
      GeometrySolutionStep(workingLaTeX: "P \\approx \\left(\\frac{1}{4} \\times 2 \\times 3.142 \\times $r\\right) + $r + $r", explanation: "Use the approximate value of pi (\\pi \\approx 3.142)."),
      GeometrySolutionStep(workingLaTeX: "P \\approx ${arcLength.toStringAsFixed(2)} + $r + $r", explanation: "Calculate the length of the curved arc."),
      GeometrySolutionStep(workingLaTeX: "P \\approx $pFormatted", explanation: "Add the curved arc and the two straight edges to find the total perimeter.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "P \\approx $pFormatted");
  }

  // Case 2: Given Perimeter (P), find Radius (r)
  static GeometryResult solveForRadius(double p) {
    // For JSS1, factoring is easier explained with a constant number.
    // P = r * [ (1/4 * 2 * 3.142) + 1 + 1 ]
    // P = r * [ 1.571 + 2 ]
    // P = r * 3.571
    double constantSum = ((1/4) * 2 * piApprox) + 2; // 3.571
    double r = p / constantSum;
    String rFormatted = r.toStringAsFixed(2);

    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = \\left(\\frac{1}{4} \\times 2\\pi r\\right) + r + r", explanation: "Start with the formula, replacing edges 'a' and 'b' with the radius 'r'."),
      GeometrySolutionStep(workingLaTeX: "P = r\\left( \\frac{2\\pi}{4} + 2 \\right)", explanation: "Factor out the common radius 'r' to isolate it."),
      GeometrySolutionStep(workingLaTeX: "P \\approx r\\left( \\frac{2 \\times 3.142}{4} + 2 \\right)", explanation: "Use the approximate value of pi (\\pi \\approx 3.142)."),
      GeometrySolutionStep(workingLaTeX: "P \\approx r(1.571 + 2)", explanation: "Solve the fraction inside the brackets."),
      GeometrySolutionStep(workingLaTeX: "P \\approx r(3.571)", explanation: "Add the values in the brackets. This is our constant for a quadrant."),
      GeometrySolutionStep(workingLaTeX: "$p \\approx r \\times 3.571", explanation: "Substitute the given perimeter (P = $p)."),
      GeometrySolutionStep(workingLaTeX: "r \\approx \\frac{$p}{3.571}", explanation: "Divide both sides by 3.571 to solve for the radius."),
      GeometrySolutionStep(workingLaTeX: "r \\approx $rFormatted", explanation: "Calculate the final radius.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "r \\approx $rFormatted");
  }
}