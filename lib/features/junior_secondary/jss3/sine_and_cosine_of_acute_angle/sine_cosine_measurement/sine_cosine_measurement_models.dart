/// Represents a single pedagogical step in the Sines and Cosines of Acute Angles by Drawing and Measurement (Pages 162–165) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SineCosineMeasurementStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SineCosineMeasurementStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Sine & Cosine by Measurement Interactive Squared-Paper & Circle-Quadrant Visualizer.
/// Replicates Figs. 15.10, 15.11, 15.12 & 15.13 (Pages 163–165) with 100% Math.tex fraction rendering!
class SineCosineMeasurementCanvasData {
  final int diagramType;
  // 0: Right-Angled Triangle on Squared Paper (Example 4a 40° Fig. 15.10 & Example 4b 55° Fig. 15.11)
  // 1: Circle Quadrant of Radius 10 cm for Sine (Example 5a sin θ = 0.37 Fig. 15.12)
  // 2: Circle Quadrant of Radius 10 cm for Cosine (Example 5b cos θ = 0.42 Fig. 15.13)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final double oppLength;
  final double adjLength;
  final double hypLength;
  final double angleDeg;

  final String oppLabel;
  final String adjLabel;
  final String hypLabel;
  final String angleLabel;

  final String measurementTableLaTeX; // Scale Drawing & Quadrant Measurement Table in Math.tex!
  final String bottomSummaryLaTeX;

  const SineCosineMeasurementCanvasData({
    this.diagramType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.oppLength = 8.375,
    this.adjLength = 10.0,
    this.hypLength = 13.0,
    this.angleDeg = 40.0,
    this.oppLabel = '8.375 cm',
    this.adjLabel = '10 cm',
    this.hypLabel = '13 cm',
    this.angleLabel = '40°',
    this.measurementTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 162–165 (Examples 4a–b, 5a–b & Exercise 15.2 #1–16).
class SineCosineMeasurementPreset {
  final String chipLabel;
  final int mode;
  // 0: Given Acute Angle θ -> Draw on Squared Paper, Measure Opp & Hyp, and Calculate sin θ & cos θ (Example 4a 40°, Example 4b 55° & Ex 15.2 #1–10)
  // 1: Given sin θ as Decimal or Fraction -> Construct Quadrant of Circle (Radius 10 cm) & Measure Angle θ (Example 5a 0.37 Fig 15.12 & Ex 15.2 #11, #12, #14)
  // 2: Given cos θ as Decimal or Fraction -> Construct Quadrant of Circle (Radius 10 cm) & Measure Angle θ (Example 5b 0.42 Fig 15.13 & Ex 15.2 #13, #15, #16)

  final String input1;
  final String input2;
  final String input3;

  const SineCosineMeasurementPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SineCosineMeasurementResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SineCosineMeasurementStep> steps;
  final SineCosineMeasurementCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SineCosineMeasurementResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SineCosineMeasurementResult.error({
    required int mode,
    required String message,
  }) {
    return SineCosineMeasurementResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SineCosineMeasurementCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}