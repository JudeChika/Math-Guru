/// Represents a single pedagogical step in the Areas of Plane Shapes, Using Trigonometry (Pages 184–187) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class AreasUsingTrigonometryStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const AreasUsingTrigonometryStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Areas Using Trigonometry Interactive Diagram + Math.tex Board.
/// Replicates Figs. 16.32–16.51 (Triangles, Parallelograms & Trapeziums with Perpendicular Altitude h and Method I & II Table)!
class AreasUsingTrigonometryCanvasData {
  final int shapeType;
  // 0: Triangle (Figs. 16.32, 16.34, 16.37–16.41, Example 4 & Exercise 16.2 #1–5)
  // 1: Parallelogram (Figs. 16.33, 16.35, 16.42–16.46, Example 5 & Exercise 16.2 #6–10)
  // 2: Trapezium (Figs. 16.36, 16.47–16.51, Example 6 & Exercise 16.2 #11–15)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String baseLabel;
  final String slantLabel;
  final String topParallelLabel;
  final String angleLabel;
  final String heightLabel;

  final String comparisonTableLaTeX; // Method I (Find Height h First) vs Method II (Direct Trig Formula) Table in Math.tex!
  final String bottomSummaryLaTeX;

  const AreasUsingTrigonometryCanvasData({
    this.shapeType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.baseLabel = '',
    this.slantLabel = '',
    this.topParallelLabel = '',
    this.angleLabel = '',
    this.heightLabel = '',
    this.comparisonTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 184–187 (Examples 4–6 & Exercise 16.2 #1–15).
class AreasUsingTrigonometryPreset {
  final String chipLabel;
  final int mode;
  // 0: Area of a Triangle Using Trigonometry — Method I (h = c sin B, A = ½ah) & Method II (A = ½ac sin B) (Example 4 & Ex 16.2 #1–5)
  // 1: Area of a Parallelogram Using Trigonometry — Method I (h = a sin θ, A = bh) & Method II (A = ab sin θ) (Example 5 & Ex 16.2 #6–10)
  // 2: Area of a Trapezium Using Trigonometry — Find Perpendicular Height h First, Then A = ½(a + b)h (Example 6 & Ex 16.2 #11–15)

  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String unit;
  final String specialVariant; // e.g., 'isosceles_base_angles_2', 'two_angles_3', 'obtuse_4', 'right_hyp_5'

  const AreasUsingTrigonometryPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.unit = 'cm',
    this.specialVariant = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class AreasUsingTrigonometryResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<AreasUsingTrigonometryStep> steps;
  final AreasUsingTrigonometryCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const AreasUsingTrigonometryResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory AreasUsingTrigonometryResult.error({
    required int mode,
    required String message,
  }) {
    return AreasUsingTrigonometryResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const AreasUsingTrigonometryCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}