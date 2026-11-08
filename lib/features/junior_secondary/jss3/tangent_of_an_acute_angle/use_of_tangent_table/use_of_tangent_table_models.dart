/// Represents a single pedagogical step in the Use of Tangent Table (Pages 151–154 & 156) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class UseOfTangentTableStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const UseOfTangentTableStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Use of Tangent Table Interactive 4-Figure Table Excerpt + Math.tex Board.
/// Replicates Table 14.1 (Page 152) with Degree Column x, Interval Columns (.0–.9), and ADD Differences Columns (1–9)!
class UseOfTangentTableCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String tableExcerptLaTeX; // Authentic 4-Figure Tangent Table Row Excerpt rendered via Math.tex!
  final String calculationBoxLaTeX; // Step-by-Step Main Entry + ADD Difference Addition Box in Math.tex!
  final String bottomSummaryLaTeX;

  const UseOfTangentTableCanvasData({
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 151–154 (Examples 7–10, Exercise 14.3 #1–44) and Page 156 (Revision Exercise 14 #2 & #3).
class UseOfTangentTablePreset {
  final String chipLabel;
  final int mode;
  // 0: Find Tangent of a Given Angle from the 4-Figure Table (Whole, Tenths & Hundredths with ADD Differences — Examples 7, 8, 9, Ex 14.3 #1–24 & Rev Ex 14 #2)
  // 1: Find the Acute Angle Whose Tangent is Given as a Decimal (Reverse Table Lookup — Example 10a, 10b, Ex 14.3 #25–38 & Rev Ex 14 #3a–b)
  // 2: Find the Acute Angle Whose Tangent is Given as a Fraction p/q (Convert Fraction to Decimal First — Example 10c, Ex 14.3 #39–44 & Rev Ex 14 #3c–d)

  final String input1;
  final String input2;

  const UseOfTangentTablePreset({
    required this.chipLabel,
    required this.mode,
    required this.input1,
    this.input2 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class UseOfTangentTableResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<UseOfTangentTableStep> steps;
  final UseOfTangentTableCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const UseOfTangentTableResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory UseOfTangentTableResult.error({
    required int mode,
    required String message,
  }) {
    return UseOfTangentTableResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const UseOfTangentTableCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}