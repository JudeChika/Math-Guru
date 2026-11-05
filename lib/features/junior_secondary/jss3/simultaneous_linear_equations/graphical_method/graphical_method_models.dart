/// Represents a single pedagogical step in the Graphical Method (Pages 91–94) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class GraphicalMethodStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const GraphicalMethodStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Represents a plotted point (x, y) on one of the two linear graphs.
class GraphPoint {
  final double x;
  final double y;

  const GraphPoint(this.x, this.y);
}

/// Encapsulates all visual elements for the Graphical Method Interactive Cartesian Graph + Math.tex Tables of Values.
/// Replicates Figs. 10.1–10.5 and Tables 10.1–10.10 (Pages 91–94) with 100% Math.tex fraction rendering!
class GraphicalMethodCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String eq1SubjectLaTeX; // e.g. y = \frac{x + 12}{4}
  final String eq2SubjectLaTeX; // e.g. y = 8 - x
  final String table1LaTeX; // Table of values for Line 1 rendered via Math.tex!
  final String table2LaTeX; // Table of values for Line 2 rendered via Math.tex!

  final List<GraphPoint> line1Points;
  final List<GraphPoint> line2Points;
  final GraphPoint intersection;
  final String intersectionLabelLaTeX;
  final String bottomSummaryLaTeX;

  const GraphicalMethodCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.eq1SubjectLaTeX = '',
    this.eq2SubjectLaTeX = '',
    this.table1LaTeX = '',
    this.table2LaTeX = '',
    this.line1Points = const [],
    this.line2Points = const [],
    this.intersection = const GraphPoint(0, 0),
    this.intersectionLabelLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 91–94 (Examples 1a–c, 2a–b & Exercise 10.1 #1–10).
class GraphicalMethodPreset {
  final String chipLabel;
  final String eq1Input;
  final String eq2Input;
  final String xValuesInput;

  const GraphicalMethodPreset({
    required this.chipLabel,
    required this.eq1Input,
    required this.eq2Input,
    this.xValuesInput = '-2, -1, 0, 1, 2, 3, 4',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class GraphicalMethodResult {
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<GraphicalMethodStep> steps;
  final GraphicalMethodCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const GraphicalMethodResult({
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory GraphicalMethodResult.error({
    required String message,
  }) {
    return GraphicalMethodResult(
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const GraphicalMethodCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}