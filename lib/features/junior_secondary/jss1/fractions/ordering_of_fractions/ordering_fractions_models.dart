class FractionInput {
  int? numerator;
  int? denominator;
  FractionInput({this.numerator, this.denominator});
}

class WorkingStep {
  final int index;
  final int numerator;
  final int denominator;
  final int lcm;
  final int factor;
  final int value;
  WorkingStep({
    required this.index,
    required this.numerator,
    required this.denominator,
    required this.lcm,
    required this.factor,
    required this.value,
  });
}

class FractionWithValue {
  final int numerator;
  final int denominator;
  final int value;
  FractionWithValue({
    required this.numerator,
    required this.denominator,
    required this.value,
  });
}