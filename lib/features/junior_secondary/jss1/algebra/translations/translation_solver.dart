// lib/features/junior_secondary/jss1/algebra/translations/translation_solver.dart

import 'translation_models.dart';

class TranslationSolver {

  // ==========================================
  // ALGORITHM A: WORDS -> MATH
  // ==========================================
  static TranslationResult translateWordsToMath(String input) {
    if (input.trim().isEmpty) {
      return TranslationResult(steps: [], finalOutput: "", isOutputMath: true, valid: false, errorMessage: "Please enter a word problem.");
    }

    try {
      List<TranslationStep> steps = [];
      String currentText = input.toLowerCase();

      steps.add(TranslationStep(
        content: input,
        explanation: "This is our word problem. First, let's identify the unknown value and assign it a letter (like 'x').",
        isMathFormat: false,
      ));

      // 1. Handle JSS1 Continuation phrases across multiple sentences
      currentText = currentText
          .replaceAll(RegExp(r'\.\s*this\s+fraction\s+is\s*'), ' ')
          .replaceAll(RegExp(r'\.\s*this\s+result\s+is\s*'), ' ')
          .replaceAll(RegExp(r'\.\s*this\s+fraction\s*'), ' ')
          .replaceAll(RegExp(r'\.\s*this\s+result\s*'), ' ')
          .replaceAll(RegExp(r'\.\s*it\s+is\s*'), ' ')
          .replaceAll(RegExp(r'\.\s*the\s+result\s+is\s*'), ' = ')
          .replaceAll(RegExp(r'\.\s*this\s+gives\s*'), ' = ')
          .replaceAll(RegExp(r'this\s+fraction\s+is\s*'), ' ')
          .replaceAll(RegExp(r'this\s+result\s+is\s*'), ' ');

      // Normalize and clean punctuation
      currentText = currentText.replaceAll(',', '').replaceAll('.', '');
      currentText = currentText.replaceAll('when ', '').replaceAll('we get ', 'is ');

      // 2. Identify variables
      String varReplaced = currentText
          .replaceAll('a certain number', 'x')
          .replaceAll('an unknown number', 'x')
          .replaceAll('the number', 'x')
          .replaceAll('a number', 'x');

      if (varReplaced != currentText) {
        steps.add(TranslationStep(
          content: varReplaced,
          explanation: "We replaced the unknown word ('a number', 'the number') with the letter 'x'.",
          isMathFormat: false,
        ));
      }
      currentText = varReplaced;

      // 3. Convert word numbers to digits
      currentText = _convertWordsToDigits(currentText);

      // 4. Translate Multiplications to make terms compact first
      String mathExpr = currentText
          .replaceAll('twice x', '2x')
          .replaceAll('thrice x', '3x')
          .replaceAll(' times x', 'x')
          .replaceAll('times x', 'x')
          .replaceAll(' times ', ' * ')
          .replaceAll('multiplied by', '*')
          .replaceAll('product of', '*');

      mathExpr = mathExpr.replaceAll(RegExp(r'\s+'), ' ').trim();
      mathExpr = mathExpr.replaceAllMapped(RegExp(r'(\d)\s*\*?\s*x'), (match) {
        return '${match.group(1)}x';
      });

      // 5. Clause Grouping (Critical for BODMAS and Multi-sentence math)
      mathExpr = mathExpr.replaceAllMapped(RegExp(r'([^=]+?)\s+(?:is\s+)?divided\s+by\s+([a-z0-9x]+)'), (match) {
        String num = match.group(1)!.trim();
        if (!num.startsWith('(')) num = '($num)';
        return '$num / ${match.group(2)}';
      });

      mathExpr = mathExpr.replaceAllMapped(RegExp(r'([^=]+?)\s+(?:is\s+)?multiplied\s+by\s+([a-z0-9x]+)'), (match) {
        String num = match.group(1)!.trim();
        if (!num.startsWith('(')) num = '($num)';
        return '$num * ${match.group(2)}';
      });

      // 6. Handle SWAP operators (subtracted from, less than)
      mathExpr = mathExpr.replaceAllMapped(RegExp(r'([a-z0-9x]+(?:\s*[+*]\s*[a-z0-9x]+)*)\s+(?:is\s+)?subtracted\s+from\s+([a-z0-9x]+(?:\s*[+*]\s*[a-z0-9x]+)*)'), (match) {
        return '${match.group(2)} - ${match.group(1)}';
      });
      mathExpr = mathExpr.replaceAllMapped(RegExp(r'([a-z0-9x]+(?:\s*[+*]\s*[a-z0-9x]+)*)\s+(?:is\s+)?less\s+than\s+([a-z0-9x]+(?:\s*[+*]\s*[a-z0-9x]+)*)'), (match) {
        return '${match.group(2)} - ${match.group(1)}';
      });

      // 7. Translate Equals
      mathExpr = mathExpr
          .replaceAll('is the same as', '=')
          .replaceAll('the same as', '=')
          .replaceAll('is equal to', '=')
          .replaceAll('equals', '=')
          .replaceAll('gives', '=')
          .replaceAll('yields', '=')
          .replaceAll('leaves', '=')
          .replaceAll('the result is', '=')
          .replaceAll(' is ', ' = ');

      // 8. Translate remaining operators
      mathExpr = mathExpr
          .replaceAll('is added to', '+')
          .replaceAll('added to', '+')
          .replaceAll('increased by', '+')
          .replaceAll('sum of', '+')
          .replaceAll('plus', '+')
          .replaceAll('decreased by', '-')
          .replaceAll('minus', '-')
          .replaceAll('divided by', '/')
          .replaceAll('quotient of', '/')
          .replaceAll('over', '/');

      // Clean up final spacing formatting
      mathExpr = mathExpr.replaceAll('+', ' + ').replaceAll('-', ' - ').replaceAll('=', ' = ').replaceAll('/', ' / ');
      mathExpr = mathExpr.replaceAll(RegExp(r'\s+'), ' ').trim();

      steps.add(TranslationStep(
        content: mathExpr,
        explanation: "We group the clauses using brackets to obey BODMAS, then replace the operation words with their mathematical symbols (+, -, =, etc.).",
        isMathFormat: true,
      ));

      // 9. Final Output (Convert string divisions to LaTeX fractions)
      String finalAns = mathExpr.replaceAll('*', '\\times');
      finalAns = finalAns.replaceAllMapped(RegExp(r'\(([^)]+)\)\s*/\s*([a-z0-9x]+)'), (match) {
        return '\\frac{${match.group(1)}}{${match.group(2)}}';
      });

      steps.add(TranslationStep(
        content: finalAns,
        explanation: "This is the final mathematical statement, written in proper algebraic format.",
        isMathFormat: true,
        isFinalAnswer: true,
      ));

      return TranslationResult(steps: steps, finalOutput: finalAns, isOutputMath: true);

    } catch (e) {
      return TranslationResult(steps: [], finalOutput: "", isOutputMath: true, valid: false, errorMessage: "Could not translate. Please use standard JSS1 phrasing.");
    }
  }

