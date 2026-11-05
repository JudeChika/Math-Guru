/// Represents a single pedagogical step in the Multiplication & Division in Base 2 solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class BinaryMulDivStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const BinaryMulDivStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Binary Multiplication & Division Math.tex Visualisation Area.
/// Every long-multiplication array, division fraction, remainder ladder, and QR V-tree is rendered via Math.tex!
class BinaryMulDivCanvasData {
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

  const BinaryMulDivCanvasData({
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 60–64.
class BinaryMulDivPreset {
  final String chipLabel;
  final int mode;
  // 0: Binary Long Multiplication (Example 3a–c, Ex 6.2 Part A #1–12 & Rev Ex 6 #11–12)
  // 1: Binary Division — Base-10 Bridge Method & Missing Factor y (Example 4a–c, Ex 6.2 Part B #1–8, Ex 6.3 #11, #15 & Rev Ex 6 #13–15)
  // 2: Combined Order-of-Operations (BODMAS), Brackets, Powers & Square Roots in Base 2 (Exercise 6.3 #3–10, #12–14)
  // 3: Quantitative Reasoning V-Tree Multiplication & Division Puzzles (Pages 62–63 #1–5)

  final int subMode;
  final String input1;
  final String input2;
  final String input3;

  const BinaryMulDivPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class BinaryMulDivResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<BinaryMulDivStep> steps;
  final BinaryMulDivCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BinaryMulDivResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BinaryMulDivResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return BinaryMulDivResult(
      mode: mode,
      subMode: subMode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BinaryMulDivCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}