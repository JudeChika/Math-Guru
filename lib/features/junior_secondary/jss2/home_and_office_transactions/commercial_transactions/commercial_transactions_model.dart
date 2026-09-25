/// Represents a single logical deduction or mathematical step.
class CommercialStep {
  final String title;
  final String description;
  final String mathLaTeX;

  CommercialStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents an item sold for commission calculations
class CommItem {
  final String name;
  final double quantity;
  final double unitPrice;

  CommItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
}

/// Holds the results of a solved commercial transaction problem.
class CommercialResult {
  final String mode; // 'ProfitLoss' or 'Commission'
  final Map<String, String> finalAnswers;
  final List<String> workings;
  final List<CommercialStep> steps;
  final bool valid;
  final String? errorMessage;

  CommercialResult({
    required this.mode,
    required this.finalAnswers,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}