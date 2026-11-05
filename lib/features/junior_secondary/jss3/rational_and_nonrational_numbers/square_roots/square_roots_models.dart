/// Represents a single pedagogical step in the Square Roots solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SquareRootsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SquareRootsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Square Roots Math.tex Visualisation Area.
/// Every fraction, inequality, and radical expression is rendered using flutter_math_fork (Math.tex)!
class SquareRootsCanvasData {
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

  const SquareRootsCanvasData({
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 54–57.
class SquareRootsPreset {
  final String chipLabel;
  final int mode;
  // 0: Progressive Trial Method for Non-Rational Square Roots (Examples 2 & 3, Ex 5.3 #1–10 & Rev Ex 5 #10a–j)
  // 1: Exact Square Roots of Perfect Squares, Decimals & Mixed Fractions (± Sign Rule — Activity 5.1 & Rev Ex 5 #10g, h)
  // 2: Activity 5.1 Explorer — Square Roots of the First 20 Natural Numbers (√1 to √20)

  final int accuracyMode; // 0: 1 d.p. (Ex 3 & Ex 5.3), 1: 2 s.f. (Ex 2), 2: 3 s.f. (Rev Ex 5 #10)
  final String input1;

  const SquareRootsPreset({
    required this.chipLabel,
    required this.mode,
    this.accuracyMode = 0,
    required this.input1,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SquareRootsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SquareRootsStep> steps;
  final SquareRootsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SquareRootsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SquareRootsResult.error({
    required int mode,
    required String message,
  }) {
    return SquareRootsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SquareRootsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}