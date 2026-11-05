/// Represents a single pedagogical step in the Addition & Subtraction of Binary Numbers solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class BinaryAddSubStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const BinaryAddSubStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Binary Addition & Subtraction Math.tex Visualisation Area.
/// Every vertical binary array, carry/borrow row, and Quantitative Reasoning box is rendered via Math.tex!
class BinaryAddSubCanvasData {
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

  const BinaryAddSubCanvasData({
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 58–60 & 62–64.
class BinaryAddSubPreset {
  final String chipLabel;
  final int mode;
  // 0: Binary Addition (2 or 3 Binary Numbers — Example 1a–d, Ex 6.1 #1–10, Rev Ex 6 #1–2)
  // 1: Binary Subtraction with Column-by-Column Borrowing (Example 2a–c, Ex 6.1 #15–20, Rev Ex 6 #3–5)
  // 2: Find the Missing Binary Number (•••••) in Additions & Subtractions (Ex 6.1 #11–14, #21–24 & Rev Ex 6 #6–10)
  // 3: Quantitative Reasoning Split-Box Puzzles (Pages 62–63 #6–10) & Combined Add/Sub Chains (Ex 6.3 #1)

  final int subMode;
  // Mode 2: 0 = Missing Addend (A + •••• = S or A + B + •••• = S), 1 = Missing Subtrahend (M − •••• = D), 2 = Missing Minuend (•••• − S = D)
  // Mode 3: 0 = Quantitative Reasoning Split-Box (TopLeft + TopRight = Bottom), 1 = Combined Add/Sub Chain (A + B − C)

  final String input1;
  final String input2;
  final String input3;

  const BinaryAddSubPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class BinaryAddSubResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<BinaryAddSubStep> steps;
  final BinaryAddSubCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BinaryAddSubResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BinaryAddSubResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return BinaryAddSubResult(
      mode: mode,
      subMode: subMode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BinaryAddSubCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}