import 'dart:math' as math;
import 'formulae_substitution_models.dart';

/// Exact Rational Number Engine for Formulae & Substitution
/// Supports integers, proper/improper fractions, mixed numbers (e.g. 3 1/4, 2 3/4, 5 1/2), and decimals!
class _SubFrac {
  final int num;
  final int den;

  const _SubFrac(this.num, [this.den = 1]);

  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  static int lcm(int a, int b) =>
      (a == 0 || b == 0) ? 1 : (a.abs() * b.abs()) ~/ gcd(a, b);

  factory _SubFrac.from(int n, [int d = 1]) {
    if (d == 0) {
      throw const FormatException("Division by zero in formula evaluation.");
    }
    if (n == 0) return const _SubFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _SubFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _SubFrac.parse(String raw) {
    String s = raw.trim().replaceAll('−', '-');
    if (s.isEmpty) return const _SubFrac(0, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1).trim();
    } else if (s.startsWith('+')) {
      s = s.substring(1).trim();
    }

    // Check for mixed number like "3 1/4" or "2 3/4" or "5 1/2"
    final RegExp mixedReg = RegExp(r'^(\d+)(?:\s+|_)(\d+)/(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      return _SubFrac.from(sign * (w * d + n), d);
    }

    s = s.replaceAll(' ', '');
    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _SubFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _SubFrac.from(sign * n, d);
    }
    return _SubFrac.from(sign * int.parse(s), 1);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isImproper => num.abs() > den && den > 1;
  double get toDouble => num / den;

  _SubFrac abs() => _SubFrac(num.abs(), den);
  _SubFrac operator +(_SubFrac other) =>
      _SubFrac.from(num * other.den + other.num * den, den * other.den);
  _SubFrac operator -(_SubFrac other) =>
      _SubFrac.from(num * other.den - other.num * den, den * other.den);
  _SubFrac operator *(_SubFrac other) =>
      _SubFrac.from(num * other.num, den * other.den);
  _SubFrac operator /(_SubFrac other) =>
      _SubFrac.from(num * other.den, den * other.num);

  _SubFrac powInt(int exp) {
    if (exp == 0) return const _SubFrac(1, 1);
    int n = 1;
    int d = 1;
    for (int i = 0; i < exp.abs(); i++) {
      n *= num;
      d *= den;
    }
    return exp > 0 ? _SubFrac.from(n, d) : _SubFrac.from(d, n);
  }

  static int? _exactSqrtInt(int n) {
    if (n < 0) return null;
    if (n == 0) return 0;
    final int r = math.sqrt(n).round();
    return (r * r == n) ? r : null;
  }

  _SubFrac? exactSqrt() {
    if (num < 0) return null;
    final int? rn = _exactSqrtInt(num);
    final int? rd = _exactSqrtInt(den);
    if (rn == null || rd == null) return null;
    return _SubFrac.from(rn, rd);
  }

  String toLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr\\frac{$an}{$den}';
  }

  String toMixedLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    if (an > den) {
      final int whole = an ~/ den;
      final int rem = an % den;
      if (rem == 0) return '$signStr$whole';
      return '$signStr$whole\\frac{$rem}{$den}';
    }
    return '$signStr\\frac{$an}{$den}';
  }

  @override
  String toString() => toLaTeX();
}

/// Holds both the exact rational value AND the complete unskipped step-by-step LaTeX trail of how an expression was evaluated!
class _EvalTrace {
  final _SubFrac value;
  final String explicitFormulaLaTeX;
  final String substitutedLaTeX;
  final List<String> microStepsLaTeX;
  final List<String> proseSteps;

  const _EvalTrace({
    required this.value,
    required this.explicitFormulaLaTeX,
    required this.substitutedLaTeX,
    required this.microStepsLaTeX,
    required this.proseSteps,
  });
}

/// Recursive Descent Rational Expression Evaluator for Universal Formula Substitution
class _RationalParser {
  final String input;
  final Map<String, _SubFrac> env;
  int _pos = 0;

  _RationalParser(this.input, this.env);

  void _skipSpaces() {
    while (_pos < input.length && input[_pos] == ' ') {
      _pos++;
    }
  }

  _SubFrac parseExpression() {
    _SubFrac left = _parseTerm();
    while (true) {
      _skipSpaces();
      if (_pos >= input.length) break;
      final String ch = input[_pos];
      if (ch == '+') {
        _pos++;
        left = left + _parseTerm();
      } else if (ch == '-') {
        _pos++;
        left = left - _parseTerm();
      } else {
        break;
      }
    }
    return left;
  }

  _SubFrac _parseTerm() {
    _SubFrac left = _parseFactor();
    while (true) {
      _skipSpaces();
      if (_pos >= input.length) break;
      final String ch = input[_pos];
      if (ch == '*') {
        _pos++;
        left = left * _parseFactor();
      } else if (ch == '/') {
        _pos++;
        left = left / _parseFactor();
      } else if (ch == '(' ||
          RegExp(r'[a-zA-Z]').hasMatch(ch) ||
          input.startsWith('sqrt', _pos)) {
        left = left * _parseFactor();
      } else {
        break;
      }
    }
    return left;
  }

  _SubFrac _parseFactor() {
    _skipSpaces();
    if (_pos < input.length && input[_pos] == '+') {
      _pos++;
      return _parseFactor();
    }
    if (_pos < input.length && input[_pos] == '-') {
      _pos++;
      return const _SubFrac(-1, 1) * _parseFactor();
    }
    return _parsePower();
  }

  _SubFrac _parsePower() {
    _SubFrac base = _parsePrimary();
    _skipSpaces();
    if (_pos < input.length && input[_pos] == '^') {
      _pos++;
      final _SubFrac expFrac = _parsePrimary();
      return base.powInt(expFrac.num ~/ expFrac.den);
    }
    return base;
  }

  _SubFrac _parsePrimary() {
    _skipSpaces();
    if (_pos >= input.length) {
      return const _SubFrac(0, 1);
    }

    if (input.startsWith('sqrt(', _pos)) {
      _pos += 5;
      final _SubFrac inside = parseExpression();
      _skipSpaces();
      if (_pos < input.length && input[_pos] == ')') _pos++;
      final _SubFrac? exact = inside.exactSqrt();
      if (exact != null) return exact;
      final double approx = math.sqrt(inside.toDouble);
      return _SubFrac.parse(approx.toStringAsFixed(4));
    }

    if (input[_pos] == '(' || input[_pos] == '[') {
      final String closeChar = input[_pos] == '(' ? ')' : ']';
      _pos++;
      final _SubFrac inside = parseExpression();
      _skipSpaces();
      if (_pos < input.length && input[_pos] == closeChar) _pos++;
      return inside;
    }

    final RegExp numReg = RegExp(r'^\d+(?:\.\d+)?');
    final Match? nm = numReg.firstMatch(input.substring(_pos));
    if (nm != null) {
      final String numStr = nm.group(0)!;
      _pos += numStr.length;
      return _SubFrac.parse(numStr);
    }

    if (input.startsWith('sinpi', _pos)) {
      _pos += 5;
      return env['sinpi'] ?? env['sin'] ?? const _SubFrac(1, 2);
    }
    if (input.startsWith('pi', _pos)) {
      _pos += 2;
      return env['pi'] ?? env['π'] ?? const _SubFrac(22, 7);
    }
    if (input.startsWith('π', _pos)) {
      _pos += 1;
      return env['pi'] ?? env['π'] ?? const _SubFrac(22, 7);
    }

    final String ch = input[_pos];
    if (RegExp(r'[a-zA-Z]').hasMatch(ch)) {
      _pos++;
      if (!env.containsKey(ch)) {
        throw FormatException("Missing value for variable '$ch'.");
      }
      return env[ch]!;
    }

    _pos++;
    return const _SubFrac(0, 1);
  }
}

