/// Represents a single pedagogical step in the Changing Numerical Expressions into Words solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class NumericalToWordsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const NumericalToWordsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the CustomPaint Expression-to-Words Syntax Tree.
class NumericalToWordsCanvasData {
  // Top Tier Nodes (Left / Numerator / 1st Part & Right / Denominator / 2nd Part)
  final String leftNodeTitle; // e.g., "Numerator (53 × 79)" or "1st Number (67)"
  final String leftNodeMath; // e.g., "53 × 79 = 4,187"
  final String leftNodeWords; // e.g., "the product of 53 and 79"

  final String rightNodeTitle; // e.g., "Denominator (22)" or "2nd Number (8)"
  final String rightNodeMath; // e.g., "22"
  final String rightNodeWords; // e.g., "22"

  // Middle Bridge (Connecting Operation)
  final String bridgeSymbol; // e.g., "+", "−", "×", "÷"
  final String bridgeRuleBadge; // e.g., "67 > 8  ➔  Positive Difference" or "Fraction Bar  ➔  Divided By"

  // Bottom Complete English Translation & Value Banner
  final String primaryWordsBanner; // e.g., "the product of 53 and 79 divided by 22."
  final String altWordsBanner; // e.g., "Alternative: 53 multiplied by 79, all divided by 22."
  final String evaluatedValueBanner; // e.g., "Evaluated Value = 190 7/22 (≈ 190.3182)"

  final String headerBadge;
  final String subBadge;

  const NumericalToWordsCanvasData({
    this.leftNodeTitle = '',
    this.leftNodeMath = '',
    this.leftNodeWords = '',
    this.rightNodeTitle = '',
    this.rightNodeMath = '',
    this.rightNodeWords = '',
    this.bridgeSymbol = '+',
    this.bridgeRuleBadge = '',
    this.primaryWordsBanner = '',
    this.altWordsBanner = '',
    this.evaluatedValueBanner = '',
    this.headerBadge = '',
    this.subBadge = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Example 13(a–e) and Exercise #1–20.
class NumericalToWordsPreset {
  final String chipLabel;
  final int mode;
  // 0: Universal Expression-to-Words Translator (Free-Form Input for Any Expression)
  // 1: Basic Sum, Positive/Negative Difference & Product Builder (Ex 13a–d & #1, #2, #8, #9, #14)
  // 2: Bracketed & Combined Product/Sum/Difference Builder (#5, #6, #7, #13, #15)
  // 3: Fractional Division Expressions Numerator / Denominator (Ex 13e & #3, #4, #10–12, #16–20)

  final int subMode;
  final String exprInput; // Used in Mode 0
  final String input1;
  final String input2;
  final String input3;

  const NumericalToWordsPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.exprInput = '',
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class NumericalToWordsResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<NumericalToWordsStep> steps;
  final NumericalToWordsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const NumericalToWordsResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory NumericalToWordsResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return NumericalToWordsResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const NumericalToWordsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}