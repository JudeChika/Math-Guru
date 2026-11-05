/// Represents a single pedagogical step in the Formulae and Substitution (Pages 103–106 & 111–113) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class FormulaeSubstitutionStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const FormulaeSubstitutionStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Formulae & Substitution Math.tex Visualisation Area.
/// Every fraction (\frac{}{}), mixed number, exponent, and radical is rendered via flutter_math_fork (Math.tex)!
class FormulaeSubstitutionCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String substitutionTableLaTeX; // Step-by-Step Substitution & BODMAS Evaluation Table in Math.tex!
  final String bottomSummaryLaTeX;

  const FormulaeSubstitutionCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.substitutionTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 103–106 (Examples 1–3, Exercises 11.1 & 11.2) and Pages 111–113 (Revision Exercise 11 #1–4).
class FormulaeSubstitutionPreset {
  final String chipLabel;
  final int mode;
  // 0: Direct Expression / Formula Substitution (Example 1a–d, Ex 11.1 #1–25 & Rev Ex 11 #1–2)
  // 1: Formulae with Square Roots & Quadratic Formula (Ex 11.1 #5, #16, #18, #21 & Ex 11.2 #8)
  // 2: Mensuration, Science & Financial Formula Word Problems (Examples 2 & 3, Ex 11.2 #1–15)

  final String formulaInput;
  final String valuesInput;
  final String targetVarInput;
  final String contextDescription;
  final String unit;

  const FormulaeSubstitutionPreset({
    required this.chipLabel,
    required this.mode,
    required this.formulaInput,
    required this.valuesInput,
    this.targetVarInput = '',
    this.contextDescription = '',
    this.unit = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class FormulaeSubstitutionResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<FormulaeSubstitutionStep> steps;
  final FormulaeSubstitutionCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const FormulaeSubstitutionResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory FormulaeSubstitutionResult.error({
    required int mode,
    required String message,
  }) {
    return FormulaeSubstitutionResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const FormulaeSubstitutionCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}