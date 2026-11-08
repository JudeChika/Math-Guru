/// Represents a single pedagogical step in the Areas of Similar Plane Shapes (Pages 132–136 & 139) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class AreasSimilarShapesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const AreasSimilarShapesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Areas of Similar Shapes Interactive Diagram + Math.tex Board.
/// Every fraction (\frac{}{}), square root (\sqrt{}), and \pi surface area is rendered via flutter_math_fork (Math.tex)!
class AreasSimilarShapesCanvasData {
  final int diagramType;
  // 0: Two Separate Similar Shapes (Triangles, Rectangles, Trapeziums, Cylinders/Cones/Spheres — Examples 1–2, Ex 13.1 #1–5, #8)
  // 1: Nested Similar Triangles with Parallel Line (Example 3 Fig 13.3 & Ex 13.1 #6 Fig 13.9)
  // 2: Non-Parallel Nested Similar Triangles (Ex 13.1 #7 Fig 13.10)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String shape1Title;
  final String shape1AreaLabel;
  final String shape1SideLabel;

  final String shape2Title;
  final String shape2AreaLabel;
  final String shape2SideLabel;

  final String areaTableLaTeX; // Scale Factor (n) vs Area Factor (n^2) Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const AreasSimilarShapesCanvasData({
    this.diagramType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.shape1Title = '',
    this.shape1AreaLabel = '',
    this.shape1SideLabel = '',
    this.shape2Title = '',
    this.shape2AreaLabel = '',
    this.shape2SideLabel = '',
    this.areaTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 132–136 & 139 (Examples 1–3, Exercise 13.1 #1–8, Exercise 13.3 #2, and Revision Exercise 13 #1).
class AreasSimilarShapesPreset {
  final String chipLabel;
  final int mode;
  // 0: Given Two Corresponding Sides & One Area -> Find Area Factor (n²) & Unknown Area (Example 2, Ex 13.1 #1–4 & Ex 13.3 #2)
  // 1: Given Two Areas (Including π Surface Areas) & One Side -> Find Scale Factor (n = √Area Ratio) & Unknown Side (Example 1, Ex 13.1 #5, #8a–c & Rev Ex 13 #1)
  // 2: Nested Similar Triangles -> Find Area of Whole Triangle AND Area of Remaining Trapezium/Quadrilateral (Example 3, Ex 13.1 #6 & #7)
  // 3: Deductive Proof from Right-Angled Triangle Base & Height (Page 132 Fig 13.1a & b Intro)

  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String extraOption; // e.g., 'tiles', 'nested_parallel', 'nested_quad_given'

  const AreasSimilarShapesPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.extraOption = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class AreasSimilarShapesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<AreasSimilarShapesStep> steps;
  final AreasSimilarShapesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const AreasSimilarShapesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory AreasSimilarShapesResult.error({
    required int mode,
    required String message,
  }) {
    return AreasSimilarShapesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const AreasSimilarShapesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}