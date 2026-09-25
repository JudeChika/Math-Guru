/// Represents a single pedagogical step during the arithmetic evaluation.
class HouseholdStep {
  final String title;
  final String description;
  final String mathLaTeX;

  HouseholdStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class HouseholdResult {
  final String topic; // 'Discount' or 'Instalment'
  final String subTopic;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<HouseholdStep> steps;
  final bool valid;
  final String? errorMessage;

  HouseholdResult({
    required this.topic,
    required this.subTopic,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}