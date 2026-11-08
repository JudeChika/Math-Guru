/// Represents a single pedagogical step in the Area of Plane Shapes (Pages 178–183 & 197) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class AreaOfPlaneShapesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const AreaOfPlaneShapesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Area of Plane Shapes Interactive Diagram + Math.tex Board.
/// Replicates Figs. 16.1–16.31 & 16.88–16.94 (Basic Shapes, Semicircle+Rectangle, Shaded Regions, Kites & Regular Hexagon)!
class AreaOfPlaneShapesCanvasData {
  final int diagramType;
  // 0: Basic Plane Shape (Rectangle, Square, Triangle, Circle, Trapezium, Parallelogram, Kite — Example 1a–f & Ex 16.1 #1–18)
  // 1: Composite Shape by Addition (Semicircle on Rectangle, L-Shape, T-Shape, Regular Hexagon — Example 2, Ex 16.1 #10, #15, #16, #19 & Rev Ex 16 #1, #4–7)
  // 2: Shaded Region by Subtraction (Circle in Square, Parallelogram in Rectangle, Triangle in Rectangle — Example 3 & Ex 16.1 #25–28)

  final String shapeSubType; // 'rectangle', 'square', 'triangle', 'circle', 'trapezium', 'parallelogram', 'kite', 'hexagon', 'semicircle_rect', 'shaded_circle_square', 'shaded_poly'

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String dim1Label;
  final String dim2Label;
  final String dim3Label;
  final String areaInsideLabel;

  final String summaryTableLaTeX; // Step-by-Step Area Decomposition & Formula Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const AreaOfPlaneShapesCanvasData({
    this.diagramType = 0,
    this.shapeSubType = 'rectangle',
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.dim1Label = '',
    this.dim2Label = '',
    this.dim3Label = '',
    this.areaInsideLabel = '',
    this.summaryTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 178–183 (Examples 1–3 & Exercise 16.1 #1–28) and Page 197 (Revision Exercise 16 #1–7).
class AreaOfPlaneShapesPreset {
  final String chipLabel;
  final int mode;
  // 0: Basic Plane Shapes (Rectangle, Square, Triangle, Circle, Trapezium, Parallelogram, Kite — Example 1a–f & Ex 16.1 #1–18)
  // 1: Composite Shapes by Addition & Regular Hexagon (Example 2, Ex 16.1 #10, #15, #16, #19 & Rev Ex 16 #1, #4–7)
  // 2: Shaded Regions by Subtraction (Example 3 & Ex 16.1 #25–28)
  // 3: Reverse Area & Word Problems (Find Missing Side/Radius/Tiles from Area — Ex 16.1 #20–24)

  final String shapeKey;
  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String unit;

  const AreaOfPlaneShapesPreset({
    required this.chipLabel,
    required this.mode,
    required this.shapeKey,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.unit = 'cm',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class AreaOfPlaneShapesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<AreaOfPlaneShapesStep> steps;
  final AreaOfPlaneShapesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const AreaOfPlaneShapesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory AreaOfPlaneShapesResult.error({
    required int mode,
    required String message,
  }) {
    return AreaOfPlaneShapesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const AreaOfPlaneShapesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}