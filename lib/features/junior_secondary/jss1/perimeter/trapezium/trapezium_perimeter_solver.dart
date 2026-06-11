import 'trapezium_perimeter_models.dart';

class TrapeziumPerimeterSolver {

  // Case 1: Given a, b, c, d, find P
  static GeometryResult solveForPerimeter(double a, double b, double c, double d) {
    double p = a + b + c + d;
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c + d", explanation: "Start with the formula for the perimeter of a trapezium, where 'a', 'b', 'c', and 'd' are the four sides."),
      GeometrySolutionStep(workingLaTeX: "P = $a + $b + $c + $d", explanation: "Substitute the values of the sides into the formula."),
      GeometrySolutionStep(workingLaTeX: "P = $p", explanation: "Add the values to find the final perimeter.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "P = $p");
  }

  // Case 2: Solve for a, given P, b, c, d
  static GeometryResult solveForSideA(double p, double b, double c, double d) {
    double a = p - (b + c + d);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c + d", explanation: "Start with the perimeter formula."),
      GeometrySolutionStep(workingLaTeX: "a = P - (b + c + d)", explanation: "Rearrange the formula to solve for side 'a'."),
      GeometrySolutionStep(workingLaTeX: "a = $p - ($b + $c + $d)", explanation: "Substitute P = $p, b = $b, c = $c, and d = $d into the formula."),
      GeometrySolutionStep(workingLaTeX: "a = $p - ${b + c + d}", explanation: "Calculate the sum of the other three sides."),
      GeometrySolutionStep(workingLaTeX: "a = $a", explanation: "Subtract from the perimeter to find side 'a'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "a = $a");
  }

  // Case 3: Solve for b, given P, a, c, d
  static GeometryResult solveForSideB(double p, double a, double c, double d) {
    double b = p - (a + c + d);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c + d", explanation: "Start with the perimeter formula."),
      GeometrySolutionStep(workingLaTeX: "b = P - (a + c + d)", explanation: "Rearrange the formula to solve for side 'b'."),
      GeometrySolutionStep(workingLaTeX: "b = $p - ($a + $c + $d)", explanation: "Substitute P = $p, a = $a, c = $c, and d = $d into the formula."),
      GeometrySolutionStep(workingLaTeX: "b = $p - ${a + c + d}", explanation: "Calculate the sum of the other three sides."),
      GeometrySolutionStep(workingLaTeX: "b = $b", explanation: "Subtract from the perimeter to find side 'b'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "b = $b");
  }

  // Case 4: Solve for c, given P, a, b, d
  static GeometryResult solveForSideC(double p, double a, double b, double d) {
    double c = p - (a + b + d);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c + d", explanation: "Start with the perimeter formula."),
      GeometrySolutionStep(workingLaTeX: "c = P - (a + b + d)", explanation: "Rearrange the formula to solve for side 'c'."),
      GeometrySolutionStep(workingLaTeX: "c = $p - ($a + $b + $d)", explanation: "Substitute P = $p, a = $a, b = $b, and d = $d into the formula."),
      GeometrySolutionStep(workingLaTeX: "c = $p - ${a + b + d}", explanation: "Calculate the sum of the other three sides."),
      GeometrySolutionStep(workingLaTeX: "c = $c", explanation: "Subtract from the perimeter to find side 'c'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "c = $c");
  }

  // Case 5: Solve for d, given P, a, b, c
  static GeometryResult solveForSideD(double p, double a, double b, double c) {
    double d = p - (a + b + c);
    List<GeometrySolutionStep> steps = [
      GeometrySolutionStep(workingLaTeX: "P = a + b + c + d", explanation: "Start with the perimeter formula."),
      GeometrySolutionStep(workingLaTeX: "d = P - (a + b + c)", explanation: "Rearrange the formula to solve for side 'd'."),
      GeometrySolutionStep(workingLaTeX: "d = $p - ($a + $b + $c)", explanation: "Substitute P = $p, a = $a, b = $b, and c = $c into the formula."),
      GeometrySolutionStep(workingLaTeX: "d = $p - ${a + b + c}", explanation: "Calculate the sum of the other three sides."),
      GeometrySolutionStep(workingLaTeX: "d = $d", explanation: "Subtract from the perimeter to find side 'd'.", isFinalAnswer: true),
    ];
    return GeometryResult(steps: steps, finalAnswerLaTeX: "d = $d");
  }
}