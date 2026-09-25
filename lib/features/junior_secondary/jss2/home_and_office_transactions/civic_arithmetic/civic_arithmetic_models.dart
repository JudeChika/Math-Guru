/// Represents a single pedagogical step during the arithmetic evaluation.
class CivicStep {
  final String title;
  final String description;
  final String mathLaTeX;

  CivicStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a single line item in a composite bill.
class BillItem {
  final String name;
  final double quantity;
  final double unitPrice;

  BillItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class CivicResult {
  final String topic; // 'VAT', 'Utility', or 'Composite'
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<CivicStep> steps;
  final bool valid;
  final String? errorMessage;

  CivicResult({
    required this.topic,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}