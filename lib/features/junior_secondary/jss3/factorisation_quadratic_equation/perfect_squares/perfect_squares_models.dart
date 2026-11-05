/// Represents a single pedagogical step in the Perfect Squares (Pages 75–77) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class PerfectSquaresStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const PerfectSquaresStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Perfect Squares Math.tex Visualisation Area.
/// Replicates the Textbook Identity Decomposition & Arrow-Mapping Table (Page 76) in Math.tex!
class PerfectSquaresCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String decompositionBoxLaTeX; // Textbook Page 76 Method 1 & Method 2 Comparison Box in Math.tex!
  final String bottomSummaryLaTeX;

  const PerfectSquaresCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.decompositionBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 75–77 (Example 4a–e & Exercise 8.4 #1–20).
class PerfectSquaresPreset {
  final String chipLabel;
  final int mode;
  // 0: Factorise Perfect Square Quadratic (Shows BOTH Method 1 & Method 2 from Page 76! — Example 4a–e & Exercise 8.4 #1–20)
  // 1: Find the Missing Term (k) to Make a Quadratic a Perfect Square (Exam-Standard Extension)

  final String exprInput;
  final String term1Input;
  final String term2Input;
  final int missingPosition; // 0: Middle term missing, 1: Last/Constant term missing, 2: First term missing

  const PerfectSquaresPreset({
    required this.chipLabel,
    required this.mode,
    this.exprInput = '',
    this.term1Input = '',
    this.term2Input = '',
    this.missingPosition = 0,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class PerfectSquaresResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<PerfectSquaresStep> steps;
  final PerfectSquaresCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const PerfectSquaresResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory PerfectSquaresResult.error({
    required int mode,
    required String message,
  }) {
    return PerfectSquaresResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const PerfectSquaresCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}