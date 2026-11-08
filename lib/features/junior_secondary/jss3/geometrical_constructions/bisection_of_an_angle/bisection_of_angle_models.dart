/// Represents a single pedagogical step in the Bisection of an Angle (Pages 201–202 & 207–209) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class BisectionOfAngleStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const BisectionOfAngleStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Bisection of an Angle Interactive Compass-Arc Diagram + Math.tex Board.
/// Replicates Figs. 17.6–17.8 (Pages 201–202), Fig. 17.34 (Page 207), and Rev Ex 17 #4–5 (Pages 208–209)!
class BisectionOfAngleCanvasData {
  final int diagramType;
  // 0: Single Angle Bisection AOB with Arc XY and Cross-Arcs at Z (Figs. 17.6–17.8 & Fig. 17.34)
  // 1: Quartering an Angle into 4 Equal Parts (Exercise 17.1 #3–4 & Rev Ex 17 #5)
  // 2: Triangle PQR with All Three Angle Bisectors Meeting at Concurrent Incentre I (Rev Ex 17 #4)

  final double totalAngleDeg;

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String vertexLabel; // e.g. 'O' or 'B'
  final String topRayLabel; // e.g. 'A'
  final String botRayLabel; // e.g. 'B' or 'C'
  final String halfAngleLabel; // e.g. '27.5°' or '22.5°'

  final String summaryTableLaTeX; // Step-by-Step Compass Bisection & Protractor Check Table in Math.tex!
  final String bottomSummaryLaTeX;

  const BisectionOfAngleCanvasData({
    this.diagramType = 0,
    this.totalAngleDeg = 60.0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.vertexLabel = 'O',
    this.topRayLabel = 'A',
    this.botRayLabel = 'B',
    this.halfAngleLabel = '30°',
    this.summaryTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 201–202 & 207–209.
class BisectionOfAnglePreset {
  final String chipLabel;
  final int mode;
  // 0: Bisect Any Given Angle into Two Equal Parts (Pages 201–202 Figs. 17.6–17.8, Ex 17.1 #1, #2a–f, #5–7 & Quantitative #2)
  // 1: Divide an Angle into Four Equal Parts by Repeated Bisection (Ex 17.1 #3, #4 & Rev Ex 17 #5)
  // 2: Construct Triangle PQR & Bisect All Three Interior Angles to Meet at Incentre I (Rev Ex 17 #4, Page 208)

  final String input1;
  final String input2;
  final String input3;

  const BisectionOfAnglePreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class BisectionOfAngleResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<BisectionOfAngleStep> steps;
  final BisectionOfAngleCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BisectionOfAngleResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BisectionOfAngleResult.error({
    required int mode,
    required String message,
  }) {
    return BisectionOfAngleResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BisectionOfAngleCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}