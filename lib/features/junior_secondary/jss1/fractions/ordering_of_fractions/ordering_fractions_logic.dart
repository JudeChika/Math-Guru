import 'ordering_fractions_models.dart';

class OrderingFractionsLogic {
  static int gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static int lcm2(int a, int b) => (a * b) ~/ gcd(a, b);

  static int findLcmList(List<int> nums) {
    int lcm = nums[0];
    for (int n in nums.skip(1)) {
      lcm = lcm2(lcm, n);
    }
    return lcm;
  }

  static List<WorkingStep> calculateWorkingSteps(List<FractionInput> fractions) {
    final numerators = fractions.map((f) => f.numerator!).toList();
    final denominators = fractions.map((f) => f.denominator!).toList();
    final lcm = findLcmList(denominators);
    final steps = <WorkingStep>[];
    for (int i = 0; i < fractions.length; i++) {
      final factor = lcm ~/ denominators[i];
      final value = numerators[i] * factor;
      steps.add(WorkingStep(
        index: i,
        numerator: numerators[i],
        denominator: denominators[i],
        lcm: lcm,
        factor: factor,
        value: value,
      ));
    }
    return steps;
  }

  static List<FractionWithValue> orderFractions(
      List<WorkingStep> steps, {
        required bool ascending,
      }) {
    final withValues = [
      for (final step in steps)
        FractionWithValue(
          numerator: step.numerator,
          denominator: step.denominator,
          value: step.value,
        )
    ];
    withValues.sort((a, b) =>
    ascending ? a.value.compareTo(b.value) : b.value.compareTo(a.value));
    return withValues;
  }
}