class FormulaeSubstitutionLogic {
  // ===========================================================================
  // 20 TEXTBOOK PRESETS (Pages 103–106 & 111–113: Examples 1–3, Ex 11.1, Ex 11.2, Rev Ex 11)
  // ===========================================================================
  static const List<FormulaeSubstitutionPreset> textbookPresets = [
    FormulaeSubstitutionPreset(
      chipLabel: "Example 1a (Page 103): a² + 3b when a = 2, b = 4",
      mode: 0,
      formulaInput: 'a^2 + 3b',
      valuesInput: 'a = 2, b = 4',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Example 1b (Page 103): 1/p + 3/q when p = 6, q = 5",
      mode: 0,
      formulaInput: '1/p + 3/q',
      valuesInput: 'p = 6, q = 5',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Example 1c (Page 103): a = (2b - 3d)/(3b - 2) when b = 4, d = 2",
      mode: 0,
      formulaInput: 'a = (2b - 3d)/(3b - 2)',
      valuesInput: 'b = 4, d = 2',
      targetVarInput: 'a',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Example 1d (Page 103): x = ac + bk when a = 2, c = 1/2, b = 1, k = 3/4",
      mode: 0,
      formulaInput: 'x = ac + bk',
      valuesInput: 'a = 2, c = 1/2, b = 1, k = 3/4',
      targetVarInput: 'x',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Example 2 (Page 105): Box Volume V = blh (b = 15, l = 13.5, h = 7)",
      mode: 2,
      formulaInput: 'V = b * l * h',
      valuesInput: 'b = 15, l = 13.5, h = 7',
      targetVarInput: 'V',
      contextDescription:
      "The volume V of a rectangular box is given by V = blh, where b is the breadth, l the length and h the height.",
      unit: ' cm³',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Example 3 (Page 105): Population T = A² + B² (A = 5000, B = 1650)",
      mode: 2,
      formulaInput: 'T = A^2 + B^2',
      valuesInput: 'A = 5000, B = 1650',
      targetVarInput: 'T',
      contextDescription:
      "The total T of a population of city C is connected by the formula T = A² + B².",
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #3 (Page 104): (x² + y²)/(z - 1) when x = 6, y = 4, z = 3",
      mode: 0,
      formulaInput: '(x^2 + y^2)/(z - 1)',
      valuesInput: 'x = 6, y = 4, z = 3',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #4 (Page 104): d/(4e) - 2/(5f) when d = 5, e = 6, f = 2",
      mode: 0,
      formulaInput: 'd/(4e) - 2/(5f)',
      valuesInput: 'd = 5, e = 6, f = 2',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #5 (Page 104): √(d² - 2u) when d = 16, u = 56",
      mode: 1,
      formulaInput: 'sqrt(d^2 - 2u)',
      valuesInput: 'd = 16, u = 56',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #6 (Page 104): s(x - y)/(x + y) when s = 3, x = 4, y = 1/2",
      mode: 0,
      formulaInput: 's(x - y)/(x + y)',
      valuesInput: 's = 3, x = 4, y = 1/2',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #13 (Page 104): b = (1/2 c)/(3d - 4) when c = 8, d = 4",
      mode: 0,
      formulaInput: 'b = (1/2 * c)/(3d - 4)',
      valuesInput: 'c = 8, d = 4',
      targetVarInput: 'b',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #18 (Page 105): Heron's Formula A = √(s(s-a)(s-b)(s-c))",
      mode: 1,
      formulaInput: 'A = sqrt(s(s - a)(s - b)(s - c))',
      valuesInput: 's = 10, a = 4, b = 2, c = 5',
      targetVarInput: 'A',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #19 (Page 105): r = x²/a² - y²/b² when x=3, a=4, y=2, b=5",
      mode: 0,
      formulaInput: 'r = x^2/a^2 - y^2/b^2',
      valuesInput: 'x = 3, a = 4, y = 2, b = 5',
      targetVarInput: 'r',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #21 (Page 105): Find y if y² = x² + z² - 6 (x = 9, z = 5)",
      mode: 1,
      formulaInput: 'y^2 = x^2 + z^2 - 6',
      valuesInput: 'x = 9, z = 5',
      targetVarInput: 'y',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.1 #22 (Page 105): AP Sum s = n/2(2a + (n-1)d) (n=14, a=0, d=4)",
      mode: 0,
      formulaInput: 's = (n/2)(2a + (n - 1)d)',
      valuesInput: 'n = 14, a = 0, d = 4',
      targetVarInput: 's',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.2 #5 (Page 106): A = π(R² - r²) (R = 6400, r = 2900, π = 22/7)",
      mode: 2,
      formulaInput: 'A = pi(R^2 - r^2)',
      valuesInput: 'pi = 22/7, R = 6400, r = 2900',
      targetVarInput: 'A',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.2 #6 (Page 106): Simple Interest I = PRT/100 (P=1000, R=5 1/2, T=3)",
      mode: 2,
      formulaInput: 'I = (P * R * T)/100',
      valuesInput: 'P = 1000, R = 5 1/2, T = 3',
      targetVarInput: 'I',
      unit: '₦',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.2 #7 (Page 106): Trapezium A = 1/2(a + b)h (a=6.5, b=3/4, h=12)",
      mode: 2,
      formulaInput: 'A = (1/2)(a + b)h',
      valuesInput: 'a = 6.5, b = 3/4, h = 12',
      targetVarInput: 'A',
      unit: ' cm²',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.2 #8 (Page 106): Quadratic Formula x = (-b ± √(b² - 4ac))/(2a)",
      mode: 1,
      formulaInput: 'x = (-b ± sqrt(b^2 - 4ac))/(2a)',
      valuesInput: 'a = 1, b = 7, c = 3 1/4',
      targetVarInput: 'x',
    ),
    FormulaeSubstitutionPreset(
      chipLabel: "Ex 11.2 #9 (Page 106): Sphere Surface Area A = 4πr² (r = 2 3/4, π = 22/7)",
      mode: 2,
      formulaInput: 'A = 4 * pi * r^2',
      valuesInput: 'pi = 22/7, r = 2 3/4',
      targetVarInput: 'A',
      unit: ' cm²',
    ),
  ];

