/// Represents a single row in the HCF prime factorization table.
class HCFPrimeFactorizationRow {
  final int number;
  final List<int> factors;

  HCFPrimeFactorizationRow({required this.number, required this.factors});
}

/// Represents a single step in the HCF step-by-step breakdown.
class HCFSolutionStep {
  final String description;
  final String? detail;

  HCFSolutionStep({required this.description, this.detail});
}

/// Holds all mathematical results for the HCF calculation.
class HCFCalculatorResult {
  final List<int> inputNumbers;
  final List<HCFPrimeFactorizationRow> factorizationRows;
  final List<int> commonFactors;
  final int hcf;
  final String indexForm;
  final List<HCFSolutionStep> steps;
  final bool valid;
  final String? error;

  HCFCalculatorResult({
    required this.inputNumbers,
    required this.factorizationRows,
    required this.commonFactors,
    required this.hcf,
    required this.indexForm,
    required this.steps,
    required this.valid,
    this.error,
  });
}

/// Represents a single row in the LCM division table.
class LCMTableRow {
  final int divisor;
  final List<int> numbers;

  LCMTableRow({required this.divisor, required this.numbers});
}

/// Represents a single step in the LCM step-by-step breakdown.
class LCMStepExplanation {
  final String description;
  final List<int> state;

  LCMStepExplanation({required this.description, required this.state});
}

/// Holds all mathematical results for the LCM calculation.
class LCMCalculatorResult {
  final List<int> inputNumbers;
  final List<LCMTableRow> tableRows;
  final int lcm;
  final String indexForm;
  final List<LCMStepExplanation> steps;
  final bool valid;
  final String? error;

  LCMCalculatorResult({
    required this.inputNumbers,
    required this.tableRows,
    required this.lcm,
    required this.indexForm,
    required this.steps,
    required this.valid,
    this.error,
  });
}