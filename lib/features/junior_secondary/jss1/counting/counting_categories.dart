class CountingCategory {
  final String label;
  final int divisor; // E.g. 1_000_000_000_000 for Trillion
  final int digits; // Number of digits in this category group (e.g. 3 for most)

  const CountingCategory({
    required this.label,
    required this.divisor,
    required this.digits,
  });
}

// Ordered from largest to smallest
const List<CountingCategory> countingCategories = [
  CountingCategory(label: 'Trillion', divisor: 1000000000000, digits: 3),
  CountingCategory(label: 'Hundred Billion', divisor: 100000000000, digits: 1),
  CountingCategory(label: 'Ten Billion', divisor: 10000000000, digits: 1),
  CountingCategory(label: 'Billion', divisor: 1000000000, digits: 1),
  CountingCategory(label: 'Hundred Million', divisor: 100000000, digits: 1),
  CountingCategory(label: 'Ten Million', divisor: 10000000, digits: 1),
  CountingCategory(label: 'Million', divisor: 1000000, digits: 1),
  CountingCategory(label: 'Hundred Thousand', divisor: 100000, digits: 1),
  CountingCategory(label: 'Ten Thousand', divisor: 10000, digits: 1),
  CountingCategory(label: 'Thousand', divisor: 1000, digits: 1),
  CountingCategory(label: 'Hundred', divisor: 100, digits: 1),
  CountingCategory(label: 'Ten', divisor: 10, digits: 1),
  CountingCategory(label: 'Unit', divisor: 1, digits: 1),
];