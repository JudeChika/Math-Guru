/// Represents a single pedagogical step in the Component (Compound) Bar Charts (Chapter 19, Pages 222–227 & 234–235) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ComponentBarChartStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ComponentBarChartStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Represents a single category column (e.g., Mon, Tue, 2005, Dawodu) and its component values.
class ComponentBarCategoryGroup {
  final String categoryLabel;
  final List<double> componentValues;
  final List<String> componentLaTeX;
  final List<String> componentPlain;
  final double totalValue;
  final String totalLaTeX;
  final String totalPlain;

  const ComponentBarCategoryGroup({
    required this.categoryLabel,
    required this.componentValues,
    required this.componentLaTeX,
    required this.componentPlain,
    required this.totalValue,
    required this.totalLaTeX,
    required this.totalPlain,
  });
}

/// Encapsulates all visual elements for the Interactive Component Bar Chart & Completed Table Visualisation Area.
/// Every formula, fraction (\frac{}{}), mixed number, and table cell is rendered using flutter_math_fork (Math.tex)!
class ComponentBarChartCanvasData {
  final int chartStyle; // 0: Method I Side-by-Side, 1: Method II Stacked, 2: Horizontal Compound
  final String chartTitle;
  final String xAxisLabel;
  final String yAxisLabel;
  final List<String> componentNames;
  final List<ComponentBarCategoryGroup> groups;
  final double yAxisMax;
  final double yAxisStep;

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String summaryTableLaTeX; // Completed Textbook Table rendered via Math.tex!
  final String bottomSummaryLaTeX;

  const ComponentBarChartCanvasData({
    this.chartStyle = 0,
    this.chartTitle = '',
    this.xAxisLabel = '',
    this.yAxisLabel = '',
    this.componentNames = const [],
    this.groups = const [],
    this.yAxisMax = 100.0,
    this.yAxisStep = 20.0,
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

/// Pre-configured textbook preset for instant one-tap loading across Pages 222–227 & Pages 233–235.
class ComponentBarChartPreset {
  final String chipLabel;
  final int mode;
  // 0: Method I — Side-by-Side Component Bar Chart (Fig. 19.7, Table 19.5, 19.6, 19.10, 19.19)
  // 1: Method II — Stacked (Placed on Top) Component Bar Chart (Fig. 19.8, Table 19.7, 19.9, Fig. 19.18 / Table 19.20)
  // 2: Horizontal Compound Bar Chart (Exercise 19.1 #6 Table 19.8 Air Emissions)
  // 3: Component Bar Graph Interpretation & Midpoint Estimation (Example 4 & Exercise 19.1 #4c)

  final String categoriesInput;
  final String componentsRowsInput;
  final String chartTitle;
  final String xAxisLabel;
  final String yAxisLabel;
  final String unit;

  const ComponentBarChartPreset({
    required this.chipLabel,
    required this.mode,
    required this.categoriesInput,
    required this.componentsRowsInput,
    this.chartTitle = '',
    this.xAxisLabel = '',
    this.yAxisLabel = '',
    this.unit = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ComponentBarChartResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<ComponentBarChartStep> steps;
  final ComponentBarChartCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ComponentBarChartResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ComponentBarChartResult.error({
    required int mode,
    required String message,
  }) {
    return ComponentBarChartResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ComponentBarChartCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}