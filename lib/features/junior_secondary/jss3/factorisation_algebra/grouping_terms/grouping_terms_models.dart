/// Represents a single pedagogical step in the Factorisation by Grouping Like Terms solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class GroupingTermsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const GroupingTermsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Factorisation by Grouping Math.tex Visualisation Area.
/// Every pair grouping, common binomial bracket, and FOIL expansion is rendered via Math.tex!
class GroupingTermsCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String middleBannerLaTeX;
  final String bottomSummaryLaTeX;

  const GroupingTermsCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.middleBannerLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 69–71.
class GroupingTermsPreset {
  final String chipLabel;
  final int mode;
  // 0: Universal 4-Term Factorisation by Grouping (Example 6a–c, Exercise 7.5 #1–25 & Rev Ex 7 Part D #1–5)
  // 1: Already-Factored Binomial Common Factor A(X ± Y) ± B(X ± Y) (Exercise 7.5 #26–30)
  // 2: Compare Both Valid Pairings ((1st+2nd) vs (1st+3rd))
  // 3: FOIL / Expansion Verification of Grouped Factors (P + Q)(R + S)

  final String input1;
  final String input2;
  final String input3;

  const GroupingTermsPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class GroupingTermsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<GroupingTermsStep> steps;
  final GroupingTermsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const GroupingTermsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory GroupingTermsResult.error({
    required int mode,
    required String message,
  }) {
    return GroupingTermsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const GroupingTermsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}