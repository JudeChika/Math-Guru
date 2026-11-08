/// Represents a single pedagogical step in the Volumes of Similar Objects (Pages 136–141) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class VolumesSimilarObjectsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const VolumesSimilarObjectsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Volumes of Similar Objects Interactive Diagram + Math.tex Board.
/// Supports both 3D Similar Solids (Figs. 13.14–13.24) AND the Page 140 Quantitative Reasoning Triangle-Circle-Square Diagram!
class VolumesSimilarObjectsCanvasData {
  final int diagramType;
  // 0: Two Similar 3D Solids (Cones, Cylinders, Spheres, Cuboids, Frustums — Examples 4–5, Ex 13.2 #1–10, Ex 13.3)
  // 1: Page 140 Quantitative Reasoning Triangle (n^3) – Circle (n) – Square (n^2) Diagram

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String solid1Title;
  final String solid1VolLabel;
  final String solid1DimLabel;

  final String solid2Title;
  final String solid2VolLabel;
  final String solid2DimLabel;

  // For Page 140 Quantitative Reasoning Diagram (Circle = n, Square = n^2, Triangle = n^3)
  final String circleScaleLaTeX;
  final String squareAreaLaTeX;
  final String triangleVolLaTeX;

  final String volumeTableLaTeX; // Scale Factor (n), Area Factor (n^2), and Volume Factor (n^3) Table in Math.tex!
  final String bottomSummaryLaTeX;

  const VolumesSimilarObjectsCanvasData({
    this.diagramType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.solid1Title = '',
    this.solid1VolLabel = '',
    this.solid1DimLabel = '',
    this.solid2Title = '',
    this.solid2VolLabel = '',
    this.solid2DimLabel = '',
    this.circleScaleLaTeX = '',
    this.squareAreaLaTeX = '',
    this.triangleVolLaTeX = '',
    this.volumeTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 136–141 (Examples 4 & 5, Exercise 13.2 #1–10, Exercise 13.3 #1–8, Revision Exercise 13 #2 & #5, and Page 140 Quantitative Reasoning #1–8).
class VolumesSimilarObjectsPreset {
  final String chipLabel;
  final int mode;
  // 0: Given Two Linear Dimensions & One Volume/Capacity -> Find Volume Factor (n³) & Unknown Volume (Example 4, Ex 13.2 #1–6, Ex 13.3 #1, #4, #7 & Rev Ex 13 #2, #5)
  // 1: Given Two Volumes/Masses & One Linear Dimension -> Find Cube-Root Scale Factor (n = ∛Volume Ratio) & Unknown Length (Example 5, Ex 13.2 #7–10 & Ex 13.3 #3)
  // 2: Connecting Surface Area Ratio (n²) & Volume Ratio (n³) Together (Exercise 13.3 #5, #6, #8)
  // 3: Quantitative Reasoning Triangle (n³) – Circle (n) – Square (n²) Solver (Page 140 Sample & #1–8)

  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String unit;

  const VolumesSimilarObjectsPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.unit = 'cm³',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class VolumesSimilarObjectsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<VolumesSimilarObjectsStep> steps;
  final VolumesSimilarObjectsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const VolumesSimilarObjectsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory VolumesSimilarObjectsResult.error({
    required int mode,
    required String message,
  }) {
    return VolumesSimilarObjectsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const VolumesSimilarObjectsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}