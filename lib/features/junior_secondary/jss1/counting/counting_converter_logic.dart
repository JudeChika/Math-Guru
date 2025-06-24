import 'counting_categories.dart';
import 'counting_conversion_step.dart';

// You may use a package like 'number_to_words' if available, but here is a simple implementation:
String _simpleNumberToWords(int number) {
  if (number == 0) return 'zero';
  final units = [
    '',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen'
  ];
  final tens = [
    '',
    '',
    'twenty',
    'thirty',
    'forty',
    'fifty',
    'sixty',
    'seventy',
    'eighty',
    'ninety'
  ];
  String helper(int n) {
    if (n < 20) {
      return units[n];
    } else if (n < 100) {
      return tens[n ~/ 10] +
          (n % 10 > 0 ? ' ' + units[n % 10] : '');
    } else if (n < 1000) {
      return units[n ~/ 100] +
          ' hundred' +
          (n % 100 > 0 ? ' ' + helper(n % 100) : '');
    } else if (n < 1000000) {
      return helper(n ~/ 1000) +
          ' thousand' +
          (n % 1000 > 0 ? ' ' + helper(n % 1000) : '');
    } else if (n < 1000000000) {
      return helper(n ~/ 1000000) +
          ' million' +
          (n % 1000000 > 0 ? ' ' + helper(n % 1000000) : '');
    } else if (n < 1000000000000) {
      return helper(n ~/ 1000000000) +
          ' billion' +
          (n % 1000000000 > 0 ? ' ' + helper(n % 1000000000) : '');
    } else {
      return helper(n ~/ 1000000000000) +
          ' trillion' +
          (n % 1000000000000 > 0 ? ' ' + helper(n % 1000000000000) : '');
    }
  }

  return helper(number).replaceAll(RegExp(' +'), ' ').trim();
}

class CountingConverter {
  /// Converts a numeric string to a map of categories, and words, with steps.
  static ({
  Map<String, int> categoryMap,
  String inWords,
  List<CountingConversionStep> steps,
  bool valid,
  }) numberToCategoriesAndWords(String input) {
    List<CountingConversionStep> steps = [];
    final sanitized = input.replaceAll(RegExp(r'[,\s]'), '');
    if (sanitized.isEmpty || !RegExp(r'^\d+$').hasMatch(sanitized)) {
      return (
      categoryMap: {},
      inWords: '',
      steps: [
        CountingConversionStep(
            description: "Please enter a valid positive integer number.")
      ],
      valid: false,
      );
    }

    final number = BigInt.parse(sanitized);
    Map<String, int> categoryMap = {};
    var remaining = number;
    steps.add(CountingConversionStep(
        description: "Input sanitized: $sanitized (as number: $number)"));

    for (final cat in countingCategories) {
      if (remaining >= BigInt.from(cat.divisor)) {
        final value = (remaining ~/ BigInt.from(cat.divisor)).toInt();
        categoryMap[cat.label] = value;
        remaining -= BigInt.from(value) * BigInt.from(cat.divisor);
        steps.add(CountingConversionStep(
            description:
            "$value in '${cat.label}' category (${cat.divisor.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ",")})",
            resultSoFar: categoryMap.entries
                .map((e) => "${e.key}: ${e.value}")
                .join(" | ")));
      } else {
        categoryMap[cat.label] = 0;
      }
    }
    if (remaining > BigInt.zero) {
      steps.add(CountingConversionStep(
          description: "Leftover: $remaining, less than 10."));
    }

    // Compose words (replace NumberToWord().convert...)
    String inWords;
    try {
      inWords = _simpleNumberToWords(number.toInt());
    } catch (e) {
      inWords = number.toString();
    }
    steps.add(CountingConversionStep(
        description: "Number in words: ${_capitalize(inWords)}"));
    return (
    categoryMap: categoryMap,
    inWords: _capitalize(inWords),
    steps: steps,
    valid: true,
    );
  }

  /// Converts a number-in-words string to digits, then categories, with steps.
  static ({
  int? number,
  Map<String, int> categoryMap,
  List<CountingConversionStep> steps,
  bool valid,
  }) wordsToCategoriesAndNumber(String wordsInput) {
    List<CountingConversionStep> steps = [];
    final trimmed = wordsInput.trim();
    if (trimmed.isEmpty) {
      return (
      number: null,
      categoryMap: {},
      steps: [
        CountingConversionStep(description: "Please enter number in words."),
      ],
      valid: false,
      );
    }

    int? number = _wordsToNumber(trimmed);

    if (number == null) {
      return (
      number: null,
      categoryMap: {},
      steps: [
        CountingConversionStep(
            description: "Could not parse the input words to a valid number."),
      ],
      valid: false,
      );
    }

    steps.add(CountingConversionStep(
        description: "Parsed words to number: $number"));

    // Classify categories
    String numStr = number.toString();
    final numberResult = numberToCategoriesAndWords(numStr);
    steps.addAll(numberResult.steps);

    return (
    number: number,
    categoryMap: numberResult.categoryMap,
    steps: steps,
    valid: true,
    );
  }

  /// --- Helpers ---

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Converts English words to int. (Simple version, extend as needed!)
  static int? _wordsToNumber(String words) {
    var clean = words.toLowerCase().replaceAll("-", " ").replaceAll(" and ", " ");
    final units = {
      "zero": 0,
      "one": 1,
      "two": 2,
      "three": 3,
      "four": 4,
      "five": 5,
      "six": 6,
      "seven": 7,
      "eight": 8,
      "nine": 9,
      "ten": 10,
      "eleven": 11,
      "twelve": 12,
      "thirteen": 13,
      "fourteen": 14,
      "fifteen": 15,
      "sixteen": 16,
      "seventeen": 17,
      "eighteen": 18,
      "nineteen": 19,
    };
    final tens = {
      "twenty": 20,
      "thirty": 30,
      "forty": 40,
      "fifty": 50,
      "sixty": 60,
      "seventy": 70,
      "eighty": 80,
      "ninety": 90,
    };
    final scales = {
      "hundred": 100,
      "thousand": 1000,
      "million": 1000000,
      "billion": 1000000000,
      "trillion": 1000000000000,
    };

    int result = 0;
    int current = 0;
    final parts = clean.split(RegExp(r'[\s,]+'));
    for (final word in parts) {
      if (units.containsKey(word)) {
        current += units[word]!;
      } else if (tens.containsKey(word)) {
        current += tens[word]!;
      } else if (scales.containsKey(word)) {
        if (current == 0) current = 1;
        current *= scales[word]!;
        result += current;
        current = 0;
      } else if (word.isEmpty) {
        continue;
      } else {
        return null;
      }
    }
    result += current;
    return result;
  }
}