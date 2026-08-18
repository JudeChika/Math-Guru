import 'dart:math' as math;
import 'squares_roots_models.dart';

class SquaresRootsLogic {

  /// Formats numbers to drop trailing .0 for cleaner LaTeX display
  static String _fmt(num v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toString();
  }

  /// Calculates the square root of a whole number or fraction using the chosen method.
  static SquaresRootsResult calculateSquareRoot(String input, String method) {
    try {
      String trimmed = input.trim();
      if (trimmed.isEmpty) throw FormatException();

      // Handle Mixed and Proper/Improper Fractions
      if (trimmed.contains('/')) {
        if (trimmed.contains(RegExp(r'\s+'))) {
          final parts = trimmed.split(RegExp(r'\s+'));
          int whole = int.parse(parts[0]);
          final fracParts = parts[1].split('/');
          int fracNum = int.parse(fracParts[0]);
          int den = int.parse(fracParts[1]);
          if (whole <= 0 || fracNum < 0 || den <= 0) throw FormatException();
          int num = (whole * den) + fracNum;
          return _solveFractionRoot(num, den, method, originalWhole: whole, originalNum: fracNum);
        } else {
          final parts = trimmed.split('/');
          int num = int.parse(parts[0]);
          int den = int.parse(parts[1]);
          if (num <= 0 || den <= 0) throw FormatException("Numbers must be positive.");
          return _solveFractionRoot(num, den, method);
        }
      }

      // Handle Whole Numbers
      final cleanInput = trimmed.replaceAll(' ', '');
      final number = int.parse(cleanInput);
      if (number <= 0) throw FormatException("Number must be positive.");
      return _solveWholeNumberRoot(number, method);

    } catch (e) {
      return SquaresRootsResult(
          finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid input. Enter a whole number (e.g. 144), fraction (e.g. 16/25), or mixed fraction (e.g. 2 1/4)."
      );
    }
  }