  // ==========================================
  // ALGORITHM B: MATH -> WORDS
  // ==========================================
  static TranslationResult translateMathToWords(String input) {
    if (input.trim().isEmpty) {
      return TranslationResult(steps: [], finalOutput: "", isOutputMath: false, valid: false, errorMessage: "Please enter a mathematical equation.");
    }

    try {
      List<TranslationStep> steps = [];
      String expr = input.replaceAll(' ', '').toLowerCase();

      steps.add(TranslationStep(
        content: expr,
        explanation: "This is our mathematical statement. Let's break it down into parts.",
        isMathFormat: true,
      ));

      // Separate into Left and Right sides if it's an equation
      List<String> sides = expr.split('=');
      String words = "";

      if (sides.length == 2) {
        String lhsWords = _parseAlgebraicSide(sides[0]);
        String rhsWords = _parseAlgebraicSide(sides[1]);

        steps.add(TranslationStep(
          content: "$lhsWords ... is equal to ... $rhsWords",
          explanation: "We translate the left side, translate the equals sign to 'is equal to', and then translate the right side.",
          isMathFormat: false,
        ));

        words = "$lhsWords is equal to $rhsWords.";
      } else {
        words = "${_parseAlgebraicSide(expr)}.";
        steps.add(TranslationStep(
          content: words,
          explanation: "We read the coefficients, letters, and operators and write them in plain English.",
          isMathFormat: false,
        ));
      }

      // Capitalize first letter
      words = words[0].toUpperCase() + words.substring(1);

      steps.add(TranslationStep(
        content: words,
        explanation: "This is the complete sentence in words.",
        isMathFormat: false,
        isFinalAnswer: true,
      ));

      return TranslationResult(steps: steps, finalOutput: words, isOutputMath: false);

    } catch (e) {
      return TranslationResult(steps: [], finalOutput: "", isOutputMath: false, valid: false, errorMessage: "Invalid mathematical format.");
    }
  }

  // --- Helpers for Math to Words ---
  static String _parseAlgebraicSide(String side) {
    String parsed = side.replaceAll('+', ' plus ')
        .replaceAll('-', ' minus ')
        .replaceAll('/', ' divided by ')
        .replaceAll('*', ' times ')
        .replaceAll('(', ' all of ')
        .replaceAll(')', ' ');

    // Convert 3x to "3 times a number x"
    parsed = parsed.replaceAllMapped(RegExp(r'(\d+)([a-z])'), (match) {
      return "${match.group(1)} times a number ${match.group(2)}";
    });

    // Convert plain single variables "x" to "a number x"
    parsed = parsed.replaceAllMapped(RegExp(r'(?<![a-z])([a-z])(?![a-z])'), (match) {
      if (parsed.contains("times a number ${match.group(1)}")) return match.group(1)!;
      return "a number ${match.group(1)}";
    });

    // Convert plain digits to word numbers
    parsed = parsed.replaceAllMapped(RegExp(r'\b(\d+)\b'), (match) {
      return _numberToWords(int.parse(match.group(1)!));
    });

    return parsed.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // --- Simple Number to Word Converter (0-99 for JSS1 limits) ---
  static String _numberToWords(int number) {
    if (number == 0) return "zero";
    if (number < 20) {
      const units = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"];
      return units[number];
    }
    const tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"];
    if (number < 100) {
      return tens[number ~/ 10] + (number % 10 != 0 ? "-${_numberToWords(number % 10)}" : "");
    }
    return number.toString(); // Fallback for large numbers
  }

  // --- Simple Word to Number Converter ---
  static String _convertWordsToDigits(String text) {
    Map<String, String> wordToNum = {
      "twenty-five": "25", "twenty five": "25", "twenty": "20",
      "ten": "10", "eleven": "11", "twelve": "12", "thirteen": "13",
      "fourteen": "14", "fifteen": "15", "sixteen": "16",
      "seventeen": "17", "eighteen": "18", "nineteen": "19",
      "one": "1", "two": "2", "three": "3", "four": "4", "five": "5",
      "six": "6", "seven": "7", "eight": "8", "nine": "9", "zero": "0"
    };

    wordToNum.forEach((word, digit) {
      text = text.replaceAll(RegExp('\\b$word\\b'), digit);
    });
    return text;
  }
}