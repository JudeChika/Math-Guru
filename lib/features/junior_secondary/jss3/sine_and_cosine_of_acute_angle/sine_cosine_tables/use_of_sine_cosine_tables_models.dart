/// Represents a single pedagogical step in the Use of Sine and Cosine Tables (Pages 165–169 & 174) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class UseOfSineCosineTablesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const UseOfSineCosineTablesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Use of Sine & Cosine Tables Interactive 4-Figure Table Excerpt + Math.tex Board.
/// Replicates Table 15.1 & Four-Figure Sine/Cosine Tables (Pages 166–168) showing ADD Differences for Sine vs SUBTRACT Differences for Cosine!
class UseOfSineCosineTablesCanvasData {
  final bool isCosine;
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String tableExcerptLaTeX; // Authentic 4-Figure Sine or Cosine Table Row Excerpt rendered via Math.tex!
  final String calculationBoxLaTeX; // Step-by-Step Main Entry ± Difference Box in Math.tex!
  final String bottomSummaryLaTeX;

  const UseOfSineCosineTablesCanvasData({
    this.isCosine = false,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.tableExcerptLaTeX = '',
    this.calculationBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 166–168 (Examples 6–9, Exercises 15.3, 15.4, 15.5) and Page 174 (Revision Exercise 15 #1 & #2).
class UseOfSineCosineTablesPreset {
  final String chipLabel;
  final int mode;
  // 0: Table 15.1 & Complementary Angles: Find BOTH sin x and cos x (Examples 6 & 7, Exercise 15.3 #1–21)
  // 1: Find sin θ or cos θ from 4-Figure Tables (ADD Difference for Sine vs SUBTRACT Difference for Cosine — Example 8a–d, Ex 15.4 #1–22 & Rev Ex 15 #1)
  // 2: Reverse Lookup: Find Angle θ Given Decimal Sine or Cosine (Example 9a, 9d, Ex 15.5 #1–12 & Rev Ex 15 #2)
  // 3: Reverse Lookup: Find Angle θ Given Fractional Sine or Cosine p/q (Example 9b 11/13, Example 9c 14/30 & Ex 15.5 #13–18)

  final bool isCosine; // false: Sine table, true: Cosine table
  final String input1;
  final String input2;

  const UseOfSineCosineTablesPreset({
    required this.chipLabel,
    required this.mode,
    this.isCosine = false,
    required this.input1,
    this.input2 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class UseOfSineCosineTablesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<UseOfSineCosineTablesStep> steps;
  final UseOfSineCosineTablesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const UseOfSineCosineTablesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory UseOfSineCosineTablesResult.error({
    required int mode,
    required String message,
  }) {
    return UseOfSineCosineTablesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const UseOfSineCosineTablesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}