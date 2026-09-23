/// Represents a single pedagogical step during the conversion process.
class ConversionStep {
  final String title;
  final String description;
  final String mathLaTeX;

  ConversionStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the result for a specific conversion pathway (e.g., "To Percentage").
class ConversionPath {
  final String targetFormat;
  final String finalAnswerLaTeX;
  final List<String> workingsLaTeX;
  final List<ConversionStep> steps;

  ConversionPath({
    required this.targetFormat,
    required this.finalAnswerLaTeX,
    required this.workingsLaTeX,
    required this.steps,
  });
}

/// Holds the completely evaluated results for all generated conversions.
class FractionsPercentagesResult {
  final String inputType; // 'Decimal', 'Common Fraction', or 'Percentage'
  final String originalInputLaTeX;
  final List<ConversionPath> conversions;
  final bool valid;
  final String? errorMessage;

  FractionsPercentagesResult({
    required this.inputType,
    required this.originalInputLaTeX,
    required this.conversions,
    this.valid = true,
    this.errorMessage,
  });
}