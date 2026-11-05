/// Represents a single pedagogical step in the Similar Figures (Pages 115–117 & 122) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SimilarFiguresStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SimilarFiguresStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Similar Figures Interactive Shape Diagram + Math.tex Diagnostic Board.
/// Every fraction (\frac{}{}), ratio, and area relation is rendered via flutter_math_fork (Math.tex)!
class SimilarFiguresCanvasData {
  final int shapeType; // 0: Rectangles/Frames, 1: Polygons/Hexagons, 2: Circles, 3: 3D Buckets/Solids
  final bool isSimilar;

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String shape1Title;
  final String shape1Dim1Label;
  final String shape1Dim2Label;
  final double shape1Aspect;

  final String shape2Title;
  final String shape2Dim1Label;
  final String shape2Dim2Label;
  final double shape2Aspect;

  final String diagnosticTableLaTeX; // Side-Ratio & Angle Comparison Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const SimilarFiguresCanvasData({
    this.shapeType = 0,
    this.isSimilar = true,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.shape1Title = '',
    this.shape1Dim1Label = '',
    this.shape1Dim2Label = '',
    this.shape1Aspect = 1.3,
    this.shape2Title = '',
    this.shape2Dim1Label = '',
    this.shape2Dim2Label = '',
    this.shape2Aspect = 1.3,
    this.diagnosticTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 115–117 (Examples 1 & 2, Exercise 12.1 #1–4) and Page 122 (Exercise 12.2 #2 & #3).
class SimilarFiguresPreset {
  final String chipLabel;
  final int mode;
  // 0: Compare Two Rectangles / Picture Frame Border for Similarity (Example 1, Fig 12.2, Ex 12.1 #1–2, Ex 12.2 #2 Fig 12.13)
  // 1: Test Polygons / Hexagons / Quadrilaterals by Sides AND Angles (Example 2 Fig 12.3 & Ex 12.1 #4 Fig 12.5)
  // 2: Similar Circles: Ratio of Radii (R : r) vs Ratio of Areas (A : a) (Exercise 12.1 #3 Fig 12.4)
  // 3: Find Missing Dimension in Similar 3D Objects / Buckets / Solids (Exercise 12.2 #3a Fig 12.14 & #3b Fig 12.15)

  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String input5; // Optional border width or angle list

  const SimilarFiguresPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.input5 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SimilarFiguresResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SimilarFiguresStep> steps;
  final SimilarFiguresCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SimilarFiguresResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SimilarFiguresResult.error({
    required int mode,
    required String message,
  }) {
    return SimilarFiguresResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SimilarFiguresCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}