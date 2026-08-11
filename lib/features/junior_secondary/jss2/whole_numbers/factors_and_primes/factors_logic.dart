import 'dart:math' as math;
import 'factors_models.dart';

class FactorsLogic {

  /// Parses the input string to detect either a range or a list of numbers.
  static FactorsInputParsed parseInput(String text) {
    // Check for range first
    final sanitizedForRange = text.replaceAll(' ', '');
    if (sanitizedForRange.isEmpty) {
      return FactorsInputParsed(numbers: [], error: "Input cannot be empty.");
    }

    if (sanitizedForRange.contains('-')) {
      final parts = sanitizedForRange.split('-');
      if (parts.length == 2) {
        int? start = int.tryParse(parts[0]);
        int? end = int.tryParse(parts[1]);
        if (start != null && end != null && start > 0 && start <= end) {
          if (end - start > 200) {
            return FactorsInputParsed(
                numbers: [],
                error: "Range is too large. Please enter a range of 200 numbers or fewer."
            );
          }
          return FactorsInputParsed(
              numbers: List.generate(end - start + 1, (i) => start + i),
              isRange: true
          );
        }
      }
      return FactorsInputParsed(numbers: [], error: "Invalid range format. Use e.g., 10-30.");
    }

    // Fallback to comma or space separated numbers
    final commaSpaceSanitized = text.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    try {
      final numbers = commaSpaceSanitized
          .split(' ')
          .where((e) => e.isNotEmpty)
          .map((e) => int.parse(e))
          .toList();

      if (numbers.isEmpty || numbers.any((n) => n <= 0)) {
        return FactorsInputParsed(numbers: [], error: "Enter valid positive numbers.");
      }

      return FactorsInputParsed(numbers: numbers, isRange: false);
    } catch (e) {
      return FactorsInputParsed(numbers: [], error: "Invalid input format. Use numbers separated by spaces or commas.");
    }
  }

  /// Engine to compute multiples, factors, prime factors, and index form for a single number.
  static SingleNumberFactorsResult calculateForNumber(int n) {
    // 1. Calculate the first 10 Multiples
    List<int> multiples = List.generate(10, (i) => n * (i + 1));

    // 2. Calculate Factors and their Multiplication Pairs
    List<int> factors = [];
    List<String> factorPairs = [];
    for (int i = 1; i <= math.sqrt(n); i++) {
      if (n % i == 0) {
        factors.add(i);
        int pair = n ~/ i;
        factorPairs.add("$i \\times $pair = $n");
        // Only add the pair if it's not a perfect square duplicate
        if (i != pair) {
          factors.add(pair);
        }
      }
    }
    factors.sort();

    // 3. Calculate Prime Factorization
    List<int> primeFactorization = [];
    int temp = n;
    int d = 2;
    while (temp > 1 && d * d <= temp) {
      while (temp % d == 0) {
        primeFactorization.add(d);
        temp ~/= d;
      }
      d++;
    }
    if (temp > 1) primeFactorization.add(temp);

    // 4. Extract Distinct Prime Factors
    List<int> distinctPrimes = primeFactorization.toSet().toList();

    // 5. Generate Index Form (LaTeX string)
    String indexFormLaTeX = "";
    if (n == 1) {
      indexFormLaTeX = "1";
    } else {
      Map<int, int> counts = {};
      for (var p in primeFactorization) {
        counts[p] = (counts[p] ?? 0) + 1;
      }
      List<String> terms = [];
      counts.forEach((prime, count) {
        if (count == 1) {
          terms.add("$prime");
        } else {
          terms.add("$prime^{$count}");
        }
      });
      indexFormLaTeX = terms.join(" \\times ");
    }

    // 6. Assemble Step-by-Step Explanations
    List<FactorSolutionStep> steps = [];

    steps.add(FactorSolutionStep(
      description: "Step 1: Find the first few Multiples by multiplying $n by 1, 2, 3, etc.",
      workingLaTeX: "${multiples.join(', ')}, \\dots",
    ));

    steps.add(FactorSolutionStep(
      description: "Step 2: Find all Factors (numbers that divide $n without a remainder) by identifying multiplier pairs.",
      workingLaTeX: "${factorPairs.join(r' \quad ')} \\Rightarrow ${factors.join(', ')}",
    ));

    steps.add(FactorSolutionStep(
      description: "Step 3: Identify the Prime Factors (factors that are prime numbers).",
      workingLaTeX: distinctPrimes.isEmpty ? "None \\text{ (1 is not prime)}" : distinctPrimes.join(', '),
    ));

    steps.add(FactorSolutionStep(
      description: "Step 4: Perform Prime Factorization by continuously dividing $n by the smallest possible primes.",
      workingLaTeX: n == 1 ? "1" : "$n = ${primeFactorization.join(' \\times ')}",
    ));

    steps.add(FactorSolutionStep(
      description: "Step 5: Write the final result in Index Form by grouping identical primes into powers.",
      workingLaTeX: "$n = $indexFormLaTeX",
    ));

    return SingleNumberFactorsResult(
      number: n,
      multiples: multiples,
      factors: factors,
      factorPairs: factorPairs,
      distinctPrimes: distinctPrimes,
      primeFactorization: primeFactorization,
      indexFormLaTeX: indexFormLaTeX,
      steps: steps,
    );
  }
}