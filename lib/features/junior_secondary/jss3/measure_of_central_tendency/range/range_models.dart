/// Represents a single pedagogical step in the Range (Chapter 18, Pages 217–218) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class RangeStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const RangeStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Interactive Range & Extremes Visualisation Area.
/// Every formula, fraction (\frac{}{}), mixed number, and ordered cell is rendered using flutter_math_fork (Math.tex)!
class RangeCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String mainBoxLaTeX; // Ordered Data Strip with Lowest & Highest Highlighted via Math.tex!
  final String bottomSummaryLaTeX;

  const RangeCanvasData({
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 217–218.
class RangePreset {
  final String chipLabel;
  final int mode;
  // 0: Ungrouped Data List — Integers, Decimals, or Mixed Fractions (Example 7, Ex 18.4 #1a–f, #4, #5, Rev Ex 18 #1b, #2a–e, #4d)
  // 1: Given Highest & Lowest Values Directly (Exercise 18.4 #2: Oldest & Youngest)
  // 2: Find Smallest Value Given Range & Highest Value (Exercise 18.4 #3)
  // 3: Find Highest Value Given Range & Smallest Value (Exam Variation of Ex 18.4 #3)

  final String input1;
  final String input2;
  final String unit;

  const RangePreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.unit = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class RangeResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<RangeStep> steps;
  final RangeCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const RangeResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory RangeResult.error({
    required int mode,
    required String message,
  }) {
    return RangeResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const RangeCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}