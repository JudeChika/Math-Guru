import 'models.dart';

class ImproperToMixedLogic {
  static ImproperToMixedResult convert(ImproperFraction improper) {
    if (improper.denominator == 0) {
      return ImproperToMixedResult(
        input: improper,
        output: MixedNumber(whole: 0, numerator: 0, denominator: 1),
        valid: false,
        error: "Denominator cannot be zero.",
      );
    }
    int whole = improper.numerator ~/ improper.denominator;
    int remainder = improper.numerator % improper.denominator;
    return ImproperToMixedResult(
      input: improper,
      output: MixedNumber(
        whole: whole,
        numerator: remainder,
        denominator: improper.denominator,
      ),
      valid: true,
    );
  }
}