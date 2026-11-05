import 'dart:math' as math;
import 'numerical_to_words_models.dart';

/// Internal Abstract Syntax Tree (AST) node representing a number or operation in a numerical expression.
class _ExprNode {
  final String kind; // 'num', 'op', 'mul3'
  final String op; // '+', '-', '*', '/'
  final double? numVal;
  final String? numStr;
  final List<_ExprNode> children;
  final bool hadExplicitBrackets;
  final bool isImplicitBracketMul; // e.g., 3(14.1 + 0.9) or 6(18 + 8)

  const _ExprNode({
    required this.kind,
    this.op = '',
    this.numVal,
    this.numStr,
    this.children = const [],
    this.hadExplicitBrackets = false,
    this.isImplicitBracketMul = false,
  });
}

/// Evaluated & translated information for an [_ExprNode].
class _TranslatedNodeInfo {
  final double value;
  final int ratNum;
  final int ratDen;
  final String mathPlain; // e.g., "(18 + 11) − 6"
  final String mathLaTeX; // e.g., "\\frac{(18 + 11) - 6}{5}"
  final String primaryWords; // Exact textbook phrasing (Page 28–29)
  final String altWords; // Alternative exam phrasing
  final String operatorSymbol;
  final String bridgeBadge;
  final List<String> breakdownPlainLines;
  final List<String> breakdownLaTeXLines;
  final List<String> evalLaTeXLines;

  // For the 2-branch visual syntax tree
  final String leftTitle;
  final String leftMath;
  final String leftWords;
  final String rightTitle;
  final String rightMath;
  final String rightWords;

  const _TranslatedNodeInfo({
    required this.value,
    required this.ratNum,
    required this.ratDen,
    required this.mathPlain,
    required this.mathLaTeX,
    required this.primaryWords,
    required this.altWords,
    required this.operatorSymbol,
    required this.bridgeBadge,
    required this.breakdownPlainLines,
    required this.breakdownLaTeXLines,
    required this.evalLaTeXLines,
    required this.leftTitle,
    required this.leftMath,
    required this.leftWords,
    required this.rightTitle,
    required this.rightMath,
    required this.rightWords,
  });
}

class NumericalToWordsLogic {
  // ===========================================================================
  // ALL 25 TEXTBOOK PRESETS (Pages 28–29: Example 13a–e & Exercise 2.5 #1–20)
  // ===========================================================================
  static const List<NumericalToWordsPreset> textbookPresets = [
    NumericalToWordsPreset(
      chipLabel: "Ex 13a: 42 + 68",
      mode: 0,
      exprInput: '42 + 68',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex 13b: 67 − 8 (Positive Difference)",
      mode: 0,
      exprInput: '67 - 8',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex 13c: 2 − 5 (Negative Difference)",
      mode: 0,
      exprInput: '2 - 5',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex 13d: 4 × 6",
      mode: 0,
      exprInput: '4 * 6',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex 13e: (53 × 79) / 22",
      mode: 0,
      exprInput: '(53 * 79) / 22',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #1: 11 + 21",
      mode: 0,
      exprInput: '11 + 21',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #2: 9 − 4 + 2",
      mode: 0,
      exprInput: '9 - 4 + 2',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #3: 3 + 2 / (2 + 1)",
      mode: 0,
      exprInput: '3 + 2 / (2 + 1)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #4: 9 / (4 × 2)",
      mode: 0,
      exprInput: '9 / (4 * 2)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #5: 9 + (3 × 2)",
      mode: 0,
      exprInput: '9 + (3 * 2)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #6: 3(14.1 + 0.9)",
      mode: 0,
      exprInput: '3(14.1 + 0.9)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #7: 49 × 21 + 21",
      mode: 0,
      exprInput: '49 * 21 + 21',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #8: 11 − 17 (Negative Difference)",
      mode: 0,
      exprInput: '11 - 17',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #9: 33 − (−104) (Positive Difference)",
      mode: 0,
      exprInput: '33 - (-104)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #10: (−15 × 7) / 20",
      mode: 0,
      exprInput: '(-15 * 7) / 20',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #11: −9 / (3 × −4)",
      mode: 0,
      exprInput: '-9 / (3 * -4)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #12: 6(18 + 8) / 16",
      mode: 0,
      exprInput: '6(18 + 8) / 16',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #13: (15 + 11) − 10",
      mode: 0,
      exprInput: '(15 + 11) - 10',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #14: −12 + (−5)",
      mode: 0,
      exprInput: '-12 + (-5)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #15: 8 × 5(12 + 10)",
      mode: 0,
      exprInput: '8 * 5(12 + 10)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #16: 25 / (5 × 8)",
      mode: 0,
      exprInput: '25 / (5 * 8)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #17: ((18 + 11) − 6) / 5",
      mode: 0,
      exprInput: '((18 + 11) - 6) / 5',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #18: (32 × 6) / (29 − 14)",
      mode: 0,
      exprInput: '(32 * 6) / (29 - 14)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #19: 56 / (14 × 12)",
      mode: 0,
      exprInput: '56 / (14 * 12)',
    ),
    NumericalToWordsPreset(
      chipLabel: "Ex #20: (3 × 15 − 9) / 6",
      mode: 0,
      exprInput: '(3 * 15 - 9) / 6',
    ),
  ];

