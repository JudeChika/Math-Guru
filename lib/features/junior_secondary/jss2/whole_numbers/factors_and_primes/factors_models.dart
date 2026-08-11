/// Represents a single step in the step-by-step breakdown.
class FactorSolutionStep {
  final String description;
  final String workingLaTeX;

  FactorSolutionStep({
    required this.description,
    required this.workingLaTeX,
  });
}

/// Holds all mathematical results for a specific number.
class SingleNumberFactorsResult {
  final int number;
  final List<int> multiples;
  final List<int> factors;
  final List<String> factorPairs;
  final List<int> distinctPrimes;
  final List<int> primeFactorization;
  final String indexFormLaTeX;
  final List<FactorSolutionStep> steps;

  SingleNumberFactorsResult({
    required this.number,
    required this.multiples,
    required this.factors,
    required this.factorPairs,
    required this.distinctPrimes,
    required this.primeFactorization,
    required this.indexFormLaTeX,
    required this.steps,
  });
}

/// Holds the parsed input from the user, determining if it's a range or a list of numbers.
class FactorsInputParsed {
  final List<int> numbers;
  final bool isRange;
  final String? error;

  FactorsInputParsed({
    required this.numbers,
    this.isRange = false,
    this.error,
  });
}