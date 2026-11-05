import 'dart:math' as math;
import '../binary_add_sub/binary_add_sub_logic.dart';
import 'binary_mul_div_models.dart';

class BinaryMulDivLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 60–64: Examples 3–4, Ex 6.2, Ex 6.3, QR #1–5 & Rev Ex 6)
  // ===========================================================================
  static const List<BinaryMulDivPreset> textbookPresets = [
    BinaryMulDivPreset(
      chipLabel: "Example 3a (Page 60): Multiply 101₂ × 11₂",
      mode: 0,
      input1: '101',
      input2: '11',
    ),
    BinaryMulDivPreset(
      chipLabel: "Example 3b (Page 60): Multiply 1 110₂ × 101₂ (With 0-Row)",
      mode: 0,
      input1: '1 110',
      input2: '101',
    ),
    BinaryMulDivPreset(
      chipLabel: "Example 3c (Page 61): Multiply 10 101₂ × 11₂",
      mode: 0,
      input1: '10 101',
      input2: '11',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.2 Part A #11: Multiply 1 111₂ × 111₂",
      mode: 0,
      input1: '1 111',
      input2: '111',
    ),
    BinaryMulDivPreset(
      chipLabel: "Example 4a (Page 61): Divide 111 111₂ ÷ 11₂",
      mode: 1,
      subMode: 0,
      input1: '111 111',
      input2: '11',
    ),
    BinaryMulDivPreset(
      chipLabel: "Example 4b & 4c (Page 61): Divide 11 000₂ ÷ 11₂",
      mode: 1,
      subMode: 0,
      input1: '11 000',
      input2: '11',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.2 Part B #5: Divide 101 010₂ ÷ 111₂",
      mode: 1,
      subMode: 0,
      input1: '101 010',
      input2: '111',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.3 #15 (Page 62): If 100₂ × y = 1 100₂, find y",
      mode: 1,
      subMode: 1, // Solve A_two * y = B_two
      input1: '1 100',
      input2: '100',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.3 #3 (Page 62): Evaluate (1 001₂ + 101₂) × 11₂",
      mode: 2,
      subMode: 0, // (A + B) * C
      input1: '1 001',
      input2: '101',
      input3: '11',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.3 #6 (Page 62): Evaluate 110₂ × (11 101₂ − 1 011₂)",
      mode: 2,
      subMode: 1, // C * (A - B)
      input1: '11 101',
      input2: '1 011',
      input3: '110',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.3 #8 (Page 62): Evaluate (111₂ + 101₂) × (111₂ − 101₂)",
      mode: 2,
      subMode: 2, // (A + B) * (A - B)
      input1: '111',
      input2: '101',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.3 #9 (Page 62): Evaluate (1 011₂)² − (101₂)²",
      mode: 2,
      subMode: 3, // A² - B²
      input1: '1 011',
      input2: '101',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.3 #12 (Page 62): Simplify 11₂ × 1 011₂ − 111₂",
      mode: 2,
      subMode: 4, // A * B - C
      input1: '11',
      input2: '1 011',
      input3: '111',
    ),
    BinaryMulDivPreset(
      chipLabel: "Ex 6.3 #13 (Page 62): Evaluate (101₂)³ + (11₂)⁴",
      mode: 2,
      subMode: 5, // (101_two)^3 + (11_two)^4 & Identity (10_two)^4 = (100_two)^2
      input1: '101',
      input2: '11',
    ),
    BinaryMulDivPreset(
      chipLabel: "QR V-Diagram #1 (Page 62): Top [101] & [110], Find Bottom (?)",
      mode: 3,
      input1: '101',
      input2: '110',
      input3: '',
    ),
    BinaryMulDivPreset(
      chipLabel: "QR V-Diagram #2 (Page 63): Top [111] & [?], Bottom [111 111]",
      mode: 3,
      input1: '111',
      input2: '',
      input3: '111 111',
    ),
  ];

  // ===========================================================================
  // BASE-2 <-> BASE-10 CONVERSION & LONG-MULTIPLICATION ARRAY HELPERS
  // ===========================================================================
  static Map<String, dynamic> expandBinaryToBase10Lines(String cleanBin) {
    final int val10 = int.parse(cleanBin, radix: 2);
    final int n = cleanBin.length;
    final List<String> powerTerms = [];
    final List<String> evalTerms = [];

    for (int i = 0; i < n; i++) {
      final int bit = cleanBin[i] == '1' ? 1 : 0;
      final int p = n - 1 - i;
      final int pVal = 1 << p;
      powerTerms.add("($bit \\times 2^{$p})");
      evalTerms.add("${bit * pVal}");
    }

    final String grouped = BinaryAddSubLogic.groupBinLaTeX(cleanBin);
    return {
      'val10': val10,
      'line1': "${grouped}_{\\text{two}} = ${powerTerms.join(' + ')}",
      'line2': "= ${evalTerms.join(' + ')} = \\mathbf{${val10}_{\\text{ten}}}",
    };
  }

  static String buildDivisionBy2RemainderTableLaTeX(int n10) {
    if (n10 <= 0) {
      return "\\begin{array}{r|l} 2 & 0 \\\\ \\hline & 0 \\text{ r } \\mathbf{0} \\end{array}";
    }
    final List<Map<String, int>> rows = [];
    int curr = n10;
    while (curr > 0) {
      rows.add({
        'div': curr,
        'quot': curr ~/ 2,
        'rem': curr % 2,
      });
      curr ~/= 2;
    }

    final StringBuffer buf = StringBuffer();
    buf.write("\\begin{array}{r|l} ");
    for (int i = 0; i < rows.length; i++) {
      final Map<String, int> r = rows[i];
      if (i == 0) {
        buf.write("2 & ${r['div']} \\\\ \\hline ");
      }
      final String arrow = i == 0 ? "\\; \\uparrow" : "\\; \\big|";
      if (i < rows.length - 1) {
        buf.write(
            "2 & ${r['quot']} \\text{ r } \\mathbf{${r['rem']}} $arrow \\\\ \\hline ");
      } else {
        buf.write(
            "  & ${r['quot']} \\text{ r } \\mathbf{${r['rem']}} $arrow ");
      }
    }
    buf.write("\\end{array}");
    return buf.toString();
  }

  /// Builds the exact Textbook Binary Long-Multiplication LaTeX Array (matching Example 3a, 3b, 3c on Pages 60–61!)
  static String buildLongMultiplicationArrayLaTeX(
      String cleanA,
      String cleanB,
      String prodBin,
      ) {
    final int maxCols = math.max(prodBin.length, cleanA.length + cleanB.length);
    final String colSpec = List.filled(maxCols + 1, 'c').join('');
    final StringBuffer buf = StringBuffer();
    buf.write("\\begin{array}{$colSpec} ");

    void writeAlignedRow(String opCell, String digits,
        {int rightShift = 0, bool isBold = false}) {
      final List<String> cells = [opCell];
      final int totalOccupied = digits.length + rightShift;
      final int leftPad = maxCols - totalOccupied;

      for (int c = 0; c < maxCols; c++) {
        if (c < leftPad || c >= maxCols - rightShift) {
          cells.add("");
        } else {
          final String bit = digits[c - leftPad];
          cells.add(isBold ? "\\mathbf{$bit}" : bit);
        }
      }
      buf.write("${cells.join(' & ')} \\\\ ");
    }

    writeAlignedRow("", cleanA);
    writeAlignedRow("\\times", cleanB);
    buf.write("\\hline ");

    // Generate partial product rows (including 0000 row when multiplier bit is '0', matching Example 3b!)
    final String zerosA = '0' * cleanA.length;
    final int mLen = cleanB.length;
    for (int i = 0; i < mLen; i++) {
      final int bitIdx = mLen - 1 - i; // right-to-left multiplier bit
      final String mBit = cleanB[bitIdx];
      final String partial = mBit == '1' ? cleanA : zerosA;
      final String opSign = (i == mLen - 1 && mLen > 1) ? "+" : "";
      writeAlignedRow(opSign, partial, rightShift: i);
    }

    if (mLen > 1) {
      buf.write("\\hline ");
      writeAlignedRow("", prodBin, isBold: true);
    }
    buf.write("\\hline \\end{array}");
    return buf.toString();
  }

  // ===========================================================================
  // MODE 0: BINARY LONG MULTIPLICATION (Example 3a–c, Ex 6.2 Part A & Rev Ex 6 #11–12)
  // ===========================================================================
  static BinaryMulDivResult solveBinaryMultiplication({
    required String factor1Str,
    required String factor2Str,
  }) {
    try {
      final String aBin = BinaryAddSubLogic.sanitizeBinary(
        factor1Str,
        fieldName: 'First Binary Number (Multiplicand)',
      );
      final String bBin = BinaryAddSubLogic.sanitizeBinary(
        factor2Str,
        fieldName: 'Second Binary Number (Multiplier)',
      );

      final int a10 = int.parse(aBin, radix: 2);
      final int b10 = int.parse(bBin, radix: 2);
      final int prod10 = a10 * b10;
      final String prodBin = prod10.toRadixString(2);

      final String longMulArrayLaTeX =
      buildLongMultiplicationArrayLaTeX(aBin, bBin, prodBin);

      final List<String> partialStepsLaTeX = [];
      final List<String> partialStepsPlain = [];
      final String zerosA = '0' * aBin.length;

      for (int i = 0; i < bBin.length; i++) {
        final int bitIdx = bBin.length - 1 - i;
        final String mBit = bBin[bitIdx];
        final String partial = mBit == '1' ? aBin : zerosA;
        final String shiftNote = i == 0
            ? "(aligned with the units column)"
            : "(shifted $i place${i == 1 ? '' : 's'} to the left)";

        partialStepsLaTeX.add(
            "\\bullet \\text{ Partial Product ${i + 1} (multiply } ${BinaryAddSubLogic.groupBinLaTeX(aBin)}_2 \\text{ by } \\mathbf{$mBit}\\text{): } ${BinaryAddSubLogic.groupBinLaTeX(aBin)}_2 \\times $mBit = \\mathbf{$partial} \\text{ $shiftNote}");
        partialStepsPlain.add(
            "• Partial Product ${i + 1}: Multiply ${BinaryAddSubLogic.groupBinPlain(aBin)}₂ by $mBit = $partial $shiftNote.");
      }

      final String exprLaTeX =
          "${BinaryAddSubLogic.groupBinLaTeX(aBin)}_2 \\times ${BinaryAddSubLogic.groupBinLaTeX(bBin)}_2";
      final String prodGroupedLaTeX =
          "${BinaryAddSubLogic.groupBinLaTeX(prodBin)}_2";

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Recall the Four Binary Multiplication Identities (Page 60)}}",
        "0 \\times 0 = 0, \\qquad 1 \\times 0 = 0, \\qquad 0 \\times 1 = 0, \\qquad 1 \\times 1 = 1",
        "",
        "\\text{\\textbf{Step 2: Set Out as Long Multiplication in Base 2 (Example 3, Pages 60–61)}}",
        longMulArrayLaTeX,
        ...partialStepsLaTeX,
        "\\text{Add the shifted partial products in base 2 to obtain } \\mathbf{$prodGroupedLaTeX}.",
        "",
        "\\text{\\textbf{Step 3: Base 10 Verification Check}}",
        "\\text{In Base 10: } ${a10}_{10} \\times ${b10}_{10} = \\mathbf{${prod10}_{10}} = \\mathbf{$prodGroupedLaTeX} \\quad (\\text{Verified!})",
      ];

      final List<BinaryMulDivStep> steps = [
        BinaryMulDivStep(
          title:
          "Step 1: Set Out as Long Multiplication & Multiply by Each Bit (1 or 0)",
          description:
          "• When multiplying numbers in base 2 (Page 60), multiply the top binary number (${BinaryAddSubLogic.groupBinPlain(aBin)}₂) by each digit (1 or 0) of the multiplier (${BinaryAddSubLogic.groupBinPlain(bBin)}₂), shifting each new partial product one column to the left:\n\n"
              "${partialStepsPlain.join('\n')}",
          mathLinesLaTeX: [longMulArrayLaTeX, ...partialStepsLaTeX],
        ),
        BinaryMulDivStep(
          title:
          "Step 2: Add Partial Products in Base 2 & Verify in Base 10",
          description:
          "• Adding the shifted partial products column-by-column in base 2 gives ${BinaryAddSubLogic.groupBinPlain(prodBin)}₂.\n"
              "• Base 10 Check: $a10 × $b10 = $prod10 = ${BinaryAddSubLogic.groupBinPlain(prodBin)}₂.",
          mathLinesLaTeX: [
            "\\therefore \\; $exprLaTeX = \\mathbf{$prodGroupedLaTeX}",
            "\\text{Base 10 Check: } ${a10}_{10} \\times ${b10}_{10} = ${prod10}_{10} = \\mathbf{$prodGroupedLaTeX}",
          ],
        ),
      ];

      return BinaryMulDivResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Multiplication": exprLaTeX,
          "Binary Product": "\\mathbf{$prodGroupedLaTeX}",
          "Base 10 Check": "${a10}_{10} \\times ${b10}_{10} = ${prod10}_{10}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryMulDivCanvasData(
          headerLaTeX:
          "\\text{Binary Long Multiplication (Example 3): } $exprLaTeX = \\mathbf{$prodGroupedLaTeX}",
          subHeaderLaTeX:
          "\\text{Rules: } 0 \\times 0 = 0, \\quad 1 \\times 0 = 0, \\quad 0 \\times 1 = 0, \\quad 1 \\times 1 = 1",
          card1Title: "Multiplicand",
          card1LaTeX: "${BinaryAddSubLogic.groupBinLaTeX(aBin)}_2 = ${a10}_{10}",
          card2Title: "Multiplier",
          card2LaTeX: "${BinaryAddSubLogic.groupBinLaTeX(bBin)}_2 = ${b10}_{10}",
          card3Title: "Binary Product",
          card3LaTeX: "\\mathbf{$prodGroupedLaTeX} \\; (${prod10}_{10})",
          middleBannerLaTeX: longMulArrayLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $exprLaTeX = \\mathbf{$prodGroupedLaTeX} \\quad (\\text{Base 10: } $a10 \\times $b10 = $prod10)",
        ),
      );
    } catch (e) {
      return BinaryMulDivResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary numbers.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: BINARY DIVISION — TEXTBOOK BASE-10 BRIDGE METHOD (Example 4a–c)
  // Covers Example 4(a–c) (Page 61), Exercise 6.2 Part B #1–8,
  // Exercise 6.3 #11 ("How many times is 10_2 contained in 1000_2?") & #15 ("100_two * y = 1100_two")
  // ===========================================================================
  static BinaryMulDivResult solveBinaryDivision({
    required int subMode, // 0: Divide A_2 ÷ B_2 (Example 4), 1: Find Missing Factor y in B_2 × y = A_2 (Ex 6.3 #15)
    required String dividendStr,
    required String divisorStr,
  }) {
    try {
      final String divBin = BinaryAddSubLogic.sanitizeBinary(
        dividendStr,
        fieldName: subMode == 0 ? 'Dividend (First Binary Number)' : 'Product (RHS Binary Number)',
      );
      final String dsorBin = BinaryAddSubLogic.sanitizeBinary(
        divisorStr,
        fieldName: subMode == 0 ? 'Divisor (Second Binary Number)' : 'Known Factor (LHS Binary Number)',
      );

      final Map<String, dynamic> expDividend = expandBinaryToBase10Lines(divBin);
      final Map<String, dynamic> expDivisor = expandBinaryToBase10Lines(dsorBin);
      final int div10 = expDividend['val10'] as int;
      final int dsor10 = expDivisor['val10'] as int;

      if (dsor10 == 0) {
        throw const FormatException("Cannot divide by 0!");
      }

      final int quot10 = div10 ~/ dsor10;
      final int rem10 = div10 % dsor10;
      final String quotBin = quot10.toRadixString(2);
      final String remBin = rem10.toRadixString(2);

      final String divGroupedLaTeX = BinaryAddSubLogic.groupBinLaTeX(divBin);
      final String dsorGroupedLaTeX = BinaryAddSubLogic.groupBinLaTeX(dsorBin);
      final String quotGroupedLaTeX = BinaryAddSubLogic.groupBinLaTeX(quotBin);
      final String divTableLaTeX = buildDivisionBy2RemainderTableLaTeX(quot10);

      final List<String> step1Lines = [
        if (subMode == 1) ...[
          "\\text{Given equation (Exercise 6.3 \\#15): } ${dsorGroupedLaTeX}_{\\text{two}} \\times y = ${divGroupedLaTeX}_{\\text{two}}",
          "\\text{Divide both sides by } ${dsorGroupedLaTeX}_{\\text{two}}:",
          "y = \\frac{${divGroupedLaTeX}_{\\text{two}}}{${dsorGroupedLaTeX}_{\\text{two}}}",
        ] else
          "\\text{Given division (Example 4 Method, Page 61): } ${divGroupedLaTeX}_2 \\div ${dsorGroupedLaTeX}_2",
        "\\text{1. Convert the dividend } ${divGroupedLaTeX}_{\\text{two}} \\text{ to base 10:}",
        expDividend['line1'] as String,
        expDividend['line2'] as String,
        "\\text{2. Convert the divisor } ${dsorGroupedLaTeX}_{\\text{two}} \\text{ to base 10:}",
        expDivisor['line1'] as String,
        expDivisor['line2'] as String,
      ];

      final List<String> step2Lines = [
        "\\text{Divide in base 10:}",
        "\\frac{${divGroupedLaTeX}_{\\text{two}}}{${dsorGroupedLaTeX}_{\\text{two}}} = \\frac{${div10}_{\\text{ten}}}{${dsor10}_{\\text{ten}}} = \\mathbf{${quot10}_{\\text{ten}}}"
            "${rem10 > 0 ? ' \\text{ remainder } ${rem10}_{\\text{ten}}' : ''}",
        "\\text{Convert } ${quot10}_{\\text{ten}} \\text{ back to base 2 using repeated division by 2:}",
        divTableLaTeX,
        "\\text{Reading the remainders upwards } (\\uparrow): \\quad ${quot10}_{\\text{ten}} = \\mathbf{${quotGroupedLaTeX}_{\\text{two}}}",
        rem10 == 0
            ? "\\therefore \\; ${divGroupedLaTeX}_2 \\div ${dsorGroupedLaTeX}_2 = \\mathbf{${quotGroupedLaTeX}_2}"
            : "\\therefore \\; ${divGroupedLaTeX}_2 \\div ${dsorGroupedLaTeX}_2 = \\mathbf{${quotGroupedLaTeX}_2 \\text{ remainder } ${remBin}_2}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Convert Both Binary Numbers to Base 10 (Example 4, Page 61)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Divide in Base 10 and Convert the Answer Back to Base 2}}",
        ...step2Lines,
      ];

      final List<BinaryMulDivStep> steps = [
        BinaryMulDivStep(
          title:
          "Step 1: Convert Dividend (${BinaryAddSubLogic.groupBinPlain(divBin)}₂) & Divisor (${BinaryAddSubLogic.groupBinPlain(dsorBin)}₂) to Base 10",
          description:
          "• Textbook Rule (Page 61): 'When dividing numbers in base 2, it is more convenient to convert the binary numbers to base 10, divide the numbers in base 10 and convert the answer back to base 2.'\n"
              "• ${BinaryAddSubLogic.groupBinPlain(divBin)}₂ = ${div10}₁₀ and ${BinaryAddSubLogic.groupBinPlain(dsorBin)}₂ = ${dsor10}₁₀.",
          mathLinesLaTeX: step1Lines,
        ),
        BinaryMulDivStep(
          title:
          "Step 2: Divide in Base 10 ($div10 ÷ $dsor10 = $quot10) & Convert Back to Base 2",
          description:
          "• Divide in base 10: $div10 ÷ $dsor10 = $quot10${rem10 > 0 ? ' remainder $rem10' : ''}.\n"
              "• Convert ${quot10}₁₀ back to base 2 by dividing repeatedly by 2 and reading the remainders upwards (↑): ${quot10}₁₀ = ${BinaryAddSubLogic.groupBinPlain(quotBin)}₂!",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return BinaryMulDivResult(
        mode: 1,
        subMode: subMode,
        finalAnswersLaTeX: {
          "Dividend in Base 10": "${div10}_{\\text{ten}}",
          "Divisor in Base 10": "${dsor10}_{\\text{ten}}",
          "Quotient in Base 10": "${quot10}_{\\text{ten}}",
          subMode == 1 ? "Value of y (Base 2)" : "Binary Quotient (Base 2)":
          "\\mathbf{${quotGroupedLaTeX}_{\\text{two}}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryMulDivCanvasData(
          headerLaTeX: subMode == 1
              ? "\\text{Ex 6.3 \\#15 Missing Factor: } ${dsorGroupedLaTeX}_{\\text{two}} \\times y = ${divGroupedLaTeX}_{\\text{two}} \\implies y = \\mathbf{${quotGroupedLaTeX}_{\\text{two}}}"
              : "\\text{Example 4 Binary Division: } ${divGroupedLaTeX}_2 \\div ${dsorGroupedLaTeX}_2 = \\mathbf{${quotGroupedLaTeX}_2}",
          subHeaderLaTeX:
          "\\frac{${divGroupedLaTeX}_{\\text{two}}}{${dsorGroupedLaTeX}_{\\text{two}}} = \\frac{${div10}_{\\text{ten}}}{${dsor10}_{\\text{ten}}} = ${quot10}_{\\text{ten}} = \\mathbf{${quotGroupedLaTeX}_{\\text{two}}}",
          card1Title: "1. Convert to Base 10",
          card1LaTeX: "${div10}_{\\text{ten}} \\div ${dsor10}_{\\text{ten}}",
          card2Title: "2. Base 10 Quotient",
          card2LaTeX: "= \\mathbf{${quot10}_{\\text{ten}}}",
          card3Title: "3. Back to Base 2",
          card3LaTeX: "\\mathbf{${quotGroupedLaTeX}_{\\text{two}}}",
          middleBannerLaTeX: divTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\frac{${divGroupedLaTeX}_{\\text{two}}}{${dsorGroupedLaTeX}_{\\text{two}}} = \\frac{${div10}_{\\text{ten}}}{${dsor10}_{\\text{ten}}} = ${quot10}_{\\text{ten}} = \\mathbf{${quotGroupedLaTeX}_{\\text{two}}}",
        ),
      );
    } catch (e) {
      return BinaryMulDivResult.error(
        mode: 1,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary numbers for the division.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: COMBINED ORDER-OF-OPERATIONS (BODMAS), BRACKETS & POWERS IN BASE 2
  // Covers Exercise 6.3 #3–10, #12–14 on Page 62!
  // ===========================================================================
  static BinaryMulDivResult solveCombinedBinaryOperations({
    required int subMode,
    // 0: (A + B) × C  [Ex 6.3 #3, #4, #5]
    // 1: C × (A − B)  [Ex 6.3 #6, #7]
    // 2: (A + B) × (A − B)  [Ex 6.3 #8]
    // 3: A² − B²  [Ex 6.3 #9: (1 011)² − (101)²]
    // 4: A × B − C  [Ex 6.3 #12: 11_two × 1 011_two − 111_two]
    // 5: Higher Powers & Identity Proof: A³ + B⁴ & Show (10_two)⁴ = (100_two)² [Ex 6.3 #13 & #14]
    required String in1Str,
    required String in2Str,
    required String in3Str,
  }) {
    try {
      final String aBin = BinaryAddSubLogic.sanitizeBinary(
        in1Str,
        fieldName: 'First Binary Number (A)',
      );
      final String bBin = BinaryAddSubLogic.sanitizeBinary(
        in2Str,
        fieldName: 'Second Binary Number (B)',
      );

      final int a10 = int.parse(aBin, radix: 2);
      final int b10 = int.parse(bBin, radix: 2);
      final String aGrp = BinaryAddSubLogic.groupBinLaTeX(aBin);
      final String bGrp = BinaryAddSubLogic.groupBinLaTeX(bBin);

      if (subMode == 0 || subMode == 1) {
        // Sub-Mode 0: (A + B) × C (#3–#5) | Sub-Mode 1: C × (A − B) (#6–#7)
        final String cBin = BinaryAddSubLogic.sanitizeBinary(
          in3Str,
          fieldName: 'Multiplier Binary Number (C)',
        );
        final int c10 = int.parse(cBin, radix: 2);
        final String cGrp = BinaryAddSubLogic.groupBinLaTeX(cBin);
        final bool isAdd = subMode == 0;

        final Map<String, dynamic> brkRes = isAdd
            ? BinaryAddSubLogic.performDetailedBinaryAddition([aBin, bBin])
            : BinaryAddSubLogic.performDetailedBinarySubtraction(aBin, bBin);
        final String brkBin =
        (isAdd ? brkRes['sumBin'] : brkRes['diffBin']) as String;
        final int brk10 = (isAdd ? brkRes['sum10'] : brkRes['diff10']) as int;
        final String brkGrp = BinaryAddSubLogic.groupBinLaTeX(brkBin);

        final int final10 = brk10 * c10;
        final String finalBin = final10.toRadixString(2);
        final String finalGrp = BinaryAddSubLogic.groupBinLaTeX(finalBin);
        final String mulArray =
        buildLongMultiplicationArrayLaTeX(brkBin, cBin, finalBin);

        final String exprLaTeX = isAdd
            ? "\\left(${aGrp}_2 + ${bGrp}_2\\right) \\times ${cGrp}_2"
            : "${cGrp}_2 \\times \\left(${aGrp}_2 - ${bGrp}_2\\right)";

        final List<String> lines = [
          "\\text{\\textbf{Step 1: Evaluate the Expression Inside the Brackets First (BODMAS)}}",
          brkRes['arrayLaTeX'] as String,
          "${aGrp}_2 ${isAdd ? '+' : '-'} ${bGrp}_2 = \\mathbf{${brkGrp}_2} \\quad (${brk10}_{10})",
          "",
          "\\text{\\textbf{Step 2: Multiply the Bracket Result by }} ${cGrp}_2",
          mulArray,
          "\\therefore \\; $exprLaTeX = \\mathbf{${finalGrp}_2} \\quad (\\text{Base 10 Check: } $brk10 \\times $c10 = $final10)",
        ];

        return BinaryMulDivResult(
          mode: 2,
          subMode: subMode,
          finalAnswersLaTeX: {
            "Bracket Value": "${brkGrp}_2 \\; (${brk10}_{10})",
            "Final Binary Product": "\\mathbf{${finalGrp}_2}",
            "Base 10 Check": "${final10}_{10}",
          },
          workingsLaTeX: lines,
          steps: [
            BinaryMulDivStep(
              title: "Step 1: Evaluate the Bracket First (BODMAS Rule)",
              description:
              "Work out the ${isAdd ? 'addition' : 'subtraction'} inside the brackets first to get ${BinaryAddSubLogic.groupBinPlain(brkBin)}₂ (${brk10}₁₀).",
              mathLinesLaTeX: lines.sublist(1, 3),
            ),
            BinaryMulDivStep(
              title:
              "Step 2: Multiply by ${BinaryAddSubLogic.groupBinPlain(cBin)}₂ Using Binary Long Multiplication",
              description:
              "Multiply ${BinaryAddSubLogic.groupBinPlain(brkBin)}₂ by ${BinaryAddSubLogic.groupBinPlain(cBin)}₂ to get ${BinaryAddSubLogic.groupBinPlain(finalBin)}₂.",
              mathLinesLaTeX: lines.sublist(5),
            ),
          ],
          canvasData: BinaryMulDivCanvasData(
            headerLaTeX:
            "\\text{Exercise 6.3 Bracketed Binary Product: } $exprLaTeX = \\mathbf{${finalGrp}_2}",
            subHeaderLaTeX:
            "\\text{Step 1 (Bracket)} = ${brkGrp}_2 \\quad \\longrightarrow \\quad \\text{Step 2 (Multiply by } ${cGrp}_2\\text{)} = \\mathbf{${finalGrp}_2}",
            card1Title: "Bracket Result",
            card1LaTeX: "${brkGrp}_2 \\; (${brk10}_{10})",
            card2Title: "Multiplier",
            card2LaTeX: "${cGrp}_2 \\; (${c10}_{10})",
            card3Title: "Final Product",
            card3LaTeX: "\\mathbf{${finalGrp}_2} \\; (${final10}_{10})",
            middleBannerLaTeX: mulArray,
            bottomSummaryLaTeX:
            "\\therefore \\; $exprLaTeX = \\mathbf{${finalGrp}_2}",
          ),
        );
      } else if (subMode == 2 || subMode == 3) {
        // Sub-Mode 2: (A + B) × (A − B) [Ex 6.3 #8]
        // Sub-Mode 3: A² − B² [Ex 6.3 #9: (1 011)² − (101)²]
        final Map<String, dynamic> addRes =
        BinaryAddSubLogic.performDetailedBinaryAddition([aBin, bBin]);
        final Map<String, dynamic> subRes =
        BinaryAddSubLogic.performDetailedBinarySubtraction(aBin, bBin);

        final String sumBin = addRes['sumBin'] as String;
        final String diffBin = subRes['diffBin'] as String;
        final int final10 = (a10 * a10) - (b10 * b10);
        final String finalBin = final10.toRadixString(2);
        final String finalGrp = BinaryAddSubLogic.groupBinLaTeX(finalBin);

        final int aSq10 = a10 * a10;
        final int bSq10 = b10 * b10;
        final String aSqBin = aSq10.toRadixString(2);
        final String bSqBin = bSq10.toRadixString(2);

        final List<String> lines = subMode == 2
            ? [
          "\\text{\\textbf{Step 1: Evaluate Both Brackets }} (${aGrp}_2 + ${bGrp}_2) \\text{\\textbf{ and }} (${aGrp}_2 - ${bGrp}_2) \\text{\\textbf{ (Ex 6.3 \\#8)}}",
          "${aGrp}_2 + ${bGrp}_2 = \\mathbf{${BinaryAddSubLogic.groupBinLaTeX(sumBin)}_2} \\quad (${a10 + b10}_{10})",
          "${aGrp}_2 - ${bGrp}_2 = \\mathbf{${BinaryAddSubLogic.groupBinLaTeX(diffBin)}_2} \\quad (${a10 - b10}_{10})",
          "",
          "\\text{\\textbf{Step 2: Multiply the Sum by the Difference}}",
          buildLongMultiplicationArrayLaTeX(sumBin, diffBin, finalBin),
          "\\therefore \\; (${aGrp}_2 + ${bGrp}_2) \\times (${aGrp}_2 - ${bGrp}_2) = \\mathbf{${finalGrp}_2} \\quad (${final10}_{10})",
        ]
            : [
          "\\text{\\textbf{Step 1: Square Each Binary Number (Exercise 6.3 \\#9)}}",
          "\\bullet \\; (${aGrp}_2)^2 = ${aGrp}_2 \\times ${aGrp}_2 = \\mathbf{${BinaryAddSubLogic.groupBinLaTeX(aSqBin)}_2} \\quad (${a10}^2 = ${aSq10}_{10})",
          "\\bullet \\; (${bGrp}_2)^2 = ${bGrp}_2 \\times ${bGrp}_2 = \\mathbf{${BinaryAddSubLogic.groupBinLaTeX(bSqBin)}_2} \\quad (${b10}^2 = ${bSq10}_{10})",
          "",
          "\\text{\\textbf{Step 2: Subtract }} (${bGrp}_2)^2 \\text{\\textbf{ from }} (${aGrp}_2)^2",
          BinaryAddSubLogic.performDetailedBinarySubtraction(
              aSqBin, bSqBin)['arrayLaTeX'] as String,
          "\\therefore \\; (${aGrp}_2)^2 - (${bGrp}_2)^2 = \\mathbf{${finalGrp}_2} \\quad (${aSq10} - ${bSq10} = ${final10}_{10})",
        ];

        return BinaryMulDivResult(
          mode: 2,
          subMode: subMode,
          finalAnswersLaTeX: {
            if (subMode == 2) ...{
              "Sum (A + B)": "${BinaryAddSubLogic.groupBinLaTeX(sumBin)}_2",
              "Difference (A − B)":
              "${BinaryAddSubLogic.groupBinLaTeX(diffBin)}_2",
            } else ...{
              "1st Square (A²)":
              "${BinaryAddSubLogic.groupBinLaTeX(aSqBin)}_2 \\; (${aSq10}_{10})",
              "2nd Square (B²)":
              "${BinaryAddSubLogic.groupBinLaTeX(bSqBin)}_2 \\; (${bSq10}_{10})",
            },
            "Final Answer (Base 2)": "\\mathbf{${finalGrp}_2}",
            "Base 10 Value": "${final10}_{10}",
          },
          workingsLaTeX: lines,
          steps: [
            BinaryMulDivStep(
              title: subMode == 2
                  ? "Step 1: Evaluate Sum & Difference Brackets, Then Multiply (Ex 6.3 #8)"
                  : "Step 1: Square Both Binary Numbers, Then Subtract (Ex 6.3 #9)",
              description:
              "Notice that by the difference of two squares identity, (A + B)(A − B) and A² − B² both evaluate to ${BinaryAddSubLogic.groupBinPlain(finalBin)}₂ (${final10}₁₀)!",
              mathLinesLaTeX: lines,
            ),
          ],
          canvasData: BinaryMulDivCanvasData(
            headerLaTeX: subMode == 2
                ? "\\text{Exercise 6.3 \\#8: } (${aGrp}_2 + ${bGrp}_2) \\times (${aGrp}_2 - ${bGrp}_2) = \\mathbf{${finalGrp}_2}"
                : "\\text{Exercise 6.3 \\#9: } (${aGrp}_2)^2 - (${bGrp}_2)^2 = \\mathbf{${finalGrp}_2}",
            subHeaderLaTeX:
            "\\text{Difference of Squares Check: } ${a10}^2 - ${b10}^2 = $aSq10 - $bSq10 = ${final10}_{10} = \\mathbf{${finalGrp}_2}",
            card1Title: subMode == 2 ? "Sum (A + B)" : "A²",
            card1LaTeX: subMode == 2
                ? "${BinaryAddSubLogic.groupBinLaTeX(sumBin)}_2"
                : "${BinaryAddSubLogic.groupBinLaTeX(aSqBin)}_2",
            card2Title: subMode == 2 ? "Diff (A − B)" : "B²",
            card2LaTeX: subMode == 2
                ? "${BinaryAddSubLogic.groupBinLaTeX(diffBin)}_2"
                : "${BinaryAddSubLogic.groupBinLaTeX(bSqBin)}_2",
            card3Title: "Final Result",
            card3LaTeX: "\\mathbf{${finalGrp}_2} \\; (${final10}_{10})",
            middleBannerLaTeX: lines[5],
            bottomSummaryLaTeX: "\\text{Final Answer} = \\mathbf{${finalGrp}_2}",
          ),
        );
      } else if (subMode == 4) {
        // Sub-Mode 4: A × B − C (Exercise 6.3 #12: Simplify 11_two × 1 011_two − 111_two)
        final String cBin = BinaryAddSubLogic.sanitizeBinary(
          in3Str,
          fieldName: 'Subtracted Binary Number (C)',
        );
        final int c10 = int.parse(cBin, radix: 2);
        final String cGrp = BinaryAddSubLogic.groupBinLaTeX(cBin);

        final int prodAB10 = a10 * b10;
        final String prodABBin = prodAB10.toRadixString(2);
        final String mulArray =
        buildLongMultiplicationArrayLaTeX(bBin, aBin, prodABBin);

        final Map<String, dynamic> subRes =
        BinaryAddSubLogic.performDetailedBinarySubtraction(prodABBin, cBin);
        final String finalBin = subRes['diffBin'] as String;
        final int final10 = subRes['diff10'] as int;
        final String finalGrp = BinaryAddSubLogic.groupBinLaTeX(finalBin);

        final List<String> lines = [
          "\\text{\\textbf{Step 1: Multiply }} ${aGrp}_{\\text{two}} \\times ${bGrp}_{\\text{two}} \\text{\\textbf{ First (BODMAS — Ex 6.3 \\#12)}}",
          mulArray,
          "${aGrp}_{\\text{two}} \\times ${bGrp}_{\\text{two}} = \\mathbf{${BinaryAddSubLogic.groupBinLaTeX(prodABBin)}_{\\text{two}}} \\quad (${prodAB10}_{10})",
          "",
          "\\text{\\textbf{Step 2: Subtract }} ${cGrp}_{\\text{two}} \\text{\\textbf{ from the Product}}",
          subRes['arrayLaTeX'] as String,
          "\\therefore \\; ${aGrp}_{\\text{two}} \\times ${bGrp}_{\\text{two}} - ${cGrp}_{\\text{two}} = \\mathbf{${finalGrp}_{\\text{two}}} \\quad ($prodAB10 - $c10 = ${final10}_{10})",
        ];

        return BinaryMulDivResult(
          mode: 2,
          subMode: 4,
          finalAnswersLaTeX: {
            "Product (A × B)":
            "${BinaryAddSubLogic.groupBinLaTeX(prodABBin)}_2 \\; (${prodAB10}_{10})",
            "Final Answer (A × B − C)": "\\mathbf{${finalGrp}_2}",
            "Base 10 Check": "${final10}_{10}",
          },
          workingsLaTeX: lines,
          steps: [
            BinaryMulDivStep(
              title:
              "Step 1: Multiply First (BODMAS), Then Subtract ${BinaryAddSubLogic.groupBinPlain(cBin)}₂ (Ex 6.3 #12)",
              description:
              "1. Multiply ${BinaryAddSubLogic.groupBinPlain(aBin)}₂ × ${BinaryAddSubLogic.groupBinPlain(bBin)}₂ = ${BinaryAddSubLogic.groupBinPlain(prodABBin)}₂ (${prodAB10}₁₀).\n"
                  "2. Subtract ${BinaryAddSubLogic.groupBinPlain(cBin)}₂ (${c10}₁₀) to get ${BinaryAddSubLogic.groupBinPlain(finalBin)}₂ (${final10}₁₀).",
              mathLinesLaTeX: lines,
            ),
          ],
          canvasData: BinaryMulDivCanvasData(
            headerLaTeX:
            "\\text{Exercise 6.3 \\#12: } ${aGrp}_2 \\times ${bGrp}_2 - ${cGrp}_2 = \\mathbf{${finalGrp}_2}",
            subHeaderLaTeX:
            "\\text{Product} = ${BinaryAddSubLogic.groupBinLaTeX(prodABBin)}_2 \\quad \\longrightarrow \\quad \\text{Subtract } ${cGrp}_2 = \\mathbf{${finalGrp}_2}",
            card1Title: "Product A × B",
            card1LaTeX: "${BinaryAddSubLogic.groupBinLaTeX(prodABBin)}_2",
            card2Title: "Subtract C",
            card2LaTeX: "-\\; ${cGrp}_2",
            card3Title: "Final Result",
            card3LaTeX: "\\mathbf{${finalGrp}_2} \\; (${final10}_{10})",
            middleBannerLaTeX: subRes['arrayLaTeX'] as String,
            bottomSummaryLaTeX:
            "\\therefore \\; ${aGrp}_2 \\times ${bGrp}_2 - ${cGrp}_2 = \\mathbf{${finalGrp}_2}",
          ),
        );
      } else {
        // Sub-Mode 5: Higher Powers (A_two)^3 + (B_two)^4 & Identity Proof (10_two)^4 = (100_two)^2 (Ex 6.3 #13 & #14!)
        final int aCube10 = a10 * a10 * a10;
        final int bFourth10 = b10 * b10 * b10 * b10;
        final int sum10 = aCube10 + bFourth10;
        final String sumBin = sum10.toRadixString(2);
        final String sumGrp = BinaryAddSubLogic.groupBinLaTeX(sumBin);
        final String divTable = buildDivisionBy2RemainderTableLaTeX(sum10);

        final List<String> lines = [
          "\\text{\\textbf{Exercise 6.3 \\#13: Evaluate }} (${aGrp}_{\\text{two}})^3 + (${bGrp}_{\\text{two}})^4",
          "1.\\; \\text{Convert to Base 10: } ${aGrp}_{\\text{two}} = ${a10}_{\\text{ten}} \\quad \\text{and} \\quad ${bGrp}_{\\text{two}} = ${b10}_{\\text{ten}}",
          "2.\\; \\text{Evaluate powers in Base 10: } (${a10}_{\\text{ten}})^3 + (${b10}_{\\text{ten}})^4 = $aCube10 + $bFourth10 = \\mathbf{${sum10}_{\\text{ten}}}",
          "3.\\; \\text{Convert } ${sum10}_{\\text{ten}} \\text{ back to Base 2 (Repeated Division by 2):}",
          divTable,
          "\\therefore \\; (${aGrp}_{\\text{two}})^3 + (${bGrp}_{\\text{two}})^4 = \\mathbf{${sumGrp}_{\\text{two}}}",
          "",
          "\\text{\\textbf{Exercise 6.3 \\#14 Proof: Show that }} (10_{\\text{two}})^4 = (100_{\\text{two}})^2",
          "\\bullet \\; \\text{LHS} = (10_{\\text{two}})^4 = (2_{\\text{ten}})^4 = 16_{\\text{ten}} = \\mathbf{10\\,000_{\\text{two}}}",
          "\\bullet \\; \\text{RHS} = (100_{\\text{two}})^2 = (4_{\\text{ten}})^2 = 16_{\\text{ten}} = \\mathbf{10\\,000_{\\text{two}}} \\quad (\\text{LHS} = \\text{RHS Shown!})",
        ];

        return BinaryMulDivResult(
          mode: 2,
          subMode: 5,
          finalAnswersLaTeX: {
            "(${aGrp}₂)³ in Base 10": "${aCube10}_{10}",
            "(${bGrp}₂)⁴ in Base 10": "${bFourth10}_{10}",
            "Sum in Base 10": "${sum10}_{10}",
            "Final Answer (Base 2)": "\\mathbf{${sumGrp}_2}",
          },
          workingsLaTeX: lines,
          steps: [
            BinaryMulDivStep(
              title:
              "Step 1: Evaluate (${BinaryAddSubLogic.groupBinPlain(aBin)}₂)³ + (${BinaryAddSubLogic.groupBinPlain(bBin)}₂)⁴ via Base 10 (Ex 6.3 #13 & #14)",
              description:
              "1. Convert ${BinaryAddSubLogic.groupBinPlain(aBin)}₂ = $a10 and ${BinaryAddSubLogic.groupBinPlain(bBin)}₂ = $b10.\n"
                  "2. Compute $a10³ + $b10⁴ = $aCube10 + $bFourth10 = $sum10.\n"
                  "3. Convert ${sum10}₁₀ back to base 2 to get ${BinaryAddSubLogic.groupBinPlain(sumBin)}₂.",
              mathLinesLaTeX: lines,
            ),
          ],
          canvasData: BinaryMulDivCanvasData(
            headerLaTeX:
            "\\text{Exercise 6.3 \\#13 \\& \\#14 Powers in Base 2: } (${aGrp}_2)^3 + (${bGrp}_2)^4 = \\mathbf{${sumGrp}_2}",
            subHeaderLaTeX:
            "${a10}^3 + ${b10}^4 = $aCube10 + $bFourth10 = ${sum10}_{10} = \\mathbf{${sumGrp}_2}",
            card1Title: "(${aGrp}₂)³",
            card1LaTeX: "${a10}^3 = ${aCube10}_{10}",
            card2Title: "(${bGrp}₂)⁴",
            card2LaTeX: "${b10}^4 = ${bFourth10}_{10}",
            card3Title: "Sum in Base 2",
            card3LaTeX: "\\mathbf{${sumGrp}_2} \\; (${sum10}_{10})",
            middleBannerLaTeX: divTable,
            bottomSummaryLaTeX:
            "\\therefore \\; (${aGrp}_2)^3 + (${bGrp}_2)^4 = \\mathbf{${sumGrp}_2} \\quad | \\quad (10_2)^4 = (100_2)^2 = 10\\,000_2",
          ),
        );
      }
    } catch (e) {
      return BinaryMulDivResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary numbers.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: QUANTITATIVE REASONING V-TREE MULTIPLICATION & DIVISION (#1–5, Pages 62–63)
  // Sample Rule: Top-Left (111_2 = 7) × Top-Right (11_2 = 3) = Bottom (10 101_2 = 21)
  // ===========================================================================
  static BinaryMulDivResult solveQuantitativeVTree({
    required String topLeftStr,
    required String topRightStr,
    required String bottomStr,
  }) {
    try {
      final String s1 = topLeftStr.trim().replaceAll('?', '');
      final String s2 = topRightStr.trim().replaceAll('?', '');
      final String s3 = bottomStr.trim().replaceAll('?', '');

      final int emptyCount =
          (s1.isEmpty ? 1 : 0) + (s2.isEmpty ? 1 : 0) + (s3.isEmpty ? 1 : 0);
      if (emptyCount != 1) {
        throw const FormatException(
          "In Quantitative Reasoning V-Diagram mode, enter the 2 known binary boxes and leave the 1 unknown box blank (or type '?').",
        );
      }

      if (s3.isEmpty) {
        // Bottom is missing (#1: 101 & 110; #4: 1 011 & 1 001) -> Multiply Top-Left × Top-Right
        final BinaryMulDivResult mulRes = solveBinaryMultiplication(
          factor1Str: s1,
          factor2Str: s2,
        );
        if (!mulRes.valid) return mulRes;

        final String topL = BinaryAddSubLogic.sanitizeBinary(s1);
        final String topR = BinaryAddSubLogic.sanitizeBinary(s2);
        final int prod10 = int.parse(topL, radix: 2) * int.parse(topR, radix: 2);
        final String botBin = prod10.toRadixString(2);
        final String botGrp = BinaryAddSubLogic.groupBinLaTeX(botBin);

        return BinaryMulDivResult(
          mode: 3,
          finalAnswersLaTeX: {
            "Top-Left Box": "${BinaryAddSubLogic.groupBinLaTeX(topL)}_2",
            "Top-Right Box": "${BinaryAddSubLogic.groupBinLaTeX(topR)}_2",
            "Missing Bottom Box (?)": "\\mathbf{${botGrp}_2} \\; (${prod10}_{10})",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Quantitative Reasoning V-Diagram Rule (Page 62 Bottom Left, Sample 1):}}",
            "\\text{Sample: } 111_2 \\; (7_{10}) \\times 11_2 \\; (3_{10}) = 10\\,101_2 \\; (21_{10}) \\implies \\mathbf{\\text{Top-Left} \\times \\text{Top-Right} = \\text{Bottom}}",
            "",
            ...mulRes.workingsLaTeX,
          ],
          steps: mulRes.steps,
          canvasData: BinaryMulDivCanvasData(
            headerLaTeX:
            "\\text{Quantitative Reasoning V-Diagram (#1, #4): Top-Left} \\times \\text{Top-Right} = \\text{Bottom}",
            subHeaderLaTeX:
            "${BinaryAddSubLogic.groupBinLaTeX(topL)}_2 \\times ${BinaryAddSubLogic.groupBinLaTeX(topR)}_2 = \\mathbf{${botGrp}_2}",
            card1Title: "Top-Left Box",
            card1LaTeX: "${BinaryAddSubLogic.groupBinLaTeX(topL)}_2",
            card2Title: "Top-Right Box",
            card2LaTeX: "${BinaryAddSubLogic.groupBinLaTeX(topR)}_2",
            card3Title: "Bottom Box (?)",
            card3LaTeX: "\\mathbf{${botGrp}_2}",
            middleBannerLaTeX: mulRes.canvasData.middleBannerLaTeX,
            bottomSummaryLaTeX:
            "\\text{Missing Bottom Box } (?) = \\mathbf{${botGrp}_2}",
          ),
        );
      } else {
        // Either Top-Right (#2: 111 and 111 111) or Top-Left (#3: 110 and 1 100; #5: 101 and 1 001 011) is missing!
        // Divide Bottom ÷ Known Top Box!
        final String knownTop = s1.isEmpty ? s2 : s1;
        final String missingLabel =
        s1.isEmpty ? "Missing Top-Left Box (?)" : "Missing Top-Right Box (?)";

        final BinaryMulDivResult divRes = solveBinaryDivision(
          subMode: 1,
          dividendStr: s3,
          divisorStr: knownTop,
        );
        if (!divRes.valid) return divRes;

        final String botClean = BinaryAddSubLogic.sanitizeBinary(s3);
        final String topClean = BinaryAddSubLogic.sanitizeBinary(knownTop);
        final int quot10 =
            int.parse(botClean, radix: 2) ~/ int.parse(topClean, radix: 2);
        final String ansBin = quot10.toRadixString(2);
        final String ansGrp = BinaryAddSubLogic.groupBinLaTeX(ansBin);

        final String topLDisp = s1.isEmpty
            ? "\\mathbf{${ansGrp}_2}"
            : "${BinaryAddSubLogic.groupBinLaTeX(topClean)}_2";
        final String topRDisp = s2.isEmpty
            ? "\\mathbf{${ansGrp}_2}"
            : "${BinaryAddSubLogic.groupBinLaTeX(topClean)}_2";

        return BinaryMulDivResult(
          mode: 3,
          finalAnswersLaTeX: {
            "Top-Left Box": topLDisp,
            "Top-Right Box": topRDisp,
            "Bottom Box": "${BinaryAddSubLogic.groupBinLaTeX(botClean)}_2",
            missingLabel: "\\mathbf{${ansGrp}_2} \\; (${quot10}_{10})",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Quantitative Reasoning V-Diagram Rule (Pages 62–63 \\#2, \\#3, \\#5):}}",
            "\\text{Since Top-Left} \\times \\text{Top-Right} = \\text{Bottom, divide the Bottom box by the known Top box:}",
            "",
            ...divRes.workingsLaTeX,
          ],
          steps: divRes.steps,
          canvasData: BinaryMulDivCanvasData(
            headerLaTeX:
            "\\text{Quantitative Reasoning V-Diagram (#2, #3, #5): } \\frac{\\text{Bottom}}{\\text{Known Top}} = \\mathbf{${ansGrp}_2}",
            subHeaderLaTeX:
            "\\frac{${BinaryAddSubLogic.groupBinLaTeX(botClean)}_2}{${BinaryAddSubLogic.groupBinLaTeX(topClean)}_2} = \\mathbf{${ansGrp}_2}",
            card1Title: "Top-Left Box",
            card1LaTeX: topLDisp,
            card2Title: "Top-Right Box",
            card2LaTeX: topRDisp,
            card3Title: "Bottom Box",
            card3LaTeX: "${BinaryAddSubLogic.groupBinLaTeX(botClean)}_2",
            middleBannerLaTeX: divRes.canvasData.middleBannerLaTeX,
            bottomSummaryLaTeX:
            "\\text{$missingLabel} = \\mathbf{${ansGrp}_2}",
          ),
        );
      }
    } catch (e) {
      return BinaryMulDivResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary numbers in 2 of the 3 boxes.",
      );
    }
  }
}