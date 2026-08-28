
/// Represents a single slice in the pie chart.
class PieChartRow {
  final String label;
  final int frequency;
  final double degree;
  final String workingString;

  PieChartRow({
    required this.label,
    required this.frequency,
    required this.degree,
    required this.workingString,
  });
}

/// Represents a step-by-step explanation for the student.
class PieChartStep {
  final String title;
  final String description;

  PieChartStep({
    required this.title,
    required this.description,
  });
}

/// Holds the completely evaluated results, table data, and chart metrics.
class PieChartResult {
  final bool isRawData;
  final List<String> rawData;
  final List<PieChartRow> tableRows;
  final int totalFrequency;
  final List<String> interpretations;
  final List<PieChartStep> steps;
  final bool valid;
  final String? errorMessage;

  PieChartResult({
    required this.isRawData,
    required this.rawData,
    required this.tableRows,
    required this.totalFrequency,
    required this.interpretations,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}