  /// Parses comma-separated variable assignments like "a = 2, c = 1/2, b = 1, k = 3/4" or "r = 2 3/4"
  static Map<String, dynamic> _parseVariableAssignments(String rawValues) {
    final Map<String, _SubFrac> env = {};
    final List<String> mixedConversionNotesLaTeX = [];
    final List<String> assignmentChipsLaTeX = [];

    final List<String> pairs = rawValues
        .split(RegExp(r'[,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    for (final String pair in pairs) {
      if (!pair.contains('=')) continue;
      final List<String> kv = pair.split('=');
      final String k = kv[0].trim().replaceAll('π', 'pi');
      final String vRaw = kv[1].trim();

      final RegExp mixedReg = RegExp(r'^([+-]?\d+)(?:\s+|_)(\d+)/(\d+)$');
      final Match? mm = mixedReg.firstMatch(vRaw);
      final _SubFrac parsedFrac = _SubFrac.parse(vRaw);
      env[k] = parsedFrac;
      if (k == 'pi') env['π'] = parsedFrac;

      final String kDisplay = k == 'pi' ? '\\pi' : k;
      if (mm != null) {
        final String w = mm.group(1)!;
        final String n = mm.group(2)!;
        final String d = mm.group(3)!;
        mixedConversionNotesLaTeX.add(
          "\\bullet \\text{ Convert mixed number } $kDisplay = $w\\frac{$n}{$d} = \\frac{($w \\times $d) + $n}{$d} = \\mathbf{${parsedFrac.toLaTeX()}}",
        );
        assignmentChipsLaTeX
            .add("$kDisplay = $w\\frac{$n}{$d} = ${parsedFrac.toLaTeX()}");
      } else {
        assignmentChipsLaTeX.add("$kDisplay = ${parsedFrac.toLaTeX()}");
      }
    }

    return {
      'env': env,
      'mixedNotesLaTeX': mixedConversionNotesLaTeX,
      'assignmentChipsLaTeX': assignmentChipsLaTeX,
    };
  }

  /// Tokenizes and expands implicit multiplications (like "ac", "3b", "2b", "blh", "4pir^2")
  /// so EVERY letter is properly recognized and substituted with a visible \times sign!
  static String _insertExplicitMultiplication(
      String rawExpr,
      Map<String, _SubFrac> env,
      ) {
    String s = rawExpr
        .trim()
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('π', 'pi');

    s = s.replaceAll('sqrt', '§');
    s = s.replaceAll('pi', '¶');

    final StringBuffer out = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final String curr = s[i];
      out.write(curr);
      if (i + 1 < s.length) {
        final String next = s[i + 1];
        final bool currIsNum = RegExp(r'\d').hasMatch(curr);
        final bool currIsVar = RegExp(r'[a-zA-Z¶]').hasMatch(curr);
        final bool currIsClose = (curr == ')' || curr == ']');

        final bool nextIsVar = RegExp(r'[a-zA-Z¶§]').hasMatch(next);
        final bool nextIsOpen = (next == '(' || next == '[');
        final bool nextIsNum = RegExp(r'\d').hasMatch(next);

        if ((currIsNum && (nextIsVar || nextIsOpen)) ||
            (currIsVar && (nextIsVar || nextIsOpen || nextIsNum)) ||
            (currIsClose && (nextIsVar || nextIsOpen || nextIsNum))) {
          if (!(curr == '§' && next == '(')) {
            out.write('*');
          }
        }
      }
    }

    return out
        .toString()
        .replaceAll('§', 'sqrt')
        .replaceAll('¶', 'pi');
  }

  /// Evaluates a single product/power term (like "a^2", "3b", "ac", "bk", "2b", "-3d", "4*pi*r^2")
  /// and produces EVERY micro-step showing how each letter is replaced, squared, multiplied, and simplified!
  static _EvalTrace _traceProductTerm(
      String rawTerm,
      int outerSign,
      Map<String, _SubFrac> env,
      ) {
    final String expanded = _insertExplicitMultiplication(rawTerm, env);
    final List<String> factorStrs = [];
    int depth = 0;
    String cur = '';
    for (int i = 0; i < expanded.length; i++) {
      final String ch = expanded[i];
      if (ch == '(' || ch == '[') depth++;
      if (ch == ')' || ch == ']') depth--;
      if (depth == 0 && ch == '*') {
        if (cur.trim().isNotEmpty) factorStrs.add(cur.trim());
        cur = '';
      } else {
        cur += ch;
      }
    }
    if (cur.trim().isNotEmpty) factorStrs.add(cur.trim());

    final List<String> formulaFactorsLaTeX = [];
    final List<String> subFactorsLaTeX = [];
    final List<_SubFrac> factorVals = [];
    final List<String> subDescriptions = [];
    bool hadPowerOrBracket = false;

    for (final String f in factorStrs) {
      if (f.contains('^')) {
        hadPowerOrBracket = true;
        final List<String> bp = f.split('^');
        final String baseStr = bp[0].trim();
        final int exp = int.tryParse(bp[1].trim()) ?? 2;
        final _SubFrac baseVal =
        _RationalParser(baseStr, env).parseExpression();
        final _SubFrac powVal = baseVal.powInt(exp);

        final String baseDisp =
        baseStr == 'pi' ? '\\pi' : _formulaToLaTeX(baseStr);
        formulaFactorsLaTeX.add('$baseDisp^{$exp}');

        final String baseValLaTeX = baseVal.den > 1 || baseVal.isNegative
            ? "\\left(${baseVal.toLaTeX()}\\right)"
            : "(${baseVal.toLaTeX()})";
        subFactorsLaTeX.add('$baseValLaTeX^{$exp}');

        factorVals.add(powVal);
        subDescriptions.add(
          "$baseDisp^$exp = (${List.filled(exp, baseVal.toLaTeX()).join(' × ')}) = ${powVal.toLaTeX()}",
        );
      } else if (f.startsWith('(') && f.endsWith(')')) {
        hadPowerOrBracket = true;
        final String inner = f.substring(1, f.length - 1);
        final _SubFrac innerVal =
        _RationalParser(inner, env).parseExpression();
        formulaFactorsLaTeX.add('(${_formulaToLaTeX(inner)})');
        subFactorsLaTeX.add(
          "\\left(${_buildDirectSubstitutionLaTeX(inner, env)}\\right)",
        );
        factorVals.add(innerVal);
      } else {
        final _SubFrac fv = _RationalParser(f, env).parseExpression();
        final String fDisp = f == 'pi' ? '\\pi' : f;
        formulaFactorsLaTeX.add(fDisp);
        subFactorsLaTeX.add(
          fv.den > 1 || fv.isNegative
              ? "\\left(${fv.toLaTeX()}\\right)"
              : fv.toLaTeX(),
        );
        factorVals.add(fv);
        if (RegExp(r'^[a-zA-Z]+$').hasMatch(f)) {
          subDescriptions.add("$fDisp = ${fv.toLaTeX()}");
        }
      }
    }

    _SubFrac prod = _SubFrac(outerSign, 1);
    for (final _SubFrac v in factorVals) {
      prod = prod * v;
    }

    final String signPrefix = outerSign < 0 ? '-' : '';
    final String explicitForm =
        "$signPrefix${formulaFactorsLaTeX.join(' \\times ')}";
    final String subForm = "$signPrefix${subFactorsLaTeX.join(' \\times ')}";

    final List<String> chainSteps = [];
    if (formulaFactorsLaTeX.length > 1 || hadPowerOrBracket) {
      chainSteps.add(subForm);
    }

    if (hadPowerOrBracket && factorVals.length > 1) {
      chainSteps.add(
        "$signPrefix${factorVals.map((v) => v.isNegative ? '(${v.toLaTeX()})' : v.toLaTeX()).join(' \\times ')}",
      );
    }

    final bool anyFracFactor = factorVals.any((v) => v.den > 1);
    if (anyFracFactor && factorVals.length > 1) {
      final int rawNumProd = factorVals
          .map((v) => v.num)
          .reduce((int a, int b) => a * b) *
          outerSign;
      final int rawDenProd = factorVals
          .map((v) => v.den)
          .reduce((int a, int b) => a * b);
      final String numMultStr =
      factorVals.map((v) => '${v.num}').join(' \\times ');
      final List<String> denFactors = factorVals
          .where((v) => v.den > 1)
          .map((v) => '${v.den}')
          .toList();
      final String denMultStr = denFactors.length == 1
          ? denFactors.first
          : denFactors.join(' \\times ');

      chainSteps.add("\\frac{$signPrefix$numMultStr}{$denMultStr}");
      final String unreducedStr =
          "${rawNumProd < 0 ? '-' : ''}\\frac{${rawNumProd.abs()}}{$rawDenProd}";
      if (unreducedStr != prod.toLaTeX()) {
        chainSteps.add(unreducedStr);
      }
    }

    chainSteps.add("\\mathbf{${prod.toLaTeX()}}");

    return _EvalTrace(
      value: prod,
      explicitFormulaLaTeX: explicitForm,
      substitutedLaTeX: subForm,
      microStepsLaTeX: [
        "$explicitForm = ${chainSteps.join(' = ')}",
      ],
      proseSteps: [
        "Replace ${subDescriptions.join(', ')}: \$$explicitForm = ${chainSteps.join(' = ')}\$.",
      ],
    );
  }

