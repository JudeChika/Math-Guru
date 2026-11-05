/// Represents a single pedagogical step in the Non-Rational Numbers solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class NonRationalNumbersStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const NonRationalNumbersStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Non-Rational Numbers CustomPaint + Math.tex Visualizer.
/// Every fraction, radical, and π expression is rendered using flutter_math_fork (Math.tex)!
class NonRationalNumbersCanvasData {
  final int visualType;
  // 0: Rational vs. Non-Rational Classifier & Algebraic Proof Cards (Modes 0 & 3 — Ex 5.2 #1–20 & Rev Ex 5 #3, #9)
  // 1: Circle Inside a Square (Figure 5.1) & Circumference vs. Diameter Graph (Modes 1 & 2 — Table 5.1, 5.2 & Fig. 5.1)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final double circleRadiusCm; // Used in Figure 5.1 (default 3 cm)
  final String middleBannerLaTeX;
  final String bottomSummaryLaTeX;

  const NonRationalNumbersCanvasData({
    this.visualType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.circleRadiusCm = 3.0,
    this.middleBannerLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 54–57.
class NonRationalNumbersPreset {
  final String chipLabel;
  final int mode;
  // 0: Identify Rational & Non-Rational Numbers (Exercise 5.2 #1–20 & Revision Exercise 5 #3a–f)
  // 1: The Value of Pi (π = C / D), Historical Table 5.1 & Experimental Circle Graph Table 5.2 (Activity 5.2 #1–4)
  // 2: Circle Drawn Inside a Square — Exact Values & Rationality (Revision Exercise 5 #4–8, Fig. 5.1)
  // 3: Multiplying Rational & Irrational Numbers (Revision Exercise 5 #9a–b)

  final String input1;
  final String input2;

  const NonRationalNumbersPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class NonRationalNumbersResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<NonRationalNumbersStep> steps;
  final NonRationalNumbersCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const NonRationalNumbersResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory NonRationalNumbersResult.error({
    required int mode,
    required String message,
  }) {
    return NonRationalNumbersResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const NonRationalNumbersCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}