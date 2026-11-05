/// Represents a single pedagogical step in the Expansion of Algebraic Expressions solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ExpansionStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ExpansionStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Expansion Math.tex Visualisation Area.
/// Every algebraic term, exponent, and Area-Box cell is rendered using flutter_math_fork (Math.tex)!
class ExpansionCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String areaBoxLaTeX; // Textbook Area-Box Expansion Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const ExpansionCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.areaBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 65 & 71.
class ExpansionPreset {
  final String chipLabel;
  final int mode;
  // 0: Multiply Out a Single Bracket A(B ± C) or A(B ± C ± D) (Example 1a–c, Ex 7.1 Part A #1–16 & Rev Ex 7 Part A #1–10)
  // 1: Expand and Simplify Two Brackets A(B ± C) ± D(E ± F) (Exercise 7.1 Part B #1, #2, #4, #5, #9–12)
  // 2: Standalone Term Plus/Minus a Bracket M ± A(B ± C) (Exercise 7.1 Part B #3, #6, #7, #8)
  // 3: Universal Free-Form Bracket Expander & Simplifier

  final String input1;
  final String input2;
  final String input3;

  const ExpansionPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ExpansionResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ExpansionStep> steps;
  final ExpansionCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ExpansionResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ExpansionResult.error({
    required int mode,
    required String message,
  }) {
    return ExpansionResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ExpansionCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}