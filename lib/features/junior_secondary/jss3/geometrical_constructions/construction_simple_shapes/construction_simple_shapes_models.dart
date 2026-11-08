/// Represents a single pedagogical step in the Construction of Simple Shapes (Pages 206–209) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ConstructionSimpleShapesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ConstructionSimpleShapesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Construction of Simple Shapes Interactive Compass-and-Ruler Diagram + Math.tex Board.
/// Replicates Figs. 17.28–17.32, 17.38–17.39 & 17.41–17.43 (SSS/SAS/ASA Triangles, Altitude & Perpendicular Bisector, Inscribed/Circumscribed Circles, Parallelograms & Trapeziums)!
class ConstructionSimpleShapesCanvasData {
  final int diagramType;
  // 0: SSS Triangle Construction with Compass Arcs at Top Vertex (Example 1 Figs. 17.28–17.32 & Ex 17.3 #1–2)
  // 1: SAS / ASA Triangle with Altitude or Perpendicular Bisector (Ex 17.3 #3–6 & Rev Ex 17 #8–10, #12–13)
  // 2: Parallelogram / Trapezium / Quadrilateral Construction & Diagonal Measurement (Quantitative #8 Fig. 17.39 & Rev Ex 17 #11, #15)
  // 3: Triangle with Circumscribed Circle (Fig. 17.38) OR Inscribed Circle (Rev Ex 17 #14)

  final String subVariant; // 'sss', 'sas_altitude', 'asa', 'parallelogram', 'trapezium', 'circumcircle', 'incircle'

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final List<String> vertexLabels; // e.g. ['A', 'B', 'C', 'D']
  final String baseSideLabel; // e.g. 'BC = 4.6 cm'
  final String leftSideLabel; // e.g. 'AB = 3.2 cm'
  final String rightSideLabel; // e.g. 'AC = 6.2 cm'
  final String measuredFeatureLabel; // e.g. '∠A = 109°' or 'h = 3.56 cm' or 'BD = 10.4 cm'

  final String constructionTableLaTeX; // Step-by-Step Construction & Protractor/Ruler Measurement Table in Math.tex!
  final String bottomSummaryLaTeX;

  const ConstructionSimpleShapesCanvasData({
    this.diagramType = 0,
    this.subVariant = 'sss',
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.vertexLabels = const ['A', 'B', 'C'],
    this.baseSideLabel = 'BC = 4.6 cm',
    this.leftSideLabel = 'AB = 3.2 cm',
    this.rightSideLabel = 'AC = 6.2 cm',
    this.measuredFeatureLabel = '∠A = 46°, ∠B = 104°, ∠C = 30°',
    this.constructionTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 206–209 (Example 1, Exercise 17.3 #1–6, Quantitative Reasoning #6–8 Figs. 17.38–17.39, and Revision Exercise 17 #8–15).
class ConstructionSimpleShapesPreset {
  final String chipLabel;
  final int mode;
  // 0: SSS Triangle Construction (Given 3 Sides -> Construct & Measure Angles — Example 1 & Ex 17.3 #1, #2)
  // 1: SAS Triangle Construction (Given 2 Sides & Included Angle -> Construct, Measure 3rd Side, Altitude & Bisectors — Ex 17.3 #3, #4, #6 & Rev Ex 17 #8, #9, #13)
  // 2: ASA Triangle Construction (Given 1 Base & 2 Base Angles -> Construct & Measure Sides — Ex 17.3 #5 & Rev Ex 17 #10, #12)
  // 3: Parallelograms, Trapeziums & Inscribed/Circumscribed Circles (Quantitative #6–8 Figs. 17.38–17.39 & Rev Ex 17 #11, #14, #15)

  final String shapeSubKey;
  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String verticesName;

  const ConstructionSimpleShapesPreset({
    required this.chipLabel,
    required this.mode,
    this.shapeSubKey = '',
    required this.input1,
    required this.input2,
    required this.input3,
    this.input4 = '',
    this.verticesName = 'ABC',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ConstructionSimpleShapesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ConstructionSimpleShapesStep> steps;
  final ConstructionSimpleShapesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ConstructionSimpleShapesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ConstructionSimpleShapesResult.error({
    required int mode,
    required String message,
  }) {
    return ConstructionSimpleShapesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ConstructionSimpleShapesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}