import 'lcm_table_row.dart';
import 'lcm_step_explanation.dart';

class LCMCalculatorResult {
  final List<int> inputNumbers;
  final List<LCMTableRow> tableRows;
  final int lcm;
  final List<LCMStepExplanation> steps;
  final bool valid;
  final String? error;

  LCMCalculatorResult({
    required this.inputNumbers,
    required this.tableRows,
    required this.lcm,
    required this.steps,
    required this.valid,
    this.error,
  });
}

class LCMCalculatorLogic {
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
        steps: [
          LCMStepExplanation(
            description: "Please enter at least two positive integers, separated by spaces or commas.",
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
      description: "Step $stepCount: Start with the input numbers: ${working.join(', ')}",
      state: List.from(working),
    ));

    while (working.any((n) => n > 1)) {
      final divisor = _findSmallestPrimeDivisor(working);
      if (divisor == null) break; // All numbers are 1.
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
    // Add the last row (all 1s)
    tableRows.add(LCMTableRow(divisor: 1, numbers: List.from(working)));

    final lcm = divisors.fold(1, (prev, d) => prev * d);

    steps.add(LCMStepExplanation(
      description: "Final Step: Multiply all divisors used: ${divisors.join(' × ')} = $lcm",
      state: List.from(working),
    ));

    return LCMCalculatorResult(
      inputNumbers: inputNumbers,
      tableRows: tableRows,
      lcm: lcm,
      steps: steps,
      valid: true,
    );
  }
}