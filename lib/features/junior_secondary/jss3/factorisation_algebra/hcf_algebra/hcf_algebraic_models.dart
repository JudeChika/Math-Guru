/// Represents a single pedagogical step in the HCF of Algebraic Expressions solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class HcfAlgebraicStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const HcfAlgebraicStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the HCF of Algebraic Expressions Math.tex Visualisation Area.
/// Every division table, prime-factor breakdown, and exponent is rendered via Math.tex!
class HcfAlgebraicCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String divisionTableLaTeX; // Textbook Vertical Division Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const HcfAlgebraicCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.divisionTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 66–67.
class HcfAlgebraicPreset {
  final String chipLabel;
  final int mode;
  // 0: HCF of 2 Algebraic Expressions (Example 2a–d & Exercise 7.2 #1–8)
  // 1: HCF of 3 Algebraic Expressions (Example 2e & Exercise 7.2 #9–20)
  // 2: Expanded Prime-Factor & Index Comparison Method
  // 3: HCF & Remaining Quotients Inspector (Bridge to Factorisation)

  final String input1;
  final String input2;
  final String input3;

  const HcfAlgebraicPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    required this.input2,
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class HcfAlgebraicResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<HcfAlgebraicStep> steps;
  final HcfAlgebraicCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const HcfAlgebraicResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory HcfAlgebraicResult.error({
    required int mode,
    required String message,
  }) {
    return HcfAlgebraicResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const HcfAlgebraicCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}