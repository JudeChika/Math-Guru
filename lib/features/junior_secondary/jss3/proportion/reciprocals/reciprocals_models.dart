/// Represents a single pedagogical step in the Reciprocals solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ReciprocalsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ReciprocalsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Reciprocals CustomPaint + Math.tex Visualizer.
/// Every fraction expression in this model is rendered using flutter_math_fork (Math.tex)!
class ReciprocalsCanvasData {
  final int visualType;
  // 0: Multiplicative Inverse Identity & Calculator [1/x] Key Pipeline (Mode 0 — Examples 6 & 9, Ex 3.3 #1, #2)
  // 1: Power-of-10 Scaling Bridge & Long Division Box Visualizer (Modes 1 & 2 — Examples 7 & 8, Ex 3.3 #3–5)
  // 2: Division via Reciprocal & Mirror Formula Pipeline (Mode 3 — Exercise 3.4 #1–12)

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

  const ReciprocalsCanvasData({
    this.visualType = 0,
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 40–43.
class ReciprocalsPreset {
  final String chipLabel;
  final int mode;
  // 0: Reciprocal of Any Number, Fraction, Decimal, Power & Table 3.13 (Examples 6 & 9, Ex 3.3 #1, #2)
  // 1: Scaling Reciprocals by Powers of 10 (Example 7a–d & Exercise 3.3 #4, #5)
  // 2: Reciprocal by Long Division Method to 4 s.f. (Example 8 & Exercise 3.3 #3a–d)
  // 3: Evaluating Divisions Using Reciprocals, c/(2π) & Mirror Formula 1/f = 1/u + 1/v (Exercise 3.4 #1–12 & Rev Ex 3 #5)

  final int subMode;
  final String input1;
  final String input2;
  final String input3;

  const ReciprocalsPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ReciprocalsResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ReciprocalsStep> steps;
  final ReciprocalsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ReciprocalsResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ReciprocalsResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return ReciprocalsResult(
      mode: mode,
      subMode: subMode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ReciprocalsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}