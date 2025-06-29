class MixedNumber {
  final int whole;
  final int numerator;
  final int denominator;

  MixedNumber({
    required this.whole,
    required this.numerator,
    required this.denominator,
  });
}

class ImproperFraction {
  final int numerator;
  final int denominator;

  ImproperFraction({
    required this.numerator,
    required this.denominator,
  });
}

class MixedToImproperResult {
  final MixedNumber input;
  final ImproperFraction output;
  final bool valid;
  final String? error;

  MixedToImproperResult({
    required this.input,
    required this.output,
    required this.valid,
    this.error,
  });
}

class ImproperToMixedResult {
  final ImproperFraction input;
  final MixedNumber output;
  final bool valid;
  final String? error;

  ImproperToMixedResult({
    required this.input,
    required this.output,
    required this.valid,
    this.error,
  });
}