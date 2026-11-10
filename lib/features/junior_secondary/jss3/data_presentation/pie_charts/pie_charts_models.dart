/// Represents a single pedagogical step in the Pie Charts (Chapter 19, Pages 228–233 & 236–237) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class PieChartStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const PieChartStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Represents a single evaluated sector of the Pie Chart.
class PieChartSectorData {
  final String label;
  final double angleDegrees;
  final double percentage;
  final double? quantityValue;

  final String fractionOfCircleLaTeX;
  final String angleLaTeX;
  final String percentageLaTeX;
  final String quantityLaTeX;
  final String anglePlain;
  final String percentagePlain;
  final String quantityPlain;

  const PieChartSectorData({
    required this.label,
    required this.angleDegrees,
    required this.percentage,
    this.quantityValue,
    required this.fractionOfCircleLaTeX,
    required this.angleLaTeX,
    required this.percentageLaTeX,
    this.quantityLaTeX = '-',
    required this.anglePlain,
    required this.percentagePlain,
    this.quantityPlain = '-',
  });
}

/// Encapsulates all visual elements for the Interactive Pie Chart & Sectorial Table Visualisation Area.
/// Every formula, fraction (\frac{}{}), mixed number, and table cell is rendered using flutter_math_fork (Math.tex)!
class PieChartCanvasData {
  final String chartTitle;
  final List<PieChartSectorData> sectors;
  final String circleRadiusNote;

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String sectorTableLaTeX; // Completed Table 19.12 / 19.17 / 19.18 rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const PieChartCanvasData({
    this.chartTitle = '',
    this.sectors = const [],
    this.circleRadiusNote = '',
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.sectorTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 228–233 & Pages 236–237.
class PieChartPreset {
  final String chipLabel;
  final int mode;
  // 0: Frequencies / Quantities -> Sectorial Angles (Example 5, Ex 19.2 #1–#4, Rev Ex 19 #4)
  // 1: Percentages (including mixed fractions like 30 5/9%) -> Angles & Quantities (Example 6, Rev Ex 19 #7)
  // 2: Sectorial Angles (including unknown x or a, or mixed % sectors) -> Missing Angle & Quantities (Ex 19.2 #5–#7, Rev Ex 19 #5, #8)
  // 3: Ratios (including fractional ratios like 1 : 3/2 : 2) -> Sectorial Angles (Rev Ex 19 #6)

  final String categoriesInput;
  final String valuesInput;
  final String totalOrKnownInput;
  final String chartTitle;
  final String unit;

  const PieChartPreset({
    required this.chipLabel,
    required this.mode,
    required this.categoriesInput,
    required this.valuesInput,
    this.totalOrKnownInput = '',
    this.chartTitle = '',
    this.unit = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class PieChartResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<PieChartStep> steps;
  final PieChartCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const PieChartResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory PieChartResult.error({
    required int mode,
    required String message,
  }) {
    return PieChartResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const PieChartCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}