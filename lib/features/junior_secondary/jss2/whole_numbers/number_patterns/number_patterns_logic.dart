import 'dart:math' as math;
import 'number_patterns_models.dart';

class NumberPatternsLogic {

  /// Helper to nicely format doubles (removes trailing .0)
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return double.parse(v.toStringAsFixed(4)).toString();
  }

  /// Parses an individual term, supporting Index Forms (e.g., "2^3" -> 8)
  static double _parseTerm(String term) {
    term = term.replaceAll(' ', '');
    if (term.contains('^')) {
      final parts = term.split('^');
      if (parts.length == 2) {
        final base = double.parse(parts[0]);
        final exp = double.parse(parts[1]);
        return math.pow(base, exp).toDouble();
      }
    }
    return double.parse(term);
  }

  /// Calculates multiples of a specific number within a user-defined range.
  static MultiplesResult calculateMultiples(String rangeInput, String multipleInput) {
    try {
      // Parse Range
      final cleanRange = rangeInput.replaceAll(' ', '');
      int start = 0;
      int end = 0;

      if (cleanRange.contains('-')) {
        final parts = cleanRange.split('-');
        start = int.parse(parts[0]);
        end = int.parse(parts[1]);
      } else {
        return MultiplesResult(start: 0, end: 0, multipleOf: 0, multiples: [], steps: [], valid: false, errorMessage: "Enter range as 'start-end' (e.g. 10-50).");
      }

      if (start > end) {
        final temp = start;
        start = end;
        end = temp;
      }

      if (end - start > 1000) {
        return MultiplesResult(start: 0, end: 0, multipleOf: 0, multiples: [], steps: [], valid: false, errorMessage: "Range too large. Max range is 1000 numbers.");
      }

      // Parse Multiple
      final multipleOf = int.parse(multipleInput.trim());
      if (multipleOf <= 0) {
        return MultiplesResult(start: 0, end: 0, multipleOf: 0, multiples: [], steps: [], valid: false, errorMessage: "Multiple must be greater than 0.");
      }

      List<int> multiples = [];
      for (int i = start; i <= end; i++) {
        if (i % multipleOf == 0) {
          multiples.add(i);
        }
      }

      List<PatternSolutionStep> steps = [
        PatternSolutionStep(
          description: "Step 1: Identify the range boundary.",
          workingLaTeX: "\\text{Range: } $start \\text{ to } $end",
        ),
        PatternSolutionStep(
          description: "Step 2: Find the first number \$\\ge\$ $start that divides perfectly by $multipleOf.",
          workingLaTeX: multiples.isNotEmpty ? "\\text{First multiple } = ${multiples.first}" : "\\text{No multiples found.}",
        ),
      ];

      if (multiples.isNotEmpty) {
        steps.add(PatternSolutionStep(
          description: "Step 3: Keep adding $multipleOf until you exceed the end of the range ($end).",
          workingLaTeX: multiples.join(', '),
          isFinalAnswer: true,
        ));
      }

      return MultiplesResult(
          start: start,
          end: end,
          multipleOf: multipleOf,
          multiples: multiples,
          steps: steps
      );

    } catch (e) {
      return MultiplesResult(start: 0, end: 0, multipleOf: 0, multiples: [], steps: [], valid: false, errorMessage: "Invalid input. Check your numbers.");
    }
  }

  /// Analyzes a sequence, determines its pattern, and finds the next N terms.
  static SequenceResult calculateNextTerms(String sequenceInput, String nInput) {
    try {
      final n = int.parse(nInput.trim());
      if (n <= 0) throw const FormatException();

      final rawTerms = sequenceInput.split(RegExp(r'[, ]+')).where((s) => s.isNotEmpty).toList();
      if (rawTerms.length < 3) {
        return SequenceResult(originalSequence: [], patternType: "", commonDifferenceOrRatio: 0, nextTermsRequested: n, nextTerms: [], steps: [], valid: false, errorMessage: "Please enter at least 3 terms to establish a pattern.");
      }

      List<double> seq = rawTerms.map((t) => _parseTerm(t)).toList();
      List<PatternSolutionStep> steps = [];

      steps.add(PatternSolutionStep(
        description: "Step 1: Evaluate the given sequence.",
        workingLaTeX: seq.map((e) => _fmt(e)).join(', '),
      ));

      // Helper to check if elements in a list are identical (constant)
      bool isConstant(List<double> list) {
        if (list.isEmpty) return true;
        double first = list.first;
        for (var val in list) {
          if ((val - first).abs() > 1e-9) return false;
        }
        return true;
      }

      // Find the first differences between terms
      List<double> diffs = [];
      for (int i = 1; i < seq.length; i++) {
        diffs.add(seq[i] - seq[i-1]);
      }

      // Test 1: Arithmetic Pattern (Constant Difference)
      if (isConstant(diffs)) {
        double diff = diffs.first;

        steps.add(PatternSolutionStep(
          description: "Step 2: Find the difference between consecutive terms.",
          workingLaTeX: "d = ${_fmt(seq[1])} - ${_fmt(seq[0])} = ${_fmt(diff)}",
        ));
        steps.add(PatternSolutionStep(
          description: "Conclusion: The difference is constant. It is an Arithmetic pattern.",
        ));

        List<double> nextTerms = [];
        double current = seq.last;
        for (int i = 0; i < n; i++) {
          current += diff;
          nextTerms.add(current);
        }

        steps.add(PatternSolutionStep(
          description: "Step 3: Keep adding $diff to find the next $n terms.",
          workingLaTeX: nextTerms.map((e) => _fmt(e)).join(', '),
          isFinalAnswer: true,
        ));

        return SequenceResult(originalSequence: seq, patternType: "Arithmetic (Constant Difference)", commonDifferenceOrRatio: diff, nextTermsRequested: n, nextTerms: nextTerms, steps: steps);
      }

      // Test 2: Geometric Pattern (Constant Ratio)
      if (!seq.contains(0)) {
        List<double> ratios = [];
        for (int i = 1; i < seq.length; i++) {
          ratios.add(seq[i] / seq[i-1]);
        }

        if (isConstant(ratios)) {
          double ratio = ratios.first;

          steps.add(PatternSolutionStep(
            description: "Step 2: Find the ratio between consecutive terms.",
            workingLaTeX: "r = ${_fmt(seq[1])} \\div ${_fmt(seq[0])} = ${_fmt(ratio)}",
          ));
          steps.add(PatternSolutionStep(
            description: "Conclusion: The ratio is constant. It is a Geometric pattern.",
          ));

          List<double> nextTerms = [];
          double current = seq.last;
          for (int i = 0; i < n; i++) {
            current *= ratio;
            nextTerms.add(current);
          }

          steps.add(PatternSolutionStep(
            description: "Step 3: Keep multiplying by $ratio to find the next $n terms.",
            workingLaTeX: nextTerms.map((e) => _fmt(e)).join(', '),
            isFinalAnswer: true,
          ));

          return SequenceResult(originalSequence: seq, patternType: "Geometric (Constant Ratio)", commonDifferenceOrRatio: ratio, nextTermsRequested: n, nextTerms: nextTerms, steps: steps);
        }
      }

      // Test 3: Changing Difference (Quadratic Sequence) e.g., 1, 2, 4, 7, 11
      List<double> secondDiffs = [];
      for (int i = 1; i < diffs.length; i++) {
        secondDiffs.add(diffs[i] - diffs[i-1]);
      }

      if (diffs.length >= 2 && isConstant(secondDiffs)) {
        double diffOfDiff = secondDiffs.first;

        steps.add(PatternSolutionStep(
          description: "Step 2: Find the differences between consecutive terms.",
          workingLaTeX: diffs.map((e) => "+${_fmt(e)}").join(', '),
        ));
        steps.add(PatternSolutionStep(
          description: "Step 3: Notice that the differences themselves form a pattern! They increase by exactly ${_fmt(diffOfDiff)} each time.",
        ));

        List<double> nextTerms = [];
        double currentTerm = seq.last;
        double currentDiff = diffs.last;

        for (int i = 0; i < n; i++) {
          currentDiff += diffOfDiff;
          currentTerm += currentDiff;
          nextTerms.add(currentTerm);
        }

        steps.add(PatternSolutionStep(
          description: "Step 4: Continue the pattern of adding the next increasing difference to find the next $n terms.",
          workingLaTeX: nextTerms.map((e) => _fmt(e)).join(', '),
          isFinalAnswer: true,
        ));

        return SequenceResult(originalSequence: seq, patternType: "Changing Difference", commonDifferenceOrRatio: diffOfDiff, nextTermsRequested: n, nextTerms: nextTerms, steps: steps);
      }

      // Test 4: Fibonacci-like Sequence (Sum of previous two terms)
      bool isFibo = true;
      for (int i = 2; i < seq.length; i++) {
        if ((seq[i] - (seq[i-1] + seq[i-2])).abs() > 1e-9) {
          isFibo = false;
          break;
        }
      }

      if (seq.length >= 3 && isFibo) {
        steps.add(PatternSolutionStep(
          description: "Step 2: Check the relationship between neighboring terms.",
          workingLaTeX: "${_fmt(seq[0])} + ${_fmt(seq[1])} = ${_fmt(seq[2])}",
        ));
        steps.add(PatternSolutionStep(
          description: "Conclusion: Each number is the sum of the two numbers right before it. This is known as a Fibonacci-style sequence!",
        ));

        List<double> nextTerms = [];
        double n1 = seq[seq.length - 2];
        double n2 = seq.last;

        for (int i = 0; i < n; i++) {
          double next = n1 + n2;
          nextTerms.add(next);
          n1 = n2;
          n2 = next;
        }

        steps.add(PatternSolutionStep(
          description: "Step 3: Keep adding the last two numbers together to find the next $n terms.",
          workingLaTeX: nextTerms.map((e) => _fmt(e)).join(', '),
          isFinalAnswer: true,
        ));

        return SequenceResult(originalSequence: seq, patternType: "Fibonacci-Style", commonDifferenceOrRatio: 0, nextTermsRequested: n, nextTerms: nextTerms, steps: steps);
      }

      // Test 5: Constant Third Difference (Cubic Sequences e.g., 1, 8, 27, 64)
      List<double> thirdDiffs = [];
      for (int i = 1; i < secondDiffs.length; i++) {
        thirdDiffs.add(secondDiffs[i] - secondDiffs[i-1]);
      }

      if (secondDiffs.length >= 2 && isConstant(thirdDiffs)) {
        double diffOfDiffOfDiff = thirdDiffs.first;

        steps.add(PatternSolutionStep(
          description: "Step 2: Find the differences between consecutive terms.",
          workingLaTeX: diffs.map((e) => "+${_fmt(e)}").join(', '),
        ));
        steps.add(PatternSolutionStep(
          description: "Step 3: Find the second differences (the differences of the differences).",
          workingLaTeX: secondDiffs.map((e) => "+${_fmt(e)}").join(', '),
        ));
        steps.add(PatternSolutionStep(
          description: "Step 4: Notice that the third level of differences is constant! They increase by exactly ${_fmt(diffOfDiffOfDiff)} each time.",
        ));

        List<double> nextTerms = [];
        double currentTerm = seq.last;
        double currentDiff = diffs.last;
        double currentSecondDiff = secondDiffs.last;

        for (int i = 0; i < n; i++) {
          currentSecondDiff += diffOfDiffOfDiff;
          currentDiff += currentSecondDiff;
          currentTerm += currentDiff;
          nextTerms.add(currentTerm);
        }

        steps.add(PatternSolutionStep(
          description: "Step 5: Continue this multi-level pattern to find the next $n terms.",
          workingLaTeX: nextTerms.map((e) => _fmt(e)).join(', '),
          isFinalAnswer: true,
        ));

        return SequenceResult(originalSequence: seq, patternType: "Cubic Sequence", commonDifferenceOrRatio: diffOfDiffOfDiff, nextTermsRequested: n, nextTerms: nextTerms, steps: steps);
      }

      // Unknown
      return SequenceResult(originalSequence: seq, patternType: "Unknown", commonDifferenceOrRatio: 0, nextTermsRequested: n, nextTerms: [], steps: [], valid: false, errorMessage: "The sequence pattern is not recognized as a standard mathematical sequence.");

    } catch (e) {
      return SequenceResult(originalSequence: [], patternType: "", commonDifferenceOrRatio: 0, nextTermsRequested: 0, nextTerms: [], steps: [], valid: false, errorMessage: "Invalid input. Use numbers (e.g. 2, 4, 6) and a whole number for next terms.");
    }
  }

  /// Generates Pascal's Triangle up to a requested number of rows.
  static PascalResult generatePascal(String rowsInput) {
    try {
      final n = int.parse(rowsInput.trim());
      if (n <= 0 || n > 20) {
        return PascalResult(numberOfRows: 0, triangleRows: [], steps: [], valid: false, errorMessage: "Please enter a valid number of rows (1 to 20).");
      }

      List<List<int>> triangle = [];
      for (int i = 0; i < n; i++) {
        List<int> row = List.filled(i + 1, 1);
        for (int j = 1; j < i; j++) {
          row[j] = triangle[i - 1][j - 1] + triangle[i - 1][j];
        }
        triangle.add(row);
      }

      List<PatternSolutionStep> steps = [];

      steps.add(PatternSolutionStep(
        description: "Step 1: The Top. Pascal's Triangle always begins with a single 1 at the very top (Row 1).",
      ));

      if (n >= 2) {
        steps.add(PatternSolutionStep(
          description: "Step 2: The Edges. Notice that the outside edges (the start and end of every row) are always the number 1.",
        ));
      }

      if (n >= 3) {
        steps.add(PatternSolutionStep(
          description: "Step 3: The Golden Rule! To find any number on the inside of the triangle, you simply add the two numbers sitting directly above it (left and right).",
        ));
        steps.add(PatternSolutionStep(
          description: "Let's look at Row 3: The middle number is 2. Why? Because the two numbers directly above it in Row 2 are 1 and 1.",
          workingLaTeX: "1 + 1 = 2",
        ));
      }

      if (n >= 4) {
        steps.add(PatternSolutionStep(
          description: "Let's check Row 4: The inside numbers are 3 and 3. We get them by adding the numbers straight above them in Row 3!",
          workingLaTeX: "1 + 2 = 3 \\quad \\text{and} \\quad 2 + 1 = 3",
        ));
      }

      if (n >= 5) {
        steps.add(PatternSolutionStep(
          description: "For Row 5, we follow the exact same pattern! Add the pairs from Row 4:",
          workingLaTeX: "1 + 3 = 4, \\quad 3 + 3 = 6, \\quad 3 + 1 = 4",
        ));
      }

      steps.add(PatternSolutionStep(
        description: "We continue this pattern of adding the two numbers above for as many rows as we need! Here is your triangle with \$$n\$ rows.",
        isFinalAnswer: true,
      ));

      return PascalResult(numberOfRows: n, triangleRows: triangle, steps: steps);
    } catch (e) {
      return PascalResult(numberOfRows: 0, triangleRows: [], steps: [], valid: false, errorMessage: "Invalid input. Please enter a whole number.");
    }
  }
}