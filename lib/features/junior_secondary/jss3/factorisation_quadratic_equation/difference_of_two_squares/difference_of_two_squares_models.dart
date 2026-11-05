/// Represents a single pedagogical step in the Difference of Two Squares (Pages 77–80) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class DifferenceOfTwoSquaresStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const DifferenceOfTwoSquaresStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Difference of Two Squares Math.tex Visualisation Area.
/// Every fraction (\frac{}{}), mixed number, and geometric area identity (Page 77 EFGH square) is rendered via Math.tex!
class DifferenceOfTwoSquaresCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String identityBoxLaTeX; // Algebraic / Numerical Identity Table & Page 77 Area Proof in Math.tex!
  final String bottomSummaryLaTeX;

  const DifferenceOfTwoSquaresCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.identityBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 77–80 (Examples 5 & 6, Exercises 8.5 & 8.6, Revision Exercise 8 Parts B, C & D).
class DifferenceOfTwoSquaresPreset {
  final String chipLabel;
  final int mode;
  // 0: Algebraic Factorisation (Includes HCF Extraction, Fractions & Mixed Numbers — Example 5a–e & Exercise 8.5 #1–22)
  // 1: Numerical Evaluation Using Difference of Two Squares (Example 6a–e, Exercise 8.6 #1–15 & Rev Ex 8 Part D)

  final String input1;
  final String input2;

  const DifferenceOfTwoSquaresPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class DifferenceOfTwoSquaresResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<DifferenceOfTwoSquaresStep> steps;
  final DifferenceOfTwoSquaresCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const DifferenceOfTwoSquaresResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory DifferenceOfTwoSquaresResult.error({
    required int mode,
    required String message,
  }) {
    return DifferenceOfTwoSquaresResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const DifferenceOfTwoSquaresCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}