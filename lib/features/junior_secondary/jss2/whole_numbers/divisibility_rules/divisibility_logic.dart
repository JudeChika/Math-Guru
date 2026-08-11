import 'divisibility_models.dart';

class DivisibilityLogic {
  /// Cleans the input string by removing spaces and commas.
  static String _sanitizeNumber(String input) {
    return input.replaceAll(RegExp(r'[\s,]'), '');
  }

  /// Main entry point to check divisibility and generate steps.
  static DivisibilityResult checkDivisibility(String numberInput, String divisorInput) {
    final cleanNumber = _sanitizeNumber(numberInput);
    final cleanDivisor = _sanitizeNumber(divisorInput);

    if (cleanNumber.isEmpty || cleanDivisor.isEmpty) {
      return _errorResult("Please enter both a number and a divisor.");
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return _errorResult("The large number must contain only digits.");
    }

    final int? divisor = int.tryParse(cleanDivisor);
    if (divisor == null || divisor <= 0) {
      return _errorResult("The divisor must be a positive integer greater than zero.");
    }

    return _applyRule(cleanNumber, divisor);
  }

  static DivisibilityResult _errorResult(String message) {
    return DivisibilityResult(
      number: "",
      divisor: 0,
      isDivisible: false,
      ruleApplied: "",
      steps: [],
      valid: false,
      error: message,
    );
  }

  static DivisibilityResult _applyRule(String number, int divisor) {
    switch (divisor) {
      case 2:
        return _ruleFor2(number);
      case 3:
        return _ruleForSumOfDigits(number, 3);
      case 4:
        return _ruleFor4(number);
      case 5:
        return _ruleFor5(number);
      case 6:
        return _ruleFor6(number);
      case 8:
        return _ruleFor8(number);
      case 9:
        return _ruleForSumOfDigits(number, 9);
      case 10:
        return _ruleFor10(number);
      case 11:
        return _ruleFor11(number);
      default:
        return _fallbackRule(number, divisor);
    }
  }

  static DivisibilityResult _ruleFor2(String number) {
    final lastDigit = int.parse(number[number.length - 1]);
    final isDivisible = lastDigit % 2 == 0;

    return DivisibilityResult(
        number: number,
        divisor: 2,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: "A number is divisible by 2 if its last digit is an even number (0, 2, 4, 6, or 8).",
        steps: [
          DivisibilityStep(
            description: "Step 1: Look at the last digit of $number.",
            workingLaTeX: "Last\\;Digit = $lastDigit",
          ),
          DivisibilityStep(
            description: "Step 2: Check if $lastDigit is even.",
            workingLaTeX: isDivisible ? "$lastDigit \\text{ is even.}" : "$lastDigit \\text{ is odd.}",
          ),
          DivisibilityStep(
            description: "Conclusion: Since the last digit is ${isDivisible ? 'even' : 'odd'}, the whole number is ${isDivisible ? '' : 'NOT '}divisible by 2.",
          ),
        ]
    );
  }

  static DivisibilityResult _ruleForSumOfDigits(String number, int divisor) {
    int sum = 0;
    List<String> digits = [];
    for (int i = 0; i < number.length; i++) {
      int d = int.parse(number[i]);
      sum += d;
      digits.add(d.toString());
    }

    final isDivisible = sum % divisor == 0;
    final rule = divisor == 3
        ? "A number is divisible by 3 if the SUM of all its digits is divisible by 3."
        : "A number is divisible by 9 if the SUM of all its digits is a multiple of 9.";

    return DivisibilityResult(
        number: number,
        divisor: divisor,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: rule,
        steps: [
          DivisibilityStep(
            description: "Step 1: Add all the digits of the number together.",
            workingLaTeX: "${digits.join(' + ')} = $sum",
          ),
          DivisibilityStep(
            description: "Step 2: Check if the total sum ($sum) is divisible by $divisor.",
            workingLaTeX: "$sum \\div $divisor = ${sum ~/ divisor}${sum % divisor == 0 ? '' : ' \\text{ R } ${sum % divisor}'}",
          ),
          DivisibilityStep(
            description: "Conclusion: Because $sum is ${isDivisible ? '' : 'NOT '}divisible by $divisor, the entire number $number is ${isDivisible ? '' : 'NOT '}divisible by $divisor.",
          ),
        ]
    );
  }

