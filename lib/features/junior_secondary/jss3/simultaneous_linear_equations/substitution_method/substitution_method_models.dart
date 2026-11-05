/// Represents a single pedagogical step in the Substitution Method (Pages 94–97) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SubstitutionMethodStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SubstitutionMethodStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Substitution Method Math.tex Visualisation Area.
/// Every Equation (1) -> Equation (3) -> Equation (2) substitution and fraction (\frac{10 + 3y}{2}) is rendered via Math.tex!
class SubstitutionMethodCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String flowTableLaTeX; // Equation (1) -> (3) -> (2) Substitution Flow Table in Math.tex!
  final String bottomSummaryLaTeX;

  const SubstitutionMethodCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.flowTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 94–97 (Examples 3a–e, 4a–b, Exercise 10.2 #1–20) and Page 101 (Revision Exercise 10 Part A #1–10).
class SubstitutionMethodPreset {
  final String chipLabel;
  final int subjectChoice;
  // 0: Auto-pick best variable & equation (or follow textbook Example 3 & 4 choice)
  // 1: Force making 1st variable (e.g. x) the subject from Equation (1) (Example 3b & 3c)
  // 2: Force making 2nd variable (e.g. y) the subject from Equation (1) or (2)

  final String eq1Input;
  final String eq2Input;

  const SubstitutionMethodPreset({
    required this.chipLabel,
    this.subjectChoice = 0,
    required this.eq1Input,
    required this.eq2Input,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SubstitutionMethodResult {
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SubstitutionMethodStep> steps;
  final SubstitutionMethodCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SubstitutionMethodResult({
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SubstitutionMethodResult.error({
    required String message,
  }) {
    return SubstitutionMethodResult(
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SubstitutionMethodCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}