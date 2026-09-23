/// Represents a single pedagogical step during the proportion evaluation.
class ProportionStep {
  final String title;
  final String description;
  final String mathLaTeX;

  ProportionStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class ProportionResult {
  final String givenQuantity;
  final String givenUnit;
  final String givenTarget;
  final String targetUnit;
  final String newQuantity;
  final bool isDirect;

  final String finalAnswerLaTeX;
  final List<String> workingsLaTeX;
  final List<ProportionStep> steps;
  final bool valid;
  final String? errorMessage;

  ProportionResult({
    required this.givenQuantity,
    required this.givenUnit,
    required this.givenTarget,
    required this.targetUnit,
    required this.newQuantity,
    required this.isDirect,
    required this.finalAnswerLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}