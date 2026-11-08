/// Represents a single pedagogical step in the Use of the Tangent Ratio (Pages 148–151 & 156) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class UseOfTangentRatioStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const UseOfTangentRatioStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Use of the Tangent Ratio Interactive Diagram + Math.tex Board.
/// Replicates Figs. 14.12–14.18 & 14.21 with labeled Opposite, Adjacent, and Angle θ and 100% Math.tex rendering!
class UseOfTangentRatioCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String topVertex;
  final String rightAngleVertex;
  final String baseVertex;

  final String oppLabel;
  final String adjLabel;
  final String angleLabel;
  final bool angleAtTop; // True if given acute angle is at the top vertex (as in Examples 4 & 5!)

  final String calculationTableLaTeX; // Step-by-Step Tangent Equation Rearrangement Table in Math.tex!
  final String bottomSummaryLaTeX;

  const UseOfTangentRatioCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.topVertex = 'Z',
    this.rightAngleVertex = 'Y',
    this.baseVertex = 'X',
    this.oppLabel = '12.6 cm',
    this.adjLabel = '15 cm',
    this.angleLabel = '40°',
    this.angleAtTop = false,
    this.calculationTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 148–151 (Examples 4–6 & Exercise 14.2 #1–12) and Page 156 (Revision Exercise 14 #4 & #6).
class UseOfTangentRatioPreset {
  final String chipLabel;
  final int mode;
  // 0: Find Opposite Side Given Angle θ & Adjacent Side (opp = adj × tan θ — Examples 4 & 5, Ex 14.2 #1, #3, #4, #6, #7, #9, #10, #12)
  // 1: Find Adjacent Side Given Angle θ & Opposite Side (adj = opp / tan θ — Example 6 & Ex 14.2 #2, #5, #8)
  // 2: Find Acute Angle θ Given Opposite & Adjacent Sides (tan θ = opp / adj — Rev Ex 14 #4a–b & #6)

  final String angleInput;
  final String oppInput;
  final String adjInput;
  final String givenTanInput;
  final String unknownSymbol;
  final String triName;
  final bool angleAtTop;

  const UseOfTangentRatioPreset({
    required this.chipLabel,
    required this.mode,
    this.angleInput = '',
    this.oppInput = '',
    this.adjInput = '',
    this.givenTanInput = '',
    this.unknownSymbol = 'x',
    this.triName = 'XYZ',
    this.angleAtTop = false,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class UseOfTangentRatioResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<UseOfTangentRatioStep> steps;
  final UseOfTangentRatioCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const UseOfTangentRatioResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory UseOfTangentRatioResult.error({
    required int mode,
    required String message,
  }) {
    return UseOfTangentRatioResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const UseOfTangentRatioCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}