/// Represents a single pedagogical step in the Using Sine and Cosine to Find Right-Angled Triangles (Pages 168–172 & 174–175) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SineCosineRightTrianglesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SineCosineRightTrianglesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Using Sine and Cosine in Right-Angled Triangles Interactive Diagram + Math.tex Board.
/// Replicates Figs. 15.14–15.24 & 15.28–15.30 with Opposite, Adjacent, Hypotenuse, and Angle θ rendered via Math.tex!
class SineCosineRightTrianglesCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String topVertex;
  final String rightAngleVertex;
  final String baseVertex;

  final String oppLabel;
  final String adjLabel;
  final String hypLabel;
  final String angleLabel;

  final String calculationTableLaTeX; // Step-by-Step SOH-CAH Rearrangement & Evaluation Table in Math.tex!
  final String bottomSummaryLaTeX;

  const SineCosineRightTrianglesCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.topVertex = 'A',
    this.rightAngleVertex = 'B',
    this.baseVertex = 'C',
    this.oppLabel = '8.39 cm',
    this.adjLabel = 'BC',
    this.hypLabel = '15 cm',
    this.angleLabel = '34°',
    this.calculationTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 168–172 (Examples 10 & 11, Exercise 15.6 #1–24) and Pages 174–175 (Revision Exercise 15 #3–10).
class SineCosineRightTrianglesPreset {
  final String chipLabel;
  final int mode;
  // 0: Find Opposite or Adjacent Leg Given Hypotenuse & Acute Angle (Examples 10 & 11, Ex 15.6 #1–9, #11, #13, #15 & Rev Ex 15 #4a, #4c, #6, #7)
  // 1: Find Hypotenuse Given One Leg & Acute Angle (Unknown in Denominator — Ex 15.6 #10, #12, #22 & Rev Ex 15 #4b, #4d, #10)
  // 2: Find Unknown Acute Angle Given One Leg & Hypotenuse (Ex 15.6 #16, #17, #21 & Rev Ex 15 #3a–d, #8, #9)
  // 3: Combined Sums, Pythagoras & Algebraic Sine/Cosine Identities (Ex 15.6 #14, #18, #19, #20, #24 & Rev Ex 15 #5)

  final bool useCosine; // false: Sine (Opposite & Hypotenuse), true: Cosine (Adjacent & Hypotenuse)
  final String input1;
  final String input2;
  final String input3;
  final String extraType;

  const SineCosineRightTrianglesPreset({
    required this.chipLabel,
    required this.mode,
    this.useCosine = false,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.extraType = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SineCosineRightTrianglesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SineCosineRightTrianglesStep> steps;
  final SineCosineRightTrianglesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SineCosineRightTrianglesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SineCosineRightTrianglesResult.error({
    required int mode,
    required String message,
  }) {
    return SineCosineRightTrianglesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SineCosineRightTrianglesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}