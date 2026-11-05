/// Represents a single pedagogical step in the Elimination Method (Pages 97–99 & 102) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class EliminationMethodStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const EliminationMethodStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Elimination Method Math.tex Visualisation Area.
/// Replicates the Textbook Vertical Subtraction/Addition Column (Page 98) in Math.tex!
class EliminationMethodCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String verticalColumnLaTeX; // Textbook Page 98 Vertical Addition/Subtraction Array in Math.tex!
  final String bottomSummaryLaTeX;

  const EliminationMethodCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.verticalColumnLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 97–99 (Examples 5a–b, 6a–b, Exercise 10.3 #1–15) and Page 102 (Revision Exercise 10 Part B #1–10).
class EliminationMethodPreset {
  final String chipLabel;
  final int eliminateChoice;
  // 0: Auto-pick best variable to eliminate (or opposite-sign variable as in Example 5b)
  // 1: Eliminate 1st Variable (e.g. x) (Example 5a, 6a, 6b)
  // 2: Eliminate 2nd Variable (e.g. y) (Example 5b)

  final String eq1Input;
  final String eq2Input;

  const EliminationMethodPreset({
    required this.chipLabel,
    this.eliminateChoice = 0,
    required this.eq1Input,
    required this.eq2Input,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class EliminationMethodResult {
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<EliminationMethodStep> steps;
  final EliminationMethodCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const EliminationMethodResult({
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory EliminationMethodResult.error({
    required String message,
  }) {
    return EliminationMethodResult(
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const EliminationMethodCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}