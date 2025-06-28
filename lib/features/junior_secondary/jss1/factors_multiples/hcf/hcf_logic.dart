import 'hcf_prime_factorization_row.dart';
import 'hcf_solution_step.dart';

class HCFCalculatorResult {
  final List<int> inputNumbers;
  final List<HCFPrimeFactorizationRow> factorizationRows;
  final List<int> commonFactors;
  final int hcf;
  final List<HCFSolutionStep> steps;
  final bool valid;
  final String? error;

  HCFCalculatorResult({
    required this.inputNumbers,
    required this.factorizationRows,
    required this.commonFactors,
    required this.hcf,
    required this.steps,
    required this.valid,
    this.error,
  });
}

class HCFCalculatorLogic {
  /// Parses and validates input string into a list of integers.
  static List<int>? parseNumbers(String input) {
    final sanitized = input.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (sanitized.isEmpty) return null;
    try {
      final numbers = sanitized
          .split(' ')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => int.parse(e))
          .toList();
      if (numbers.length < 2 || numbers.any((n) => n <= 0)) return null;
      return numbers;
    } catch (_) {
      return null;
    }
  }

  /// Returns the prime factorization of a given integer as a sorted list.
  static List<int> primeFactors(int n) {
    List<int> factors = [];
    int d = 2;
    while (n > 1 && d * d <= n) {
      while (n % d == 0) {
        factors.add(d);
        n ~/= d;
      }
      d++;
    }
    if (n > 1) factors.add(n);
    return factors;
  }

  /// Returns the list of common factors in all lists (with minimum powers).
  static List<int> findCommonFactors(List<List<int>> lists) {
    if (lists.isEmpty) return [];
    final Map<int, int> minCounts = {};
    final Map<int, int> first = {};
    for (final f in lists[0]) {
      first[f] = (first[f] ?? 0) + 1;
    }
    minCounts.addAll(first);

    for (int i = 1; i < lists.length; i++) {
      final Map<int, int> counts = {};
      for (final f in lists[i]) {
        counts[f] = (counts[f] ?? 0) + 1;
      }
      for (final key in minCounts.keys.toList()) {
        if (counts.containsKey(key)) {
          minCounts[key] = minCounts[key]! < counts[key]! ? minCounts[key]! : counts[key]!;
        } else {
          minCounts.remove(key);
        }
      }
    }
    List<int> result = [];
    minCounts.forEach((prime, count) {
      result.addAll(List.filled(count, prime));
    });
    result.sort();
    return result;
  }

  static HCFCalculatorResult calculateHCF(String input) {
    final inputNumbers = parseNumbers(input);
    if (inputNumbers == null) {
      return HCFCalculatorResult(
        inputNumbers: [],
        factorizationRows: [],
        commonFactors: [],
        hcf: 0,
        steps: [
          HCFSolutionStep(
            description: "Please enter at least two positive integers, separated by spaces or commas.",
            detail: null,
          ),
        ],
        valid: false,
        error: "Invalid input.",
      );
    }

    // Step 1: Prime factorization
    final factorizationRows = <HCFPrimeFactorizationRow>[];
    final allFactors = <List<int>>[];
    for (final num in inputNumbers) {
      final pf = primeFactors(num);
      allFactors.add(pf);
      factorizationRows.add(HCFPrimeFactorizationRow(number: num, factors: pf));
    }

    // Step 2: Find common factors
    final commonFactors = findCommonFactors(allFactors);

    // Step 3: Compute HCF
    final hcf = commonFactors.isEmpty ? 1 : commonFactors.reduce((a, b) => a * b);

    // Step-by-step explanations
    final steps = <HCFSolutionStep>[];
    steps.add(HCFSolutionStep(
      description: "Step 1: Prime factorize each number.",
      detail: factorizationRows
          .map((row) => "${row.number} = ${row.factors.join(' × ')}")
          .join('\n'),
    ));

    steps.add(HCFSolutionStep(
      description: "Step 2: Identify the common prime factors in all lists.",
      detail: commonFactors.isEmpty
          ? "There are no common prime factors among all numbers."
          : "Common factors: ${commonFactors.join(' × ')}",
    ));

    steps.add(HCFSolutionStep(
      description: "Step 3: Multiply the common factors to get the HCF.",
      detail: "HCF = ${commonFactors.isEmpty ? 1 : commonFactors.join(' × ')} = $hcf",
    ));

    return HCFCalculatorResult(
      inputNumbers: inputNumbers,
      factorizationRows: factorizationRows,
      commonFactors: commonFactors,
      hcf: hcf,
      steps: steps,
      valid: true,
    );
  }
}