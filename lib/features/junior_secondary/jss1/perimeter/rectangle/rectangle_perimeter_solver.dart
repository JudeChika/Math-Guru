// lib/features/junior_secondary/jss1/geometry/perimeter/rectangle/rectangle_perimeter_solver.dart

import 'rectangle_perimeter_models.dart';

class RectanglePerimeterSolver {

  // Case 1: Given Length (l) and Breadth (b), find Perimeter (P)
  static GeometryResult solveForPerimeter(double l, double b) {
    double p = 2 * (l + b);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = 2(l + b)", explanation: "Start with the formula for the perimeter of a rectangle, where 'P' is perimeter, 'l' is length, and 'b' is breadth."),
      GeometrySolutionStep(workingLaTeX: "P = 2($l + $b)", explanation: "Substitute the values of length ($l) and breadth ($b) into the formula."),
      GeometrySolutionStep(workingLaTeX: "P = 2(${l + b})", explanation: "Add the values inside the parentheses."),
      GeometrySolutionStep(workingLaTeX: "P = $p", explanation: "Multiply to find the final perimeter.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "P = $p");
  }

  // Case 2: Given Perimeter (P) and Breadth (b), find Length (l)
  static GeometryResult solveForLength(double p, double b) {
    double l = (p / 2) - b;
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = 2(l + b)", explanation: "Start with the formula for the perimeter of a rectangle."),
      GeometrySolutionStep(workingLaTeX: "\\frac{P}{2} = l + b", explanation: "Divide both sides by 2 to isolate the sum of length and breadth."),
      GeometrySolutionStep(workingLaTeX: "l = \\frac{P}{2} - b", explanation: "Rearrange to solve for length 'l'."),
      GeometrySolutionStep(workingLaTeX: "l = \\frac{$p}{2} - $b", explanation: "Substitute P = $p and b = $b into the formula."),
      GeometrySolutionStep(workingLaTeX: "l = ${p/2} - $b", explanation: "Calculate the half-perimeter."),
      GeometrySolutionStep(workingLaTeX: "l = $l", explanation: "Calculate the final length.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "l = $l");
  }

  // Case 3: Given Perimeter (P) and Length (l), find Breadth (b)
  static GeometryResult solveForBreadth(double p, double l) {
    double b = (p / 2) - l;
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = 2(l + b)", explanation: "Start with the formula for the perimeter of a rectangle."),
      GeometrySolutionStep(workingLaTeX: "\\frac{P}{2} = l + b", explanation: "Divide both sides by 2."),
      GeometrySolutionStep(workingLaTeX: "b = \\frac{P}{2} - l", explanation: "Rearrange to solve for breadth 'b'."),
      GeometrySolutionStep(workingLaTeX: "b = \\frac{$p}{2} - $l", explanation: "Substitute P = $p and l = $l into the formula."),
      GeometrySolutionStep(workingLaTeX: "b = ${p/2} - $l", explanation: "Calculate the half-perimeter."),
      GeometrySolutionStep(workingLaTeX: "b = $b", explanation: "Calculate the final breadth.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "b = $b");
  }
}