class NumberLineIntegerLogic {
  static NumberLineSolution compute(int a, int b, String op) {
    final result = op == '+' ? a + b : a - b;

    final explanations = <String>[
      "Start at 0 on the number line.",
      "Move from 0 to $a to get your first number.",
      if (op == '+')
        "Since you are adding, move $b steps to the right from $a."
      else
        "Since you are subtracting, move $b steps to the left from $a.",
      "You land on $result. That is your final answer.",
    ];

    return NumberLineSolution(result: result, explanations: explanations);
  }
}

class NumberLineSolution {
  final int result;
  final List<String> explanations;

  NumberLineSolution({required this.result, required this.explanations});
}
