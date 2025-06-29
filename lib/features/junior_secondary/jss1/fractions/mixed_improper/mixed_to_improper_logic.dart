import 'models.dart';

class MixedToImproperLogic {
  static MixedToImproperResult convert(MixedNumber mixed) {
    if (mixed.denominator == 0) {
      return MixedToImproperResult(
        input: mixed,
        output: ImproperFraction(numerator: 0, denominator: 1),
        valid: false,
        error: "Denominator cannot be zero.",
      );
    }
    int improperNumerator = mixed.whole * mixed.denominator + mixed.numerator;
    return MixedToImproperResult(
      input: mixed,
      output: ImproperFraction(
          numerator: improperNumerator, denominator: mixed.denominator),
      valid: true,
    );
  }
}