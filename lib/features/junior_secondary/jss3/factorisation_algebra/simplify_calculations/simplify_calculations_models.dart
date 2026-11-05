/// Represents a single pedagogical step in the Simplifying Calculations by Factorisation solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SimplifyCalculationsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SimplifyCalculationsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Exact parsed representation of any input number (integer, decimal, proper/improper fraction, or mixed number).
class ParsedCalcTerm {
  final String rawInput;
  final double value;
  final int num; // Signed reduced improper numerator
  final int den; // Positive reduced denominator
  final bool isFractionOrMixed;
  final bool isMixedInput;
  final String displayPlain; // e.g., "5/6", "3 1/4", "1 6/11", "35"
  final String displayLaTeX; // e.g., "\\frac{5}{6}", "3\\frac{1}{4}", "1\\frac{6}{11}", "35"
  final String improperLaTeX; // e.g., "\\frac{5}{6}", "\\frac{13}{4}", "\\frac{17}{11}", "35"

  const ParsedCalcTerm({
    required this.rawInput,
    required this.value,
    required this.num,
    required this.den,
    this.isFractionOrMixed = false,
    this.isMixedInput = false,
    required this.displayPlain,
    required this.displayLaTeX,
    required this.improperLaTeX,
  });
}

/// Encapsulates all visual elements for the Simplifying Calculations Math.tex Visualisation Area.
/// Every fraction, mixed number, and Quantitative Reasoning Roof diagram is rendered via Math.tex!
class SimplifyCalculationsCanvasData {
  final int visualType;
  // 0: Factorisation Shortcut Pipeline (Modes 0, 1 & 2 — Example 5 & Exercise 7.4 #1–20)
  // 1: Quantitative Reasoning Roof / Triangle Diagram (Mode 3 — Page 70 #10–15)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  // For VisualType 1 (Page 70 Quantitative Reasoning Roof/Triangle Diagram)
  final String peakLaTeX;
  final String leftWingLaTeX;
  final String rightWingLaTeX;
  final String bottomBaseLaTeX;

  final String middleBannerLaTeX;
  final String bottomSummaryLaTeX;

  const SimplifyCalculationsCanvasData({
    this.visualType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.peakLaTeX = '',
    this.leftWingLaTeX = '',
    this.rightWingLaTeX = '',
    this.bottomBaseLaTeX = '',
    this.middleBannerLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 68–70.
class SimplifyCalculationsPreset {
  final String chipLabel;
  final int mode;
  // 0: Standard Two-Product Sum or Difference: k × a ± k × b = k(a ± b) (Example 5a–c & Ex 7.4 #1, #3–15, #17–20)
  // 1: Implicit × 1 Term: k × a ± k = k(a ± 1) (Exercise 7.4 #2: 199 × 19 + 19)
  // 2: Square Term: k × a ± k² = k(a ± k) (Exercise 7.4 #16: 39 × 139 − 39²)
  // 3: Quantitative Reasoning Roof / Triangle Puzzles (Page 70 #10–15: Peak × (Left + Right) = Bottom)

  final int subMode; // 0 = Addition (+), 1 = Subtraction (−)
  final String input1; // Common Factor k (or Peak in Mode 3)
  final String input2; // First Term a (or Left Wing in Mode 3)
  final String input3; // Second Term b (or Right Wing in Mode 3)
  final String input4; // Bottom Base in Mode 3

  const SimplifyCalculationsPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    required this.input1,
    required this.input2,
    this.input3 = '',
    this.input4 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SimplifyCalculationsResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SimplifyCalculationsStep> steps;
  final SimplifyCalculationsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SimplifyCalculationsResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SimplifyCalculationsResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return SimplifyCalculationsResult(
      mode: mode,
      subMode: subMode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SimplifyCalculationsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}