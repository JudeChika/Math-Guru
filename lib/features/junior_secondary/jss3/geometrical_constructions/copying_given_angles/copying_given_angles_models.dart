/// Represents a single pedagogical step in the Copying Given Angles (Pages 205–208) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class CopyingGivenAnglesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const CopyingGivenAnglesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Copying Given Angles Interactive Side-by-Side Compass Diagram + Math.tex Board.
/// Replicates Figs. 17.23–17.27 (Pages 205–206) & Fig. 17.37 (Page 207) showing Given Angle BAC on the Left and Copied Angle QPR on the Right!
class CopyingGivenAnglesCanvasData {
  final int diagramType;
  // 0: Standard Side-by-Side Angle Copy (Given ∠BAC with Arc XY on Left, Copied ∠QPR with Arc RS & Chord Cut at T on Right — Figs. 17.23–17.27 & Fig. 17.37)
  // 1: Construct a Parallel Line Through an External Point by Copying a Corresponding Angle (Application of Copying Angles)

  final double angleDeg;

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String givenAngleName; // e.g. 'BAC'
  final String copiedAngleName; // e.g. 'QPR'
  final String arcRadiusLabel; // e.g. 'r = 4 cm'
  final String chordLengthLabel; // e.g. 'XY = ST = 3.29 cm'

  final String comparisonTableLaTeX; // Step-by-Step SSS Congruence & Chord Transfer Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const CopyingGivenAnglesCanvasData({
    this.diagramType = 0,
    this.angleDeg = 48.0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.givenAngleName = 'BAC',
    this.copiedAngleName = 'QPR',
    this.arcRadiusLabel = 'r = 4 cm',
    this.chordLengthLabel = 'XY = ST = 3.29 cm',
    this.comparisonTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 205–208 (Figs. 17.23–17.27, Exercise 17.2 #9a–d, and Quantitative Reasoning #5 Fig. 17.37).
class CopyingGivenAnglesPreset {
  final String chipLabel;
  final int mode;
  // 0: Copy Any Given Angle ∠BAC to Form an Identical Angle ∠QPR Using Compasses & Ruler (Pages 205–206 Figs. 17.23–17.27 & Ex 17.2 #9a–d)
  // 1: Construct a Line Parallel to a Given Line Through an External Point by Copying a Corresponding Angle

  final String angleInput;
  final String radiusInput;
  final String givenVerticesInput;
  final String copiedVerticesInput;

  const CopyingGivenAnglesPreset({
    required this.chipLabel,
    required this.mode,
    required this.angleInput,
    this.radiusInput = '4',
    this.givenVerticesInput = 'BAC',
    this.copiedVerticesInput = 'QPR',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class CopyingGivenAnglesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<CopyingGivenAnglesStep> steps;
  final CopyingGivenAnglesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const CopyingGivenAnglesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory CopyingGivenAnglesResult.error({
    required int mode,
    required String message,
  }) {
    return CopyingGivenAnglesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const CopyingGivenAnglesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}