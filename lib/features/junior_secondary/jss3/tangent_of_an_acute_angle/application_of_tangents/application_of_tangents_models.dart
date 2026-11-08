/// Represents a single pedagogical step in the Application of Tangents in Practical Problems (Pages 154–158) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ApplicationOfTangentsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ApplicationOfTangentsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Application of Tangents Interactive Elevation/Depression Sight-Line + Math.tex Board.
/// Replicates Figs. 14.19 & 14.20 (Page 154) with Horizontal Sight Line, Angle of Depression, Alternate Angle of Elevation, and Math.tex Table!
class ApplicationOfTangentsCanvasData {
  final bool isAngleOfDepression;
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String angleLabel;
  final String heightLabel;
  final String distanceLabel;

  final String practicalTableLaTeX; // Step-by-Step Practical Trigonometric Solution Table in Math.tex!
  final String bottomSummaryLaTeX;

  const ApplicationOfTangentsCanvasData({
    this.isAngleOfDepression = true,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.angleLabel = '38°',
    this.heightLabel = 'h = 12.19 m',
    this.distanceLabel = '15.6 m',
    this.practicalTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 154–158 (Examples 11 & 12, Exercise 14.4 #1–12, and Revision Exercise 14 #7–14).
class ApplicationOfTangentsPreset {
  final String chipLabel;
  final int mode;
  // 0: Angle of Elevation & Depression — Find Height or Horizontal Distance (Example 11, Ex 14.4 #4a–b, #5, #11 & Rev Ex 14 #7, #9, #13)
  // 1: Find Angle of Elevation/Depression/Slope Given Two Lengths (Example 12, Ex 14.4 #1–3, #6, #8, #10 & Rev Ex 14 #14)
  // 2: Multi-Step Practical Problems (Moving Nearer a Tower, Tree Shadow at Two Sun Angles, Two Boats from Cliff, 3D Box Angles & Compass Bearings — Ex 14.4 #7, #12 & Rev Ex 14 #8, #10, #11, #12)

  final String verticalInput;
  final String horizontalInput;
  final String angleInput;
  final String extraOption;

  const ApplicationOfTangentsPreset({
    required this.chipLabel,
    required this.mode,
    this.verticalInput = '',
    this.horizontalInput = '',
    this.angleInput = '',
    this.extraOption = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ApplicationOfTangentsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ApplicationOfTangentsStep> steps;
  final ApplicationOfTangentsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ApplicationOfTangentsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ApplicationOfTangentsResult.error({
    required int mode,
    required String message,
  }) {
    return ApplicationOfTangentsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ApplicationOfTangentsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}