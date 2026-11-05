/// Represents a single pedagogical step in the Word Problems Involving Simultaneous Linear Equations (Pages 99–102) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SimultaneousWordProblemsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SimultaneousWordProblemsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Simultaneous Word Problems Math.tex Visualisation Area.
/// Every formed equation, elimination/substitution step, and contextual conclusion is rendered via Math.tex!
class SimultaneousWordProblemsCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String summaryTableLaTeX; // Word-to-Simultaneous Equations Summary Table in Math.tex!
  final String bottomSummaryLaTeX;

  const SimultaneousWordProblemsCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.summaryTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 99–102 (Examples 7, 8, 9, Exercise 10.4 #1–10, and Revision Exercise 10 Part D #1–5).
class SimultaneousWordProblemsPreset {
  final String chipLabel;
  final int mode;
  // 0: Cost of Tickets, Notes, Books & Bolts (Example 7, Ex 10.4 #2, #3, #5, #8, #9 & Rev Ex 10D #3)
  // 1: Total Quantity & Weighted Sum / Machine Rates (Example 8 & Ex 10.4 #4)
  // 2: Two Numbers (Sum, Difference, Average & Multiples — Example 9, Ex 10.4 #1, #6, #10 & Rev Ex 10D #1, #4)
  // 3: Age & Fraction Numerator/Denominator Word Problems (Ex 10.4 #7 & Rev Ex 10D #2, #5)

  final String problemStatement;
  final String var1Meaning;
  final String var2Meaning;
  final String eq1Str;
  final String eq2Str;
  final String unit1;
  final String unit2;
  final bool isFractionBuilder; // True for Rev Ex 10D #5 ("What is the original fraction x/y?")

  const SimultaneousWordProblemsPreset({
    required this.chipLabel,
    required this.mode,
    required this.problemStatement,
    required this.var1Meaning,
    required this.var2Meaning,
    required this.eq1Str,
    required this.eq2Str,
    this.unit1 = '',
    this.unit2 = '',
    this.isFractionBuilder = false,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SimultaneousWordProblemsResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SimultaneousWordProblemsStep> steps;
  final SimultaneousWordProblemsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SimultaneousWordProblemsResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SimultaneousWordProblemsResult.error({
    required int mode,
    required String message,
  }) {
    return SimultaneousWordProblemsResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SimultaneousWordProblemsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}