import 'binary_conversion_models.dart';

class DecimalToBinaryLogic {
  static List<DecimalToBinaryResult> convert(List<String> inputs, {required bool useSumOfPowers}) {
    return inputs.map((s) {
      final n = int.tryParse(s.trim());
      if (n == null) {
        return DecimalToBinaryResult(
          decimal: 0,
          binary: '',
          expandedSteps: ['Invalid decimal number: $s'],
          stepByStep: [],
          method: useSumOfPowers ? 'SumOfPowers' : 'Division',
        );
      }
      return useSumOfPowers ? _sumOfPowers(n) : _division(n);
    }).toList();
  }

  // Division-by-2 method
  static DecimalToBinaryResult _division(int n) {
    if (n == 0) {
      return DecimalToBinaryResult(
        decimal: 0,
        binary: '0',
        expandedSteps: ['0${_subscript(10)} = 0${_subscript(2)}'],
        stepByStep: ['0 divided by 2 is 0, remainder 0'],
        method: 'Division',
      );
    }

    List<int> remainders = [];
    List<String> steps = [];
    int value = n;
    while (value > 0) {
      int quotient = value ~/ 2;
      int rem = value % 2;
      steps.add('Divide $value by 2: Quotient = $quotient, Remainder = $rem');
      remainders.add(rem);
      value = quotient;
    }
    String binary = remainders.reversed.join();
    List<String> expandedSteps = [
      '${_withBaseSub(n.toString(), 10)} = ${_withBaseSub(binary, 2)}'
    ];
    expandedSteps.add('Using division by 2 method:');
    expandedSteps.addAll(steps);
    expandedSteps.add('Binary digits (from last remainder to first): ${remainders.reversed.join(' ')}');
    expandedSteps.add('Final Answer:\n${_withBaseSub(n.toString(), 10)} = ${_withBaseSub(binary, 2)}');
    return DecimalToBinaryResult(
      decimal: n,
      binary: binary,
      expandedSteps: expandedSteps,
      stepByStep: expandedSteps.sublist(1), // All steps except the first summary
      method: 'Division',
    );
  }

  // Sum of powers of 2 method
  static DecimalToBinaryResult _sumOfPowers(int n) {
    if (n == 0) {
      return DecimalToBinaryResult(
        decimal: 0,
        binary: '0',
        expandedSteps: ['0${_subscript(10)} = 0${_subscript(2)}'],
        stepByStep: ['0 can only be represented as 0 in base two.'],
        method: 'SumOfPowers',
      );
    }

    int value = n;
    List<int> powers = [];
    List<String> steps = [];
    int maxPower = 0;
    while ((1 << maxPower) <= value) {
      maxPower++;
    }
    maxPower--;

    int tempValue = value;
    for (int p = maxPower; p >= 0; p--) {
      int pow2 = 1 << p;
      if (tempValue >= pow2) {
        powers.add(p);
        steps.add('Subtract ${pow2} (2${_superscript(p)}) from $tempValue: ${tempValue} - ${pow2} = ${tempValue - pow2} (Mark 1 in position for 2${_superscript(p)})');
        tempValue -= pow2;
      } else {
        steps.add('2${_superscript(p)} = $pow2 is greater than $tempValue (Mark 0 in this position)');
      }
    }

    String binary = List.generate(maxPower + 1, (i) {
      int p = maxPower - i;
      return powers.contains(p) ? '1' : '0';
    }).join();

    List<String> expandedSteps = [];
    // Expanded notation line 1
    expandedSteps.add('${_withBaseSub(n.toString(), 10)} = ' +
        powers.map((p) => '2${_superscript(p)}').join(' + '));
    // Expanded notation line 2 (values)
    expandedSteps.add('= ' + powers.map((p) => '${1 << p}').join(' + '));
    // Expanded notation line 3 (binary)
    expandedSteps.add('= ${_withBaseSub(binary, 2)}');
    expandedSteps.addAll(steps);
    expandedSteps.add('Final Answer:\n${_withBaseSub(n.toString(), 10)} = ${_withBaseSub(binary, 2)}');

    return DecimalToBinaryResult(
      decimal: n,
      binary: binary,
      expandedSteps: expandedSteps,
      stepByStep: steps,
      method: 'SumOfPowers',
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