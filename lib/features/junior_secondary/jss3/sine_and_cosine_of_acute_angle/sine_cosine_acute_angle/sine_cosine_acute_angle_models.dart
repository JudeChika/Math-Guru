/// Represents a single pedagogical step in the Sine and Cosine of an Acute Angle (Pages 159–162) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SineCosineAcuteAngleStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SineCosineAcuteAngleStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Sine & Cosine of an Acute Angle Interactive Right-Angled Triangle + Math.tex Board.
/// Replicates Figs. 15.1–15.9 (Pages 159–162) with Opposite, Adjacent, and Hypotenuse arrows and 100% Math.tex fraction rendering!
class SineCosineAcuteAngleCanvasData {
  final int diagramType;
  // 0: Single Right-Angled Triangle (Figs. 15.1–15.6, Examples 1–3 & Ex 15.1 #1–16, #19–21)
  // 1: Split / Composite Right-Angled Triangles (Figs. 15.7 & 15.8, Ex 15.1 #17 & #18)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String topVertex; // e.g. 'A'
  final String rightAngleVertex; // e.g. 'B' (90°)
  final String baseVertex; // e.g. 'C'
  final String topAngleLabel; // e.g. 'β' or 'φ'
  final String baseAngleLabel; // e.g. 'θ' or 'α'

  final String oppSideLabel; // e.g. 'AB (Opp)' or '5'
  final String adjSideLabel; // e.g. 'BC (Adj)' or '12'
  final String hypSideLabel; // e.g. 'AC (Hyp)' or '13'

  final String ratioTableLaTeX; // Sine & Cosine Ratios Evaluation Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const SineCosineAcuteAngleCanvasData({
    this.diagramType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.topVertex = 'A',
    this.rightAngleVertex = 'B',
    this.baseVertex = 'C',
    this.topAngleLabel = 'β',
    this.baseAngleLabel = 'θ',
    this.oppSideLabel = 'AB (Opp)',
    this.adjSideLabel = 'BC (Adj)',
    this.hypSideLabel = 'AC (Hyp)',
    this.ratioTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 159–162 (Examples 1–3 & Exercise 15.1 #1–21).
class SineCosineAcuteAnglePreset {
  final String chipLabel;
  final int mode;
  // 0: Express sin & cos from Triangle Vertex Labels (Fig 15.1, Example 1 Fig 15.2 & Ex 15.1 #1, #2, #9, #10)
  // 1: Express sin & cos in Terms of Single-Letter Sides a, b, c (Example 2 Fig 15.3 & Ex 15.1 #3, #4, #11, #15)
  // 2: Evaluate Numerical sin, cos, Sums (sin α + sin β) & Squares (cos²β, sin²α) (Example 3a–e Fig 15.4 & Ex 15.1 #5–8, #12–14, #16, #19–21)
  // 3: Composite / Split Right-Angled Triangles (Exercise 15.1 #17 Fig 15.7 & #18 Fig 15.8)

  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String input5;

  const SineCosineAcuteAnglePreset({
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
class SineCosineAcuteAngleResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SineCosineAcuteAngleStep> steps;
  final SineCosineAcuteAngleCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SineCosineAcuteAngleResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SineCosineAcuteAngleResult.error({
    required int mode,
    required String message,
  }) {
    return SineCosineAcuteAngleResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SineCosineAcuteAngleCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}