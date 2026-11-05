/// Represents a single pedagogical step in the Indirect Proportion solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class IndirectProportionStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const IndirectProportionStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Exact parsed representation of any positive quantity (integer, decimal, proper/improper fraction, or mixed number).
class ParsedInvQuantity {
  final String rawInput;
  final double value;
  final int num; // Reduced numerator
  final int den; // Reduced denominator
  final bool isFractionOrMixed;
  final bool isMixedInput;
  final String displayPlain; // e.g., "22 1/2", "3 1/2", "120"
  final String displayLaTeX; // e.g., "22\\frac{1}{2}", "3\\frac{1}{2}", "120"
  final String improperLaTeX; // e.g., "\\frac{45}{2}", "\\frac{7}{2}", "120"

  const ParsedInvQuantity({
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

/// Represents a plotted point on the Textbook Millimetre Graph Paper (Figure 3.4).
class InversePlotPoint {
  final double x; // Time or Workers or Items
  final double y; // Speed or Price or Days
  final String pointLaTeX; // Rendered via Math.tex in the visualisation overlay!

  const InversePlotPoint({
    required this.x,
    required this.y,
    required this.pointLaTeX,
  });
}

/// Represents a dotted graph-reading interpolation trace line.
class InverseGraphTrace {
  final double xVal;
  final double yVal;
  final String badgeLaTeX; // Rendered via Math.tex inside the visualisation area!

  const InverseGraphTrace({
    required this.xVal,
    required this.yVal,
    required this.badgeLaTeX,
  });
}

/// Encapsulates all visual elements for the Millimetre Graph Paper & Math.tex Overlay Visualizer.
class IndirectProportionCanvasData {
  final int visualType;
  // 0: Millimetre Graph Paper (Fig. 3.4 Hyperbola Curve y = k/x)
  // 1: Compound & Multi-Part Proportion Balance / Pipeline (Mode 2 Ex 3.2 #3 & Mode 3 Ex 3.2 #5)

  final double constantProductK; // k = x * y
  final String xAxisLaTeX; // e.g., "\\text{Time (h)}"
  final String yAxisLaTeX; // e.g., "\\text{Speed (km/h)}"
  final String curveEquationLaTeX; // e.g., "\\text{Speed} = \\frac{120}{\\text{Time}}"

  final List<InversePlotPoint> points;
  final List<InverseGraphTrace> traces;

  // For VisualType 1 (Compound Proportion & Constant-Speed Pipeline — Modes 2 & 3)
  final String topCard1Title;
  final String topCard1LaTeX;
  final String topCard2Title;
  final String topCard2LaTeX;
  final String middleFormulaLaTeX;
  final String bottomResultLaTeX;

  final String headerLaTeX;
  final String subHeaderLaTeX;
  final String bottomSummaryLaTeX;

  const IndirectProportionCanvasData({
    this.visualType = 0,
    this.constantProductK = 120.0,
    this.xAxisLaTeX = 'x',
    this.yAxisLaTeX = 'y',
    this.curveEquationLaTeX = 'y = \\frac{k}{x}',
    this.points = const [],
    this.traces = const [],
    this.topCard1Title = '',
    this.topCard1LaTeX = '',
    this.topCard2Title = '',
    this.topCard2LaTeX = '',
    this.middleFormulaLaTeX = '',
    this.bottomResultLaTeX = '',
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 37–40 & 43.
class IndirectProportionPreset {
  final String chipLabel;
  final int mode;
  // 0: Inverse Unitary Method Word Problems x₁y₁ = x₂y₂ (Examples 4 & 5, Ex 3.2 #1, #2, #4)
  // 1: 2-Row Indirect Proportion Table & Hyperbola Graph (Table 3.9, Fig 3.4, Ex 3.2 #6, #7, Rev Ex 3 #3)
  // 2: Compound Proportion — Workers, Work/Length & Time (Exercise 3.2 #3: 15 men dig 90 m in 3 h)
  // 3: Constant-Speed Multi-Part Journey (Exercise 3.2 #5a–d: 175 km in 3 ½ hours)

  final String xLabel;
  final String yLabel;
  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String input5;
  final String tableRow1Csv;
  final String graphQueriesCsv;

  const IndirectProportionPreset({
    required this.chipLabel,
    required this.mode,
    this.xLabel = 'Time (h)',
    this.yLabel = 'Speed (km/h)',
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.input5 = '',
    this.tableRow1Csv = '',
    this.graphQueriesCsv = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class IndirectProportionResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<IndirectProportionStep> steps;
  final IndirectProportionCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const IndirectProportionResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory IndirectProportionResult.error({
    required int mode,
    required String message,
  }) {
    return IndirectProportionResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const IndirectProportionCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}