  // ===========================================================================
  // FORMATTING & RATIONAL ARITHMETIC HELPERS
  // ===========================================================================
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

  static String fmt(double v, {int maxDecimals = 4}) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String capitalizeSentence(String s) {
    final String t = s.trim();
    if (t.isEmpty) return '';
    final String cap = t[0].toUpperCase() + t.substring(1);
    return cap.endsWith('.') ? cap : '$cap.';
  }

  static Map<String, String> formatRational(int num, int den) {
    if (den == 0) {
      return {
        'plain': 'Undefined (Division by 0)',
        'latex': '\\text{Undefined}',
      };
    }
    if (num == 0) {
      return {'plain': '0', 'latex': '0'};
    }
    final bool isNeg = (num < 0) ^ (den < 0);
    int n = num.abs();
    int d = den.abs();
    final int g = gcd(n, d);
    n ~/= g;
    d ~/= g;
    final String sign = isNeg ? '-' : '';

    if (d == 1) {
      return {'plain': '$sign$n', 'latex': '$sign$n'};
    }
    if (n > d) {
      final int w = n ~/ d;
      final int rem = n % d;
      return {
        'plain': '$sign$w $rem/$d (or ${fmt(num / den)})',
        'latex': '$sign\\frac{$n}{$d} = $sign$w\\frac{$rem}{$d}',
      };
    }
    return {
      'plain': '$sign$n/$d (or ${fmt(num / den)})',
      'latex': '$sign\\frac{$n}{$d}',
    };
  }

  // ===========================================================================
  // RECURSIVE EXPRESSION PARSER (Supports Implicit Bracket Multiplication!)
  // ===========================================================================
  static String _stripOuterParens(String s) {
    String cur = s.trim();
    while (cur.startsWith('(') && cur.endsWith(')')) {
      int depth = 0;
      bool matchesOuter = true;
      for (int i = 0; i < cur.length; i++) {
        if (cur[i] == '(') depth++;
        if (cur[i] == ')') depth--;
        if (depth == 0 && i < cur.length - 1) {
          matchesOuter = false;
          break;
        }
      }
      if (matchesOuter) {
        cur = cur.substring(1, cur.length - 1).trim();
      } else {
        break;
      }
    }
    return cur;
  }

  static bool _isBinaryOperatorAt(String s, int idx) {
    final String ch = s[idx];
    if (ch == '*' || ch == '/') return true;
    if (ch != '+' && ch != '-') return false;
    if (idx == 0) return false;
    int j = idx - 1;
    while (j >= 0 && s[j] == ' ') {
      j--;
    }
    if (j < 0) return false;
    final String prev = s[j];
    // If preceded by '(', '+', '-', '*', '/', then this '+' or '-' is a unary sign on a negative/positive number!
    if (prev == '(' ||
        prev == '+' ||
        prev == '-' ||
        prev == '*' ||
        prev == '/') {
      return false;
    }
    return true;
  }

