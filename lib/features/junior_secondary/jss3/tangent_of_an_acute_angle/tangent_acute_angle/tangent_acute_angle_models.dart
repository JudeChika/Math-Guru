/// Represents a single pedagogical step in the Tangent of an Acute Angle (Pages 142–147 & 150–151) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class TangentAcuteAngleStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const TangentAcuteAngleStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Tangent of an Acute Angle Interactive Right-Angled Triangle + Math.tex Board.
/// Replicates Fig. 14.2 (Page 143) with Opposite, Adjacent, and Hypotenuse arrows and 100% Math.tex fraction rendering!
class TangentAcuteAngleCanvasData {
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
  final String baseVertex; // e.g. 'C' (contains acute angle θ)
  final String angleLabel; // e.g. 'θ' or 'x'

  final String oppSideLabel; // e.g. 'AB (opp)' or 'y cm'
  final String adjSideLabel; // e.g. 'BC (adj)' or 'x cm'
  final String hypSideLabel; // e.g. 'AC (hyp)'

  final String anatomyTableLaTeX; // Opposite, Adjacent, Hypotenuse & Tangent Ratio Table in Math.tex!
  final String bottomSummaryLaTeX;

  const TangentAcuteAngleCanvasData({
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
    this.angleLabel = 'θ',
    this.oppSideLabel = 'Opposite (opp)',
    this.adjSideLabel = 'Adjacent (adj)',
    this.hypSideLabel = 'Hypotenuse (hyp)',
    this.anatomyTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 142–147 (Fig. 14.2, Exercise 14.1 #1, #2, #3, #5) and Pages 150–151 (Exercise 14.2 #11a–d).
class TangentAcuteAnglePreset {
  final String chipLabel;
  final int mode;
  // 0: Express tan θ from Right-Angled Triangle Vertex Labels (Fig 14.2 & Exercise 14.1 #1a–f in Fig 14.7)
  // 1: Identify Opp, Adj, Hyp from Single-Letter Side Labels & Write tan θ (Exercise 14.1 #2a–h in Fig 14.8 & #3a–b in Fig 14.9)
  // 2: Express Both Complementary Tangent Ratios (tan A & tan C) or Simplify Numerical Ratios (Ex 14.1 #5 Fig 14.10 & Ex 14.2 #11a–d Fig 14.17)

  final String input1;
  final String input2;
  final String input3;
  final String input4;

  const TangentAcuteAnglePreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class TangentAcuteAngleResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<TangentAcuteAngleStep> steps;
  final TangentAcuteAngleCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const TangentAcuteAngleResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory TangentAcuteAngleResult.error({
    required int mode,
    required String message,
  }) {
    return TangentAcuteAngleResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const TangentAcuteAngleCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}