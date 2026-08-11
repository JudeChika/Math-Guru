import 'hcf_lcm_models.dart';

class HCFLCMLogic {

  /// Parses and validates input string into a list of integers.
  /// Allows single numbers to enable prime factorization capabilities.
  static List<int>? parseNumbers(String input) {
    final sanitized = input.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (sanitized.isEmpty) return null;
    try {
      final numbers = sanitized
          .split(' ')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => int.parse(e))
          .toList();

      // Allow single numbers (length >= 1)
      if (numbers.isEmpty || numbers.any((n) => n <= 0)) return null;
      return numbers;
    } catch (_) {
      return null;
    }
  }

  /// Returns the prime factorization of a given integer as a sorted list.
  static List<int> _primeFactors(int n) {
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
  static List<int> _findCommonFactors(List<List<int>> lists) {
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

  /// Converts a list of prime factors into a mathematical index form string (e.g. 2² × 3)
  static String toIndexFormString(List<int> primes) {
    if (primes.isEmpty) return "1";

    Map<int, int> counts = {};
    for (int p in primes) {
      counts[p] = (counts[p] ?? 0) + 1;
    }

    List<String> terms = [];
    const superscripts = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];
    String toSuper(int n) => n.toString().split('').map((char) => superscripts[int.parse(char)]).join('');

    final sortedPrimes = counts.keys.toList()..sort();
    for (var prime in sortedPrimes) {
      final count = counts[prime]!;
      if (count == 1) {
        terms.add("$prime");
      } else {
        terms.add("$prime${toSuper(count)}");
      }
    }
    return terms.join(" × ");
  }

  static HCFCalculatorResult calculateHCF(String input) {
    final inputNumbers = parseNumbers(input);
    if (inputNumbers == null) {
      return HCFCalculatorResult(
        inputNumbers: [],
        factorizationRows: [],
        commonFactors: [],
        hcf: 0,
        indexForm: "1",
        steps: [
          HCFSolutionStep(
            description: "Please enter one or more positive integers, separated by spaces or commas.",
            detail: null,
          ),
        ],
        valid: false,
        error: "Invalid input.",
      );
    }

    final factorizationRows = <HCFPrimeFactorizationRow>[];
    final allFactors = <List<int>>[];
    for (final num in inputNumbers) {
      final pf = _primeFactors(num);
      allFactors.add(pf);
      factorizationRows.add(HCFPrimeFactorizationRow(number: num, factors: pf));
    }

    final commonFactors = _findCommonFactors(allFactors);
    final hcf = commonFactors.isEmpty ? 1 : commonFactors.reduce((a, b) => a * b);
    final indexForm = toIndexFormString(commonFactors);

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
      detail: commonFactors.isEmpty
          ? "HCF = 1"
          : "Common Factors: ${commonFactors.join(' × ')}\nIndex Form: $indexForm\nHCF = $hcf",
    ));

    return HCFCalculatorResult(
      inputNumbers: inputNumbers,
      factorizationRows: factorizationRows,
      commonFactors: commonFactors,
      hcf: hcf,
      indexForm: indexForm,
      steps: steps,
      valid: true,
    );
  }

  /// Returns the lowest prime divisor of any number in the list > 1, or null if all are 1.
  static int? _findSmallestPrimeDivisor(List<int> numbers) {
    int max = numbers.reduce((a, b) => a > b ? a : b);
    if (max <= 1) return null;
    for (int d = 2; d <= max; d++) {
      if (numbers.any((n) => n % d == 0 && n > 1)) return d;
    }
    return null;
  }

  /// Main LCM calculation using the division table method.
  static LCMCalculatorResult calculateLCM(String input) {
    final inputNumbers = parseNumbers(input);
    if (inputNumbers == null) {
      return LCMCalculatorResult(
        inputNumbers: [],
        tableRows: [],
        lcm: 0,
        indexForm: "1",
        steps: [
          LCMStepExplanation(
            description: "Please enter one or more positive integers, separated by spaces or commas.",
            state: [],
          ),
        ],
        valid: false,
        error: "Invalid input.",
      );
    }

    List<LCMTableRow> tableRows = [];
    List<LCMStepExplanation> steps = [];
    List<int> working = List.from(inputNumbers);
    List<int> divisors = [];
    int stepCount = 1;

    steps.add(LCMStepExplanation(
      description: "Step $stepCount: Start with the input number(s): ${working.join(', ')}",
      state: List.from(working),
    ));

    while (working.any((n) => n > 1)) {
      final divisor = _findSmallestPrimeDivisor(working);
      if (divisor == null) break;

      List<int> nextRow = [];
      for (int n in working) {
        if (n % divisor == 0 && n != 1) {
          nextRow.add(n ~/ divisor);
        } else {
          nextRow.add(n);
        }
      }
      divisors.add(divisor);
      tableRows.add(LCMTableRow(divisor: divisor, numbers: List.from(working)));
      stepCount++;
      steps.add(LCMStepExplanation(
        description: "Step $stepCount: Divide by $divisor. Result: ${nextRow.join(', ')}",
        state: List.from(nextRow),
      ));
      working = nextRow;
    }

    tableRows.add(LCMTableRow(divisor: 1, numbers: List.from(working)));

    final lcm = divisors.fold(1, (prev, d) => prev * d);
    final indexForm = toIndexFormString(divisors);

    String finalDescription = divisors.isEmpty
        ? "Final Step: The number is already 1."
        : "Final Step: Multiply all divisors used:\n${divisors.join(' × ')}\nIndex Form: $indexForm\nLCM = $lcm";

    steps.add(LCMStepExplanation(
      description: finalDescription,
      state: List.from(working),
    ));

    return LCMCalculatorResult(
      inputNumbers: inputNumbers,
      tableRows: tableRows,
      lcm: lcm,
      indexForm: indexForm,
      steps: steps,
      valid: true,
    );
  }
}