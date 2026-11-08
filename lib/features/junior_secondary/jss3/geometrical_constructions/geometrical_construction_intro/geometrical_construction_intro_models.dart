/// Represents a single pedagogical step in the Construction (Perpendicular Bisectors & Perpendiculars, Pages 200–201 & 207–209) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class GeometricalConstructionIntroStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const GeometricalConstructionIntroStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Construction Interactive Compass-and-Ruler Diagram + Math.tex Board.
/// Replicates Figs. 17.1–17.5, 17.33 & 17.40 with visible compass arcs and 100% Math.tex fraction rendering!
class GeometricalConstructionIntroCanvasData {
  final int diagramType;
  // 0: Perpendicular Bisector PQ of Line Segment AB Meeting at Midpoint M (Figs. 17.1 & 17.2, Page 200–201)
  // 1: Double Perpendicular Bisector (Quartering AB at D and E + Circle of Centre E & Radius AE — Rev Ex 17 #6, Page 209)
  // 2: Perpendicular Line MY from an External Point M to a Line AB (Figs. 17.3–17.5, Page 201 & Rev Ex 17 #7 Fig. 17.40)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final double lineLength;
  final double compassRadius;

  final String segLabel; // e.g. 'AB = 8 cm'
  final String halfLabel; // e.g. 'AM = MB = 4 cm'
  final String extraLabel; // e.g. 'AE = 2 cm' or '∠ = 90°'

  final String constructionTableLaTeX; // Step-by-Step Compass & Ruler Construction Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const GeometricalConstructionIntroCanvasData({
    this.diagramType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.lineLength = 8.0,
    this.compassRadius = 6.0,
    this.segLabel = 'AB = 8 cm',
    this.halfLabel = 'AM = MB = 4 cm',
    this.extraLabel = '∠PMA = 90°',
    this.constructionTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 200–201 & 207–209.
class GeometricalConstructionIntroPreset {
  final String chipLabel;
  final int mode;
  // 0: Perpendicular Bisector of a Line Segment AB (Pages 200–201, Figs. 17.1–17.2 & Quantitative #1 Fig. 17.33)
  // 1: Quartering a Line Segment & Drawing Circle of Centre E, Radius AE (Revision Exercise 17 #6i–iv, Page 209)
  // 2: Perpendicular Line from a Given External Point M (or Point P on Line) to AB (Page 201, Figs. 17.3–17.5 & Rev Ex 17 #1, #7)

  final String input1;
  final String input2;
  final String input3;

  const GeometricalConstructionIntroPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class GeometricalConstructionIntroResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<GeometricalConstructionIntroStep> steps;
  final GeometricalConstructionIntroCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const GeometricalConstructionIntroResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory GeometricalConstructionIntroResult.error({
    required int mode,
    required String message,
  }) {
    return GeometricalConstructionIntroResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const GeometricalConstructionIntroCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}