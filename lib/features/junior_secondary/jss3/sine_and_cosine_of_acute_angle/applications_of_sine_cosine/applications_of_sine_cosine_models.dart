/// Represents a single pedagogical step in the Applications of Sines and Cosines of Acute Angles (Pages 172–176) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ApplicationsOfSineCosineStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ApplicationsOfSineCosineStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Applications of Sines & Cosines Interactive Diagram + Math.tex Board.
/// Replicates Figs. 15.25–15.27, 15.31 & 15.32 (Leaning Ladders, Tree Shadows, See-Saws, Circle Chords, and Conical Funnels)!
class ApplicationsOfSineCosineCanvasData {
  final int diagramType;
  // 0: Leaning Ladder / Pole / Sight-Line Right-Angled Triangle (Figs. 15.25, 15.26, 15.27)
  // 1: Symmetrical Isosceles / Circle Chord / Conical Funnel (Ex 15.7 #12, #16 & Rev Ex 15 #17, #19 Fig. 15.32)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String oppLabel;
  final String adjLabel;
  final String hypLabel;
  final String angleLabel;

  final String practicalTableLaTeX; // Step-by-Step Practical Sine/Cosine Solution Table in Math.tex!
  final String bottomSummaryLaTeX;

  const ApplicationsOfSineCosineCanvasData({
    this.diagramType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.oppLabel = 'Pole',
    this.adjLabel = '7 m',
    this.hypLabel = 'x = 8.65 m',
    this.angleLabel = '36°',
    this.practicalTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 172–176 (Examples 12 & 13, Exercise 15.7 #1–18, and Revision Exercise 15 #11–20).
class ApplicationsOfSineCosinePreset {
  final String chipLabel;
  final int mode;
  // 0: Find Hypotenuse or Leg Given Angle & One Side (Ladders, Scaffolds, See-Saws, Roofs & Bearings — Example 12, Ex 15.7 #1–4, #6–10, #13–15, #18 & Rev Ex 15 #11, #12, #20)
  // 1: Find Angle of Inclination/Elevation/Depression Given One Leg & Hypotenuse (Example 13, Ex 15.7 #5, #11 & Rev Ex 15 #14, #16)
  // 2: Isosceles Triangles, Chords of Circles & Conical Funnels (Ex 15.7 #12, #16 & Rev Ex 15 #17, #19 Fig. 15.32)
  // 3: Multi-Step Ladder Push & Composite Farmland Problems (Ex 15.7 #17 & Rev Ex 15 #13, #15 Fig. 15.31, #18)

  final bool useCosine;
  final String input1;
  final String input2;
  final String input3;
  final String extraOption;

  const ApplicationsOfSineCosinePreset({
    required this.chipLabel,
    required this.mode,
    this.useCosine = false,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.extraOption = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ApplicationsOfSineCosineResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ApplicationsOfSineCosineStep> steps;
  final ApplicationsOfSineCosineCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ApplicationsOfSineCosineResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ApplicationsOfSineCosineResult.error({
    required int mode,
    required String message,
  }) {
    return ApplicationsOfSineCosineResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ApplicationsOfSineCosineCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}