  static SquaresRootsResult _solveWholeNumberRoot(int n, String method) {
    bool useDivisibilityRules = method == 'Divisibility Rules';
    bool usePerfectSquare = method == 'Perfect Square';

    List<String> workings = [];
    List<SquareRootStep> steps = [];

    workings.add("\\sqrt{${_fmt(n)}}");
    steps.add(SquareRootStep(
        explanation: "We need to find the square root of $n.",
        mathLaTeX: "\\sqrt{${_fmt(n)}}"
    ));

    if (n == 1) {
      workings.add("1");
      steps.add(SquareRootStep(explanation: "The square root of 1 is 1.", mathLaTeX: "1"));
      return SquaresRootsResult(finalAnswerLaTeX: "1", workingsLaTeX: workings, steps: steps);
    }

    // 1. Prime Factorization & LCM Table setup
    List<int> factors = [];
    List<int> lcmDivisors = [];
    List<int> lcmQuotients = [n];

    int current = n;
    int d = 2;

    List<SquareRootStep> divisibilitySteps = [];

    while (current > 1) {
      while (current % d == 0) {
        if (useDivisibilityRules) {
          _addDivisibilityExplanation(current, d, divisibilitySteps);
        }
        factors.add(d);
        lcmDivisors.add(d);
        current ~/= d;
        lcmQuotients.add(current);
      }
      d++;
      if (d * d > current && current > 1) {
        if (useDivisibilityRules) {
          _addDivisibilityExplanation(current, current, divisibilitySteps);
        }
        factors.add(current);
        lcmDivisors.add(current);
        current ~/= current; // becomes 1
        lcmQuotients.add(current);
        break;
      }
    }

    // Generate LCM Table LaTeX (Continuous Division Board)
    String lcmTableLatex = "\\begin{array}{r|l}\n";
    for (int i = 0; i < lcmDivisors.length; i++) {
      lcmTableLatex += "${lcmDivisors[i]} & ${lcmQuotients[i]} \\\\\n";
      lcmTableLatex += "\\hline\n";
    }
    lcmTableLatex += " & ${lcmQuotients.last} \n\\end{array}";

    // Add the LCM Table to the visual Workings section
    workings.add(lcmTableLatex);

    // Count prime factors to check if it's a perfect square
    Map<int, int> counts = {};
    for (var f in factors) {
      counts[f] = (counts[f] ?? 0) + 1;
    }

    List<String> oddPowers = [];
    bool isPerfect = true;
    for (var entry in counts.entries) {
      if (entry.value % 2 != 0) {
        isPerfect = false;
        oddPowers.add(entry.value == 1 ? "${entry.key}" : "${entry.key}^{${entry.value}}");
      }
    }

    if (!isPerfect) {
      double root = math.sqrt(n);
      String msg = "$n is not a perfect square.";
      if (usePerfectSquare) {
        msg = "$n is not a perfect square because its prime factor(s) ${oddPowers.join(' and ')} have an odd power.";
      }
      return SquaresRootsResult(
        valid: false,
        finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
        errorMessage: "$msg Its square root is a decimal (approx ${_fmt(double.parse(root.toStringAsFixed(3)))}).",
      );
    }

    if (usePerfectSquare) {
      List<String> indexForm = [];
      List<String> halvedForm = [];
      List<int> halvedValues = [];

      counts.forEach((prime, count) {
        indexForm.add(count == 1 ? "$prime" : "$prime^{$count}");
        halvedForm.add(count ~/ 2 == 1 ? "$prime" : "$prime^{${count ~/ 2}}");
        halvedValues.add(math.pow(prime, count ~/ 2).toInt());
      });

      workings.add("$n = ${indexForm.join(' \\times ')}");
      steps.add(SquareRootStep(
          explanation: "Step 1: Use the continuous division (LCM) method to find the prime factors, then write $n in index form.",
          mathLaTeX: "$n = ${indexForm.join(' \\times ')}"
      ));

      workings.add("\\sqrt{${indexForm.join(' \\times ')}}");
      steps.add(SquareRootStep(
          explanation: "Step 2: To find the square root, check if all the powers are even. Since they are, $n is a perfect square! We halve the powers and remove the square root symbol.",
          mathLaTeX: "\\sqrt{${indexForm.join(' \\times ')}} = ${halvedForm.join(' \\times ')}"
      ));

      workings.add(halvedForm.join(' \\times '));

      bool needsExpansion = halvedForm.any((s) => s.contains('^'));
      if (needsExpansion) {
        workings.add(halvedValues.join(' \\times '));
        steps.add(SquareRootStep(
            explanation: "Step 3: Evaluate the powers.",
            mathLaTeX: halvedValues.join(' \\times ')
        ));
      }

      int result = halvedValues.fold(1, (a, b) => a * b);
      if (halvedValues.length > 1 || needsExpansion) {
        workings.add(_fmt(result));
        steps.add(SquareRootStep(
            explanation: "Step ${needsExpansion ? 4 : 3}: Multiply the numbers together to get your final answer.",
            mathLaTeX: _fmt(result)
        ));
      }

      return SquaresRootsResult(
          finalAnswerLaTeX: _fmt(result),
          workingsLaTeX: workings,
          steps: steps
      );
    }

    if (!useDivisibilityRules) {
      steps.add(SquareRootStep(
          explanation: "Step 1: Use the continuous division (LCM) method to find the prime factors of $n.",
          mathLaTeX: lcmTableLatex
      ));
      steps.add(SquareRootStep(
          explanation: "Now write out $n as a product of these prime factors.",
          mathLaTeX: "$n = ${factors.join(' \\times ')}"
      ));
    } else {
      steps.addAll(divisibilitySteps);
    }

    workings.add("\\sqrt{${factors.join(' \\times ')}}");

    // Group into identical pairs
    List<String> pairs = [];
    List<int> singles = [];
    counts.forEach((prime, count) {
      int pairsCount = count ~/ 2;
      for (int i = 0; i < pairsCount; i++) {
        pairs.add("($prime \\times $prime)");
        singles.add(prime);
      }
    });

    workings.add("\\sqrt{${pairs.join(' \\times ')}}");
    steps.add(SquareRootStep(
        explanation: "Group the identical prime factors into pairs.",
        mathLaTeX: "\\sqrt{${pairs.join(' \\times ')}}"
    ));

    workings.add(singles.join(' \\times '));
    steps.add(SquareRootStep(
        explanation: "To find the square root, take exactly one number from each pair and remove the square root symbol.",
        mathLaTeX: singles.join(' \\times ')
    ));

    int result = singles.fold(1, (a, b) => a * b);
    if (singles.length > 1) {
      workings.add(_fmt(result));
      steps.add(SquareRootStep(
          explanation: "Multiply the extracted numbers together to get your final answer.",
          mathLaTeX: _fmt(result)
      ));
    }

    return SquaresRootsResult(
        finalAnswerLaTeX: _fmt(result),
        workingsLaTeX: workings,
        steps: steps
    );
  }

