// lib/features/junior_secondary/jss1/geometry/perimeter/triangle/triangle_perimeter_solver.dart

import 'triangle_perimeter_models.dart';

class TrianglePerimeterSolver {

  // Case 1: Given a, b, c, find P
  static GeometryResult solveForPerimeter(double a, double b, double c) {
    double p = a + b + c;
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c", explanation: "Start with the formula for the perimeter of a triangle, where 'a', 'b', and 'c' are the three sides."),
      GeometrySolutionStep(workingLaTeX: "P = $a + $b + $c", explanation: "Substitute the values of the sides into the formula."),
      GeometrySolutionStep(workingLaTeX: "P = $p", explanation: "Add the values to find the final perimeter.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "P = $p");
  }

  // Case 2: Solve for a, given P, b, c
  static GeometryResult solveForSideA(double p, double b, double c) {
    double a = p - (b + c);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c", explanation: "Start with the perimeter formula."),
      GeometrySolutionStep(workingLaTeX: "a = P - (b + c)", explanation: "Rearrange the formula to solve for side 'a'."),
      GeometrySolutionStep(workingLaTeX: "a = $p - ($b + $c)", explanation: "Substitute P = $p, b = $b, and c = $c into the formula."),
      GeometrySolutionStep(workingLaTeX: "a = $p - ${b + c}", explanation: "Calculate the sum of sides 'b' and 'c'."),
      GeometrySolutionStep(workingLaTeX: "a = $a", explanation: "Subtract from the perimeter to find side 'a'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "a = $a");
  }

  // Case 3: Solve for b, given P, a, c
  static GeometryResult solveForSideB(double p, double a, double c) {
    double b = p - (a + c);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c", explanation: "Start with the perimeter formula."),
      GeometrySolutionStep(workingLaTeX: "b = P - (a + c)", explanation: "Rearrange the formula to solve for side 'b'."),
      GeometrySolutionStep(workingLaTeX: "b = $p - ($a + $c)", explanation: "Substitute P = $p, a = $a, and c = $c into the formula."),
      GeometrySolutionStep(workingLaTeX: "b = $p - ${a + c}", explanation: "Calculate the sum of sides 'a' and 'c'."),
      GeometrySolutionStep(workingLaTeX: "b = $b", explanation: "Subtract from the perimeter to find side 'b'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "b = $b");
  }

  // Case 4: Solve for c, given P, a, b
  static GeometryResult solveForSideC(double p, double a, double b) {
    double c = p - (a + b);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c", explanation: "Start with the perimeter formula."),
      GeometrySolutionStep(workingLaTeX: "c = P - (a + b)", explanation: "Rearrange the formula to solve for side 'c'."),
      GeometrySolutionStep(workingLaTeX: "c = $p - ($a + $b)", explanation: "Substitute P = $p, a = $a, and b = $b into the formula."),
      GeometrySolutionStep(workingLaTeX: "c = $p - ${a + b}", explanation: "Calculate the sum of sides 'a' and 'b'."),
      GeometrySolutionStep(workingLaTeX: "c = $c", explanation: "Subtract from the perimeter to find side 'c'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "c = $c");
  }
}