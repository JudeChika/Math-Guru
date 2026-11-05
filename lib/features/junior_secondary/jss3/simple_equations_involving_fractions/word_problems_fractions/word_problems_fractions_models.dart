/// Represents a single pedagogical step in the Word Problems Involving Algebraic Fractions (Pages 86–89) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class WordProblemsFractionsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const WordProblemsFractionsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Word Problems Involving Algebraic Fractions Math.tex Visualisation Area.
/// Every formed fractional equation, LCM/cross-multiplication step, and "Check:" verification is rendered via Math.tex!
class WordProblemsFractionsCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String translationTableLaTeX; // Word-to-Algebra Translation & Verification Table in Math.tex!
  final String bottomSummaryLaTeX;

  const WordProblemsFractionsCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.translationTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 86–89 (Example 5a–e, Exercise 9.4 #1–20, and Revision Exercise 9 #8).
class WordProblemsFractionsPreset {
  final String chipLabel;
  final int mode;
  // 0: Ratio & Proportion Word Problems (Example 5a, Ex 9.4 #4, #7)
  // 1: Fraction of a Number Added/Subtracted (Example 5b, 5c, Ex 9.4 #1, #5, #8)
  // 2: Reciprocal of a Number Word Problems (Example 5d, Ex 9.4 #14, #15, #18)
  // 3: "Think of a Number" & Two-Sided Fractional Operations (Example 5e, Ex 9.4 #2, #3, #6, #16, #19)
  // 4: Equal Perimeters of Square & Rectangle with Fractional Sides (Revision Exercise 9 #8a–d)

  final String problemStatement;
  final String unknownMeaning;
  final String equationStr;
  final String extraType; // e.g., 'cyclists_ex9_4_3', 'oranges_ex9_4_7', 'perimeters_rev_9_8'

  const WordProblemsFractionsPreset({
    required this.chipLabel,
    required this.mode,
    required this.problemStatement,
    required this.unknownMeaning,
    required this.equationStr,
    this.extraType = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class WordProblemsFractionsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<WordProblemsFractionsStep> steps;
  final WordProblemsFractionsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const WordProblemsFractionsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory WordProblemsFractionsResult.error({
    required int mode,
    required String message,
  }) {
    return WordProblemsFractionsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const WordProblemsFractionsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}