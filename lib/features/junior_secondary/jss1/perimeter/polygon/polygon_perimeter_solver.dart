import 'polygon_perimeter_models.dart';

class PolygonPerimeterSolver {

  /// Dynamically computes the perimeter for an n-sided polygon
  static GeometryResult solveForPerimeter(List<double> sides) {
    if (sides.length < 3) {
      return GeometryResult(
          steps: [],
          finalAnswerLaTeX: "",
          valid: false,
          errorMessage: "A polygon must have at least 3 sides."
      );
    }

    double p = sides.fold(0, (sum, side) => sum + side);
    List<GeometrySolutionStep> steps = [];

    // Step 1: Generate dynamic formula (e.g., P = l_1 + l_2 + l_3 + ...)
    List<String> lVariables = List.generate(sides.length, (i) => "l_{${i + 1}}");
    String formulaLaTeX = "P = ${lVariables.join(' + ')}";

    steps.add(GeometrySolutionStep(
        workingLaTeX: formulaLaTeX,
        explanation: "Start with the formula for the perimeter of a/an ${sides.length}-sided polygon, where 'P' is the perimeter and 'l' represents the length of each side."
    ));

    // Step 2: Substitute values
    String substitutionLaTeX = "P = ${sides.join(' + ')}";
    steps.add(GeometrySolutionStep(
        workingLaTeX: substitutionLaTeX,
        explanation: "Substitute the given lengths into the formula."
    ));

    // Step 3: Compute final answer
    steps.add(GeometrySolutionStep(
        workingLaTeX: "P = $p",
        explanation: "Add all the lengths together to find the final perimeter.",
        isFinalAnswer: true
    ));

    return GeometryResult(steps: steps, finalAnswerLaTeX: "P = $p");
  }
}