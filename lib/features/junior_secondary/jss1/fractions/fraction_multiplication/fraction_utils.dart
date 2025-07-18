import 'fraction_models.dart';

class FractionUtils {
  static Fraction parseFraction(String input) {
    input = input.trim();

    if (input.contains(' ')) {
      final parts = input.split(' ');
      final whole = int.parse(parts[0]);
      final fracParts = parts[1].split('/');
      final numerator = int.parse(fracParts[0]);
      final denominator = int.parse(fracParts[1]);
      int improperNumerator = whole.abs() * denominator + numerator;
      if (whole < 0) improperNumerator = -improperNumerator;
      return Fraction(improperNumerator, denominator);
    } else if (input.contains('/')) {
      final parts = input.split('/');
      return Fraction(int.parse(parts[0]), int.parse(parts[1]));
    } else {
      return Fraction(int.parse(input), 1);
    }
  }

  static String toImproperLatex(String input) {
    input = input.trim();
    if (input.contains(' ')) {
      final parts = input.split(' ');
      final whole = int.parse(parts[0]);
      final fracParts = parts[1].split('/');
      final numerator = int.parse(fracParts[0]);
      final denominator = int.parse(fracParts[1]);
      int improperNumerator = whole.abs() * denominator + numerator;
      if (whole < 0) improperNumerator = -improperNumerator;
      return '\\frac{$improperNumerator}{$denominator}';
    } else if (input.contains('/')) {
      return toLatex(input);
    } else {
      return input;
    }
  }

  static int gcd(int a, int b) {
    return b == 0 ? a.abs() : gcd(b, a % b);
  }

  static int lcm(int a, int b) {
    return (a * b).abs() ~/ gcd(a, b);
  }

  static int lcmForList(List<int> numbers) {
    return numbers.reduce((a, b) => lcm(a, b));
  }

  static Fraction simplify(Fraction f) {
    final g = gcd(f.numerator, f.denominator);
    return Fraction(f.numerator ~/ g, f.denominator ~/ g);
  }

  static String toMixedFractionLatex(Fraction f) {
    if (f.numerator.abs() < f.denominator) {
      return '\\frac{${f.numerator}}{${f.denominator}}';
    }
    int whole = f.numerator ~/ f.denominator;
    int remainder = f.numerator.abs() % f.denominator;
    if (remainder == 0) return '$whole';
    return '$whole\\ \\frac{$remainder}{${f.denominator}}';
  }

  static String toLatex(String input) {
    input = input.trim();
    if (input.contains(' ')) {
      final parts = input.split(' ');
      final whole = parts[0];
      final fracParts = parts[1].split('/');
      return '$whole\\ \\frac{${fracParts[0]}}{${fracParts[1]}}';
    } else if (input.contains('/')) {
      final parts = input.split('/');
      return '\\frac{${parts[0]}}{${parts[1]}}';
    } else {
      return input;
    }
  }
}
