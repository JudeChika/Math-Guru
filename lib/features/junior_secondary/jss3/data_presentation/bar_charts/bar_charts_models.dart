/// Represents a single pedagogical step in the Bar Charts (Chapter 19, Pages 220–225 & 233–234) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class BarChartStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const BarChartStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Represents a single category bar in the interactive custom chart canvas.
class BarChartItemData {
  final String label;
  final double value;
  final String valueDisplayPlain;
  final String valueLaTeX;
  final String fractionOfTotalLaTeX;
  final String percentagePlain;
  final bool isHighest;
  final bool isLowest;

  const BarChartItemData({
    required this.label,
    required this.value,
    required this.valueDisplayPlain,
    required this.valueLaTeX,
    required this.fractionOfTotalLaTeX,
    required this.percentagePlain,
    this.isHighest = false,
    this.isLowest = false,
  });
}

/// Encapsulates all visual elements for the Large Interactive Bar Chart & Mathfork Visualisation Area.
class BarChartCanvasData {
  final int mode; // 0: Vertical Bar Chart, 1: Horizontal Bar Chart, 2: Bar Line Graph, 3: Fractional Subgroup Bar Chart
  final String chartTitle;
  final String xAxisLabel;
  final String yAxisLabel;
  final List<BarChartItemData> bars;
  final double maxScaleY;
  final double scaleStepY;
  final double meanValue;
  final double? passMark;

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String tableBoxLaTeX; // Summary Fraction & Percentage Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const BarChartCanvasData({
    this.mode = 0,
    this.chartTitle = '',
    this.xAxisLabel = '',
    this.yAxisLabel = '',
    this.bars = const [],
    this.maxScaleY = 10.0,
    this.scaleStepY = 2.0,
    this.meanValue = 0.0,
    this.passMark,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.tableBoxLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 220–225 & Pages 233–234.
class BarChartPreset {
  final String chipLabel;
  final int mode;
  // 0: Vertical Bar Chart & Quiz Interpretation (Example 1 Table 19.2, Example 2 Fig 19.6, Fig 19.2, Rev Ex 19 #2 Fig 19.17)
  // 1: Horizontal Bar Chart (Exercise 19.1 #2 Table 19.4 Daily Sales of PMS in Litres)
  // 2: Bar Line Graph (Fig 19.3 Dog Owners & Revision Exercise 19 #1 Fig 19.16 Pets Owned)
  // 3: Fractional Subgroup Breakdown from Bar Chart (Exercise 19.1 #1 Fig 19.9 Favourite Colours of JSS 3A)

  final String categoriesInput;
  final String valuesInput;
  final String chartTitle;
  final String xAxisLabel;
  final String yAxisLabel;
  final String extraInput; // Pass mark (Mode 0) or Fractional subgroup rules (Mode 3)

  const BarChartPreset({
    required this.chipLabel,
    required this.mode,
    required this.categoriesInput,
    required this.valuesInput,
    this.chartTitle = '',
    this.xAxisLabel = '',
    this.yAxisLabel = '',
    this.extraInput = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class BarChartResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<BarChartStep> steps;
  final BarChartCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BarChartResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BarChartResult.error({
    required int mode,
    required String message,
  }) {
    return BarChartResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BarChartCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}