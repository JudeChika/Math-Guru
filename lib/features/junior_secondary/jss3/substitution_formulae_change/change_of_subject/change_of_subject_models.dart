/// Represents a single pedagogical step in the Changing the Subject of a Formula (Pages 106–113) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ChangeOfSubjectStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ChangeOfSubjectStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Changing the Subject of a Formula Math.tex Visualisation Area.
/// Every inverse operation, fraction (\frac{}{}), and root/power transformation is rendered via Math.tex!
class ChangeOfSubjectCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String pipelineTableLaTeX; // Inverse-Operations Transformation Pipeline Table in Math.tex!
  final String bottomSummaryLaTeX;

  const ChangeOfSubjectCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.pipelineTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 106–113 (Examples 4–7, Exercises 11.3 & 11.4, and Revision Exercise 11 #5–20).
class ChangeOfSubjectPreset {
  final String chipLabel;
  final int mode;
  // 0: Linear, Factored & Fractional Formulae (Examples 4–7, Ex 11.3 #1–3, #5–11, #13–15, #17, #19, #22, #24–28, #32, #34)
  // 1: Formulae Involving Squares, Cubes & Square Roots (Ex 11.3 #4, #12, #16, #18, #20, #21, #29–31, #33, #35 & Ex 11.4 #1, #2, #8)
  // 2: Change the Subject AND Substitute Values (Two-Part Exam Questions: Examples 6 & 7, Ex 11.4 #1–10 & Rev Ex 11 #6–20)

  final String formulaInput;
  final String newSubjectInput;
  final String valuesOptionalInput;
  final String contextDescription;

  const ChangeOfSubjectPreset({
    required this.chipLabel,
    required this.mode,
    required this.formulaInput,
    required this.newSubjectInput,
    this.valuesOptionalInput = '',
    this.contextDescription = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ChangeOfSubjectResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ChangeOfSubjectStep> steps;
  final ChangeOfSubjectCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ChangeOfSubjectResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ChangeOfSubjectResult.error({
    required int mode,
    required String message,
  }) {
    return ChangeOfSubjectResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ChangeOfSubjectCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}