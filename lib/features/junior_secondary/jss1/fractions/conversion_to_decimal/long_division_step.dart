class LongDivisionStep {
  final int currentDividend;
  final int divisor;
  final int quotientDigit;
  final int product;
  final int remainder;
  final int position; // 0: before decimal point, >=1: n-th decimal digit

  LongDivisionStep({
    required this.currentDividend,
    required this.divisor,
    required this.quotientDigit,
    required this.product,
    required this.remainder,
    required this.position,
  });
}