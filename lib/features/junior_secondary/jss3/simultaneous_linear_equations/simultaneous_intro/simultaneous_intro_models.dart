/// Represents a single pedagogical step in the Simultaneous Linear Equations Introduction (Page 91 & Page 102) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SimultaneousIntroStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SimultaneousIntroStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Simultaneous Linear Equations Intro Math.tex Visualisation Area.
/// Every equation, fraction (\frac{}{}), and dual-equation check is rendered via flutter_math_fork (Math.tex)!
class SimultaneousIntroCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String overviewTableLaTeX; // Dual-Equation Verification & Overview Table in Math.tex!
  final String bottomSummaryLaTeX;

  const SimultaneousIntroCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.overviewTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Page 91 (Notebooks & Pencils Intro) and Page 102 (Revision Exercise 10 Part C #1–10).
class SimultaneousIntroPreset {
  final String chipLabel;
  final int mode;
  // 0: Form & Solve Simultaneous Equations from Real-Life Statements / Pairs (Page 91 Intro & Rev Ex 10 Part C #1–10)
  // 1: Verify Whether a Given Pair (x, y) Satisfies Both Simultaneous Equations

  final String eq1Input;
  final String eq2Input;
  final String testVar1Input;
  final String testVar2Input;
  final String contextDescription;

  const SimultaneousIntroPreset({
    required this.chipLabel,
    required this.mode,
    required this.eq1Input,
    required this.eq2Input,
    this.testVar1Input = '',
    this.testVar2Input = '',
    this.contextDescription = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SimultaneousIntroResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SimultaneousIntroStep> steps;
  final SimultaneousIntroCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SimultaneousIntroResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SimultaneousIntroResult.error({
    required int mode,
    required String message,
  }) {
    return SimultaneousIntroResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SimultaneousIntroCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}