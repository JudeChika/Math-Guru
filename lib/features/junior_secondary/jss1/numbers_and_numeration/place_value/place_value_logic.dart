import 'place_value_categories.dart';
import 'place_value_conversion_step.dart';

class PlaceValueLogic {
  /// Parses input string into a list of digits, preserving order.
  static ({
  List<int> digits,
  List<PlaceValueConversionStep> steps,
  bool valid,
  }) parseDigits(String input) {
    List<PlaceValueConversionStep> steps = [];
    final sanitized = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (sanitized.isEmpty) {
      steps.add(PlaceValueConversionStep(
        description: "Please enter at least one digit.",
      ));
      return (digits: [], steps: steps, valid: false);
    }
    List<int> digits = sanitized.split('').map((e) => int.parse(e)).toList();
    steps.add(PlaceValueConversionStep(
      description: "Parsed input to digit list: ${digits.join(', ')}",
    ));
    return (digits: digits, steps: steps, valid: true);
  }

  /// Maps digits to their categories starting from the left (highest).
  static ({
  List<Map<String, dynamic>> tableRows,
  List<PlaceValueConversionStep> steps,
  }) mapDigitsToCategories(List<int> digits) {
    List<PlaceValueConversionStep> steps = [];
    int categoryStart = placeValueCategories.length - digits.length;
    if (categoryStart < 0) categoryStart = 0;

    final tableRows = <Map<String, dynamic>>[];
    for (int i = 0; i < digits.length; i++) {
      final categoryIndex = i + categoryStart;
      final category = placeValueCategories[categoryIndex];
      final position = i + 1;
      final digit = digits[i];
      final placeValue = digit * category.value;
      tableRows.add({
        'digit': digit,
        'position': position,
        'category': category.label,
        'categoryValue': category.value,
        'placeValue': placeValue,
      });
      steps.add(PlaceValueConversionStep(
        description:
        "Digit $digit is at position $position from left: ${category.label} (value ${category.value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')})",
        resultSoFar:
        "Digit: $digit, Category: ${category.label}, Place Value: $placeValue",
      ));
    }
    return (tableRows: tableRows, steps: steps);
  }

  /// Determines the place value of a digit at a given index, with steps.
  static ({
  Map<String, dynamic>? result,
  List<PlaceValueConversionStep> steps,
  bool valid,
  }) findPlaceValue(
      List<int> digits,
      int selectedIndex,
      ) {
    List<PlaceValueConversionStep> steps = [];
    if (selectedIndex < 0 || selectedIndex >= digits.length) {
      steps.add(PlaceValueConversionStep(
        description: "Selected position is out of bounds.",
      ));
      return (result: null, steps: steps, valid: false);
    }
    int categoryStart = placeValueCategories.length - digits.length;
    if (categoryStart < 0) categoryStart = 0;
    final categoryIndex = selectedIndex + categoryStart;

    final digit = digits[selectedIndex];
    final category = placeValueCategories[categoryIndex];
    final placeValue = digit * category.value;

    steps.add(PlaceValueConversionStep(
      description:
      "Selected digit: $digit at position ${selectedIndex + 1} from left.",
    ));
    steps.add(PlaceValueConversionStep(
      description:
      "Category: ${category.label} (${category.value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')})",
    ));
    steps.add(PlaceValueConversionStep(
      description:
      "Place value = $digit × ${category.value} = ${placeValue.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}",
    ));
    return (
    result: {
      'digit': digit,
      'category': category.label,
      'categoryValue': category.value,
      'placeValue': placeValue,
      'position': selectedIndex + 1,
    },
    steps: steps,
    valid: true,
    );
  }
}