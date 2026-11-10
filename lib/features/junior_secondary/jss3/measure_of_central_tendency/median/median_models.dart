/// Represents a single pedagogical step in the Median (Chapter 18, Pages 213–215) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class MedianStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const MedianStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Interactive Median & Cumulative Frequency Visualisation Area.
/// Every formula, fraction (\frac{}{}), ordered term, and table cell is rendered using flutter_math_fork (Math.tex)!
class MedianCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String mainBoxLaTeX; // Ordered Strip or Cumulative Frequency Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const MedianCanvasData({
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 213–215 & Page 218.
class MedianPreset {
  final String chipLabel;
  final int mode;
  // 0: Ungrouped Data List (Example 2 Odd, Example 3 Even, Exercise 18.2 #1a–g, #3a–e)
  // 1: Frequency Table (Example 4 Table 18.6, Exercise 18.2 #2 Table 18.7, #4 Table 18.8, #5 Table 18.9)

  final String input1;
  final String input2;
  final String unit;

  const MedianPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.unit = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class MedianResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<MedianStep> steps;
  final MedianCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const MedianResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory MedianResult.error({
    required int mode,
    required String message,
  }) {
    return MedianResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const MedianCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}