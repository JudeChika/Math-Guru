/// Represents a single pedagogical step in the Coefficients of Terms (Pages 73–74) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class CoefficientsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const CoefficientsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Coefficients of Terms Math.tex Visualisation Area.
/// Every fractional coefficient (\frac{2}{7}, -\frac{11}{18}, -\frac{7}{40}) is rendered via Math.tex!
class CoefficientsCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String anatomyTableLaTeX; // Term Anatomy Breakdown Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const CoefficientsCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.anatomyTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 73–74 (Example 2 & Exercise 8.2).
class CoefficientsPreset {
  final String chipLabel;
  final int mode;
  // 0: Direct Quadratic Polynomial (Standard or Scrambled Order, including Fractions — Example 2a–e, Page 73)
  // 1: Product of Two Binomials Requiring Expansion First (Exercise 8.2 #1–6, #10, Page 74)
  // 2: Squared Binomial Requiring Expansion First (Exercise 8.2 #7–9, Page 74)

  final String input1;
  final String input2;

  const CoefficientsPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class CoefficientsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<CoefficientsStep> steps;
  final CoefficientsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const CoefficientsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory CoefficientsResult.error({
    required int mode,
    required String message,
  }) {
    return CoefficientsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const CoefficientsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}