// lib/features/junior_secondary/jss1/geometry/perimeter/square/square_perimeter_solver.dart

import 'square_perimeter_models.dart';

class SquarePerimeterSolver {

  static GeometryResult solveForPerimeter(String lInput) {
    try {
      double l = double.parse(lInput.trim());
      List<GeometrySolutionStep> steps = [];
      double p = 4 * l;

      steps.add(GeometrySolutionStep(workingLaTeX: "P = 4 \\times l", explanation: "Start with the formula for the perimeter of a square, where 'P' is perimeter and 'l' is the length of one side."));
      steps.add(GeometrySolutionStep(workingLaTeX: "P = 4 \\times $l", explanation: "Substitute the side length 'l' ($l) into the formula."));
      steps.add(GeometrySolutionStep(workingLaTeX: "P = $p", explanation: "Calculate the final perimeter.", isFinalAnswer: true));

      return GeometryResult(steps: steps, finalAnswerLaTeX: "P = $p", isSolvingForPerimeter: true);
    } catch (_) {
      return GeometryResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid side length.", isSolvingForPerimeter: true);
    }
  }

  static GeometryResult solveForSide(String pInput) {
    try {
      double p = double.parse(pInput.trim());
      List<GeometrySolutionStep> steps = [];
      double l = p / 4;

      steps.add(GeometrySolutionStep(workingLaTeX: "P = 4 \\times l", explanation: "Start with the formula for the perimeter of a square, where 'P' is perimeter and 'l' is the length of one side."));
      steps.add(GeometrySolutionStep(workingLaTeX: "l = \\frac{P}{4}", explanation: "Rearrange the formula to solve for side length 'l'."));
      steps.add(GeometrySolutionStep(workingLaTeX: "l = \\frac{$p}{4}", explanation: "Substitute the perimeter ($p) into the formula."));
      steps.add(GeometrySolutionStep(workingLaTeX: "l = $l", explanation: "Calculate the side length 'l'.", isFinalAnswer: true));

      return GeometryResult(steps: steps, finalAnswerLaTeX: "l = $l", isSolvingForPerimeter: false);
    } catch (_) {
      return GeometryResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid perimeter.", isSolvingForPerimeter: false);
    }
  }
}