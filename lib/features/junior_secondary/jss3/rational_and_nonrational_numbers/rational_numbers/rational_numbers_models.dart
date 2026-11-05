/// Represents a single pedagogical step in the Rational Numbers solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class RationalNumbersStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const RationalNumbersStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Rational Numbers Math.tex Visualisation Area.
/// Every fraction and recurring-dot expression is rendered using flutter_math_fork (Math.tex)!
class RationalNumbersCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String middleBannerLaTeX;
  final String bottomSummaryLaTeX;

  const RationalNumbersCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.middleBannerLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 52–54 & 56–57.
class RationalNumbersPreset {
  final String chipLabel;
  final int mode;
  // 0: Rewrite Terminating Decimals as Rational Numbers a/b in Lowest Form (Ex 5.1 #1a–e & Rev Ex 5 #1a–j)
  // 1: Convert Recurring Decimals to Rational Numbers a/b Using Simultaneous Equations (1) & (2) (Example 1a–b & Ex 5.1 #3a–f)
  // 2: Express Fractions a/b as Terminating or Recurring Decimals with Dot Notation (Ex 5.1 #2a–j, #4a–j & Rev Ex 5 #2a–d)
  // 3: Number Set Hierarchy & Linear Equation Motivating Rational Numbers (Page 52: 2x + 5 = 12)

  final String input1; // Whole/Decimal part or Fraction string
  final String input2; // Recurring digits block (for Mode 1) or Equation RHS

  const RationalNumbersPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class RationalNumbersResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<RationalNumbersStep> steps;
  final RationalNumbersCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const RationalNumbersResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory RationalNumbersResult.error({
    required int mode,
    required String message,
  }) {
    return RationalNumbersResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const RationalNumbersCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}