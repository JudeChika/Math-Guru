class MixedNumber {
  final int whole;
  final int numerator;
  final int denominator;

  MixedNumber({required this.whole, required this.numerator, required this.denominator});
}

class ImproperFraction {
  final int numerator;
  final int denominator;

  ImproperFraction({required this.numerator, required this.denominator});
}

class MixedToImproperResult {
  final MixedNumber input;
  final ImproperFraction output;
  final List<String> workings;
  final List<String> steps;
  final bool valid;
  final String? error;

  MixedToImproperResult({
    required this.input,
    required this.output,
    required this.workings,
    required this.steps,
    required this.valid,
    this.error,
  });
}

class ImproperToMixedResult {
  final ImproperFraction input;
  final MixedNumber output;
  final List<String> workingsDecompose;
  final List<String> stepsDecomposeMethod;
  final List<String> workingsLongDivision;
  final List<String> stepsLongDivision;
  final bool valid;
  final String? error;

  ImproperToMixedResult({
    required this.input,
    required this.output,
    required this.workingsDecompose,
    required this.stepsDecomposeMethod,
    required this.workingsLongDivision,
    required this.stepsLongDivision,
    required this.valid,
    this.error,
  });
}