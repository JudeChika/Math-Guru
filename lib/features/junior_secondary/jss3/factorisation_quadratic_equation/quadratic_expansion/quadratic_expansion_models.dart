/// Represents a single pedagogical step in the Expansion of Algebraic Expressions (Chapter 8, Page 73) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class QuadraticExpansionStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const QuadraticExpansionStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Quadratic Box / 2x2 Multiplication Grid Visualisation Area.
/// Every term, fraction (\frac{}{}), exponent, and grid cell is rendered using flutter_math_fork (Math.tex)!
class QuadraticExpansionCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String quadraticBoxLaTeX; // 2x2 Quadratic Box Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const QuadraticExpansionCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.quadraticBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Page 73 (Example 1 & Exercise 8.1) and Page 80 (Revision Exercise 8 Part A).
class QuadraticExpansionPreset {
  final String chipLabel;
  final int mode;
  // 0: Product of Two Binomials (a ± b)(c ± d) (Example 1a–d, g & Exercise 8.1 #1–40)
  // 1: Square of a Binomial (a ± b)² (Example 1e–f & Exercise 8.1 #41–44)
  // 2: Monomial × Binomial a(b ± c) (Revision Box, Page 73)
  // 3: Universal Free-Form Binomial / Polynomial Expander

  final String input1;
  final String input2;

  const QuadraticExpansionPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class QuadraticExpansionResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<QuadraticExpansionStep> steps;
  final QuadraticExpansionCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const QuadraticExpansionResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory QuadraticExpansionResult.error({
    required int mode,
    required String message,
  }) {
    return QuadraticExpansionResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const QuadraticExpansionCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}