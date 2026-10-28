/// Represents a single pedagogical step in the Word Problems Involving Fractions solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class FractionWordProblemStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const FractionWordProblemStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Exact parsed representation of any input number (integer, decimal, proper/improper fraction, or mixed number).
class ParsedRational {
  final String rawInput;
  final double value;
  final int num; // Signed improper numerator (reduced)
  final int den; // Positive denominator (reduced)
  final bool isFractionOrMixed;
  final bool isMixedInput;
  final String displayPlain; // e.g., "3/4", "2 1/2", "15"
  final String displayLaTeX; // e.g., "\\frac{3}{4}", "2\\frac{1}{2}", "15"
  final String improperLaTeX; // e.g., "\\frac{3}{4}", "\\frac{5}{2}", "15"

  const ParsedRational({
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

/// Represents a single partitioned segment in the Whole-Bar Partition Visualizer (Mode 3).
class WholeBarSegment {
  final String title; // e.g., "1st Share (1/3)"
  final String fractionOfWholeText; // e.g., "1/3 of Whole"
  final String valueText; // e.g., "= 15,000"
  final double proportion; // 0.0 to 1.0
  final int colorIndex; // 0: Purple, 1: Orange, 2: Green

  const WholeBarSegment({
    required this.title,
    required this.fractionOfWholeText,
    required this.valueText,
    required this.proportion,
    required this.colorIndex,
  });
}

/// Encapsulates all visual elements for the CustomPaint canvas.
class FractionWordProblemsCanvasData {
  final int visualType;
  // 0: LCM Denominator-Clearing & Algebraic Balance Scale Visualizer (Modes 0, 1 & 2)
  // 1: Proportional Whole-Bar Partition Visualizer (Mode 3 — Real-Life Shares & "Of the Remainder")

  // VisualType 0 fields (LCM Clearing Pipeline)
  final String topFractionalEqText; // e.g., "(3/4)x − 4 = 11" or "(x + 5)/4 = 7"
  final String lcmBridgeBadgeText; // e.g., "Multiply Every Term by LCM = 4"
  final String clearedIntegerEqText; // e.g., "3x − 16 = 44   ➔   3x = 60"
  final String finalSolutionBannerText; // e.g., "x = 20"

  // VisualType 1 fields (Proportional Whole-Bar Partition)
  final String totalWholeTitle; // e.g., "Total Original Whole (x = 45,000)"
  final List<WholeBarSegment> segments;

  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const FractionWordProblemsCanvasData({
    this.visualType = 0,
    this.topFractionalEqText = '',
    this.lcmBridgeBadgeText = '',
    this.clearedIntegerEqText = '',
    this.finalSolutionBannerText = '',
    this.totalWholeTitle = '',
    this.segments = const [],
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook and BECE exam preset for instant one-tap loading across all 4 modes.
class FractionWordProblemPreset {
  final String chipLabel;
  final int mode;
  // 0: Fractions of an Unknown Number x (Single, Sum/Diff of Two Fractions, Two-Sided)
  // 1: Algebraic Numerators / Linear Expressions Divided by a Denominator
  // 2: Unknown in the Denominator & Finding an Original Fraction (N / D)
  // 3: Real-Life Fractional Shares of a Whole & "Of the Remainder" Word Problems

  final int subMode;
  final String input1;
  final String input2;
  final String input3;
  final String input4;

  const FractionWordProblemPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class FractionWordProblemResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<FractionWordProblemStep> steps;
  final FractionWordProblemsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const FractionWordProblemResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory FractionWordProblemResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return FractionWordProblemResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const FractionWordProblemsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}