  /// Converts a user formula string into clean display LaTeX
  static String _formulaToLaTeX(String raw) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('*', ' \\times ')
        .replaceAll('pi', '\\pi')
        .replaceAll('π', '\\pi')
        .replaceAll('±', '\\pm');

    s = s.replaceAllMapped(
      RegExp(r'sqrt\(([^()]+(?:\([^()]*\)[^()]*)*)\)'),
          (Match m) => '\\sqrt{${m.group(1)}}',
    );

    s = s.replaceAllMapped(
      RegExp(r'\(([^()]+)\)\s*/\s*\(([^()]+)\)'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    s = s.replaceAllMapped(
      RegExp(r'\(([^()]+)\)\s*/\s*([a-zA-Z0-9^]+)'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    s = s.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9^]+)\s*/\s*\(([^()]+)\)'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    s = s.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9^]+)\s*/\s*([a-zA-Z0-9^]+)'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    return s;
  }

  /// Replaces each variable in an expression with its bracketed LaTeX value for Step 1 display,
  /// properly expanding adjacent variables like "ac + bk" into "(2 \times \frac{1}{2}) + (1 \times \frac{3}{4})"!
  static String _buildDirectSubstitutionLaTeX(
      String rhsExpr,
      Map<String, _SubFrac> env,
      ) {
    final String expanded = _insertExplicitMultiplication(rhsExpr, env);
    String base = _formulaToLaTeX(expanded);

    if (env.containsKey('pi')) {
      base = base.replaceAll('\\pi', "\\left(${env['pi']!.toLaTeX()}\\right)");
    }
    final List<String> singleVars = env.keys
        .where((k) => k.length == 1 && k != 'π')
        .toList();
    for (final String v in singleVars) {
      final _SubFrac val = env[v]!;
      final String valBrack = val.den > 1 || val.isNegative
          ? "\\left(${val.toLaTeX()}\\right)"
          : "(${val.toLaTeX()})";
      base = base.replaceAllMapped(
        RegExp('(?<!\\\\)\\b$v\\b'),
            (_) => valBrack,
      );
    }
    return base;
  }

  /// Traces a general sum/difference of terms (such as numerator "2b - 3d", denominator "3b - 2", or "ac + bk")
  static _EvalTrace _traceLinearOrPolySum(
      String exprStr,
      Map<String, _SubFrac> env,
      ) {
    final String clean = exprStr.trim().replaceAll('−', '-');

    final List<String> terms = [];
    final List<int> signs = [];
    int depth = 0;
    String cur = '';
    int curSign = 1;

    for (int i = 0; i < clean.length; i++) {
      final String ch = clean[i];
      if (ch == '(' || ch == '[') depth++;
      if (ch == ')' || ch == ']') depth--;
      if (depth == 0 && (ch == '+' || ch == '-') && cur.trim().isNotEmpty) {
        terms.add(cur.trim());
        signs.add(curSign);
        cur = '';
        curSign = (ch == '-') ? -1 : 1;
      } else {
        cur += ch;
      }
    }
    if (cur.trim().isNotEmpty) {
      terms.add(cur.trim());
      signs.add(curSign);
    }

    final List<_EvalTrace> termTraces = [];
    final List<String> microLines = [];
    final List<String> proseLines = [];

    for (int i = 0; i < terms.length; i++) {
      final _EvalTrace tt = _traceProductTerm(terms[i], signs[i], env);
      termTraces.add(tt);
      final String rawTermLaTeX =
          "${signs[i] < 0 ? '-' : (i == 0 ? '' : '+')}${_formulaToLaTeX(terms[i])}";
      microLines.add(
        "\\bullet \\text{ Evaluate } $rawTermLaTeX: \\quad ${tt.microStepsLaTeX.first}",
      );
      proseLines.add("• For \$$rawTermLaTeX\$: ${tt.proseSteps.first}");
    }

    final List<_SubFrac> termValues =
    termTraces.map((t) => t.value).toList();
    final _SubFrac totalVal = termValues.fold(
      const _SubFrac(0, 1),
          (_SubFrac a, _SubFrac b) => a + b,
    );

    final String subCombinedLaTeX = termTraces
        .asMap()
        .entries
        .map((e) {
      final String s = e.value.substitutedLaTeX;
      if (e.key == 0) return s;
      return s.startsWith('-')
          ? "- ${s.substring(1).trim()}"
          : "+ $s";
    })
        .join(' ');

    if (terms.length > 1) {
      final String evaluatedTermsLine = termValues
          .asMap()
          .entries
          .map((e) => e.value.toLaTeX(withSign: e.key > 0))
          .join(' ');
      microLines.add(
        "\\bullet \\text{ Put the evaluated terms together: } = $evaluatedTermsLine",
      );

      final bool anyFrac = termValues.any((v) => v.den > 1);
      if (anyFrac) {
        final int commonLcm = termValues
            .map((t) => t.den)
            .reduce((int a, int b) => _SubFrac.lcm(a, b));
        final List<String> multNumParts = [];
        final List<String> scaledNumParts = [];
        for (int i = 0; i < termValues.length; i++) {
          final _SubFrac tv = termValues[i];
          final int mult = commonLcm ~/ tv.den;
          final int scaledN = tv.num * mult;
          final String sPrefix = scaledN < 0
              ? (i == 0 ? '-' : '- ')
              : (i == 0 ? '' : '+ ');
          multNumParts.add("$sPrefix$mult(${tv.num.abs()})");
          scaledNumParts.add("$sPrefix${scaledN.abs()}");
        }
        final int sumNum = termValues
            .map((tv) => tv.num * (commonLcm ~/ tv.den))
            .reduce((int a, int b) => a + b);
        final String unreducedSumLaTeX =
            "${sumNum < 0 ? '-' : ''}\\frac{${sumNum.abs()}}{$commonLcm}";

        microLines.addAll([
          "\\bullet \\text{ Find the LCM of the denominators } (\\text{LCM} = $commonLcm) \\text{ and combine numerators:}",
          "= \\frac{${multNumParts.join(' ')}}{$commonLcm} = \\frac{${scaledNumParts.join(' ')}}{$commonLcm} = $unreducedSumLaTeX ${unreducedSumLaTeX != totalVal.toLaTeX() ? '= \\mathbf{${totalVal.toLaTeX()}}' : ''}",
        ]);
        proseLines.add(
          "• Combine the fractions using their common denominator (LCM = $commonLcm): \$\\frac{${multNumParts.join(' ')}}{$commonLcm} = \\frac{${scaledNumParts.join(' ')}}{$commonLcm} = ${totalVal.toLaTeX()}\$.",
        );
      } else {
        microLines.add("= \\mathbf{${totalVal.toLaTeX()}}");
        proseLines.add(
          "• Combine the numbers: \$$evaluatedTermsLine = ${totalVal.toLaTeX()}\$.",
        );
      }
    }

    return _EvalTrace(
      value: totalVal,
      explicitFormulaLaTeX: _formulaToLaTeX(exprStr),
      substitutedLaTeX: subCombinedLaTeX,
      microStepsLaTeX: microLines,
      proseSteps: proseLines,
    );
  }

  // ===========================================================================
  // MASTER SOLVER: FORMULAE AND SUBSTITUTION (Pages 103–106 & 111–113)
  // ===========================================================================
  static FormulaeSubstitutionResult solveSubstitution({
    required int mode,
    required String formulaRaw,
    required String valuesRaw,
    String targetVarRaw = '',
    String contextDescription = '',
    String unit = '',
  }) {
    try {
      if (formulaRaw.trim().isEmpty || valuesRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the formula/expression (e.g. a^2 + 3b or 1/p + 3/q) and the given variable values (e.g. a = 2, b = 4).",
        );
      }

      final Map<String, dynamic> parsedVals =
      _parseVariableAssignments(valuesRaw);
      final Map<String, _SubFrac> env =
      parsedVals['env'] as Map<String, _SubFrac>;
      final List<String> mixedNotesLaTeX =
      parsedVals['mixedNotesLaTeX'] as List<String>;
      final List<String> assignmentChipsLaTeX =
      parsedVals['assignmentChipsLaTeX'] as List<String>;

      if (env.isEmpty) {
        throw const FormatException(
          "Please enter the given values in the format 'a = 2, b = 4' or 'p = 6, q = 5'.",
        );
      }

      final String cleanFormula = formulaRaw
          .trim()
          .replaceAll('−', '-')
          .replaceAll('²', '^2')
          .replaceAll('³', '^3');

      // Special Handler 1: Quadratic Formula x = (-b ± sqrt(b^2 - 4ac))/(2a) (Exercise 11.2 #8, Page 106!)
      if (cleanFormula.contains('±') ||
          cleanFormula.contains('+-') ||
          cleanFormula.replaceAll(' ', '').contains('b^2-4ac')) {
        final _SubFrac a = env['a'] ?? const _SubFrac(1, 1);
        final _SubFrac b = env['b'] ?? const _SubFrac(7, 1);
        final _SubFrac c = env['c'] ?? const _SubFrac(13, 4);

        final _SubFrac bSq = b * b;
        final _SubFrac fourAC = const _SubFrac(4, 1) * a * c;
        final _SubFrac disc = bSq - fourAC;
        final _SubFrac? sqrtDisc = disc.exactSqrt();
        if (sqrtDisc == null) {
          throw const FormatException(
            "The discriminant b² - 4ac is not a rational square.",
          );
        }
        final _SubFrac twoA = const _SubFrac(2, 1) * a;
        final _SubFrac negB = const _SubFrac(-1, 1) * b;

        final _SubFrac root1 = (negB + sqrtDisc) / twoA;
        final _SubFrac root2 = (negB - sqrtDisc) / twoA;

        final String r1Disp = root1.isImproper
            ? "${root1.toLaTeX()} = ${root1.toMixedLaTeX()}"
            : root1.toLaTeX();
        final String r2Disp = root2.isImproper
            ? "${root2.toLaTeX()} = ${root2.toMixedLaTeX()}"
            : root2.toLaTeX();

        const String quadFormulaLaTeX =
            "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}";
        final String subLineLaTeX =
            "x = \\frac{-(${b.toLaTeX()}) \\pm \\sqrt{(${b.toLaTeX()})^2 - 4(${a.toLaTeX()})\\left(${c.toLaTeX()}\\right)}}{2(${a.toLaTeX()})}";

        final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Quadratic Formula Stage (Ex 11.2 \\#8)} & \\textbf{Step-by-Step Evaluation} \\\\ \\hline "
            "\\text{1. Given Formula} & $quadFormulaLaTeX \\\\ \\hline "
            "\\text{2. Substitute } a, b, c & $subLineLaTeX \\\\ \\hline "
            "\\text{3. Discriminant } (b^2 - 4ac) & ${bSq.toLaTeX()} - ${fourAC.toLaTeX()} = \\mathbf{${disc.toLaTeX()}} \\implies \\sqrt{${disc.toLaTeX()}} = \\mathbf{${sqrtDisc.toLaTeX()}} \\\\ \\hline "
            "\\text{4. Two Roots } (x_1, x_2) & x = \\frac{${negB.toLaTeX()} \\pm ${sqrtDisc.toLaTeX()}}{${twoA.toLaTeX()}} \\implies \\mathbf{x = ${root1.toMixedLaTeX()} \\text{ or } ${root2.toMixedLaTeX()}} \\\\ \\hline "
            "\\end{array}";

        final List<String> workings = [
          "\\text{\\textbf{Given Quadratic Formula (Exercise 11.2 \\#8, Page 106):}}",
          "\\mathbf{$quadFormulaLaTeX}",
          "\\text{Given values: } ${assignmentChipsLaTeX.join(', \\quad ')}",
          if (mixedNotesLaTeX.isNotEmpty) ...mixedNotesLaTeX,
          "",
          "\\text{\\textbf{Step 1: Substitute the Given Values of }} \\mathbf{a, b, \\text{ and } c} \\text{\\textbf{ into the Formula}}",
          subLineLaTeX,
          "",
          "\\text{\\textbf{Step 2: Evaluate the Expression Under the Square Root Sign }} \\mathbf{(b^2 - 4ac)}",
          "\\bullet \\; b^2 = (${b.toLaTeX()})^2 = \\mathbf{${bSq.toLaTeX()}}",
          "\\bullet \\; 4ac = 4 \\times ${a.toLaTeX()} \\times ${c.toLaTeX()} = \\mathbf{${fourAC.toLaTeX()}}",
          "\\bullet \\; b^2 - 4ac = ${bSq.toLaTeX()} - ${fourAC.toLaTeX()} = \\mathbf{${disc.toLaTeX()}}",
          "\\bullet \\; \\sqrt{b^2 - 4ac} = \\sqrt{${disc.toLaTeX()}} = \\mathbf{${sqrtDisc.toLaTeX()}}",
          "",
          "\\text{\\textbf{Step 3: Split into the '+' Case and '−' Case to Find Both Values of }} \\mathbf{x}",
          "x = \\frac{${negB.toLaTeX()} \\pm ${sqrtDisc.toLaTeX()}}{${twoA.toLaTeX()}}",
          "\\bullet \\text{ First root (+ sign): } x_1 = \\frac{${negB.toLaTeX()} + ${sqrtDisc.toLaTeX()}}{${twoA.toLaTeX()}} = \\frac{${(negB + sqrtDisc).toLaTeX()}}{${twoA.toLaTeX()}} = \\mathbf{$r1Disp}",
          "\\bullet \\text{ Second root (− sign): } x_2 = \\frac{${negB.toLaTeX()} - ${sqrtDisc.toLaTeX()}}{${twoA.toLaTeX()}} = \\frac{${(negB - sqrtDisc).toLaTeX()}}{${twoA.toLaTeX()}} = \\mathbf{$r2Disp}",
        ];

        return FormulaeSubstitutionResult(
          mode: mode,
          finalAnswersLaTeX: {
            "Given Formula": quadFormulaLaTeX,
            "Discriminant (b² - 4ac)": disc.toLaTeX(),
            "1st Root (x₁)": "\\mathbf{$r1Disp}",
            "2nd Root (x₂)": "\\mathbf{$r2Disp}",
          },
          workingsLaTeX: workings,
          steps: [
            FormulaeSubstitutionStep(
              title: "Step 1: Convert Any Mixed Numbers & Substitute \$a, b, c\$",
              description:
              "• First, we convert any mixed fraction (such as \$c = 3\\frac{1}{4} = \\frac{13}{4}\$) into an improper fraction so we can multiply it easily.\n"
                  "• Next, we replace \$a\$, \$b\$, and \$c\$ in the quadratic formula with their given numbers inside brackets.",
              mathLinesLaTeX: [
                if (mixedNotesLaTeX.isNotEmpty) ...mixedNotesLaTeX,
                subLineLaTeX,
              ],
            ),
            FormulaeSubstitutionStep(
              title:
              "Step 2: Simplify Inside the Square Root (\$b^2 - 4ac\$) First (BODMAS)",
              description:
              "• Following BODMAS, we work out the expression inside the square root symbol first.\n"
                  "• Squaring \$b = ${b.toLaTeX()}\$ gives \$${bSq.toLaTeX()}\$, and multiplying \$4 \\times a \\times c\$ gives \$${fourAC.toLaTeX()}\$.\n"
                  "• Subtracting gives \$${bSq.toLaTeX()} - ${fourAC.toLaTeX()} = ${disc.toLaTeX()}\$, and taking the square root gives \$\\sqrt{${disc.toLaTeX()}} = ${sqrtDisc.toLaTeX()}\$.",
              mathLinesLaTeX: [
                "b^2 - 4ac = ${bSq.toLaTeX()} - ${fourAC.toLaTeX()} = ${disc.toLaTeX()}",
                "\\sqrt{${disc.toLaTeX()}} = \\mathbf{${sqrtDisc.toLaTeX()}}",
              ],
            ),
            FormulaeSubstitutionStep(
              title:
              "Step 3: Calculate Both Roots Using the \$+\$ and \$-\$ Signs",
              description:
              "• The symbol \$\\pm\$ means 'plus or minus', so we split the calculation into two separate paths: one where we add \$${sqrtDisc.toLaTeX()}\$ in the numerator, and one where we subtract \$${sqrtDisc.toLaTeX()}\$.",
              mathLinesLaTeX: [
                "x_1 = \\frac{${negB.toLaTeX()} + ${sqrtDisc.toLaTeX()}}{${twoA.toLaTeX()}} = \\mathbf{$r1Disp}",
                "x_2 = \\frac{${negB.toLaTeX()} - ${sqrtDisc.toLaTeX()}}{${twoA.toLaTeX()}} = \\mathbf{$r2Disp}",
              ],
            ),
          ],
          canvasData: FormulaeSubstitutionCanvasData(
            headerLaTeX:
            "\\text{Quadratic Formula Substitution (Ex 11.2 \\#8): } \\mathbf{x = ${root1.toMixedLaTeX()} \\text{ or } ${root2.toMixedLaTeX()}}",
            subHeaderLaTeX: subLineLaTeX,
            card1Title: "Discriminant",
            card1LaTeX: "b^2 - 4ac = \\mathbf{${disc.toLaTeX()}}",
            card2Title: "1st Root (x₁)",
            card2LaTeX: "\\mathbf{$r1Disp}",
            card3Title: "2nd Root (x₂)",
            card3LaTeX: "\\mathbf{$r2Disp}",
            substitutionTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\mathbf{x = ${root1.toMixedLaTeX()} \\quad \\text{or} \\quad x = ${root2.toMixedLaTeX()}}",
          ),
        );
      }

      // Separate LHS subject (if present, e.g. "a = (2b - 3d)/(3b - 2)" or "y^2 = x^2 + z^2 - 6") from RHS expression
      String lhsSubject = targetVarRaw.trim();
      String rhsExpr = cleanFormula;
      bool lhsIsSquared = false;

      if (cleanFormula.contains('=')) {
        final List<String> eqParts = cleanFormula.split('=');
        final String leftSide = eqParts[0].trim();
        final String rightSide = eqParts[1].trim();
        if (RegExp(r'^[a-zA-Z](?:\^2)?$').hasMatch(leftSide)) {
          lhsSubject = leftSide.replaceAll('^2', '');
          lhsIsSquared = leftSide.endsWith('^2');
          rhsExpr = rightSide;
        } else if (RegExp(r'^[a-zA-Z](?:\^2)?$').hasMatch(rightSide)) {
          lhsSubject = rightSide.replaceAll('^2', '');
          lhsIsSquared = rightSide.endsWith('^2');
          rhsExpr = leftSide;
        }
      }

      final String formulaDisplayLaTeX = _formulaToLaTeX(cleanFormula);
      final String directSubLaTeX = _buildDirectSubstitutionLaTeX(rhsExpr, env);

      // Evaluate the RHS expression using our exact rational recursive-descent parser
      final _RationalParser parser =
      _RationalParser(_insertExplicitMultiplication(rhsExpr, env), env);
      final _SubFrac rhsVal = parser.parseExpression();

      // Build detailed intermediate breakdown lines so NOT A SINGLE STEP is skipped!
      final List<String> intermediateLinesLaTeX = [];
      final List<String> intermediateProseBullets = [];

      final String rhsTrimmed = rhsExpr.trim();
      if (rhsTrimmed.startsWith('sqrt(') && rhsTrimmed.endsWith(')')) {
        final String insideSqrt =
        rhsTrimmed.substring(5, rhsTrimmed.length - 1).trim();
        final _EvalTrace insideTrace = _traceLinearOrPolySum(insideSqrt, env);
        intermediateLinesLaTeX.addAll([
          "\\text{\\textbf{Step 3a: Evaluate the Expression Inside the Square Root }} \\left(${_formulaToLaTeX(insideSqrt)}\\right):",
          ...insideTrace.microStepsLaTeX,
          "\\text{\\textbf{Step 3b: Take the Square Root of }} \\mathbf{${insideTrace.value.toLaTeX()}}:",
          "\\sqrt{${insideTrace.value.toLaTeX()}} = \\mathbf{${rhsVal.toLaTeX()}}",
        ]);
        intermediateProseBullets.addAll([
          ...insideTrace.proseSteps,
          "• Finally, take the square root of \$${insideTrace.value.toLaTeX()}\$ to get \$\\sqrt{${insideTrace.value.toLaTeX()}} = ${rhsVal.toLaTeX()}\$.",
        ]);
      } else {
        int topSlashIdx = -1;
        int depth = 0;
        for (int i = 0; i < rhsExpr.length; i++) {
          if (rhsExpr[i] == '(' || rhsExpr[i] == '[') depth++;
          if (rhsExpr[i] == ')' || rhsExpr[i] == ']') depth--;
          if (depth == 0 && rhsExpr[i] == '/') {
            topSlashIdx = i;
            break;
          }
        }

        if (topSlashIdx != -1) {
          String numSubExpr = rhsExpr.substring(0, topSlashIdx).trim();
          String denSubExpr = rhsExpr.substring(topSlashIdx + 1).trim();
          if (numSubExpr.startsWith('(') && numSubExpr.endsWith(')')) {
            numSubExpr = numSubExpr.substring(1, numSubExpr.length - 1);
          }
          if (denSubExpr.startsWith('(') && denSubExpr.endsWith(')')) {
            denSubExpr = denSubExpr.substring(1, denSubExpr.length - 1);
          }
          final _EvalTrace numTrace = _traceLinearOrPolySum(numSubExpr, env);
          final _EvalTrace denTrace = _traceLinearOrPolySum(denSubExpr, env);
          final _SubFrac numVal = numTrace.value;
          final _SubFrac denVal = denTrace.value;

          final String unreducedDivLaTeX =
              "\\frac{${numVal.toLaTeX()}}{${denVal.toLaTeX()}}";
          final int gNumDen = (numVal.den == 1 && denVal.den == 1)
              ? _SubFrac.gcd(numVal.num.abs(), denVal.num.abs())
              : 1;

          intermediateLinesLaTeX.addAll([
            "\\text{\\textbf{Step 3a: Evaluate the Numerator }} \\left(${_formulaToLaTeX(numSubExpr)}\\right):",
            ...numTrace.microStepsLaTeX,
            "",
            "\\text{\\textbf{Step 3b: Evaluate the Denominator }} \\left(${_formulaToLaTeX(denSubExpr)}\\right):",
            ...denTrace.microStepsLaTeX,
            "",
            "\\text{\\textbf{Step 3c: Divide Numerator by Denominator \\& Reduce to Lowest Terms:}}",
            if (gNumDen > 1)
              "$unreducedDivLaTeX = \\frac{${numVal.num} \\div $gNumDen}{${denVal.num} \\div $gNumDen} = \\mathbf{${rhsVal.toLaTeX()}}"
            else
              "$unreducedDivLaTeX = \\mathbf{${rhsVal.toLaTeX()}}",
          ]);
          intermediateProseBullets.addAll([
            "• Work out the top part (numerator) step-by-step:",
            ...numTrace.proseSteps,
            "• Work out the bottom part (denominator) step-by-step:",
            ...denTrace.proseSteps,
            if (gNumDen > 1)
              "• Divide numerator and denominator by their common factor ($gNumDen): \$\\frac{${numVal.num} \\div $gNumDen}{${denVal.num} \\div $gNumDen} = ${rhsVal.toLaTeX()}\$."
            else
              "• Divide the numerator by the denominator: \$$unreducedDivLaTeX = ${rhsVal.toLaTeX()}\$.",
          ]);
        } else {
          final _EvalTrace fullTrace = _traceLinearOrPolySum(rhsExpr, env);
          intermediateLinesLaTeX.addAll(fullTrace.microStepsLaTeX);
          intermediateProseBullets.addAll(fullTrace.proseSteps);
        }
      }

      String finalAnswerLaTeX = '';
      final List<String> rootExtractionLinesLaTeX = [];

      if (lhsIsSquared) {
        final _SubFrac? sqRoot = rhsVal.exactSqrt();
        if (sqRoot != null) {
          finalAnswerLaTeX = "\\pm ${sqRoot.toMixedLaTeX()}";
          rootExtractionLinesLaTeX.addAll([
            "$lhsSubject^2 = ${rhsVal.toLaTeX()}",
            "\\text{Take the square root of both sides:}",
            "$lhsSubject = \\pm\\sqrt{${rhsVal.toLaTeX()}} = \\mathbf{\\pm ${sqRoot.toMixedLaTeX()}}",
          ]);
        } else {
          finalAnswerLaTeX = "\\pm\\sqrt{${rhsVal.toLaTeX()}}";
        }
      } else {
        final String exactStr = rhsVal.toLaTeX();
        final String mixedStr = rhsVal.toMixedLaTeX();
        finalAnswerLaTeX =
        rhsVal.isImproper ? "$exactStr = $mixedStr" : exactStr;
      }

      final String lhsPrefix =
      lhsSubject.isNotEmpty ? "$lhsSubject = " : "";
      final String unitSuffix =
      unit.isNotEmpty ? "\\text{$unit}" : "";
      final String unitPrefix =
      unit.startsWith('₦') ? "\\text{₦}" : "";
      final String formattedWithUnit = unit.startsWith('₦')
          ? "$lhsPrefix$unitPrefix$finalAnswerLaTeX"
          : "$lhsPrefix$finalAnswerLaTeX$unitSuffix";

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Substitution Stage (Pages 103–105)} & \\textbf{Mathematical Working} \\\\ \\hline "
          "\\text{1. Given Formula / Expression} & \\mathbf{$formulaDisplayLaTeX} \\\\ \\hline "
          "\\text{2. Given Variable Values} & ${assignmentChipsLaTeX.join(', \\quad ')} \\\\ \\hline "
          "\\text{3. Direct Substitution} & $lhsPrefix$directSubLaTeX \\\\ \\hline "
          "\\text{4. Final Evaluated Value} & \\mathbf{$formattedWithUnit} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Principle of Substitution (Page 103):}}",
        "\\text{Substitution means replacing letters in an algebraic expression or formula with their given}",
        "\\text{numerical values in order to evaluate the quantity.}",
        if (contextDescription.trim().isNotEmpty)
          "\\text{Context: $contextDescription}",
        "",
        "\\text{\\textbf{Step 1: Write Down the Formula and the Given Values}}",
        "\\text{Formula / Expression: } \\mathbf{$formulaDisplayLaTeX}",
        "\\text{Given Values: } \\mathbf{${assignmentChipsLaTeX.join(', \\quad ')}}",
        if (mixedNotesLaTeX.isNotEmpty) ...[
          "",
          "\\text{\\textbf{Preliminary Step: Convert Mixed Numbers to Improper Fractions}}",
          ...mixedNotesLaTeX,
        ],
        "",
        "\\text{\\textbf{Step 2: Substitute Each Letter with Its Numerical Value Inside Brackets}}",
        "${lhsIsSquared ? '$lhsSubject^2 = ' : lhsPrefix}$directSubLaTeX",
        "",
        "\\text{\\textbf{Step 3: Evaluate Step-by-Step Following BODMAS (Brackets, Powers, Multiply/Divide, Add/Subtract)}}",
        ...intermediateLinesLaTeX,
        if (rootExtractionLinesLaTeX.isNotEmpty)
          ...rootExtractionLinesLaTeX
        else
          "\\therefore \\; \\mathbf{$formattedWithUnit}",
      ];

      final List<FormulaeSubstitutionStep> steps = [
        FormulaeSubstitutionStep(
          title:
          "Step 1: Identify the Formula and Given Variable Values (Page 103)",
          description:
          "• A formula is a mathematical rule that connects two or more quantities using letters.\n"
              "• We first list the exact numerical value given for each letter: \$${assignmentChipsLaTeX.join(', \\; ')}\$."
              "${mixedNotesLaTeX.isNotEmpty ? '\n• Since some values are given as mixed fractions, we convert them to improper fractions first so we can multiply and divide them accurately.' : ''}",
          mathLinesLaTeX: [
            "\\text{Formula: } \\mathbf{$formulaDisplayLaTeX}",
            "\\text{Given: } ${assignmentChipsLaTeX.join(', \\quad ')}",
            if (mixedNotesLaTeX.isNotEmpty) ...mixedNotesLaTeX,
          ],
        ),
        FormulaeSubstitutionStep(
          title:
          "Step 2: Replace Every Letter with Its Given Number in Brackets",
          description:
          "• We carefully replace each letter in the formula with its numerical value wrapped in brackets.\n"
              "• Why do we put brackets around substituted numbers? Because in algebra, letters written side-by-side (like \$3b\$ or \$ac\$) mean multiplication, and brackets prevent signs or digits from getting mixed up!",
          mathLinesLaTeX: [
            "${lhsIsSquared ? '$lhsSubject^2 = ' : lhsPrefix}$directSubLaTeX",
          ],
        ),
        FormulaeSubstitutionStep(
          title: "Step 3: Evaluate Using BODMAS & Simplify Fractions",
          description:
          "• Following the BODMAS order of operations, we evaluate powers/squares and brackets first, then multiplications and divisions, and finally additions and subtractions.\n"
              "${intermediateProseBullets.isNotEmpty ? intermediateProseBullets.join('\n') : '• Simplifying the arithmetic step-by-step gives our final exact value.'}",
          mathLinesLaTeX: [
            ...intermediateLinesLaTeX,
            if (rootExtractionLinesLaTeX.isNotEmpty)
              ...rootExtractionLinesLaTeX
            else
              "\\therefore \\; \\mathbf{$formattedWithUnit}",
          ],
        ),
      ];

      return FormulaeSubstitutionResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Formula": formulaDisplayLaTeX,
          "Given Values": assignmentChipsLaTeX.join(',\\; '),
          "Evaluated Answer": "\\mathbf{$formattedWithUnit}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: FormulaeSubstitutionCanvasData(
          headerLaTeX:
          "\\text{Formulae \\& Substitution (Pages 103–106): } \\mathbf{$formattedWithUnit}",
          subHeaderLaTeX:
          "${lhsIsSquared ? '$lhsSubject^2 = ' : lhsPrefix}$directSubLaTeX = \\mathbf{$formattedWithUnit}",
          card1Title: "Formula",
          card1LaTeX: "\\mathbf{$formulaDisplayLaTeX}",
          card2Title: "Given Values",
          card2LaTeX: assignmentChipsLaTeX.join(',\\; '),
          card3Title: "Evaluated Result",
          card3LaTeX: "\\mathbf{$formattedWithUnit}",
          substitutionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX: "\\therefore \\; \\mathbf{$formattedWithUnit}",
        ),
      );
    } catch (e) {
      return FormulaeSubstitutionResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please check your formula and variable values (e.g. Formula: a^2 + 3b, Values: a = 2, b = 4).",
      );
    }
  }
}