  static DivisibilityResult _ruleFor4(String number) {
    if (number.length < 2) number = "0$number";
    final lastTwo = number.substring(number.length - 2);
    final val = int.parse(lastTwo);
    final isDivisible = val % 4 == 0;

    return DivisibilityResult(
        number: number,
        divisor: 4,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: "A number is divisible by 4 if the number formed by its last two digits is divisible by 4.",
        steps: [
          DivisibilityStep(
            description: "Step 1: Extract the last two digits of the number.",
            workingLaTeX: "Last\\;Two\\;Digits = $lastTwo",
          ),
          DivisibilityStep(
            description: "Step 2: Check if $lastTwo is divisible by 4.",
            workingLaTeX: "$lastTwo \\div 4 = ${val ~/ 4}${val % 4 == 0 ? '' : ' \\text{ R } ${val % 4}'}",
          ),
          DivisibilityStep(
            description: "Conclusion: Therefore, $number is ${isDivisible ? '' : 'NOT '}divisible by 4.",
          ),
        ]
    );
  }

  static DivisibilityResult _ruleFor8(String number) {
    if (number.length < 3) number = number.padLeft(3, '0');
    final lastThree = number.substring(number.length - 3);
    final val = int.parse(lastThree);
    final isDivisible = val % 8 == 0;

    return DivisibilityResult(
        number: number,
        divisor: 8,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: "A number is divisible by 8 if the number formed by its last three digits is divisible by 8.",
        steps: [
          DivisibilityStep(
            description: "Step 1: Extract the last three digits of the number.",
            workingLaTeX: "Last\\;Three\\;Digits = $lastThree",
          ),
          DivisibilityStep(
            description: "Step 2: Check if $lastThree is divisible by 8.",
            workingLaTeX: "$lastThree \\div 8 = ${val ~/ 8}${val % 8 == 0 ? '' : ' \\text{ R } ${val % 8}'}",
          ),
          DivisibilityStep(
            description: "Conclusion: Therefore, $number is ${isDivisible ? '' : 'NOT '}divisible by 8.",
          ),
        ]
    );
  }

  static DivisibilityResult _ruleFor5(String number) {
    final lastDigit = number[number.length - 1];
    final isDivisible = lastDigit == '0' || lastDigit == '5';

    return DivisibilityResult(
        number: number,
        divisor: 5,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: "A number is divisible by 5 if its last digit is either 0 or 5.",
        steps: [
          DivisibilityStep(
            description: "Step 1: Look at the last digit of the number.",
            workingLaTeX: "Last\\;Digit = $lastDigit",
          ),
          DivisibilityStep(
            description: "Conclusion: Since the last digit is ${isDivisible ? '0 or 5' : 'neither 0 nor 5'}, the number is ${isDivisible ? '' : 'NOT '}divisible by 5.",
          ),
        ]
    );
  }

  static DivisibilityResult _ruleFor10(String number) {
    final lastDigit = number[number.length - 1];
    final isDivisible = lastDigit == '0';

    return DivisibilityResult(
        number: number,
        divisor: 10,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: "A number is divisible by 10 if its last digit is 0.",
        steps: [
          DivisibilityStep(
            description: "Step 1: Look at the last digit of the number.",
            workingLaTeX: "Last\\;Digit = $lastDigit",
          ),
          DivisibilityStep(
            description: "Conclusion: Since the last digit is ${isDivisible ? '0' : 'NOT 0'}, the number is ${isDivisible ? '' : 'NOT '}divisible by 10.",
          ),
        ]
    );
  }

