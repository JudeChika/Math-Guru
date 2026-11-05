/// Represents a single pedagogical step in the Enlargement and Scale Factor (Pages 123–130) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class EnlargementStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const EnlargementStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// 2D Coordinate Point for plotting Object vertices, Image vertices, and Centre of Enlargement O on squared paper.
class EnlargementPoint {
  final String label;
  final double x;
  final double y;

  const EnlargementPoint(this.label, this.x, this.y);
}

/// Encapsulates all visual elements for the Enlargement & Scale Factor Interactive Squared-Paper + Math.tex Board.
/// Replicates Figs. 12.16–12.23 & 12.30 (Projection Rays from O, Object & Enlarged Image, and Math.tex Transformation Table)!
class EnlargementCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final EnlargementPoint centreO;
  final List<EnlargementPoint> objectPoints;
  final List<EnlargementPoint> imagePoints;

  final String transformationTableLaTeX; // Ray, Side-Ratio, or Coordinate Enlargement Table in Math.tex!
  final String bottomSummaryLaTeX;

  const EnlargementCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.centreO = const EnlargementPoint('O', 0, 0),
    this.objectPoints = const [],
    this.imagePoints = const [],
    this.transformationTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 123–130 (Activity 12.1, Examples 6 & 7, Exercise 12.3 #1–10, Quantitative Reasoning Page 128, and Revision Exercise 12 #1–6).
class EnlargementPreset {
  final String chipLabel;
  final int mode;
  // 0: Find Scale Factor & Ray Ratios from Object & Image Lengths (Activity 12.1, Examples 6 & 7, Ex 12.3 #1, #7, #8, Quantitative Page 128 & Rev Ex 12 #4)
  // 1: Find Missing Image or Object Length & Angle Given Scale Factor (Ex 12.3 #9, #10 & Rev Ex 12 #1, #2, #3, #5)
  // 2: Coordinate Grid Enlargement from Centre O(x₀, y₀) (Ex 12.3 #3, #4, #5, #6, #7, #8 & Rev Ex 12 #6)

  final String input1;
  final String input2;
  final String input3;
  final String input4;

  const EnlargementPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class EnlargementResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<EnlargementStep> steps;
  final EnlargementCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const EnlargementResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory EnlargementResult.error({
    required int mode,
    required String message,
  }) {
    return EnlargementResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const EnlargementCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}