/// Represents a single pedagogical step in the Concentric Circles and Sectors of a Circle (Pages 187–192 & 196–197) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ConcentricCirclesSectorsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ConcentricCirclesSectorsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Concentric Circles & Sectors Interactive Diagram + Math.tex Board.
/// Replicates Figs. 16.52–16.80 & 16.95 (Annulus/Ring, Sector OAB, Square-Minus-Quadrant, Segment & Arbelos Semicircles)!
class ConcentricCirclesSectorsCanvasData {
  final int diagramType;
  // 0: Concentric Circles / Flat Ring / Circular Path (Figs. 16.52, 16.54, 16.56, 16.60–16.64, Example 7 & Ex 16.3 #1–5)
  // 1: Sector of a Circle OAB (Figs. 16.53, 16.55, 16.57–16.59, 16.65–16.78, 16.95, Examples 8–10, Ex 16.3 #6–14 & Rev Ex 16 #8)
  // 2: Composite Sector / Segment Shaded Portions (Figs. 16.79a–c & 16.80, Ex 16.3 #15a–c & #16)

  final String subVariant; // 'ring', 'sector', 'sq_minus_quad', 'segment', 'arbelos', 'two_circles_ratio'
  final double sectorAngleDeg;

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String label1; // e.g. 'R = 14 m' or 'r = 4.2 m'
  final String label2; // e.g. 'r = 12 m' or 'θ = 125°'
  final String label3; // e.g. 'Area = 163.4 m²'

  final String breakdownTableLaTeX; // Step-by-Step Annulus or Sector Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const ConcentricCirclesSectorsCanvasData({
    this.diagramType = 0,
    this.subVariant = 'ring',
    this.sectorAngleDeg = 125.0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.label1 = '',
    this.label2 = '',
    this.label3 = '',
    this.breakdownTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 187–192 & 196–197 (Examples 7–10, Exercise 16.3 #1–16, Puzzle Fig. 16.87, and Revision Exercise 16 #8).
class ConcentricCirclesSectorsPreset {
  final String chipLabel;
  final int mode;
  // 0: Area of a Flat Ring, Washer, or Circular Path: A = π(R² - r²) = π(R + r)(R - r) (Example 7 & Exercise 16.3 #1–5)
  // 1: Area of a Sector of a Circle: A = (θ / 360) × πr² (Example 8, Exercise 16.3 #6–13 & Rev Ex 16 #8)
  // 2: Reverse Sector Problems: Find Angle θ OR Find Radius r Given Sector Area (Examples 9 & 10, Exercise 16.3 #14a–d)
  // 3: Composite Sector Shaded Portions & Circle Ratio Problems (Exercise 16.3 #15a–c, #16 & Page 196 Puzzle)

  final String input1;
  final String input2;
  final String input3;
  final String piMode; // '22/7' or '3.14'
  final String unit;
  final String subKey;

  const ConcentricCirclesSectorsPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.piMode = '22/7',
    this.unit = 'cm',
    this.subKey = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ConcentricCirclesSectorsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ConcentricCirclesSectorsStep> steps;
  final ConcentricCirclesSectorsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ConcentricCirclesSectorsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ConcentricCirclesSectorsResult.error({
    required int mode,
    required String message,
  }) {
    return ConcentricCirclesSectorsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ConcentricCirclesSectorsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}