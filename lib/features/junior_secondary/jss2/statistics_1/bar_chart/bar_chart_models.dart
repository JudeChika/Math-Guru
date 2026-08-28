/// Represents a single category/bar in the chart.
class BarChartRow {
  final String label;
  final int frequency;

  BarChartRow({
    required this.label,
    required this.frequency,
  });
}

/// Represents a step-by-step explanation for the student.
class BarChartStep {
  final String title;
  final String description;

  BarChartStep({
    required this.title,
    required this.description,
  });
}

/// Holds the completely evaluated results, table data, and chart metrics.
class BarChartResult {
  final bool isRawData;
  final List<String> rawData;
  final List<BarChartRow> tableRows;
  final int maxFrequency;
  final List<String> interpretations;
  final List<BarChartStep> steps;
  final bool valid;
  final String? errorMessage;

  BarChartResult({
    required this.isRawData,
    required this.rawData,
    required this.tableRows,
    required this.maxFrequency,
    required this.interpretations,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}