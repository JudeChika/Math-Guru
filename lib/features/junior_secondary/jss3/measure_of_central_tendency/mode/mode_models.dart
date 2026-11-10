/// Represents a single pedagogical step in the Mode (Chapter 18, Pages 215–216 & 218) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ModeStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ModeStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Interactive Mode & Frequency Table Visualisation Area.
/// Every formula, fraction (\frac{}{}), percentage, and table cell is rendered using flutter_math_fork (Math.tex)!
class ModeCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String mainBoxLaTeX; // Frequency Table with Modal Highlight rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const ModeCanvasData({
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 215–216 & Page 218.
class ModePreset {
  final String chipLabel;
  final int mode;
  // 0: Ungrouped Data List — Numeric or Qualitative (Example 5, Ex 18.3 #1a–e, #3, #4, #5, Rev Ex 18 #4)
  // 1: Frequency Distribution Table — Numeric or Grade Labels A–F (Example 6 Table 18.10, Ex 18.3 #2 Table 18.11, Rev Ex 18 #3, #5, #6)

  final String input1;
  final String input2;
  final String targetValue; // Optional target for % or count query (e.g. Ex 18.3 #2b: age 15)
  final String unit;

  const ModePreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.targetValue = '',
    this.unit = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ModeResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ModeStep> steps;
  final ModeCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ModeResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ModeResult.error({
    required int mode,
    required String message,
  }) {
    return ModeResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ModeCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}