  static int _findLastTopLevelAddSub(String s) {
    int depth = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      final String ch = s[i];
      if (ch == ')') depth++;
      if (ch == '(') depth--;
      if (depth == 0 &&
          (ch == '+' || ch == '-') &&
          _isBinaryOperatorAt(s, i)) {
        return i;
      }
    }
    return -1;
  }

  static int _findLastTopLevelMulDiv(String s) {
    int depth = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      final String ch = s[i];
      if (ch == ')') depth++;
      if (ch == '(') depth--;
      if (depth == 0 &&
          (ch == '*' || ch == '/') &&
          _isBinaryOperatorAt(s, i)) {
        return i;
      }
    }
    return -1;
  }

  static _ExprNode parseExpression(
      String raw, {
        bool hadExplicitBrackets = false,
      }) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('[', '(')
        .replaceAll(']', ')')
        .trim();

    if (s.isEmpty) {
      throw const FormatException(
        "Please enter a numerical expression (e.g. 42 + 68, 67 - 8, 2 - 5, 3(14.1 + 0.9), or (53 * 79) / 22).",
      );
    }

    // Check if the entire expression is wrapped in outer parentheses
    final String stripped = _stripOuterParens(s);
    if (stripped.length != s.length) {
      // Check if stripped is just a negative number like "(-104)" or "(-5)"
      final double? negCheck = double.tryParse(stripped.replaceAll(' ', ''));
      if (negCheck != null) {
        return _ExprNode(
          kind: 'num',
          numVal: negCheck,
          numStr: fmt(negCheck),
          hadExplicitBrackets: true,
        );
      }
      return parseExpression(stripped, hadExplicitBrackets: true);
    }

    // 1. Check for top-level Addition (+) or Subtraction (-) from right to left
    final int addSubIdx = _findLastTopLevelAddSub(s);
    if (addSubIdx != -1) {
      final String op = s[addSubIdx];
      final String leftRaw = s.substring(0, addSubIdx).trim();
      final String rightRaw = s.substring(addSubIdx + 1).trim();
      final _ExprNode leftNode = parseExpression(leftRaw);
      final _ExprNode rightNode = parseExpression(rightRaw);

      return _ExprNode(
        kind: 'op',
        op: op,
        children: [leftNode, rightNode],
        hadExplicitBrackets: hadExplicitBrackets,
      );
    }

    // 2. Check for 3-factor implicit bracket multiplication like "8 * 5(12 + 10)" (Exercise #15!)
    final RegExp mul3ImplicitReg = RegExp(
      r'^([+-]?\d+\.?\d*)\s*\*\s*([+-]?\d+\.?\d*)\s*\((.+)\)$',
    );
    final Match? m3 = mul3ImplicitReg.firstMatch(s);
    if (m3 != null) {
      final String innerCheck = m3.group(3)!;
      // Ensure the '(' and ')' match as a single group
      if (_stripOuterParens('($innerCheck)') == innerCheck.trim()) {
        final _ExprNode f1 = parseExpression(m3.group(1)!);
        final _ExprNode f2 = parseExpression(m3.group(2)!);
        final _ExprNode f3 =
        parseExpression(innerCheck, hadExplicitBrackets: true);
        return _ExprNode(
          kind: 'mul3',
          op: '*',
          children: [f1, f2, f3],
          hadExplicitBrackets: hadExplicitBrackets,
          isImplicitBracketMul: true,
        );
      }
    }

    // 3. Check for top-level Multiplication (*) or Division (/)
    final int mulDivIdx = _findLastTopLevelMulDiv(s);
    if (mulDivIdx != -1) {
      final String op = s[mulDivIdx];
      final String leftRaw = s.substring(0, mulDivIdx).trim();
      final String rightRaw = s.substring(mulDivIdx + 1).trim();
      final _ExprNode leftNode = parseExpression(leftRaw);
      final _ExprNode rightNode = parseExpression(rightRaw);

      return _ExprNode(
        kind: 'op',
        op: op,
        children: [leftNode, rightNode],
        hadExplicitBrackets: hadExplicitBrackets,
      );
    }

    // 4. Check for 2-factor implicit bracket multiplication like "3(14.1 + 0.9)" or "6(18 + 8)" (#6 & #12!)
    final RegExp implicitBracketReg =
    RegExp(r'^([+-]?\d+\.?\d*)\s*\((.+)\)$');
    final Match? impM = implicitBracketReg.firstMatch(s);
    if (impM != null) {
      final _ExprNode coeffNode = parseExpression(impM.group(1)!);
      final _ExprNode bracketNode =
      parseExpression(impM.group(2)!, hadExplicitBrackets: true);
      return _ExprNode(
        kind: 'op',
        op: '*',
        children: [coeffNode, bracketNode],
        hadExplicitBrackets: hadExplicitBrackets,
        isImplicitBracketMul: true,
      );
    }

    // 5. Base Case: Single Number (Integer or Decimal, Positive or Negative)
    final String cleanNum = s.replaceAll(' ', '');
    final double? val = double.tryParse(cleanNum);
    if (val == null) {
      throw FormatException(
        "Could not parse '$raw'. Use +, -, *, / and brackets, e.g. 67 - 8, 3(14.1 + 0.9), or (53 * 79) / 22.",
      );
    }

    return _ExprNode(
      kind: 'num',
      numVal: val,
      numStr: fmt(val),
      hadExplicitBrackets: hadExplicitBrackets,
    );
  }

  // ===========================================================================
  // RECURSIVE AST EVALUATOR & ENGLISH WORD TRANSLATOR (Pages 28–29 Rules!)
  // ===========================================================================
  static _TranslatedNodeInfo _translateAndEvaluateNode(
      _ExprNode node, {
        bool isRoot = false,
      }) {
    // 1. Leaf Number Node
    if (node.kind == 'num') {
      final double v = node.numVal!;
      final String s = node.numStr!;
      int decPlaces = 0;
      if (s.contains('.')) {
        decPlaces = s.split('.')[1].length.clamp(0, 6);
      }
      final int den = math.pow(10, decPlaces).round();
      final int num = (v * den).round();
      final int g = gcd(num, den);

      return _TranslatedNodeInfo(
        value: v,
        ratNum: num ~/ g,
        ratDen: den ~/ g,
        mathPlain: s,
        mathLaTeX: s,
        primaryWords: s,
        altWords: s,
        operatorSymbol: '',
        bridgeBadge: 'Single Number: $s',
        breakdownPlainLines: [],
        breakdownLaTeXLines: [],
        evalLaTeXLines: [s],
        leftTitle: 'Number',
        leftMath: s,
        leftWords: s,
        rightTitle: '',
        rightMath: '',
        rightWords: '',
      );
    }

    // 2. Three-Factor Product Node: k1 * k2(a + b) (Exercise #15: 8 × 5(12 + 10))
    if (node.kind == 'mul3') {
      final _TranslatedNodeInfo c1 =
      _translateAndEvaluateNode(node.children[0]);
      final _TranslatedNodeInfo c2 =
      _translateAndEvaluateNode(node.children[1]);
      final _TranslatedNodeInfo c3 =
      _translateAndEvaluateNode(node.children[2]);

      final double val = c1.value * c2.value * c3.value;
      final int rNum = c1.ratNum * c2.ratNum * c3.ratNum;
      final int rDen = c1.ratDen * c2.ratDen * c3.ratDen;
      final int g = gcd(rNum, rDen);

      final String mathPlain =
          "${c1.mathPlain} × ${c2.mathPlain}(${c3.mathPlain})";
      final String mathLaTeX =
          "${c1.mathLaTeX} \\times ${c2.mathLaTeX}(${c3.mathLaTeX})";

      final String primaryWords =
          "the product of ${c1.primaryWords}, ${c2.primaryWords} and ${c3.primaryWords}";
      final String altWords =
          "the product of ${c1.primaryWords} and ${c2.primaryWords} multiplied by ${c3.primaryWords}";

      final List<String> bPlain = [
        ...c3.breakdownPlainLines,
        "• Inside the brackets: (${c3.mathPlain}) translates to '${c3.primaryWords}' (= ${fmt(c3.value)}).",
        "• Multiplying by ${c1.mathPlain} and ${c2.mathPlain} gives: '$primaryWords'.",
      ];
      final List<String> bLaTeX = [
        ...c3.breakdownLaTeXLines,
        "\\bullet \\text{ Bracket } (${c3.mathLaTeX}): \\; \\text{${c3.primaryWords}}",
        "\\bullet \\text{ Full expression } $mathLaTeX: \\; \\text{$primaryWords}",
      ];
      final List<String> evLines = [
        "$mathLaTeX = ${c1.mathLaTeX} \\times ${c2.mathLaTeX} \\times ${fmt(c3.value)}",
        "= ${fmt(c1.value * c2.value)} \\times ${fmt(c3.value)} = \\mathbf{${fmt(val)}}",
      ];

      return _TranslatedNodeInfo(
        value: val,
        ratNum: rNum ~/ g,
        ratDen: rDen ~/ g,
        mathPlain: mathPlain,
        mathLaTeX: mathLaTeX,
        primaryWords: primaryWords,
        altWords: altWords,
        operatorSymbol: '×',
        bridgeBadge: '3-Factor Product (Implicit Bracket Multiplication)',
        breakdownPlainLines: bPlain,
        breakdownLaTeXLines: bLaTeX,
        evalLaTeXLines: evLines,
        leftTitle: 'Multipliers (${c1.mathPlain} × ${c2.mathPlain})',
        leftMath: '${c1.mathPlain} × ${c2.mathPlain} = ${fmt(c1.value * c2.value)}',
        leftWords: 'the product of ${c1.primaryWords} and ${c2.primaryWords}',
        rightTitle: 'Bracket (${c3.mathPlain})',
        rightMath: '(${c3.mathPlain}) = ${fmt(c3.value)}',
        rightWords: c3.primaryWords,
      );
    }

    // 3. Binary Operation Node ('+', '-', '*', '/')
    final String op = node.op;
    final _ExprNode leftChild = node.children[0];
    final _ExprNode rightChild = node.children[1];
    final _TranslatedNodeInfo L = _translateAndEvaluateNode(leftChild);
    final _TranslatedNodeInfo R = _translateAndEvaluateNode(rightChild);

    // Format child math display (adding parentheses if explicit brackets were present)
    String formatChildPlain(_ExprNode chNode, _TranslatedNodeInfo chInfo,
        {bool isRightOperand = false}) {
      if (chNode.hadExplicitBrackets) {
        return "(${chInfo.mathPlain})";
      }
      if (isRightOperand && chNode.kind == 'num' && chInfo.value < 0 && (op == '+' || op == '-')) {
        return "(${chInfo.mathPlain})";
      }
      return chInfo.mathPlain;
    }

    String formatChildLaTeX(_ExprNode chNode, _TranslatedNodeInfo chInfo,
        {bool isRightOperand = false}) {
      if (chNode.hadExplicitBrackets) {
        return "(${chInfo.mathLaTeX})";
      }
      if (isRightOperand && chNode.kind == 'num' && chInfo.value < 0 && (op == '+' || op == '-')) {
        return "(${chInfo.mathLaTeX})";
      }
      return chInfo.mathLaTeX;
    }

    final String lPlain = formatChildPlain(leftChild, L);
    final String rPlain =
    formatChildPlain(rightChild, R, isRightOperand: true);
    final String lLaTeX = formatChildLaTeX(leftChild, L);
    final String rLaTeX =
    formatChildLaTeX(rightChild, R, isRightOperand: true);

    double val = 0.0;
    int rNum = 0;
    int rDen = 1;
    String mathPlain = "";
    String mathLaTeX = "";
    String primaryWords = "";
    String altWords = "";
    String opSym = "";
    String bridgeBadge = "";
    final List<String> bPlain = [
      ...L.breakdownPlainLines,
      ...R.breakdownPlainLines,
    ];
    final List<String> bLaTeX = [
      ...L.breakdownLaTeXLines,
      ...R.breakdownLaTeXLines,
    ];
    final List<String> evLines = [];

    // Join helper that inserts a comma when the first phrase already contains "and" (for clarity!)
    String joinWithAnd(String phrase1, String phrase2) {
      if (phrase1.contains(' and ')) {
        return "$phrase1, and $phrase2";
      }
      return "$phrase1 and $phrase2";
    }

    if (op == '+') {
      val = L.value + R.value;
      rDen = (L.ratDen * R.ratDen) ~/ gcd(L.ratDen, R.ratDen);
      rNum = L.ratNum * (rDen ~/ L.ratDen) + R.ratNum * (rDen ~/ R.ratDen);

      mathPlain = "$lPlain + $rPlain";
      mathLaTeX = "$lLaTeX + $rLaTeX";
      opSym = '+';
      bridgeBadge = "Addition (+)  ➔  'the sum of ... and ...'";

      // Special natural phrasing for chains like 9 - 4 + 2 (#2) or 49 * 21 + 21 (#7)
      if (leftChild.kind == 'op' &&
          leftChild.op == '-' &&
          !leftChild.hadExplicitBrackets) {
        primaryWords =
        "${R.primaryWords} added to ${L.primaryWords} (or: the sum of ${L.primaryWords}, and ${R.primaryWords})";
        altWords = "${L.primaryWords} plus ${R.primaryWords}";
      } else {
        primaryWords = "the sum of ${joinWithAnd(L.primaryWords, R.primaryWords)}";
        altWords = "${R.primaryWords} added to ${L.primaryWords}";
      }

      bPlain.add(
          "• Addition ($mathPlain): Using the textbook rule 'a + b is the sum of a and b', this translates to '$primaryWords'.");
      bLaTeX.add(
          "\\bullet \\; $mathLaTeX \\longrightarrow \\text{the sum of ${L.primaryWords} and ${R.primaryWords}}");

      if (leftChild.kind != 'num' || rightChild.kind != 'num') {
        evLines.add("$mathLaTeX = ${fmt(L.value)} + ${R.value < 0 ? '(${fmt(R.value)})' : fmt(R.value)}");
      }
      evLines.add("$mathLaTeX = \\mathbf{${formatRational(rNum, rDen)['latex']}}");
    } else if (op == '-') {
      val = L.value - R.value;
      rDen = (L.ratDen * R.ratDen) ~/ gcd(L.ratDen, R.ratDen);
      rNum = L.ratNum * (rDen ~/ L.ratDen) - R.ratNum * (rDen ~/ R.ratDen);

      mathPlain = "$lPlain − $rPlain";
      mathLaTeX = "$lLaTeX - $rLaTeX";
      opSym = '−';

      // Page 28 Textbook Rule: Compare L.value and R.value!
      // If L.value > R.value -> "the positive difference between L and R"
      // If L.value < R.value -> "the negative difference between L and R"
      final bool isPositiveDiff = L.value >= R.value;
      final String diffTypeWord =
      isPositiveDiff ? "positive difference" : "negative difference";
      final String compSym = isPositiveDiff ? ">" : "<";

      bridgeBadge =
      "Compare: ${fmt(L.value)} $compSym ${fmt(R.value)}  ➔  ${isPositiveDiff ? 'Positive' : 'Negative'} Difference";

      primaryWords =
      "the $diffTypeWord between ${joinWithAnd(L.primaryWords, R.primaryWords)}";
      altWords = "${R.primaryWords} subtracted from ${L.primaryWords}";

      bPlain.add(
          "• Subtraction ($mathPlain): Compare the first quantity (${fmt(L.value)}) and the second quantity (${fmt(R.value)}).\n"
              "  Since ${fmt(L.value)} $compSym ${fmt(R.value)}, the result is ${isPositiveDiff ? 'positive' : 'negative'}, so by the Page 28 rule this is '$primaryWords' (or '$altWords').");
      bLaTeX.add(
          "\\bullet \\; \\text{Compare } ${fmt(L.value)} \\text{ and } ${fmt(R.value)}: \\quad \\mathbf{${fmt(L.value)} $compSym ${fmt(R.value)}} \\implies \\text{\\textbf{$diffTypeWord}}");
      bLaTeX.add(
          "\\bullet \\; $mathLaTeX \\longrightarrow \\text{$primaryWords}");

      if (leftChild.kind != 'num' || rightChild.kind != 'num') {
        evLines.add(
            "$mathLaTeX = ${fmt(L.value)} - ${R.value < 0 ? '(${fmt(R.value)})' : fmt(R.value)}");
      } else if (R.value < 0) {
        evLines.add(
            "$mathLaTeX = ${L.mathLaTeX} + ${fmt(R.value.abs())}");
      }
      evLines.add("$mathLaTeX = \\mathbf{${formatRational(rNum, rDen)['latex']}}");
    } else if (op == '*') {
      val = L.value * R.value;
      rNum = L.ratNum * R.ratNum;
      rDen = L.ratDen * R.ratDen;
      final int g = gcd(rNum, rDen);
      rNum ~/= g;
      rDen ~/= g;

      if (node.isImplicitBracketMul) {
        mathPlain = "${L.mathPlain}(${R.mathPlain})";
        mathLaTeX = "${L.mathLaTeX}(${R.mathLaTeX})";
      } else {
        mathPlain = "$lPlain × $rPlain";
        mathLaTeX = "$lLaTeX \\times $rLaTeX";
      }

      opSym = '×';
      bridgeBadge = node.isImplicitBracketMul
          ? "Implicit Bracket Multiplication  ➔  'the product of ... and ...'"
          : "Multiplication (×)  ➔  'the product of ... and ...'";

      primaryWords =
      "the product of ${joinWithAnd(L.primaryWords, R.primaryWords)}";
      altWords = "${L.primaryWords} multiplied by ${R.primaryWords}";

      bPlain.add(
          "• Multiplication ($mathPlain): ${node.isImplicitBracketMul ? 'A number written directly in front of a bracket means multiplication. ' : ''}This translates to '$primaryWords'.");
      bLaTeX.add(
          "\\bullet \\; $mathLaTeX \\longrightarrow \\text{$primaryWords}");

      if (leftChild.kind != 'num' || rightChild.kind != 'num') {
        evLines.add(
            "$mathLaTeX = ${fmt(L.value)} \\times ${R.value < 0 ? '(${fmt(R.value)})' : fmt(R.value)}");
      }
      evLines.add("$mathLaTeX = \\mathbf{${formatRational(rNum, rDen)['latex']}}");
    } else {
      // Division ('/') — Fractional bar Numerator / Denominator (Example 13e & #3, #4, #10–12, #16–20)
      if (R.value.abs() < 1e-12 || R.ratNum == 0) {
        throw const FormatException("Denominator cannot be zero.");
      }
      val = L.value / R.value;
      rNum = L.ratNum * R.ratDen;
      rDen = L.ratDen * R.ratNum;
      if (rDen < 0) {
        rNum = -rNum;
        rDen = -rDen;
      }
      final int g = gcd(rNum, rDen);
      rNum ~/= g;
      rDen ~/= g;

      // In a fraction \frac{Numerator}{Denominator}, outer brackets on numerator/denominator are not needed in LaTeX
      mathPlain =
      "${leftChild.kind == 'num' ? L.mathPlain : '(${L.mathPlain})'} / ${rightChild.kind == 'num' ? R.mathPlain : '(${R.mathPlain})'}";
      mathLaTeX = "\\frac{${L.mathLaTeX}}{${R.mathLaTeX}}";
      opSym = '÷';
      bridgeBadge =
      "Fraction Bar (Numerator ÷ Denominator)  ➔  '... divided by ...'";

      // Add a comma before "divided by" if the numerator is a compound phrase for crystal-clear English!
      final String commaBeforeDiv =
      leftChild.kind == 'num' ? "" : (L.primaryWords.length > 26 ? "," : "");
      primaryWords =
      "${L.primaryWords}$commaBeforeDiv divided by ${R.primaryWords}";
      altWords =
      "the quotient when ${L.primaryWords} is divided by ${R.primaryWords}";

      bPlain.add(
          "• Fraction Bar ($mathPlain): As shown in Example 13e, translate the entire numerator first ('${L.primaryWords}'), followed by 'divided by' and the denominator ('${R.primaryWords}'): '$primaryWords'.");
      bLaTeX.add(
          "\\bullet \\; \\text{Numerator } (${L.mathLaTeX}) \\div \\text{Denominator } (${R.mathLaTeX}) \\longrightarrow \\text{$primaryWords}");

      if (leftChild.kind != 'num' || rightChild.kind != 'num') {
        evLines.add(
            "$mathLaTeX = \\frac{${fmt(L.value)}}{${fmt(R.value)}}");
      }
      evLines.add(
          "$mathLaTeX = \\mathbf{${formatRational(rNum, rDen)['latex']}}");
    }

    return _TranslatedNodeInfo(
      value: val,
      ratNum: rNum,
      ratDen: rDen,
      mathPlain: mathPlain,
      mathLaTeX: mathLaTeX,
      primaryWords: primaryWords,
      altWords: altWords,
      operatorSymbol: opSym,
      bridgeBadge: bridgeBadge,
      breakdownPlainLines: bPlain,
      breakdownLaTeXLines: bLaTeX,
      evalLaTeXLines: evLines,
      leftTitle: op == '/' ? 'Numerator (Top)' : '1st Part (Left)',
      leftMath: "${L.mathPlain} = ${fmt(L.value)}",
      leftWords: L.primaryWords,
      rightTitle: op == '/' ? 'Denominator (Bottom)' : '2nd Part (Right)',
      rightMath: "${R.mathPlain} = ${fmt(R.value)}",
      rightWords: R.primaryWords,
    );
  }

  // ===========================================================================
  // MASTER SOLVER FOR ANY NUMERICAL EXPRESSION (Modes 0, 1, 2 & 3)
  // ===========================================================================
  static NumericalToWordsResult solveNumericalExpressionToWords({
    required int mode,
    int subMode = 0,
    required String rawExpression,
  }) {
    try {
      final _ExprNode root = parseExpression(rawExpression);
      if (root.kind == 'num') {
        throw const FormatException(
          "Please include at least one operation (+, −, ×, ÷, or brackets) so the expression can be translated into words.",
        );
      }

      final _TranslatedNodeInfo info =
      _translateAndEvaluateNode(root, isRoot: true);
      final Map<String, String> valFmt =
      formatRational(info.ratNum, info.ratDen);

      final String finalSentence = capitalizeSentence(info.primaryWords);
      final String altSentence = capitalizeSentence(info.altWords);

      // STEP 1: Inner-to-Outer Structural & Sign Breakdown (Safe for Math.tex!)
      final List<String> step1LaTeX = [
        "\\text{Given Numerical Expression:}",
        "\\mathbf{${info.mathLaTeX}}",
        ...info.breakdownLaTeXLines,
      ];

      // STEP 2: Complete English Word Translation (Textbook Example 13 Style)
      final List<String> step2LaTeX = [
        "${info.mathLaTeX} \\; : \\; \\mathbf{\\text{$finalSentence}}",
        "\\text{Alternative Accepted Phrasing: } \\text{$altSentence}",
      ];

      // STEP 3: Unabridged BODMAS Numerical Evaluation Check
      final List<String> step3LaTeX = [
        "\\text{Evaluate } ${info.mathLaTeX} \\text{ step-by-step using BODMAS:}",
        ...info.evalLaTeXLines,
        if (valFmt['plain'] != fmt(info.value))
          "\\text{Decimal Equivalent} = \\mathbf{${fmt(info.value)}}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Break Down Each Part of the Numerical Expression}}",
        ...step1LaTeX,
        "",
        "\\text{\\textbf{Step 2: Write the Complete Expression in Words (Example 13 Style)}}",
        ...step2LaTeX,
        "",
        "\\text{\\textbf{Step 3: Step-by-Step Numerical Evaluation (BODMAS Check)}}",
        ...step3LaTeX,
      ];

      final List<NumericalToWordsStep> steps = [
        NumericalToWordsStep(
          title:
          "Step 1: Analyze the Parts & Operations in ${info.mathPlain} (Page 28 Rules)",
          description:
          "• Textbook Rules (Page 28):\n"
              "  1. a + b is 'the sum of a and b'.\n"
              "  2. If a > b, then a − b is 'the positive difference between a and b', whereas b − a is 'the negative difference between b and a'.\n"
              "  3. a × b (or k(a + b)) is 'the product of ...'.\n"
              "  4. A fraction bar (Numerator / Denominator) is read as '... divided by ...'.\n\n"
              "${info.breakdownPlainLines.join('\n')}",
          mathLinesLaTeX: step1LaTeX,
        ),
        NumericalToWordsStep(
          title:
          "Step 2: Combine into the Complete English Word Statement (Example 13)",
          description:
          "Putting the translated parts together in order gives:\n"
              "• Textbook Word Form: \"$finalSentence\"\n"
              "• Alternative Exam Form: \"$altSentence\"",
          mathLinesLaTeX: step2LaTeX,
        ),
        NumericalToWordsStep(
          title: "Step 3: Evaluate the Numerical Expression Using BODMAS",
          description:
          "For completeness, evaluating the expression ${info.mathPlain} step-by-step gives ${valFmt['plain']}.",
          mathLinesLaTeX: step3LaTeX,
        ),
      ];

      return NumericalToWordsResult(
        mode: mode,
        subMode: subMode,
        finalAnswers: {
          "Numerical Expression": info.mathPlain,
          "In Words (Textbook)": finalSentence,
          "Evaluated Value": valFmt['plain']!,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: NumericalToWordsCanvasData(
          leftNodeTitle: info.leftTitle,
          leftNodeMath: info.leftMath,
          leftNodeWords: info.leftWords,
          rightNodeTitle: info.rightTitle,
          rightNodeMath: info.rightMath,
          rightNodeWords: info.rightWords,
          bridgeSymbol: info.operatorSymbol,
          bridgeRuleBadge: info.bridgeBadge,
          primaryWordsBanner: "In Words:  \"$finalSentence\"",
          altWordsBanner: "Alt Form:  \"$altSentence\"",
          evaluatedValueBanner:
          "Expression: ${info.mathPlain}   |   Evaluated Value = ${valFmt['plain']}",
          headerBadge: "${info.mathPlain}   ➔   \"$finalSentence\"",
          subBadge: info.bridgeBadge,
        ),
      );
    } catch (e) {
      return NumericalToWordsResult.error(
        mode: mode,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid numerical expression.",
      );
    }
  }

  // ===========================================================================
  // STRUCTURED BUILDER HELPERS FOR MODES 1, 2 & 3
  // ===========================================================================
  static NumericalToWordsResult solveStructuredMode1({
    required int subMode,
    // 0: a + b (Sum)
    // 1: a - b (Auto Positive / Negative Difference)
    // 2: a * b (Product)
    // 3: a - b + c (Three-Term Chain — Ex #2)
    required String aStr,
    required String bStr,
    required String cStr,
  }) {
    final String a = aStr.trim();
    final String b = bStr.trim();
    final String c = cStr.trim();
    if (a.isEmpty || b.isEmpty || (subMode == 3 && c.isEmpty)) {
      return NumericalToWordsResult.error(
        mode: 1,
        subMode: subMode,
        message: "Please enter numbers in all fields.",
      );
    }

    final String bFormatted =
    b.startsWith('-') && !b.startsWith('(') ? '($b)' : b;
    String expr = "";
    if (subMode == 0) {
      expr = "$a + $bFormatted";
    } else if (subMode == 1) {
      expr = "$a - $bFormatted";
    } else if (subMode == 2) {
      expr = "$a * $b";
    } else {
      expr = "$a - $bFormatted + $c";
    }
    return solveNumericalExpressionToWords(
      mode: 1,
      subMode: subMode,
      rawExpression: expr,
    );
  }

  static NumericalToWordsResult solveStructuredMode2({
    required int subMode,
    // 0: k(a + b) or k(a - b) — Ex #6: 3(14.1 + 0.9)
    // 1: a + (b * c) — Ex #5: 9 + (3 * 2)
    // 2: a * b + c — Ex #7: 49 * 21 + 21
    // 3: (a + b) - c — Ex #13: (15 + 11) - 10
    // 4: k1 * k2(a + b) — Ex #15: 8 * 5(12 + 10)
    required String in1Str,
    required String in2Str,
    required String in3Str,
  }) {
    final String p1 = in1Str.trim();
    final String p2 = in2Str.trim();
    final String p3 = in3Str.trim();
    if (p1.isEmpty || p2.isEmpty || p3.isEmpty) {
      return NumericalToWordsResult.error(
        mode: 2,
        subMode: subMode,
        message: "Please fill in all three fields for the bracketed expression.",
      );
    }

    String expr = "";
    if (subMode == 0) {
      expr = "$p1($p2 + $p3)";
    } else if (subMode == 1) {
      expr = "$p1 + ($p2 * $p3)";
    } else if (subMode == 2) {
      expr = "$p1 * $p2 + $p3";
    } else if (subMode == 3) {
      expr = "($p1 + $p2) - $p3";
    } else {
      // For subMode 4 (Ex #15: 8 * 5(12 + 10)), in1 = "8 * 5" or "8", in2 = "12", in3 = "10"
      final String prefix = p1.contains('*') || p1.contains('×') ? p1 : "8 * $p1";
      expr = "$prefix($p2 + $p3)";
    }
    return solveNumericalExpressionToWords(
      mode: 2,
      subMode: subMode,
      rawExpression: expr,
    );
  }

  static NumericalToWordsResult solveStructuredMode3({
    required int subMode,
    // 0: Numerator / Denominator — Ex 13e & #4, #10–12, #16–20
    // 1: Whole Number + (Numerator / Denominator) — Ex #3: 3 + 2 / (2 + 1)
    required String numeratorStr,
    required String denominatorStr,
    required String leadingWholeStr,
  }) {
    final String num = numeratorStr.trim();
    final String den = denominatorStr.trim();
    final String whole = leadingWholeStr.trim();
    if (num.isEmpty || den.isEmpty || (subMode == 1 && whole.isEmpty)) {
      return NumericalToWordsResult.error(
        mode: 3,
        subMode: subMode,
        message:
        "Please enter both the Numerator expression and the Denominator expression.",
      );
    }

    final String numWrapped =
    double.tryParse(num.replaceAll(' ', '')) != null ? num : '($num)';
    final String denWrapped =
    double.tryParse(den.replaceAll(' ', '')) != null ? den : '($den)';

    final String expr = subMode == 0
        ? "$numWrapped / $denWrapped"
        : "$whole + ($numWrapped / $denWrapped)";

    return solveNumericalExpressionToWords(
      mode: 3,
      subMode: subMode,
      rawExpression: expr,
    );
  }
}