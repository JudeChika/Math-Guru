/// Represents a single pedagogical step in the Mean (Chapter 18, Pages 211–213) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class MeanStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const MeanStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Interactive Mean & Frequency Table Visualisation Area.
/// Every formula, fraction (\frac{}{}), mixed number, and table cell is rendered using flutter_math_fork (Math.tex)!
class MeanCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String mainBoxLaTeX; // Data / Frequency Table (Table 18.2 / 18.4 format) rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const MeanCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.mainBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 211–213 & Page 218.
class MeanPreset {
  final String chipLabel;
  final int mode;
  // 0: Ungrouped Data List (Example 1, Exercise 18.1 #1a–e, #4, Revision Ex 18 #1, #2a–e)
  // 1: Frequency Distribution Table (Table 18.1/18.2, Exercise 18.1 #2 Table 18.3, #5 Table 18.5, Rev Ex 18 #3, #5, #6)
  // 2: Missing Value / Combined Mean (Given Mean & Known Scores)
  // 3: Student × Subject Matrix Table (Exercise 18.1 #3 Table 18.4, Page 213)

  final String input1;
  final String input2;
  final String input3;
  final String unit;

  const MeanPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.unit = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class MeanResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<MeanStep> steps;
  final MeanCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const MeanResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory MeanResult.error({
    required int mode,
    required String message,
  }) {
    return MeanResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const MeanCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}