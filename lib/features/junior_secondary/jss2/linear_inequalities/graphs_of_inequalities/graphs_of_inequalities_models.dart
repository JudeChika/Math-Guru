/// Represents a single pedagogical step in the 22-2 Graphs of Inequalities solver.
class GraphInequalityStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const GraphInequalityStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class GraphInequalityPreset {
  final String chipLabel;
  final int mode;
  // 0: Sketch Graph of Inequality (Fig 22.1–22.3, Fig 22.6, Ex 22d #2)
  // 1: Read Inequality from Graph (Example 5 / Fig 22.4, Ex 22d #1a–j / Fig 22.5)
  // 2: Solve 1-Step / 2-Step & Sketch Graph (Example 6 & Example 7 / Fig 22.6)
  // 3: Linear Inequality Inspector (Index = 1 & Variable Count Classifier — Page 193)

  final int graphStyle;
  // 0: Raised Ray Above Number Line (Fig 22.5 / Ex 22d #1)
  // 1: Heavy Line Directly ON Number Line (Fig 22.1, 22.2, 22.4)
  // 2: Compare All 3 Textbook Styles (Fig 22.3)

  // Mode 0 fields (Sketch Graph)
  final String varName;
  final String symbol; // '<', '>', '<=', '>=', '!='
  final String boundaryStr; // Supports integers, decimals, and mixed fractions like "2 1/2"
  final bool isReversedInput; // e.g., 3 1/2 <= x -> x >= 3 1/2

  // Mode 1 fields (Read Graph)
  final bool isShadedCircle;
  final bool pointsRight;

  // Mode 2 & Mode 3 fields (Solve & Graph / Linear Inspector)
  final String fullInequalityExpr;

  const GraphInequalityPreset({
    required this.chipLabel,
    required this.mode,
    this.graphStyle = 0,
    this.varName = 'x',
    this.symbol = '<',
    this.boundaryStr = '2',
    this.isReversedInput = false,
    this.isShadedCircle = false,
    this.pointsRight = false,
    this.fullInequalityExpr = 'x + 4 < 6',
  });
}

/// Encapsulates number-line drawing parameters for the CustomPaint canvas.
class NumberLineVisualData {
  final bool isInspectorMode;
  final double boundaryVal;
  final String boundaryDisplay; // e.g., "2", "-4", "2½", "3½"
  final String varName;
  final String symbolDisplay; // '<', '>', '≤', '≥', '≠'
  final bool isShaded; // true: solid ●, false: open ○
  final bool pointsRight; // true: arrow →, false: arrow ←
  final bool isNotEqual; // true if '≠' (arrows both ways from open circle)
  final int graphStyle; // 0: Raised Ray, 1: On-Line, 2: All 3 Styles (Fig 22.3)
  final String headerBadge;
  final String subBadge;
  final String inspectorDetails;

  const NumberLineVisualData({
    this.isInspectorMode = false,
    this.boundaryVal = 2.0,
    this.boundaryDisplay = '2',
    this.varName = 'x',
    this.symbolDisplay = '<',
    this.isShaded = false,
    this.pointsRight = false,
    this.isNotEqual = false,
    this.graphStyle = 0,
    this.headerBadge = '',
    this.subBadge = '',
    this.inspectorDetails = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and number-line visualizer data.
class GraphInequalityResult {
  final int mode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<GraphInequalityStep> steps;
  final NumberLineVisualData visualData;
  final bool valid;
  final String? errorMessage;

  const GraphInequalityResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.visualData,
    this.valid = true,
    this.errorMessage,
  });

  factory GraphInequalityResult.error({
    required int mode,
    required String message,
  }) {
    return GraphInequalityResult(
      mode: mode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      visualData: const NumberLineVisualData(),
      valid: false,
      errorMessage: message,
    );
  }
}