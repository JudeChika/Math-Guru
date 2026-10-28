/// Represents a single pedagogical step in the Flow Charts solver.
class FlowChartStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const FlowChartStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Defines the visual shape of a node in a textbook computer flow chart (Figures 1.1–1.3).
enum FlowNodeType {
  startStopPill, // Rounded stadium/pill box for 'Start' and 'Stop'
  processRect, // Rectangular instruction box (e.g., 'Choose x', 'Find 2x', 'Add 8')
  decisionHexagon, // 6-sided elongated decision hexagon (e.g., 'Is 2x + 8 = 12?')
}

/// Represents a single box/node in the Flow Chart diagram.
class FlowChartNode {
  final String boxLetter; // '', 'A', 'B', 'C', 'D', 'E', 'F' (matching Fig 1.3)
  final String text; // Instruction inside the box
  final String subExprLaTeX; // Algebraic meaning of this box (e.g. "2x + 6")
  final FlowNodeType type;

  const FlowChartNode({
    this.boxLetter = '',
    required this.text,
    this.subExprLaTeX = '',
    this.type = FlowNodeType.processRect,
  });
}

/// Represents one trial iteration of the computer testing a value of x in the flow chart loop.
class FlowTrialTraceRow {
  final double xVal;
  final List<String> boxValues; // Evaluated value at each box (A, B, C, ...)
  final bool isEqualYes; // true: Decision box outputs 'Yes -> Stop'; false: 'No -> Try again'

  const FlowTrialTraceRow({
    required this.xVal,
    required this.boxValues,
    required this.isEqualYes,
  });
}

/// Encapsulates all visual elements for the CustomPaint Flow Chart Diagram (Figures 1.1–1.3).
class FlowChartCanvasData {
  final int mode;
  // 0: One-Sided & Bracketed Equation Flow Chart (Ex 8 [Fig 1.1 & 1.2], Ex 1.5 #1 & #4)
  // 1: Two-Sided Comparison Flow Chart with Labeled Boxes A–F (Ex 9 [Fig 1.3] & Ex 1.5 #2)
  // 2: Fractional / Multi-Part Word Problem Flow Chart (Ex 1.5 #3: 1/2x + 2x = 25)
  // 3: Sequential Instruction & Algorithm Organizer (Ex 1.5 #5a–h: Drawing a Circle)

  final List<FlowChartNode> mainNodes; // Vertical chain from 'Start' down to 'Stop'
  final bool hasTryAgainLoop; // true for Modes 0, 1, 2 (has 'No -> Try again' feedback loop)
  final int loopReturnIndex; // Index in mainNodes where the 'Try again' loop feeds back (usually index 1: 'Choose x')
  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const FlowChartCanvasData({
    this.mode = 0,
    this.mainNodes = const [],
    this.hasTryAgainLoop = true,
    this.loopReturnIndex = 1,
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class FlowChartPreset {
  final String chipLabel;
  final int mode;
  final int chartStyle; // 0: Fig 1.2/1.3 Algebraic Style ('Choose x'), 1: Fig 1.1 Verbal Style ('Choose a number')
  final String input1;
  final String input2;
  final String input3;

  const FlowChartPreset({
    required this.chipLabel,
    required this.mode,
    this.chartStyle = 0,
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and flow chart visualizer state.
class FlowChartResult {
  final int mode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<FlowChartStep> steps;
  final FlowChartCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const FlowChartResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory FlowChartResult.error({
    required int mode,
    required String message,
  }) {
    return FlowChartResult(
      mode: mode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const FlowChartCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}