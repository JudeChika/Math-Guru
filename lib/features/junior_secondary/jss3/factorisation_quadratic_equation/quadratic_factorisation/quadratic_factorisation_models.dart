/// Represents a single pedagogical step in the Factorisation of Quadratic Expressions (Pages 74–75 & 79) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class QuadraticFactorisationStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const QuadraticFactorisationStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Factorisation of Quadratic Expressions Math.tex Visualisation Area.
/// Includes both the Page 74 Factor-Branch Diagram and the Page 79 Quantitative Reasoning 3-Tier Box!
class QuadraticFactorisationCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String quantitativeBoxLaTeX; // Page 79 Quantitative Reasoning 3-Tier Box Table in Math.tex!
  final String bottomSummaryLaTeX;

  const QuadraticFactorisationCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.quantitativeBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 74–75 (Example 3 & Exercise 8.3), Page 79 (Quantitative Reasoning), and Page 80 (Revision Exercise 8 Parts B & C).
class QuadraticFactorisationPreset {
  final String chipLabel;
  final int mode;
  // 0: Full Quadratic Expression Parser (e.g. x^2 + 8x + 12, 3x^2 - 10x + 3, 4 - x - 3x^2)
  // 1: Coefficients a, b, c Builder (ax² + bx + c)

  final String exprInput;
  final String aInput;
  final String bInput;
  final String cInput;
  final String varInput;

  const QuadraticFactorisationPreset({
    required this.chipLabel,
    required this.mode,
    this.exprInput = '',
    this.aInput = '',
    this.bInput = '',
    this.cInput = '',
    this.varInput = 'x',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class QuadraticFactorisationResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<QuadraticFactorisationStep> steps;
  final QuadraticFactorisationCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const QuadraticFactorisationResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory QuadraticFactorisationResult.error({
    required int mode,
    required String message,
  }) {
    return QuadraticFactorisationResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const QuadraticFactorisationCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}