/// Represents a single pedagogical step in the Simple Equations with Binomial Denominators (Pages 84–85) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class BinomialDenominatorsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const BinomialDenominatorsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Binomial Denominators Math.tex Visualisation Area.
/// Every fraction (\frac{}{}), binomial LCM product, and mixed-number solution is rendered via Math.tex!
class BinomialDenominatorsCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String binomialTableLaTeX; // Binomial LCM & Cross-Multiplication Table in Math.tex!
  final String bottomSummaryLaTeX;

  const BinomialDenominatorsCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.binomialTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 84–85 (Example 4a–c & Exercise 9.3 #1–15).
class BinomialDenominatorsPreset {
  final String chipLabel;
  final int mode;
  // 0: Full Equation with Binomial Denominator(s) (Example 4a–c & Exercise 9.3 #1–15)
  // 1: Two-Sided Fraction Builder: Left Fraction (N₁ / D₁) = Right Fraction (N₂ / D₂)

  final String lhsInput;
  final String rhsInput;

  const BinomialDenominatorsPreset({
    required this.chipLabel,
    required this.mode,
    required this.lhsInput,
    this.rhsInput = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class BinomialDenominatorsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<BinomialDenominatorsStep> steps;
  final BinomialDenominatorsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BinomialDenominatorsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BinomialDenominatorsResult.error({
    required int mode,
    required String message,
  }) {
    return BinomialDenominatorsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BinomialDenominatorsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}