/// Represents a single pedagogical step in the Sum and Difference Word Problems solver.
/// Every line in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SumAndDifferenceStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SumAndDifferenceStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Exact parsed representation of any input number (integer, decimal, proper/improper fraction, or mixed number).
class ParsedNumber {
  final String rawInput;
  final double value;
  final int num; // Reduced improper numerator (with sign)
  final int den; // Reduced positive denominator
  final bool isFractionOrMixed;
  final bool isMixedInput;
  final String displayPlain; // e.g., "-16", "18.5", "7 3/4", "-2 1/2"
  final String displayLaTeX; // e.g., "-16", "18.5", "7\\frac{3}{4}", "-2\\frac{1}{2}"
  final String improperLaTeX; // e.g., "\\frac{31}{4}", "-\\frac{5}{2}"

  const ParsedNumber({
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

/// Represents a single plotted marker on the Directed Number Line visualizer (Modes 0 & 1).
class NumberLineMarker {
  final double value;
  final String topLabel; // e.g., "A = -16 (Larger)" or "Case 1: x = 27.5"
  final String bottomValueLabel; // e.g., "-16" or "-10¼"
  final bool isPrimaryHighlight;

  const NumberLineMarker({
    required this.value,
    required this.topLabel,
    required this.bottomValueLabel,
    this.isPrimaryHighlight = false,
  });
}

/// Represents a directional jump arc on the Directed Number Line visualizer.
class NumberLineArc {
  final double fromVal;
  final double toVal;
  final String label; // e.g., "Positive Difference = +53" or "+9"
  final bool isPositiveJump;

  const NumberLineArc({
    required this.fromVal,
    required this.toVal,
    required this.label,
    this.isPositiveJump = true,
  });
}

/// Represents a single horizontal bar in the Algebraic Bar-Model visualizer (Modes 2 & 3).
class AlgebraicBarItem {
  final String termLabel; // e.g., "1st Odd Number: x" or "2nd Odd Number: x + 2"
  final String baseBlockLabel; // e.g., "x = 57"
  final double baseVal;
  final int offsetConst; // e.g., 0, +2, +4, -1, +1
  final String evaluatedText; // e.g., "= 59"

  const AlgebraicBarItem({
    required this.termLabel,
    required this.baseBlockLabel,
    required this.baseVal,
    this.offsetConst = 0,
    required this.evaluatedText,
  });
}

/// Encapsulates all visual elements for the CustomPaint canvas.
class SumAndDifferenceCanvasData {
  final int visualType;
  // 0: Directed Number Line & Distance Arcs (Modes 0 & 1)
  // 1: Algebraic Bar-Model & Total Brace (Modes 2 & 3)

  final List<NumberLineMarker> markers;
  final List<NumberLineArc> arcs;
  final List<AlgebraicBarItem> bars;
  final String totalBraceLabel;
  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const SumAndDifferenceCanvasData({
    this.visualType = 0,
    this.markers = const [],
    this.arcs = const [],
    this.bars = const [],
    this.totalBraceLabel = '',
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class SumAndDifferencePreset {
  final String chipLabel;
  final int mode;
  // 0: Direct Sum, Positive Difference & Negative Difference (Ex 2.1 #13, #14, #19)
  // 1: Find Unknown Number(s) Given Sum or Difference (Ex 2.1 #17, #18, #20, #21, #22, #23)
  // 2: Sum of Consecutive Numbers (Ex 2.1 #15, #16, #24, #25)
  // 3: Simultaneous Sum & Difference / Combined Pairs (Teacher's Guide Page 22)

  final int subMode;
  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final int consecutiveCount; // 2, 3, 4, or 5
  final int consecutiveType; // 0: Consecutive (x, x+1...), 1: Centered ((x-1), x, (x+1)), 2: Odd (x, x+2...), 3: Even (x, x+2...)

  const SumAndDifferencePreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.consecutiveCount = 3,
    this.consecutiveType = 0,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SumAndDifferenceResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<SumAndDifferenceStep> steps;
  final SumAndDifferenceCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SumAndDifferenceResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SumAndDifferenceResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return SumAndDifferenceResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SumAndDifferenceCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}