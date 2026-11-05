/// Represents a single pedagogical step in the Direct Proportion solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class DirectProportionStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const DirectProportionStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Exact parsed representation of any positive quantity (integer, decimal, proper/improper fraction, or mixed number).
class ParsedQuantity {
  final String rawInput;
  final double value;
  final int num; // Reduced numerator
  final int den; // Reduced denominator
  final bool isFractionOrMixed;
  final bool isMixedInput;
  final String displayPlain; // e.g., "18 1/2", "697.50", "20"
  final String displayLaTeX; // e.g., "18\\frac{1}{2}", "697.50", "20"
  final String improperLaTeX; // e.g., "\\frac{37}{2}", "\\frac{1395}{2}", "20"

  const ParsedQuantity({
    required this.rawInput,
    required this.value,
    required this.num,
    required this.den,
    this.isFractionOrMixed = false,
    this.isMixedInput = false,
    required this.displayPlain,
    required this.displayLaTeX,
    required this.improperLaTeX,
  });
}

/// Represents a plotted point (x, y) on the Textbook Millimetre Graph Paper (Figures 3.1–3.3).
class ProportionPlotPoint {
  final double x;
  final double y;
  final String label;

  const ProportionPlotPoint({
    required this.x,
    required this.y,
    required this.label,
  });
}

/// Represents a dotted graph-reading interpolation trace line (matching Figure 3.3 for 8 litres -> 3.2 litres).
class ProportionGraphTrace {
  final double xVal;
  final double yVal;
  final bool givenX; // true: trace from x-axis up to line, then left to y-axis; false: reverse
  final String badgeLabel; // e.g., "(8, 3.2)" or "(45 mi, 72 km)"

  const ProportionGraphTrace({
    required this.xVal,
    required this.yVal,
    this.givenX = true,
    required this.badgeLabel,
  });
}

/// Encapsulates all visual elements for the CustomPaint Millimetre Graph Paper & Variation Visualizer.
class DirectProportionCanvasData {
  final int visualType;
  // 0: Textbook Pink/Red Millimetre Graph Paper with Straight Line Through Origin (0,0) (Figures 3.1, 3.2, 3.3)
  // 1: Non-Linear Direct Variation Curve & Factored Square-Root Pipeline (Example 3: R = kS²)

  final String xAxisLabel; // e.g., "No. of packets of tea (x)" or "Blue paint (l)"
  final String yAxisLabel; // e.g., "Cost (₦)" or "Red paint (l)"
  final String equationBanner; // e.g., "y = 50x" or "b = 5p" or "r = (2/5)b"
  final double slopeK;
  final int powerN; // 1 for linear y = kx, 2 for y = kx², 3 for y = kx³
  final List<ProportionPlotPoint> points;
  final List<ProportionGraphTrace> traces;

  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const DirectProportionCanvasData({
    this.visualType = 0,
    this.xAxisLabel = 'x',
    this.yAxisLabel = 'y',
    this.equationBanner = 'y = kx',
    this.slopeK = 1.0,
    this.powerN = 1,
    this.points = const [],
    this.traces = const [],
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 31–37.
class DirectProportionPreset {
  final String chipLabel;
  final int mode;
  // 0: Unitary Method & Ratio Method Word Problems (Activity 3.1, Example 1 & Ex 3.1 #5, #6, #7, #8, #9, #11)
  // 1: Direct Proportion Table Builder, Ratio Verifier & Graph Reader (Example 2 & Ex 3.1 #1, #2, #3, #4, #10)
  // 2: Non-Linear Power Direct Variation Y ∝ Xⁿ / √X (Example 3: R ∝ S²)
  // 3: Custom Table Proportionality Inspector (Test if a Table of Values is in Direct Proportion)

  final int subMode;
  final String xLabel;
  final String yLabel;
  final String varX;
  final String varY;
  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String tableXValuesCsv;
  final String extraQueriesCsv;

  const DirectProportionPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.xLabel = 'No. of items',
    this.yLabel = 'Cost (N)',
    this.varX = 'x',
    this.varY = 'y',
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.tableXValuesCsv = '',
    this.extraQueriesCsv = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class DirectProportionResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<DirectProportionStep> steps;
  final DirectProportionCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const DirectProportionResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory DirectProportionResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return DirectProportionResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const DirectProportionCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}