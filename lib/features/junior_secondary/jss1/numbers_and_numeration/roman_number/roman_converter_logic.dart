import 'roman_conversion_step.dart';

class RomanConverter {
  static const Map<int, String> _arabicToRoman = {
    1000: 'M',
    900: 'CM',
    500: 'D',
    400: 'CD',
    100: 'C',
    90: 'XC',
    50: 'L',
    40: 'XL',
    10: 'X',
    9: 'IX',
    5: 'V',
    4: 'IV',
    1: 'I',
  };

  static final Map<String, int> _romanToArabic = {
    'M': 1000,
    'D': 500,
    'C': 100,
    'L': 50,
    'X': 10,
    'V': 5,
    'I': 1,
  };

  /// Converts an Arabic number to Roman numerals with step explanations.
  static (String result, List<RomanConversionStep> steps) englishToRoman(int number) {
    if (number <= 0 || number >= 4000) {
      return (
      '',
      [
        RomanConversionStep(
          description:
          "Roman numerals are only defined for numbers from 1 to 3999.",
          resultSoFar: '',
        )
      ]
      );
    }

    int remaining = number;
    String roman = '';
    List<RomanConversionStep> steps = [];

    for (final entry in _arabicToRoman.entries) {
      int value = entry.key;
      String symbol = entry.value;
      int count = remaining ~/ value;
      if (count > 0) {
        String explanation =
            "Divide $remaining by $value: quotient = $count, remainder = ${remaining % value}.\n"
            "Add '${symbol * count}' for $value × $count = ${value * count}.";
        roman += symbol * count;
        remaining -= value * count;
        steps.add(RomanConversionStep(
          description: explanation,
          resultSoFar: roman,
        ));
      }
    }

    steps.add(
      RomanConversionStep(
        description: "Final Roman numeral: $roman",
        resultSoFar: roman,
      ),
    );
    return (roman, steps);
  }

  /// Converts a Roman numeral to an Arabic number with step explanations.
  static (int result, List<RomanConversionStep> steps, bool isValid) romanToEnglish(String romanInput) {
    String roman = romanInput.toUpperCase().trim();
    int total = 0;
    int prevValue = 0;
    List<RomanConversionStep> steps = [];
    bool isValid = true;
    String runningRoman = '';

    for (int i = roman.length - 1; i >= 0; i--) {
      String char = roman[i];
      int? value = _romanToArabic[char];
      if (value == null) {
        steps.add(RomanConversionStep(
            description: "Invalid character '$char' found in input.",
            resultSoFar: '$total'
        ));
        isValid = false;
        break;
      }
      runningRoman = char + runningRoman;
      if (value < prevValue) {
        total -= value;
        steps.add(RomanConversionStep(
          description: "'$char' ($value) is less than previous value ($prevValue), so subtract: $total",
          resultSoFar: runningRoman,
        ));
      } else {
        total += value;
        steps.add(RomanConversionStep(
          description: "'$char' ($value) is greater than or equal to previous value ($prevValue), so add: $total",
          resultSoFar: runningRoman,
        ));
      }
      prevValue = value;
    }

    if (isValid) {
      steps.add(
        RomanConversionStep(
          description: "Final English value: $total",
          resultSoFar: '$total',
        ),
      );
    }
    return (total, steps, isValid);
  }
}