  static DivisibilityResult _ruleFor6(String number) {
    final lastDigit = int.parse(number[number.length - 1]);
    final isEven = lastDigit % 2 == 0;

    int sum = 0;
    for (int i = 0; i < number.length; i++) {
      sum += int.parse(number[i]);
    }
    final isSumDivBy3 = sum % 3 == 0;
    final isDivisible = isEven && isSumDivBy3;

    return DivisibilityResult(
        number: number,
        divisor: 6,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: "A number is divisible by 6 if it passes BOTH the rule for 2 (it is even) AND the rule for 3 (sum of digits divisible by 3).",
        steps: [
          DivisibilityStep(
            description: "Step 1: Check the rule for 2. Is the last digit even?",
            workingLaTeX: isEven ? "$lastDigit \\text{ is even. (Pass)}" : "$lastDigit \\text{ is odd. (Fail)}",
          ),
          DivisibilityStep(
            description: "Step 2: Check the rule for 3. Is the sum of digits divisible by 3?",
            workingLaTeX: "Sum = $sum \\Rightarrow $sum \\div 3 = ${sum ~/ 3}${sum % 3 == 0 ? ' \\text{ (Pass)}' : ' \\text{ R } ${sum % 3} \\text{ (Fail)'}",
          ),
          DivisibilityStep(
            description: "Conclusion: Since it passes ${isDivisible ? 'BOTH rules' : 'not all rules'}, the number is ${isDivisible ? '' : 'NOT '}divisible by 6.",
          ),
        ]
    );
  }

  static DivisibilityResult _ruleFor11(String number) {
    int oddSum = 0;
    int evenSum = 0;
    List<String> oddDigits = [];
    List<String> evenDigits = [];

    // Right to left or left to right works, but standard teaches left to right 1st, 2nd, 3rd position
    for (int i = 0; i < number.length; i++) {
      int d = int.parse(number[i]);
      if ((i + 1) % 2 != 0) { // 1st, 3rd, 5th...
        oddSum += d;
        oddDigits.add(d.toString());
      } else { // 2nd, 4th, 6th...
        evenSum += d;
        evenDigits.add(d.toString());
      }
    }

    int difference = (oddSum - evenSum).abs();
    bool isDivisible = difference % 11 == 0;

    return DivisibilityResult(
        number: number,
        divisor: 11,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: "A number is divisible by 11 if the difference between the sum of digits in odd positions and the sum of digits in even positions is 0 or a multiple of 11.",
        steps: [
          DivisibilityStep(
            description: "Step 1: Sum the digits in the odd positions (1st, 3rd, 5th...).",
            workingLaTeX: "${oddDigits.join(' + ')} = $oddSum",
          ),
          DivisibilityStep(
            description: "Step 2: Sum the digits in the even positions (2nd, 4th, 6th...).",
            workingLaTeX: "${evenDigits.join(' + ')} = $evenSum",
          ),
          DivisibilityStep(
            description: "Step 3: Find the difference between the two sums.",
            workingLaTeX: "|$oddSum - $evenSum| = $difference",
          ),
          DivisibilityStep(
            description: "Conclusion: Because $difference is ${isDivisible ? 'a multiple of 11 (or 0)' : 'NOT a multiple of 11'}, the number is ${isDivisible ? '' : 'NOT '}divisible by 11.",
          ),
        ]
    );
  }

  static DivisibilityResult _fallbackRule(String number, int divisor) {
    BigInt bigNum = BigInt.parse(number);
    BigInt bigDiv = BigInt.from(divisor);
    BigInt remainder = bigNum.remainder(bigDiv);
    bool isDivisible = remainder == BigInt.zero;

    return DivisibilityResult(
        number: number,
        divisor: divisor,
        isDivisible: isDivisible,
        valid: true,
        ruleApplied: "Standard Long Division (No quick rule exists for $divisor). We divide the number directly by $divisor to see if there is a remainder.",
        steps: [
          DivisibilityStep(
            description: "Step 1: Divide the large number by $divisor.",
            workingLaTeX: "$number \\div $divisor",
          ),
          DivisibilityStep(
            description: "Step 2: Check the remainder.",
            workingLaTeX: isDivisible ? "\\text{Remainder } = 0" : "\\text{Remainder } = $remainder",
          ),
          DivisibilityStep(
            description: "Conclusion: Because the remainder is ${isDivisible ? '0' : 'not 0'}, the number is ${isDivisible ? '' : 'NOT '}divisible by $divisor.",
          ),
        ]
    );
  }
}