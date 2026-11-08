/// Represents a single pedagogical step in the Tangent of Acute Angles by Measurement (Pages 143–148 & 156) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class TangentByMeasurementStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const TangentByMeasurementStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Tangent by Measurement Squared-Paper Scale Drawing + Math.tex Board.
/// Replicates Figs. 14.3, 14.4, 14.5 & 14.6 (Pages 143–145) with squared grid, axes, scale conversion, and Math.tex fraction rendering!
class TangentByMeasurementCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final double oppLength; // Real vertical opposite side length (AB or XY)
  final double adjLength; // Real horizontal adjacent side length (BC or YZ)
  final double angleDeg; // Acute angle in degrees

  final String oppLabel; // e.g. '7 cm' or '5 cm' or '8.2 cm'
  final String adjLabel; // e.g. '10 cm' or '9 cm'
  final String angleLabel; // e.g. '35°' or '29°' or '39°'

  final String measurementTableLaTeX; // Scale Drawing & Protractor Measurement Table in Math.tex!
  final String bottomSummaryLaTeX;

  const TangentByMeasurementCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.oppLength = 7.0,
    this.adjLength = 10.0,
    this.angleDeg = 35.0,
    this.oppLabel = '7 cm',
    this.adjLabel = '10 cm',
    this.angleLabel = '35°',
    this.measurementTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 143–148 (Examples 1a–b, 2, 3, Exercise 14.1 #4a–k, #6–10) and Page 156 (Revision Exercise 14 #1).
class TangentByMeasurementPreset {
  final String chipLabel;
  final int mode;
  // 0: Given Acute Angle θ & Scale/Baseline -> Draw, Measure Opposite Side & Find tan θ (Example 1a 35°, Example 1b 60° & Exercise 14.1 #4a–k)
  // 1: Given Tangent as a Fraction p/q -> Construct Right-Angled Triangle & Measure Angle θ (Example 2 5/9, Ex 14.1 #6, #7, #8, #9a–c, #10a,b,e–h & Rev Ex 14 #1 17/6)
  // 2: Given Tangent as a Decimal -> Convert to Fraction Over 10, Construct & Measure Angle α (Example 3 0.82 & Ex 14.1 #10c 0.7, #10d 0.36)

  final String input1;
  final String input2;
  final String input3;

  const TangentByMeasurementPreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class TangentByMeasurementResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<TangentByMeasurementStep> steps;
  final TangentByMeasurementCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const TangentByMeasurementResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory TangentByMeasurementResult.error({
    required int mode,
    required String message,
  }) {
    return TangentByMeasurementResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const TangentByMeasurementCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}