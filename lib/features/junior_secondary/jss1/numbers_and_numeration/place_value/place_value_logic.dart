import 'place_value_categories.dart';
import 'place_value_conversion_step.dart';

class PlaceValueLogic {
  /// Parses input string into integer and decimal digit lists, preserving order.
  static ({
  List<int> integerDigits,
  List<int> decimalDigits,
  List<PlaceValueConversionStep> steps,
  bool valid,
  }) parseDigits(String input) {
    List<PlaceValueConversionStep> steps = [];
    String sanitized = input.replaceAll(RegExp(r'[^0-9\.]'), '');
    if (sanitized.isEmpty || sanitized == ".") {
      steps.add(PlaceValueConversionStep(
        description: "Please enter at least one digit.",
      ));
      return (integerDigits: [], decimalDigits: [], steps: steps, valid: false);
    }

    // Split on decimal point
    List<String> parts = sanitized.split(".");
    List<int> integerDigits = [];
    List<int> decimalDigits = [];
    if (parts[0].isNotEmpty) {
      integerDigits = parts[0].split('').map((e) => int.parse(e)).toList();
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      decimalDigits = parts[1].split('').map((e) => int.parse(e)).toList();
    }

    steps.add(PlaceValueConversionStep(
      description: "Parsed input into integer digits: ${integerDigits.join(', ')}"
          "${decimalDigits.isNotEmpty ? " and decimal digits: ${decimalDigits.join(', ')}" : ""}",
    ));

    if (integerDigits.isEmpty && decimalDigits.isEmpty) {
      steps.add(PlaceValueConversionStep(
        description: "No valid digits found.",
      ));
      return (integerDigits: [], decimalDigits: [], steps: steps, valid: false);
    }

    return (integerDigits: integerDigits, decimalDigits: decimalDigits, steps: steps, valid: true);
  }

  /// Maps digits to their categories for both integer and decimal parts.
  static ({
  List<Map<String, dynamic>> tableRows,
  List<PlaceValueConversionStep> steps,
  }) mapDigitsToCategories(List<int> integerDigits, List<int> decimalDigits) {
    List<PlaceValueConversionStep> steps = [];
    final tableRows = <Map<String, dynamic>>[];

    // Integer part
    int intCatStart = placeValueIntegerCategories.length - integerDigits.length;
    if (intCatStart < 0) intCatStart = 0;
    for (int i = 0; i < integerDigits.length; i++) {
      final categoryIndex = i + intCatStart;
      final category = (categoryIndex < placeValueIntegerCategories.length)
          ? placeValueIntegerCategories[categoryIndex]
          : PlaceValueCategory(label: "Unknown", value: 0);
      final position = i + 1;
      final digit = integerDigits[i];
      final placeValue = digit * category.value;
      tableRows.add({
        'digit': digit,
        'position': position,
        'category': category.label,
        'categoryValue': category.value,
        'placeValue': placeValue,
        'isDecimal': false,
        'index': i, // for selection
      });
      steps.add(PlaceValueConversionStep(
        description:
        "Digit $digit is at integer position $position from left: ${category.label} (value ${category.value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')})",
        resultSoFar:
        "Digit: $digit, Category: ${category.label}, Place Value: $placeValue",
      ));
    }

    // Decimal part
    for (int j = 0; j < decimalDigits.length; j++) {
      final category = (j < placeValueDecimalCategories.length)
          ? placeValueDecimalCategories[j]
          : PlaceValueCategory(label: "Beyond Listed", value: double.parse("1e-${j + 1}"));
      final position = j + 1;
      final digit = decimalDigits[j];
      final placeValue = digit * category.value;
      tableRows.add({
        'digit': digit,
        'position': position,
        'category': category.label,
        'categoryValue': category.value,
        'placeValue': placeValue,
        'isDecimal': true,
        'index': j, // for selection
      });
      steps.add(PlaceValueConversionStep(
        description:
        "Digit $digit is at decimal position $position from decimal point: ${category.label} (value ${category.value})",
        resultSoFar:
        "Digit: $digit, Category: ${category.label}, Place Value: $placeValue",
      ));
    }

    return (tableRows: tableRows, steps: steps);
  }

  /// Determines the place value of a digit at a given index and part (integer or decimal), with steps.
  static ({
  Map<String, dynamic>? result,
  List<PlaceValueConversionStep> steps,
  bool valid,
  }) findPlaceValue(
      List<int> integerDigits,
      List<int> decimalDigits,
      int selectedIndex,
      bool isDecimal,
      ) {
    List<PlaceValueConversionStep> steps = [];
    if (!isDecimal) {
      if (selectedIndex < 0 || selectedIndex >= integerDigits.length) {
        steps.add(PlaceValueConversionStep(
          description: "Selected position is out of bounds.",
        ));
        return (result: null, steps: steps, valid: false);
      }
      int intCatStart = placeValueIntegerCategories.length - integerDigits.length;
      if (intCatStart < 0) intCatStart = 0;
      final categoryIndex = selectedIndex + intCatStart;
      final digit = integerDigits[selectedIndex];
      final category = (categoryIndex < placeValueIntegerCategories.length)
          ? placeValueIntegerCategories[categoryIndex]
          : const PlaceValueCategory(label: "Unknown", value: 0);
      final placeValue = digit * category.value;

      steps.add(PlaceValueConversionStep(
        description:
        "Selected digit: $digit at integer position ${selectedIndex + 1} from left.",
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
        'isDecimal': false,
      },
      steps: steps,
      valid: true,
      );
    } else {
      if (selectedIndex < 0 || selectedIndex >= decimalDigits.length) {
        steps.add(PlaceValueConversionStep(
          description: "Selected decimal position is out of bounds.",
        ));
        return (result: null, steps: steps, valid: false);
      }
      final digit = decimalDigits[selectedIndex];
      final category = (selectedIndex < placeValueDecimalCategories.length)
          ? placeValueDecimalCategories[selectedIndex]
          : PlaceValueCategory(label: "Beyond Listed", value: double.parse("1e-${selectedIndex + 1}"));
      final placeValue = digit * category.value;

      steps.add(PlaceValueConversionStep(
        description:
        "Selected digit: $digit at decimal position ${selectedIndex + 1} after the decimal point.",
      ));
      steps.add(PlaceValueConversionStep(
        description:
        "Category: ${category.label} (${category.value})",
      ));
      steps.add(PlaceValueConversionStep(
        description:
        "Place value = $digit × ${category.value} = $placeValue",
      ));
      return (
      result: {
        'digit': digit,
        'category': category.label,
        'categoryValue': category.value,
        'placeValue': placeValue,
        'position': selectedIndex + 1,
        'isDecimal': true,
      },
      steps: steps,
      valid: true,
      );
    }
  }
}