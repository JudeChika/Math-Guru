/// Represents a single pedagogical step in the Real-Life Activities Involving Area (Pages 193–196) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class RealLifeAreaActivitiesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const RealLifeAreaActivitiesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Real-Life Area Activities Interactive Diagram + Math.tex Board.
/// Replicates Figs. 16.81–16.86 (Garden Paths, Roads, Arch Gates, Circular Pools in Gardens) AND Page 196 Quantitative Reasoning Loops!
class RealLifeAreaActivitiesCanvasData {
  final int diagramType;
  // 0: Large Farm / Road / Paddock Area & Hectare/km² Conversions (Example 11 & Ex 16.4 #1, #6, #9)
  // 1: Rectangular Garden Surrounded by a Path / Swimming Pool Pavement (Example 12 Fig. 16.81 & Ex 16.4 #2, #10 Fig. 16.86)
  // 2: Composite Courtyard Gate / Circular Pool in Garden / Two Circular Beds (Ex 16.4 #3–5, #7, #8 Fig. 16.85)
  // 3: Page 196 Quantitative Reasoning Area Unit Conversion Oval Loop

  final String subVariant; // 'farm', 'surrounding_path', 'gate_arch', 'pool_in_garden', 'two_beds', 'quant_loop'

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String outerLabel;
  final String innerLabel;
  final String extraLabel;

  // For Page 196 Quantitative Reasoning Oval Loop
  final String leftBoxLaTeX;
  final String rightBoxLaTeX;
  final String topArrowLaTeX;
  final String bottomArrowLaTeX;

  final String summaryTableLaTeX; // Step-by-Step Real-Life Area, Pavers & Cost Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const RealLifeAreaActivitiesCanvasData({
    this.diagramType = 0,
    this.subVariant = 'farm',
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.outerLabel = '',
    this.innerLabel = '',
    this.extraLabel = '',
    this.leftBoxLaTeX = '',
    this.rightBoxLaTeX = '',
    this.topArrowLaTeX = '',
    this.bottomArrowLaTeX = '',
    this.summaryTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 193–196 (Examples 11 & 12, Exercise 16.4 #1–10, and Page 196 Quantitative Reasoning #1–12).
class RealLifeAreaActivitiesPreset {
  final String chipLabel;
  final int mode;
  // 0: Large Land Areas & Conversions Between m², Hectares (ha), and km² (Example 11 & Exercise 16.4 #1, #6, #9)
  // 1: Surrounding Paths, Pavers, Patio Tiling & Naira (₦) Cost Calculations (Example 12 & Exercise 16.4 #2, #10)
  // 2: Real-Life Gates, Advertising Boards, Circular Ponds & Garden Beds (Exercise 16.4 #3, #4, #5, #7, #8)
  // 3: Quantitative Reasoning — Area Unit Conversion Loops (Page 196 Samples & Questions #1–12)

  final String subKey;
  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String input5;

  const RealLifeAreaActivitiesPreset({
    required this.chipLabel,
    required this.mode,
    required this.subKey,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.input5 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class RealLifeAreaActivitiesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<RealLifeAreaActivitiesStep> steps;
  final RealLifeAreaActivitiesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const RealLifeAreaActivitiesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory RealLifeAreaActivitiesResult.error({
    required int mode,
    required String message,
  }) {
    return RealLifeAreaActivitiesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const RealLifeAreaActivitiesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}