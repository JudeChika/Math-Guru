import 'parallelogram_perimeter_models.dart';

class ParallelogramPerimeterSolver {

  // Case 1: Given adjacent sides a and b, find Perimeter P
  static GeometryResult solveForPerimeter(double a, double b) {
    double p = 2 * (a + b);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = 2(a + b)", explanation: "Start with the formula for the perimeter of a parallelogram, where 'P' is perimeter, and 'a' and 'b' are the adjacent sides."),
      GeometrySolutionStep(workingLaTeX: "P = 2($a + $b)", explanation: "Substitute the values of the adjacent sides ($a and $b) into the formula."),
      GeometrySolutionStep(workingLaTeX: "P = 2(${a + b})", explanation: "Add the values inside the parentheses."),
      GeometrySolutionStep(workingLaTeX: "P = $p", explanation: "Multiply to find the final perimeter.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "P = $p");
  }

  // Case 2: Given Perimeter P and side b, find side a
  static GeometryResult solveForSideA(double p, double b) {
    double a = (p / 2) - b;
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = 2(a + b)", explanation: "Start with the formula for the perimeter of a parallelogram."),
      GeometrySolutionStep(workingLaTeX: "\\frac{P}{2} = a + b", explanation: "Divide both sides by 2 to isolate the sum of the adjacent sides."),
      GeometrySolutionStep(workingLaTeX: "a = \\frac{P}{2} - b", explanation: "Rearrange the formula to solve for side 'a'."),
      GeometrySolutionStep(workingLaTeX: "a = \\frac{$p}{2} - $b", explanation: "Substitute P = $p and b = $b into the formula."),
      GeometrySolutionStep(workingLaTeX: "a = ${p/2} - $b", explanation: "Calculate the half-perimeter."),
      GeometrySolutionStep(workingLaTeX: "a = $a", explanation: "Subtract to calculate the final length of side 'a'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "a = $a");
  }

  // Case 3: Given Perimeter P and side a, find side b
  static GeometryResult solveForSideB(double p, double a) {
    double b = (p / 2) - a;
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = 2(a + b)", explanation: "Start with the formula for the perimeter of a parallelogram."),
      GeometrySolutionStep(workingLaTeX: "\\frac{P}{2} = a + b", explanation: "Divide both sides by 2."),
      GeometrySolutionStep(workingLaTeX: "b = \\frac{P}{2} - a", explanation: "Rearrange the formula to solve for side 'b'."),
      GeometrySolutionStep(workingLaTeX: "b = \\frac{$p}{2} - $a", explanation: "Substitute P = $p and a = $a into the formula."),
      GeometrySolutionStep(workingLaTeX: "b = ${p/2} - $a", explanation: "Calculate the half-perimeter."),
      GeometrySolutionStep(workingLaTeX: "b = $b", explanation: "Subtract to calculate the final length of side 'b'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "b = $b");
  }
}