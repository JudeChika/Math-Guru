/// Represents a single pedagogical step in the Factorisation by Taking Out Common Factors solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class CommonFactorsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const CommonFactorsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Common Factors Math.tex Visualisation Area.
/// Every factorisation box, fraction quotient, and exponent is rendered via Math.tex!
class CommonFactorsCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String factorBoxLaTeX; // Textbook Factorisation Box (Example 3 & QR Page 70) rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const CommonFactorsCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.factorBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 67–68 & 70–71.
class CommonFactorsPreset {
  final String chipLabel;
  final int mode;
  // 0: Factorise 2-Term & 3-Term Expressions Completely (Example 3a–c, Example 4a–c, Ex 7.3 #1–20 & Rev Ex 7 Part C)
  // 1: Complete Partially Factorised Expressions E = F(   ) (Revision Exercise 7 Part B #1–10)
  // 2: Quantitative Reasoning Factorisation Box Puzzles (Page 70 #1–9)
  // 3: Reverse Expansion Verification Check

  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String input5;

  const CommonFactorsPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.input5 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class CommonFactorsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<CommonFactorsStep> steps;
  final CommonFactorsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const CommonFactorsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory CommonFactorsResult.error({
    required int mode,
    required String message,
  }) {
    return CommonFactorsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const CommonFactorsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}