/// Represents a single pedagogical step in the Construction of Angles (30°, 45°, 60°, 90° and Combinations, Pages 202–205 & 207–209) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ConstructionOfAnglesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ConstructionOfAnglesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Construction of Angles Interactive Compass-and-Ruler Diagram + Math.tex Board.
/// Replicates Figs. 17.11–17.22 & 17.35–17.36 (60°/120° Semicircle Arcs, 90°/45° Perpendiculars, 30°/15° Bisections & Combinations)!
class ConstructionOfAnglesCanvasData {
  final int constructionFamily;
  // 0: 60° and 120° Family (Equilateral Stepping Along Semicircle — Figs. 17.17–17.20 & Fig. 17.36)
  // 1: 30° and 15° Family (Construct 60° First, Then Bisect — Figs. 17.21–17.22 & Ex 17.2 #6a)
  // 2: 90° and 45° Family (Construct 90° First, Then Bisect — Figs. 17.11–17.16 & Fig. 17.35)
  // 3: Combined Angles (75°, 105°, 135°, 150° & Triangle Angles — Ex 17.2 #2c, #6b, #7–8 & Rev Ex 17 #2–3)

  final double targetAngleDeg;

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String vertexLabel; // e.g. 'O' or 'A'
  final String angleLabel; // e.g. '60°', '45°', '30°', '135°'
  final String supplementLabel; // e.g. '120°', '135°', '150°'

  final String constructionTableLaTeX; // Step-by-Step Compass Construction & Angle Decomposition Table in Math.tex!
  final String bottomSummaryLaTeX;

  const ConstructionOfAnglesCanvasData({
    this.constructionFamily = 0,
    this.targetAngleDeg = 60.0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.vertexLabel = 'O',
    this.angleLabel = '60°',
    this.supplementLabel = '120°',
    this.constructionTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 202–205 (Figs. 17.11–17.22, Exercise 17.2 #1–10) and Pages 207–209 (Quantitative #3–4 & Revision Exercise 17 #2–3).
class ConstructionOfAnglesPreset {
  final String chipLabel;
  final int mode;
  // 0: Standard Compass Angle Construction (15°, 30°, 45°, 60°, 75°, 90°, 105°, 120°, 135°, 150°)
  // 1: Construct a Triangle Using Compass Angles & Measure the 3rd Side / Angles (Ex 17.2 #7, #8, #10 & Rev Ex 17 #2)

  final String angleInput;
  final String side1Input;
  final String side2Input;
  final String vertexName;

  const ConstructionOfAnglesPreset({
    required this.chipLabel,
    required this.mode,
    required this.angleInput,
    this.side1Input = '',
    this.side2Input = '',
    this.vertexName = 'O',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ConstructionOfAnglesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ConstructionOfAnglesStep> steps;
  final ConstructionOfAnglesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ConstructionOfAnglesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ConstructionOfAnglesResult.error({
    required int mode,
    required String message,
  }) {
    return ConstructionOfAnglesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ConstructionOfAnglesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}