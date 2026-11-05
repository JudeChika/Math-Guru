/// Represents a single pedagogical step in the Solving Simple Equations Involving Fractions (Pages 81–83) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SimpleEquationsFractionsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SimpleEquationsFractionsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Simple Equations Involving Fractions Math.tex Visualisation Area.
/// Every fraction (\frac{}{}), LCM cancellation, and mixed number is rendered via flutter_math_fork (Math.tex)!
class SimpleEquationsFractionsCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String clearingTableLaTeX; // Fraction-Clearing & LCM Transformation Table in Math.tex!
  final String bottomSummaryLaTeX;

  const SimpleEquationsFractionsCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.clearingTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 81–83 (Examples 1 & 2, Exercise 9.1 #1–12, and Revision Exercise 9 #1, #2, #5, #7).
class SimpleEquationsFractionsPreset {
  final String chipLabel;
  final int mode;
  // 0: Full Equation Input (e.g. 3/4 - w/12 = 0, (z+3)/2 - (z+2)/3 = 2, 5/6 - 3x/4 = (2x-1)/3)
  // 1: Two-Sided Fraction Builder (LHS Expression = RHS Expression)

  final String lhsInput;
  final String rhsInput;

  const SimpleEquationsFractionsPreset({
    required this.chipLabel,
    required this.mode,
    required this.lhsInput,
    this.rhsInput = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SimpleEquationsFractionsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SimpleEquationsFractionsStep> steps;
  final SimpleEquationsFractionsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SimpleEquationsFractionsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SimpleEquationsFractionsResult.error({
    required int mode,
    required String message,
  }) {
    return SimpleEquationsFractionsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SimpleEquationsFractionsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}