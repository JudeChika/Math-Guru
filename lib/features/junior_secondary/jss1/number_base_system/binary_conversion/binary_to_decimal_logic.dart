import 'binary_conversion_models.dart';

class BinaryToDecimalLogic {
  static List<BinaryToDecimalResult> convert(List<String> inputs) {
    return inputs.map((binary) => _convertSingle(binary)).toList();
  }

  static BinaryToDecimalResult _convertSingle(String binaryStr) {
    final cleaned = binaryStr.trim();
    if (!RegExp(r'^[01]+$').hasMatch(cleaned)) {
      return BinaryToDecimalResult(
        binary: cleaned,
        decimal: 0,
        expandedSteps: ["Invalid binary number: $cleaned"],
        stepByStep: [],
      );
    }

    final digits = cleaned.split('').map(int.parse).toList();
    final len = digits.length;
    List<String> expandedSteps = [];
    List<String> stepByStep = [];

    // Expanded Notation: (1×2⁴)+(1×2³)+(0×2²)+(1×2¹)+(1×2⁰)
    List<String> terms = [];
    List<String> evals = [];
    int sum = 0;
    for (int i = 0; i < len; i++) {
      final power = len - 1 - i;
      final digit = digits[i];
      final value = digit * (1 << power);
      terms.add('${digit}×2${_superscript(power)}');
      evals.add('$value');
      sum += value;
    }
    expandedSteps.add('${_withBaseSub(cleaned, 2)} = (${terms.join(') + (')})');
    expandedSteps.add('= ${evals.join(' + ')}');
    expandedSteps.add('= $sum');

    // Step-by-step
    sum = 0;
    for (int i = 0; i < len; i++) {
      final power = len - 1 - i;
      final digit = digits[i];
      final value = digit * (1 << power);
      stepByStep.add(
          'Step ${i + 1}: ${digit} × 2${_superscript(power)} = $value'
              '\nSubtotal: $sum + $value = ${sum + value}'
      );
      sum += value;
    }
    stepByStep.add('Final Answer:\n${_withBaseSub(cleaned, 2)} = $sum${_subscript(10)}');

    return BinaryToDecimalResult(
      binary: cleaned,
      decimal: sum,
      expandedSteps: expandedSteps,
      stepByStep: stepByStep,
    );
  }

  static String _superscript(int n) {
    const sups = [
      "\u2070", "\u00b9", "\u00b2", "\u00b3", "\u2074", "\u2075",
      "\u2076", "\u2077", "\u2078", "\u2079"
    ];
    if (n == 0) return sups[0];
    return n.toString().split('').map((c) => sups[int.parse(c)]).join();
  }

  static String _subscript(int n) {
    const subs = [
      "\u2080", "\u2081", "\u2082", "\u2083", "\u2084", "\u2085",
      "\u2086", "\u2087", "\u2088", "\u2089"
    ];
    return n.toString().split('').map((c) => subs[int.parse(c)]).join();
  }

  static String _withBaseSub(String val, int base) => '$val${_subscript(base)}';
}