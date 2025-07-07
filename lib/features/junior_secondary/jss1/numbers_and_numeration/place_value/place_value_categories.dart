class PlaceValueCategory {
  final String label;
  final num value; // Now num to support decimals

  const PlaceValueCategory({required this.label, required this.value});
}

// Main integer categories (left of decimal point)
const List<PlaceValueCategory> placeValueIntegerCategories = [
  PlaceValueCategory(label: 'Trillion', value: 1000000000000),
  PlaceValueCategory(label: 'Hundred Billion', value: 100000000000),
  PlaceValueCategory(label: 'Ten Billion', value: 10000000000),
  PlaceValueCategory(label: 'Billion', value: 1000000000),
  PlaceValueCategory(label: 'Hundred Million', value: 100000000),
  PlaceValueCategory(label: 'Ten Million', value: 10000000),
  PlaceValueCategory(label: 'Million', value: 1000000),
  PlaceValueCategory(label: 'Hundred Thousand', value: 100000),
  PlaceValueCategory(label: 'Ten Thousand', value: 10000),
  PlaceValueCategory(label: 'Thousand', value: 1000),
  PlaceValueCategory(label: 'Hundred', value: 100),
  PlaceValueCategory(label: 'Ten', value: 10),
  PlaceValueCategory(label: 'One', value: 1),
];

// Decimal categories (right of decimal point)
const List<PlaceValueCategory> placeValueDecimalCategories = [
  PlaceValueCategory(label: 'Tenth', value: 0.1),
  PlaceValueCategory(label: 'Hundredth', value: 0.01),
  PlaceValueCategory(label: 'Thousandth', value: 0.001),
  PlaceValueCategory(label: 'Ten Thousandth', value: 0.0001),
  PlaceValueCategory(label: 'Hundred Thousandth', value: 0.00001),
  PlaceValueCategory(label: 'Millionth', value: 0.000001),
  PlaceValueCategory(label: 'Ten Millionth', value: 0.0000001),
  PlaceValueCategory(label: 'Hundred Millionth', value: 0.00000001),
  PlaceValueCategory(label: 'Billionth', value: 0.000000001),
];

// Combined categories for quick lookup, if needed elsewhere
final List<PlaceValueCategory> placeValueCategories = [
  ...placeValueIntegerCategories,
  ...placeValueDecimalCategories,
];