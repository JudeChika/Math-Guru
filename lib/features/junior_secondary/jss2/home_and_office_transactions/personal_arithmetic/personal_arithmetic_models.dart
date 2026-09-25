/// Represents a single pedagogical step during the arithmetic evaluation.
class PersonalArithmeticStep {
  final String title;
  final String description;
  final String mathLaTeX;

  PersonalArithmeticStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a dynamic tax band defined by a range
class TaxBand {
  final double lower; // Lower bound of the band (e.g., 0, or 200000)
  final double? upper; // Upper bound. Null means "Over/Remaining".
  final double rate;   // Percentage rate for this band.

  TaxBand({
    required this.lower,
    this.upper,
    required this.rate,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class PersonalArithmeticResult {
  final String topic; // 'Interest' or 'Tax'
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<PersonalArithmeticStep> steps;
  final bool valid;
  final String? errorMessage;

  PersonalArithmeticResult({
    required this.topic,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}