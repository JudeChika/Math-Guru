/// Represents a single row in the frequency distribution table.
class FrequencyRow {
  final String value;
  final int frequency;

  FrequencyRow({
    required this.value,
    required this.frequency,
  });
}

/// Represents a step-by-step explanation for the student.
class FrequencyStep {
  final String title;
  final String description;

  FrequencyStep({
    required this.title,
    required this.description,
  });
}

/// Holds the completely evaluated results, table data, and interpretations.
class FrequencyResult {
  final List<String> rawData;
  final List<String> sortedData;
  final List<FrequencyRow> tableRows;
  final List<String> interpretations;
  final List<FrequencyStep> steps;
  final bool valid;
  final String? errorMessage;

  FrequencyResult({
    required this.rawData,
    required this.sortedData,
    required this.tableRows,
    required this.interpretations,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}