  static SquaresRootsResult _solveFractionRoot(int num, int den, String method, {int? originalWhole, int? originalNum}) {
    List<String> workings = [];
    List<SquareRootStep> steps = [];

    // Process mixed fractions first
    if (originalWhole != null && originalNum != null) {
      String mixedStr = "$originalWhole \\frac{$originalNum}{$den}";
      workings.add("\\sqrt{$mixedStr}");
      steps.add(SquareRootStep(
          explanation: "First, convert the mixed fraction to an improper fraction. Multiply the whole number ($originalWhole) by the denominator ($den) and add the numerator ($originalNum).",
          mathLaTeX: "$mixedStr = \\frac{$num}{$den}"
      ));
    }

    workings.add("\\sqrt{\\frac{$num}{$den}}");
    if (originalWhole == null) {
      steps.add(SquareRootStep(
          explanation: "We need to find the square root of the fraction $num/$den.",
          mathLaTeX: "\\sqrt{\\frac{$num}{$den}}"
      ));
    }

    // 1. Simplify the fraction FIRST (Crucial for inputs like 8/18 or 50/2)
    int gcd = _gcd(num, den);
    int simpNum = num;
    int simpDen = den;

    if (gcd > 1) {
      simpNum = num ~/ gcd;
      simpDen = den ~/ gcd;

      String simplifiedStr = simpDen == 1 ? "$simpNum" : "\\frac{$simpNum}{$simpDen}";
      workings.add("\\sqrt{$simplifiedStr}");

      steps.add(SquareRootStep(
          explanation: "First, simplify the fraction by dividing the numerator and denominator by their Highest Common Factor ($gcd).",
          mathLaTeX: "\\sqrt{\\frac{$num}{$den}} = \\sqrt{$simplifiedStr}"
      ));

      // If it simplified to a whole number, redirect to the whole number solver
      if (simpDen == 1) {
        final wholeResult = _solveWholeNumberRoot(simpNum, method);
        if (!wholeResult.valid) return wholeResult;

        workings.addAll(wholeResult.workingsLaTeX.skip(1));
        steps.addAll(wholeResult.steps.skip(1));

        return SquaresRootsResult(
            finalAnswerLaTeX: wholeResult.finalAnswerLaTeX,
            workingsLaTeX: workings,
            steps: steps
        );
      }
    }

    workings.add("\\frac{\\sqrt{$simpNum}}{\\sqrt{$simpDen}}");
    steps.add(SquareRootStep(
        explanation: "Apply the fraction rule for square roots: split the root between the numerator and the denominator.",
        mathLaTeX: "\\sqrt{\\frac{$simpNum}{$simpDen}} = \\frac{\\sqrt{$simpNum}}{\\sqrt{$simpDen}}"
    ));

    // Solve numerator
    final numResult = _solveWholeNumberRoot(simpNum, method);
    if (!numResult.valid) {
      double root = math.sqrt(simpNum / simpDen);
      return SquaresRootsResult(valid: false, finalAnswerLaTeX: "", workingsLaTeX: [], steps: [], errorMessage: "The simplified fraction $simpNum/$simpDen is not a perfect square. Its square root is a decimal (approx ${_fmt(double.parse(root.toStringAsFixed(3)))}).");
    }

    // Solve denominator
    final denResult = _solveWholeNumberRoot(simpDen, method);
    if (!denResult.valid) {
      double root = math.sqrt(simpNum / simpDen);
      return SquaresRootsResult(valid: false, finalAnswerLaTeX: "", workingsLaTeX: [], steps: [], errorMessage: "The simplified fraction $simpNum/$simpDen is not a perfect square. Its square root is a decimal (approx ${_fmt(double.parse(root.toStringAsFixed(3)))}).");
    }

    // Inject the LCM tables into fraction workings visually
    try {
      String numTable = numResult.workingsLaTeX.firstWhere((w) => w.contains('\\begin{array}'));
      workings.add("\\text{Numerator } ($simpNum): \\quad $numTable");
    } catch (_) {}

    try {
      if (simpDen != 1) {
        String denTable = denResult.workingsLaTeX.firstWhere((w) => w.contains('\\begin{array}'));
        workings.add("\\text{Denominator } ($simpDen): \\quad $denTable");
      }
    } catch (_) {}

    steps.add(SquareRootStep(
      explanation: "Find the square root of the numerator ($simpNum):",
    ));
    steps.addAll(numResult.steps.skip(1)); // Skip redundant intro step

    steps.add(SquareRootStep(
      explanation: "Find the square root of the denominator ($simpDen):",
    ));
    steps.addAll(denResult.steps.skip(1)); // Skip redundant intro step

    String finalAnswer = "\\frac{${numResult.finalAnswerLaTeX}}{${denResult.finalAnswerLaTeX}}";

    // Try to simplify final fraction
    int nVal = int.parse(numResult.finalAnswerLaTeX);
    int dVal = int.parse(denResult.finalAnswerLaTeX);
    int finalGcd = _gcd(nVal, dVal);

    if (finalGcd > 1) {
      int simpN = nVal ~/ finalGcd;
      int simpD = dVal ~/ finalGcd;
      String simplified = simpD == 1 ? "$simpN" : "\\frac{$simpN}{$simpD}";
      workings.add(finalAnswer);
      workings.add(simplified);
      steps.add(SquareRootStep(
          explanation: "Combine the results to get the fraction, then simplify it by dividing both sides by their Highest Common Factor ($finalGcd).",
          mathLaTeX: "$finalAnswer = $simplified"
      ));
      finalAnswer = simplified;
    } else if (dVal == 1) {
      String simplified = "$nVal";
      workings.add(finalAnswer);
      workings.add(simplified);
      steps.add(SquareRootStep(
          explanation: "Combine the results. Since the denominator is 1, it simplifies to a whole number.",
          mathLaTeX: "$finalAnswer = $simplified"
      ));
      finalAnswer = simplified;
    } else {
      workings.add(finalAnswer);
      steps.add(SquareRootStep(
          explanation: "Combine the results to get the final fraction.",
          mathLaTeX: finalAnswer
      ));
    }

    return SquaresRootsResult(
        finalAnswerLaTeX: finalAnswer,
        workingsLaTeX: workings,
        steps: steps
    );
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  static void _addDivisibilityExplanation(int current, int d, List<SquareRootStep> steps) {
    String rule = "";
    if (d == 2) {
      String lastDigit = current.toString()[current.toString().length - 1];
      rule = "Because $current ends in $lastDigit (an even number), we apply the Divisibility Rule for 2 and divide by 2.";
    } else if (d == 3) {
      int sum = current.toString().split('').map(int.parse).reduce((a, b) => a + b);
      rule = "The sum of the digits of $current is $sum. Since $sum is divisible by 3, we apply the Rule for 3 and divide by 3.";
    } else if (d == 5) {
      String lastDigit = current.toString()[current.toString().length - 1];
      rule = "Because $current ends in $lastDigit, we apply the Divisibility Rule for 5 and divide by 5.";
    } else {
      rule = "We divide $current by the next smallest prime number, which is $d.";
    }

    steps.add(SquareRootStep(
        explanation: rule,
        mathLaTeX: "$current \\div $d = ${current ~/ d}"
    ));
  }

  /// Calculates the smallest value of n to make an expression a perfect square.
  static SquaresRootsResult solveFindN(String input) {
    try {
      // Clean input: "2^3 x 5^2 x 11 x n" -> remove 'x n', '* n', spaces
      String clean = input.toLowerCase().replaceAll(' ', '').replaceAll('xn', '').replaceAll('*n', '').replaceAll('=n', '');
      if (clean.endsWith('n')) clean = clean.substring(0, clean.length - 1); // strip trailing n
      if (clean.endsWith('x') || clean.endsWith('*')) clean = clean.substring(0, clean.length - 1);
      if (clean.endsWith('=')) clean = clean.substring(0, clean.length - 1);

      if (clean.isEmpty) throw FormatException();

      List<String> terms = clean.split(RegExp(r'[x\*]'));
      Map<int, int> primeCounts = {};

      List<String> workings = [];
      List<SquareRootStep> steps = [];

      // Format initial expression display safely
      List<String> rawTermsDisplay = [];
      for (String term in terms) {
        if (term.contains('^')) {
          final parts = term.split('^');
          rawTermsDisplay.add("${parts[0]}^{${parts[1]}}");
        } else {
          rawTermsDisplay.add(term);
        }
      }
      workings.add("${rawTermsDisplay.join(' \\times ')} \\times n");

      steps.add(SquareRootStep(
        explanation: "We need to find the smallest whole number 'n' that makes the given expression a perfect square.",
      ));

      // Identify and factorize composites to show step-by-step
      Map<int, List<int>> compositeFactors = {};
      for (String term in terms) {
        int val = term.contains('^') ? int.parse(term.split('^')[0]) : int.parse(term);
        List<int> factors = _getPrimeFactors(val);
        // If length > 1, it's a composite number or a power of a prime, we should show its factorization.
        if (factors.length > 1 && !compositeFactors.containsKey(val)) {
          compositeFactors[val] = factors;

          List<int> divs = [];
          List<int> quots = [val];
          int current = val;
          int d = 2;
          while (current > 1) {
            while (current % d == 0) {
              divs.add(d);
              current ~/= d;
              quots.add(current);
            }
            d++;
            if (d * d > current && current > 1) {
              divs.add(current);
              current ~/= current;
              quots.add(current);
              break;
            }
          }
          String tableLatex = "\\begin{array}{r|l}\n";
          for (int i = 0; i < divs.length; i++) {
            tableLatex += "${divs[i]} & ${quots[i]} \\\\\n\\hline\n";
          }
          tableLatex += " & ${quots.last} \n\\end{array}";

          workings.add("\\text{Factors of } $val: \\quad $tableLatex");
          steps.add(SquareRootStep(
              explanation: "Notice that $val is a composite number. Use the continuous division method to find its prime factors.",
              mathLaTeX: "$val = ${factors.join(' \\times ')}"
          ));
        }
      }

      // Parse each term and accumulate prime factors
      for (String term in terms) {
        if (term.contains('^')) {
          final parts = term.split('^');
          int base = int.parse(parts[0]);
          int exp = int.parse(parts[1]);
          List<int> baseFactors = _getPrimeFactors(base);
          for (int f in baseFactors) {
            primeCounts[f] = (primeCounts[f] ?? 0) + exp;
          }
        } else {
          int val = int.parse(term);
          List<int> factors = _getPrimeFactors(val);
          for (int f in factors) {
            primeCounts[f] = (primeCounts[f] ?? 0) + 1;
          }
        }
      }

      // Sort primes for neatness
      var sortedPrimes = primeCounts.keys.toList()..sort();

      // Build combined index form for workings
      List<String> indexFormTerms = [];
      for (var prime in sortedPrimes) {
        int count = primeCounts[prime]!;
        indexFormTerms.add(count == 1 ? "$prime" : "$prime^{$count}");
      }

      String combinedIndex = indexFormTerms.join(' \\times ');

      // Show combined index form step if we actually combined things
      if (terms.length > 1 || compositeFactors.isNotEmpty) {
        workings.add("$combinedIndex \\times n");
        steps.add(SquareRootStep(
            explanation: "Express the entire sequence as a single product of prime factors in index form.",
            mathLaTeX: combinedIndex
        ));
      }

      steps.add(SquareRootStep(
        explanation: "The Golden Rule: For any number to be a perfect square, EVERY prime factor must have an EVEN power (like 2, 4, or 6).",
      ));

      List<int> missingPrimes = [];
      List<String> oddTerms = [];

      for (var prime in sortedPrimes) {
        int count = primeCounts[prime]!;
        if (count % 2 != 0) {
          missingPrimes.add(prime);
          oddTerms.add(count == 1 ? "$prime" : "$prime^{$count}");
        }
      }

      if (missingPrimes.isEmpty) {
        workings.add("n = 1");
        steps.add(SquareRootStep(
            explanation: "Since all prime factors already have EVEN powers, the expression is ALREADY a perfect square! So, n = 1.",
            mathLaTeX: "n = 1"
        ));
        return SquaresRootsResult(
            finalAnswerLaTeX: "1",
            workingsLaTeX: workings,
            steps: steps
        );
      }

      steps.add(SquareRootStep(
        explanation: "Identify the prime factors that currently have an ODD power. Here, these are: ${oddTerms.join(' and ')}.",
      ));

      steps.add(SquareRootStep(
        explanation: "To make these powers even, we must multiply the expression by one more of each of these primes.",
      ));

      workings.add("n = ${missingPrimes.join(' \\times ')}");
      steps.add(SquareRootStep(
          explanation: "Therefore, 'n' is the product of these missing primes.",
          mathLaTeX: "n = ${missingPrimes.join(' \\times ')}"
      ));

      int nValue = missingPrimes.fold(1, (a, b) => a * b);
      if (missingPrimes.length > 1) {
        workings.add("n = $nValue");
        steps.add(SquareRootStep(
            explanation: "Multiply them together to get the smallest value of n.",
            mathLaTeX: "n = $nValue"
        ));
      }

      return SquaresRootsResult(
          finalAnswerLaTeX: "$nValue",
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return SquaresRootsResult(
        valid: false, finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
        errorMessage: "Invalid format. Use numbers or index form (e.g. 2^3 x 5 x n or 24).",
      );
    }
  }

  static List<int> _getPrimeFactors(int n) {
    List<int> factors = [];
    int d = 2;
    while (n > 1) {
      while (n % d == 0) {
        factors.add(d);
        n ~/= d;
      }
      d++;
      if (d * d > n && n > 1) {
        factors.add(n);
        break;
      }
    }
    return factors;
  }
}