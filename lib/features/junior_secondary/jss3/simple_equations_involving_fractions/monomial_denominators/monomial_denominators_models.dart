/// Represents a single pedagogical step in the Simple Equations with Monomial Denominators (Pages 83–84) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class MonomialDenominatorsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const MonomialDenominatorsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Monomial Denominators Math.tex Visualisation Area.
/// Every algebraic fraction (\frac{15}{8z}, \frac{7}{30}), LCM (120z), and mixed number (8\frac{1}{28}) is rendered via Math.tex!
class MonomialDenominatorsCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String monomialTableLaTeX; // Monomial LCM & Cancellation Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const MonomialDenominatorsCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.monomialTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 83–84 (Example 3a–d, Exercise 9.2 #1–20, and Revision Exercise 9 #3, #4, #6).
class MonomialDenominatorsPreset {
  final String chipLabel;
  final int mode;
  // 0: Full Equation with Monomial Denominator(s) (Example 3a–d & Exercise 9.2 #1–20)
  // 1: Two-Sided Builder (LHS = RHS)

  final String lhsInput;
  final String rhsInput;

  const MonomialDenominatorsPreset({
    required this.chipLabel,
    required this.mode,
    required this.lhsInput,
    this.rhsInput = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class MonomialDenominatorsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<MonomialDenominatorsStep> steps;
  final MonomialDenominatorsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const MonomialDenominatorsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory MonomialDenominatorsResult.error({
    required int mode,
    required String message,
  }) {
    return MonomialDenominatorsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const MonomialDenominatorsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}