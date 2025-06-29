import 'models.dart';

class MixedToImproperLogic {
  static MixedToImproperResult convert(MixedNumber mixed) {
    if (mixed.denominator == 0) {
      return MixedToImproperResult(
        input: mixed,
        output: ImproperFraction(numerator: 0, denominator: 1),
        workings: [],
        steps: [],
        valid: false,
        error: "Denominator cannot be zero.",
      );
    }
    int improperNumerator = mixed.whole * mixed.denominator + mixed.numerator;
    List<String> workings = [
      "${mixed.whole} ${_formatFraction(mixed.numerator, mixed.denominator)} = "
          "(${mixed.whole} × ${mixed.denominator} + ${mixed.numerator}) / ${mixed.denominator}",
      "= (${mixed.whole * mixed.denominator} + ${mixed.numerator}) / ${mixed.denominator}",
      "= $improperNumerator / ${mixed.denominator}",
    ];
    List<String> steps = [
      "Step 1: Multiply the whole number by the denominator: ${mixed.whole} × ${mixed.denominator} = ${mixed.whole * mixed.denominator}.",
      "Step 2: Add the numerator: ${mixed.whole * mixed.denominator} + ${mixed.numerator} = $improperNumerator.",
      "Step 3: Place the result over the original denominator: $improperNumerator/${mixed.denominator}.",
      "Final Solution: ${_formatMixed(mixed)} = ${_formatFraction(improperNumerator, mixed.denominator)}"
    ];
    return MixedToImproperResult(
      input: mixed,
      output: ImproperFraction(numerator: improperNumerator, denominator: mixed.denominator),
      workings: workings,
      steps: steps,
      valid: true,
    );
  }

  static String _formatFraction(int num, int denom) => "$num⁄$denom";
  static String _formatMixed(MixedNumber m) => "${m.whole} ${_formatFraction(m.numerator, m.denominator)}";
}