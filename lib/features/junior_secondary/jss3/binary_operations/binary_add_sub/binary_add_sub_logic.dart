import 'dart:math' as math;
import 'binary_add_sub_models.dart';

class BinaryAddSubLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 58–60 & 62–64: Examples 1–2, Ex 6.1, QR & Rev Ex 6)
  // ===========================================================================
  static const List<BinaryAddSubPreset> textbookPresets = [
    BinaryAddSubPreset(
      chipLabel: "Example 1a (Page 58): Add 111₂ + 11₂",
      mode: 0,
      input1: '111',
      input2: '11',
    ),
    BinaryAddSubPreset(
      chipLabel: "Example 1d (Page 59): Add 110 111₂ + 1 110₂",
      mode: 0,
      input1: '110 111',
      input2: '1 110',
    ),
    BinaryAddSubPreset(
      chipLabel: "Ex 6.1 #7 (Page 60): 3-Row Addition 1 010₂ + 11 011₂ + 11 101₂",
      mode: 0,
      input1: '1 010',
      input2: '11 011',
      input3: '11 101',
    ),
    BinaryAddSubPreset(
      chipLabel: "Example 2a (Page 59): Subtract 1 110₂ − 111₂",
      mode: 1,
      input1: '1 110',
      input2: '111',
    ),
    BinaryAddSubPreset(
      chipLabel: "Example 2b (Page 59): Subtract 11 001₂ − 110₂",
      mode: 1,
      input1: '11 001',
      input2: '110',
    ),
    BinaryAddSubPreset(
      chipLabel: "Example 2c (Page 59): Subtract 11 011₂ − 1 101₂",
      mode: 1,
      input1: '11 011',
      input2: '1 101',
    ),
    BinaryAddSubPreset(
      chipLabel: "Rev Ex 6 #4 & #5 (Page 63): Multi-Zero Borrow 100 001₂ − 1 111₂",
      mode: 1,
      input1: '100 001',
      input2: '1 111',
    ),
    BinaryAddSubPreset(
      chipLabel: "Ex 6.1 #11: Missing Addend 10 111₂ + ••••• = 100 100₂",
      mode: 2,
      subMode: 0, // Missing Addend
      input1: '10 111',
      input2: '',
      input3: '100 100',
    ),
    BinaryAddSubPreset(
      chipLabel: "Ex 6.1 #12: 3-Row Missing Addend 1 111₂ + •••• + 1 010₂ = 100 001₂",
      mode: 2,
      subMode: 0,
      input1: '1 111',
      input2: '1 010',
      input3: '100 001',
    ),
    BinaryAddSubPreset(
      chipLabel: "Ex 6.1 #14: 3-Row Missing Addend 1 001₂ + •••• + 1 111₂ = 101 001₂",
      mode: 2,
      subMode: 0,
      input1: '1 001',
      input2: '1 111',
      input3: '101 001',
    ),
    BinaryAddSubPreset(
      chipLabel: "Ex 6.1 #21: Missing Subtrahend 11 110₂ − ••••• = 1 001₂",
      mode: 2,
      subMode: 1, // Missing Subtrahend (M - •••• = D)
      input1: '11 110',
      input3: '1 001',
    ),
    BinaryAddSubPreset(
      chipLabel: "Ex 6.1 #22: Missing Minuend •••••• − 1 111₂ = 11 010₂",
      mode: 2,
      subMode: 2, // Missing Minuend (•••• - S = D)
      input1: '1 111',
      input3: '11 010',
    ),
    BinaryAddSubPreset(
      chipLabel: "Rev Ex 6 #10 (Page 64): ••••••• − 101 010₂ = 101 011₂",
      mode: 2,
      subMode: 2,
      input1: '101 010',
      input3: '101 011',
    ),
    BinaryAddSubPreset(
      chipLabel: "QR Split-Box #6 (Page 63): Top [1 110 | 111], Find Bottom (?)",
      mode: 3,
      subMode: 0, // QR Split-Box
      input1: '1 110',
      input2: '111',
      input3: '',
    ),
    BinaryAddSubPreset(
      chipLabel: "QR Split-Box #7 (Page 63): Top [11 110 | ?], Bottom [111 100]",
      mode: 3,
      subMode: 0,
      input1: '11 110',
      input2: '',
      input3: '111 100',
    ),
    BinaryAddSubPreset(
      chipLabel: "Ex 6.3 #1 (Page 62): Evaluate 11 101₂ + 10 011₂ − 10 001₂",
      mode: 3,
      subMode: 1, // Combined Add/Sub Chain
      input1: '11 101',
      input2: '10 011',
      input3: '10 001',
    ),
  ];

  // ===========================================================================
  // SANITIZATION & FORMATTING HELPERS (Math.tex Safe!)
  // ===========================================================================
  static String sanitizeBinary(String raw, {String fieldName = 'binary number'}) {
    final String s = raw
        .trim()
        .replaceAll('₂', '')
        .replaceAll(RegExp(r'(_|\s)*(two|2)$', caseSensitive: false), '')
        .replaceAll(' ', '')
        .replaceAll(',', '');

    if (s.isEmpty) {
      throw FormatException(
        "Please enter a valid $fieldName using digits 0 and 1 (e.g. 110 111 or 1 110).",
      );
    }
    if (!RegExp(r'^[01]+$').hasMatch(s)) {
      throw FormatException(
        "Invalid digit in '$raw'! A binary (base 2) number can only contain the digits 0 and 1.",
      );
    }
    if (s.length > 16) {
      throw const FormatException("Please enter binary numbers up to 16 bits long.");
    }
    final String stripped = s.replaceFirst(RegExp(r'^0+(?=.)'), '');
    return stripped.isEmpty ? '0' : stripped;
  }

  /// Formats a binary string in textbook 3-bit groups from the right (e.g., `110\,111`)
  static String groupBinLaTeX(String bin) {
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < bin.length; i++) {
      if (i > 0 && (bin.length - i) % 3 == 0) {
        buf.write('\\,');
      }
      buf.write(bin[i]);
    }
    return buf.toString();
  }

  static String groupBinPlain(String bin) {
    return groupBinLaTeX(bin).replaceAll('\\,', ' ');
  }

  /// Builds a right-aligned vertical LaTeX array for binary addition or subtraction (matching Examples 1 & 2!)
  static String buildVerticalArrayLaTeX({
    required List<String> terms,
    required String opSymbol, // '+' or '-'
    required String resultBin,
    int? missingRowIndex, // Optional row index to render as \bullet\bullet\bullet\bullet
  }) {
    int maxCols = resultBin.length;
    for (final String t in terms) {
      if (t.length > maxCols) maxCols = t.length;
    }

    final String colSpec = List.filled(maxCols + 1, 'c').join('');
    final StringBuffer buf = StringBuffer();
    buf.write("\\begin{array}{$colSpec} ");

    for (int r = 0; r < terms.length; r++) {
      final String term = terms[r];
      final int pad = maxCols - term.length;
      final String opCell = (r == terms.length - 1) ? opSymbol : "";
      final List<String> cells = [opCell];

      for (int c = 0; c < maxCols; c++) {
        if (c < pad) {
          cells.add("");
        } else {
          final String bit = term[c - pad];
          if (missingRowIndex == r) {
            cells.add("\\mathbf{\\bullet}($bit)");
          } else {
            cells.add(bit);
          }
        }
      }
      buf.write("${cells.join(' & ')} \\\\ ");
    }

    buf.write("\\hline ");
    final int resPad = maxCols - resultBin.length;
    final List<String> resCells = [""];
    for (int c = 0; c < maxCols; c++) {
      if (c < resPad) {
        resCells.add("");
      } else {
        resCells.add("\\mathbf{${resultBin[c - resPad]}}");
      }
    }
    buf.write("${resCells.join(' & ')} \\\\ \\hline ");
    buf.write("\\end{array}");
    return buf.toString();
  }

  // ===========================================================================
  // CORE ENGINE 1: COLUMN-BY-COLUMN BINARY ADDITION (2 OR 3 BINARY NUMBERS)
  // Replicates Example 1(a–d) on Pages 58–59 Word-for-Word!
  // ===========================================================================
  static Map<String, dynamic> performDetailedBinaryAddition(List<String> cleanTerms) {
    final List<int> base10Vals =
    cleanTerms.map((t) => int.parse(t, radix: 2)).toList();
    final int sum10 = base10Vals.fold(0, (a, b) => a + b);
    final String sumBin = sum10.toRadixString(2);

    final int maxCols = cleanTerms.map((t) => t.length).reduce(math.max);
    final List<String> colStepsLaTeX = [];
    final List<String> colStepsPlain = [];

    int carry = 0;
    for (int col = 1; col <= maxCols; col++) {
      final List<int> colBits = [];
      for (final String term in cleanTerms) {
        final int idx = term.length - col;
        colBits.add(idx >= 0 ? (term[idx] == '1' ? 1 : 0) : 0);
      }

      final List<int> allAddedInCol = [
        ...colBits,
        if (carry > 0) carry,
      ];
      final int colSum10 = allAddedInCol.fold(0, (a, b) => a + b);
      final String colSumBin = colSum10.toRadixString(2);
      final int writtenBit = colSum10 % 2;
      final int nextCarry = colSum10 ~/ 2;
      final String nextCarryBin = nextCarry.toRadixString(2);

      final String sumExpr = allAddedInCol.join(' + ');

      if (col < maxCols) {
        if (nextCarry == 0) {
          colStepsLaTeX.add(
              "\\text{\\textbf{Column $col: }} $sumExpr = \\mathbf{$writtenBit}");
          colStepsPlain.add(
              "• Column $col: $sumExpr = $writtenBit (write down $writtenBit).");
        } else {
          colStepsLaTeX.add(
              "\\text{\\textbf{Column $col: }} $sumExpr = ${colSumBin}_2, \\text{ write down } \\mathbf{$writtenBit} \\text{ and carry } \\mathbf{$nextCarryBin} \\text{ over to column ${col + 1}.}");
          colStepsPlain.add(
              "• Column $col: $sumExpr = ${colSumBin}₂, write down $writtenBit and carry $nextCarryBin over to column ${col + 1}.");
        }
      } else {
        // Last (leftmost) column — write down the entire binary sum!
        colStepsLaTeX.add(
            "\\text{\\textbf{Column $col: }} $sumExpr = \\mathbf{${colSumBin}_2}");
        colStepsPlain.add(
            "• Column $col (leftmost column): $sumExpr = ${colSumBin}₂.");
      }

      carry = nextCarry;
    }

    return {
      'sumBin': sumBin,
      'sum10': sum10,
      'base10Vals': base10Vals,
      'colStepsLaTeX': colStepsLaTeX,
      'colStepsPlain': colStepsPlain,
      'arrayLaTeX': buildVerticalArrayLaTeX(
        terms: cleanTerms,
        opSymbol: '+',
        resultBin: sumBin,
      ),
    };
  }

  // ===========================================================================
  // CORE ENGINE 2: COLUMN-BY-COLUMN BINARY SUBTRACTION WITH BORROWING
  // Replicates Example 2(a–c) on Page 59 Word-for-Word!
  // ===========================================================================
  static Map<String, dynamic> performDetailedBinarySubtraction(
      String cleanMinuend,
      String cleanSubtrahend,
      ) {
    final int m10 = int.parse(cleanMinuend, radix: 2);
    final int s10 = int.parse(cleanSubtrahend, radix: 2);
    if (m10 < s10) {
      throw FormatException(
        "The first binary number (${groupBinPlain(cleanMinuend)}₂ = ${m10}₁₀) must be greater than or equal to the number being subtracted (${groupBinPlain(cleanSubtrahend)}₂ = ${s10}₁₀).",
      );
    }

    final int diff10 = m10 - s10;
    final String diffBin = diff10.toRadixString(2);

    final int nCols = cleanMinuend.length;
    final List<int> topBits =
    cleanMinuend.split('').map((c) => c == '1' ? 1 : 0).toList();
    final List<int> origTopBits = List<int>.from(topBits);
    final String paddedSub = cleanSubtrahend.padLeft(nCols, '0');
    final List<int> botBits =
    paddedSub.split('').map((c) => c == '1' ? 1 : 0).toList();

    final List<String> colStepsLaTeX = [];
    final List<String> colStepsPlain = [];

    for (int col = 1; col <= nCols; col++) {
      final int idx = nCols - col;
      final int currTop = topBits[idx];
      final int origTop = origTopBits[idx];
      final int b = botBits[idx];

      String movedNoteLaTeX = "";
      String movedNotePlain = "";
      if (currTop != origTop) {
        if (origTop == 1 && currTop == 0) {
          movedNoteLaTeX =
          "\\text{Note that } 1 \\text{ has been moved to column ${col - 1} leaving } 0; \\; ";
          movedNotePlain =
          "Note that 1 was moved to column ${col - 1} leaving 0; ";
        } else if (origTop == 0 && currTop == 1) {
          movedNoteLaTeX =
          "\\text{Note that borrowing across this zero left } 1 \\text{ in column $col; } ";
          movedNotePlain =
          "Note that borrowing across this zero left 1 in column $col; ";
        }
      }

      if (currTop >= b) {
        final int remBit = currTop - b;
        if (col == nCols && currTop == 0 && b == 0) {
          colStepsLaTeX.add(
              "\\text{\\textbf{Column $col: }} ${movedNoteLaTeX}0 - 0 = 0 \\text{ (leading zero omitted).}");
          colStepsPlain.add(
              "• Column $col: ${movedNotePlain}0 − 0 = 0 (leading zero omitted).");
        } else {
          colStepsLaTeX.add(
              "\\text{\\textbf{Column $col: }} $movedNoteLaTeX$currTop - $b = \\mathbf{$remBit}");
          colStepsPlain.add(
              "• Column $col: $movedNotePlain$currTop − $b = $remBit.");
        }
      } else {
        // currTop == 0 and b == 1 -> "0 - 1, it won't go!" Borrow from the next non-zero column to the left!
        int donorIdx = idx - 1;
        while (donorIdx >= 0 && topBits[donorIdx] == 0) {
          donorIdx--;
        }
        final int donorCol = nCols - donorIdx;
        topBits[donorIdx] = 0;
        for (int k = donorIdx + 1; k < idx; k++) {
          topBits[k] = 1; // Intermediate zeros become 1 when 10_2 is split!
        }

        if (donorCol == col + 1) {
          colStepsLaTeX.add(
              "\\text{\\textbf{Column $col: }} ${movedNoteLaTeX}0 - 1, \\text{ it won't go; move } 1 \\text{ in column $donorCol to column $col to get } 10_2 \\text{ (i.e. } 10_2 - 1 = \\mathbf{1}\\text{).}");
          colStepsPlain.add(
              "• Column $col: ${movedNotePlain}0 − 1, it won't go; move 1 in column $donorCol to column $col to get 10₂ (10₂ − 1 = 1).");
        } else {
          colStepsLaTeX.add(
              "\\text{\\textbf{Column $col: }} ${movedNoteLaTeX}0 - 1, \\text{ it won't go; borrow } 1 \\text{ from column $donorCol across the intermediate zero(s) (leaving } 1 \\text{ in each intermediate column) to get } 10_2 \\text{ in column $col: } 10_2 - 1 = \\mathbf{1}.");
          colStepsPlain.add(
              "• Column $col: ${movedNotePlain}0 − 1, it won't go; borrow 1 from column $donorCol across the intermediate zero(s) to get 10₂ in column $col (10₂ − 1 = 1).");
        }
      }
    }

    return {
      'diffBin': diffBin,
      'diff10': diff10,
      'm10': m10,
      's10': s10,
      'colStepsLaTeX': colStepsLaTeX,
      'colStepsPlain': colStepsPlain,
      'arrayLaTeX': buildVerticalArrayLaTeX(
        terms: [cleanMinuend, cleanSubtrahend],
        opSymbol: '-',
        resultBin: diffBin,
      ),
    };
  }

  // ===========================================================================
  // MODE 0: BINARY ADDITION SOLVER (2 OR 3 BINARY NUMBERS)
  // Covers Example 1(a–d), Exercise 6.1 #1–10 & Revision Exercise 6 #1–2
  // ===========================================================================
  static BinaryAddSubResult solveBinaryAddition({
    required String bin1Str,
    required String bin2Str,
    required String bin3Str,
  }) {
    try {
      final String b1 = sanitizeBinary(bin1Str, fieldName: '1st Binary Number');
      final String b2 = sanitizeBinary(bin2Str, fieldName: '2nd Binary Number');
      final List<String> terms = [b1, b2];
      if (bin3Str.trim().isNotEmpty) {
        terms.add(sanitizeBinary(bin3Str, fieldName: '3rd Binary Number'));
      }

      final Map<String, dynamic> addRes = performDetailedBinaryAddition(terms);
      final String sumBin = addRes['sumBin'] as String;
      final int sum10 = addRes['sum10'] as int;
      final List<int> base10Vals = addRes['base10Vals'] as List<int>;
      final List<String> colStepsLaTeX =
      addRes['colStepsLaTeX'] as List<String>;
      final List<String> colStepsPlain =
      addRes['colStepsPlain'] as List<String>;
      final String arrayLaTeX = addRes['arrayLaTeX'] as String;

      final String sumGroupedLaTeX = "${groupBinLaTeX(sumBin)}_2";
      final String termsSumLaTeX =
      terms.map((t) => "${groupBinLaTeX(t)}_2").join(' + ');
      final String base10CheckLaTeX =
          "${base10Vals.map((v) => '${v}_{10}').join(' + ')} = \\mathbf{${sum10}_{10}} = \\mathbf{$sumGroupedLaTeX}";

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Recall the Four Binary Addition Identities (Page 58)}}",
        "0 + 0 = 0, \\qquad 0 + 1 = 1, \\qquad 1 + 0 = 1, \\qquad 1 + 1 = 10_2 \\quad (1 + 1 + 1 = 11_2)",
        "",
        "\\text{\\textbf{Step 2: Set Out Vertically and Add Column-by-Column from Right to Left (Example 1)}}",
        arrayLaTeX,
        ...colStepsLaTeX,
        "",
        "\\text{\\textbf{Step 3: Base 10 Verification Check}}",
        "\\text{Check in Base 10: } $base10CheckLaTeX \\quad (\\text{Verified!})",
      ];

      final List<BinaryAddSubStep> steps = [
        BinaryAddSubStep(
          title:
          "Step 1: Align the Binary Numbers by Place Value & Apply Base-2 Addition Rules",
          description:
          "• Remember the fundamental binary addition identities on Page 58:\n"
              "  0 + 0 = 0,   0 + 1 = 1,   1 + 0 = 1,   1 + 1 = 10₂ (write 0, carry 1),   and 1 + 1 + 1 = 11₂ (write 1, carry 1).",
          mathLinesLaTeX: [arrayLaTeX],
        ),
        BinaryAddSubStep(
          title:
          "Step 2: Add Column-by-Column from Right (Column 1) to Left (Example 1 Style)",
          description: colStepsPlain.join('\n'),
          mathLinesLaTeX: colStepsLaTeX,
        ),
        BinaryAddSubStep(
          title: "Step 3: Verify the Binary Sum Using Base 10 Equivalents",
          description:
          "Convert each binary number to base 10 to verify the sum: ${base10Vals.join(' + ')} = $sum10 (base 10) = ${groupBinPlain(sumBin)}₂.",
          mathLinesLaTeX: [
            "\\text{Base 10 Check: } $base10CheckLaTeX",
            "\\therefore \\; $termsSumLaTeX = \\mathbf{$sumGroupedLaTeX}",
          ],
        ),
      ];

      return BinaryAddSubResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Addition Expression": termsSumLaTeX,
          "Binary Sum (Base 2)": "\\mathbf{$sumGroupedLaTeX}",
          "Base 10 Check": "$base10CheckLaTeX",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryAddSubCanvasData(
          headerLaTeX:
          "\\text{Binary Addition (Example 1): } $termsSumLaTeX = \\mathbf{$sumGroupedLaTeX}",
          subHeaderLaTeX:
          "\\text{Rules: } 1 + 1 = 10_2 \\text{ (write } 0, \\text{ carry } 1\\text{)} \\quad | \\quad 1 + 1 + 1 = 11_2 \\text{ (write } 1, \\text{ carry } 1\\text{)}",
          card1Title: "1st Binary Number",
          card1LaTeX: "${groupBinLaTeX(b1)}_2 = ${base10Vals[0]}_{10}",
          card2Title: terms.length == 3 ? "2nd & 3rd Numbers" : "2nd Binary Number",
          card2LaTeX: terms.length == 3
              ? "${groupBinLaTeX(b2)}_2 + ${groupBinLaTeX(terms[2])}_2"
              : "${groupBinLaTeX(b2)}_2 = ${base10Vals[1]}_{10}",
          card3Title: "Binary Sum",
          card3LaTeX: "\\mathbf{$sumGroupedLaTeX} \\; (${sum10}_{10})",
          middleBannerLaTeX: arrayLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $termsSumLaTeX = \\mathbf{$sumGroupedLaTeX} \\quad (\\text{Base 10: } ${base10Vals.join(' + ')} = $sum10)",
        ),
      );
    } catch (e) {
      return BinaryAddSubResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary numbers using only 0 and 1.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: BINARY SUBTRACTION SOLVER WITH MULTI-COLUMN BORROWING
  // Covers Example 2(a–c) (Page 59), Exercise 6.1 #15–20 & Revision Exercise 6 #3–5
  // ===========================================================================
  static BinaryAddSubResult solveBinarySubtraction({
    required String minuendStr,
    required String subtrahendStr,
  }) {
    try {
      final String mBin =
      sanitizeBinary(minuendStr, fieldName: 'Top Binary Number (Minuend)');
      final String sBin = sanitizeBinary(
        subtrahendStr,
        fieldName: 'Bottom Binary Number (Subtrahend)',
      );

      final Map<String, dynamic> subRes =
      performDetailedBinarySubtraction(mBin, sBin);
      final String diffBin = subRes['diffBin'] as String;
      final int diff10 = subRes['diff10'] as int;
      final int m10 = subRes['m10'] as int;
      final int s10 = subRes['s10'] as int;
      final List<String> colStepsLaTeX =
      subRes['colStepsLaTeX'] as List<String>;
      final List<String> colStepsPlain =
      subRes['colStepsPlain'] as List<String>;
      final String arrayLaTeX = subRes['arrayLaTeX'] as String;

      final String diffGroupedLaTeX = "${groupBinLaTeX(diffBin)}_2";
      final String exprLaTeX =
          "${groupBinLaTeX(mBin)}_2 - ${groupBinLaTeX(sBin)}_2";

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Recall the Four Binary Subtraction Identities (Page 58)}}",
        "0 - 0 = 0, \\qquad 1 - 0 = 1, \\qquad 1 - 1 = 0, \\qquad 10_2 - 1 = 1 \\quad (\\text{after borrowing } 1 \\text{ from the next column})",
        "",
        "\\text{\\textbf{Step 2: Set Out Vertically and Subtract Column-by-Column (Example 2, Page 59)}}",
        arrayLaTeX,
        ...colStepsLaTeX,
        "",
        "\\text{\\textbf{Step 3: Addition \\& Base 10 Verification Check}}",
        "\\text{Check by adding difference + subtrahend: } ${groupBinLaTeX(diffBin)}_2 + ${groupBinLaTeX(sBin)}_2 = \\mathbf{${groupBinLaTeX(mBin)}_2}",
        "\\text{Check in Base 10: } ${m10}_{10} - ${s10}_{10} = \\mathbf{${diff10}_{10}} = \\mathbf{$diffGroupedLaTeX} \\quad (\\text{Verified!})",
      ];

      final List<BinaryAddSubStep> steps = [
        BinaryAddSubStep(
          title:
          "Step 1: Set Out the Binary Subtraction Vertically (Example 2)",
          description:
          "• Recall from Page 58: 0 − 0 = 0, 1 − 0 = 1, 1 − 1 = 0.\n"
              "• Whenever we have 0 − 1 ('it won't go'), we move (borrow) 1 from the next column on the left to make 10₂ (= 2 in base 10), and then 10₂ − 1 = 1!",
          mathLinesLaTeX: [arrayLaTeX],
        ),
        BinaryAddSubStep(
          title:
          "Step 2: Subtract Column-by-Column from Right (Column 1) to Left",
          description: colStepsPlain.join('\n'),
          mathLinesLaTeX: colStepsLaTeX,
        ),
        BinaryAddSubStep(
          title: "Step 3: Verify by Addition & Base 10 Check",
          description:
          "In Base 10, ${groupBinPlain(mBin)}₂ = $m10 and ${groupBinPlain(sBin)}₂ = $s10, so $m10 − $s10 = $diff10 = ${groupBinPlain(diffBin)}₂.",
          mathLinesLaTeX: workings.sublist(workings.length - 2),
        ),
      ];

      return BinaryAddSubResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Subtraction": exprLaTeX,
          "Binary Difference": "\\mathbf{$diffGroupedLaTeX}",
          "Base 10 Check": "${m10}_{10} - ${s10}_{10} = ${diff10}_{10}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryAddSubCanvasData(
          headerLaTeX:
          "\\text{Binary Subtraction (Example 2): } $exprLaTeX = \\mathbf{$diffGroupedLaTeX}",
          subHeaderLaTeX:
          "\\text{Borrowing Rule: When } 0 - 1 \\text{ won't go, move } 1 \\text{ from the left column to make } 10_2 - 1 = 1",
          card1Title: "Minuend (Top)",
          card1LaTeX: "${groupBinLaTeX(mBin)}_2 = ${m10}_{10}",
          card2Title: "Subtrahend (Bottom)",
          card2LaTeX: "${groupBinLaTeX(sBin)}_2 = ${s10}_{10}",
          card3Title: "Difference",
          card3LaTeX: "\\mathbf{$diffGroupedLaTeX} \\; (${diff10}_{10})",
          middleBannerLaTeX: arrayLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $exprLaTeX = \\mathbf{$diffGroupedLaTeX} \\quad (\\text{Base 10: } $m10 - $s10 = $diff10)",
        ),
      );
    } catch (e) {
      return BinaryAddSubResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary numbers.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: FIND THE MISSING BINARY NUMBER (•••••) IN ADDITIONS & SUBTRACTIONS
  // Covers Exercise 6.1 #11–14, #21–24 (Page 60) & Revision Exercise 6 #6–10 (Pages 63–64)
  // ===========================================================================
  static BinaryAddSubResult solveMissingBinaryNumber({
    required int subMode,
    // 0: Missing Addend in 2-Row or 3-Row Addition (A + •••• = S  or  A + •••• + B = S)
    // 1: Missing Subtrahend in Subtraction (M − •••• = D  =>  Missing = M − D)
    // 2: Missing Minuend in Subtraction (•••• − S = D  =>  Missing = D + S)
    required String known1Str,
    required String known2OptionalStr,
    required String totalOrDiffStr,
  }) {
    try {
      final String k1 =
      sanitizeBinary(known1Str, fieldName: 'First Known Binary Number');
      final String target = sanitizeBinary(
        totalOrDiffStr,
        fieldName: subMode == 0 ? 'Given Total Sum' : 'Given Difference',
      );

      if (subMode == 0) {
        // Missing Addend in Addition (Ex 6.1 #11–14 & Rev Ex 6 #6–8)
        final bool hasSecondKnown = known2OptionalStr.trim().isNotEmpty;
        String combinedKnownBin = k1;
        final List<String> step1Lines = [];

        if (hasSecondKnown) {
          final String k2 = sanitizeBinary(
            known2OptionalStr,
            fieldName: 'Second Known Binary Number',
          );
          final Map<String, dynamic> knownAdd =
          performDetailedBinaryAddition([k1, k2]);
          combinedKnownBin = knownAdd['sumBin'] as String;

          step1Lines.addAll([
            "\\text{In a 3-row addition } (${groupBinLaTeX(k1)}_2 + \\bullet\\bullet\\bullet\\bullet + ${groupBinLaTeX(k2)}_2 = ${groupBinLaTeX(target)}_2), \\text{ first add the two known binary numbers:}",
            knownAdd['arrayLaTeX'] as String,
            "${groupBinLaTeX(k1)}_2 + ${groupBinLaTeX(k2)}_2 = \\mathbf{${groupBinLaTeX(combinedKnownBin)}_2}",
          ]);
        } else {
          step1Lines.addAll([
            "\\text{Let the missing binary number } (\\bullet\\bullet\\bullet\\bullet) \\text{ be } x:",
            "${groupBinLaTeX(k1)}_2 + x = ${groupBinLaTeX(target)}_2",
            "\\text{To find the missing addend } x, \\text{ subtract } ${groupBinLaTeX(k1)}_2 \\text{ from the sum } ${groupBinLaTeX(target)}_2:",
            "x = ${groupBinLaTeX(target)}_2 - ${groupBinLaTeX(k1)}_2",
          ]);
        }

        final Map<String, dynamic> subRes =
        performDetailedBinarySubtraction(target, combinedKnownBin);
        final String missingBin = subRes['diffBin'] as String;
        final int missing10 = subRes['diff10'] as int;

        final List<String> termsForCheck = hasSecondKnown
            ? [
          k1,
          missingBin,
          sanitizeBinary(known2OptionalStr),
        ]
            : [k1, missingBin];
        final String completedArrayLaTeX = buildVerticalArrayLaTeX(
          terms: termsForCheck,
          opSymbol: '+',
          resultBin: target,
          missingRowIndex: 1,
        );

        final List<String> step2Lines = [
          "\\text{Subtract } ${groupBinLaTeX(combinedKnownBin)}_2 \\text{ from } ${groupBinLaTeX(target)}_2:",
          subRes['arrayLaTeX'] as String,
          ...(subRes['colStepsLaTeX'] as List<String>),
          "\\therefore \\; \\text{Missing Binary Number } (\\bullet\\bullet\\bullet\\bullet) = \\mathbf{${groupBinLaTeX(missingBin)}_2} \\quad (${missing10}_{10})",
        ];

        return BinaryAddSubResult(
          mode: 2,
          subMode: 0,
          finalAnswersLaTeX: {
            "Missing Binary Number": "\\mathbf{${groupBinLaTeX(missingBin)}_2}",
            "Value in Base 10": "${missing10}_{10}",
            "Operation Used":
            "${groupBinLaTeX(target)}_2 - ${groupBinLaTeX(combinedKnownBin)}_2",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Step 1: Set Up the Missing-Addend Relationship (Exercise 6.1 \\#11–14)}}",
            ...step1Lines,
            "",
            "\\text{\\textbf{Step 2: Subtract to Find the Missing Binary Number}}",
            ...step2Lines,
            "",
            "\\text{\\textbf{Step 3: Completed Addition Array with Missing Digits Filled In}}",
            completedArrayLaTeX,
          ],
          steps: [
            BinaryAddSubStep(
              title:
              "Step 1: Use Inverse Subtraction to Isolate the Missing Binary Number",
              description: hasSecondKnown
                  ? "First add the two known binary rows (${groupBinPlain(k1)}₂ + ${groupBinPlain(sanitizeBinary(known2OptionalStr))}₂ = ${groupBinPlain(combinedKnownBin)}₂), then subtract that sum from the total (${groupBinPlain(target)}₂)."
                  : "Since Known + Missing = Total Sum, subtract ${groupBinPlain(k1)}₂ from ${groupBinPlain(target)}₂.",
              mathLinesLaTeX: step1Lines,
            ),
            BinaryAddSubStep(
              title:
              "Step 2: Perform Column-by-Column Binary Subtraction",
              description:
              (subRes['colStepsPlain'] as List<String>).join('\n'),
              mathLinesLaTeX: [...step2Lines, completedArrayLaTeX],
            ),
          ],
          canvasData: BinaryAddSubCanvasData(
            headerLaTeX:
            "\\text{Missing Binary Number in Addition: } \\mathbf{${groupBinLaTeX(missingBin)}_2}",
            subHeaderLaTeX:
            "\\text{Missing Addend} = \\text{Total Sum } (${groupBinLaTeX(target)}_2) - \\text{Known } (${groupBinLaTeX(combinedKnownBin)}_2)",
            card1Title: "Total Sum",
            card1LaTeX: "${groupBinLaTeX(target)}_2",
            card2Title: "Known Sum",
            card2LaTeX: "${groupBinLaTeX(combinedKnownBin)}_2",
            card3Title: "Missing Number",
            card3LaTeX: "\\mathbf{${groupBinLaTeX(missingBin)}_2}",
            middleBannerLaTeX: completedArrayLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Missing Binary Number } (\\bullet\\bullet\\bullet\\bullet) = \\mathbf{${groupBinLaTeX(missingBin)}_2}",
          ),
        );
      } else if (subMode == 1) {
        // Sub-Mode 2B: Missing Subtrahend (M − •••• = D  =>  Missing = M − D) (Ex 6.1 #21 & #23)
        final Map<String, dynamic> subRes =
        performDetailedBinarySubtraction(k1, target);
        final String missingBin = subRes['diffBin'] as String;
        final int missing10 = subRes['diff10'] as int;

        final String completedArrayLaTeX = buildVerticalArrayLaTeX(
          terms: [k1, missingBin],
          opSymbol: '-',
          resultBin: target,
          missingRowIndex: 1,
        );

        final List<String> lines = [
          "\\text{Given: } ${groupBinLaTeX(k1)}_2 - \\bullet\\bullet\\bullet\\bullet = ${groupBinLaTeX(target)}_2",
          "\\text{Rule: Since } \\text{Minuend} - \\text{Subtrahend} = \\text{Difference}, \\text{ then } \\text{Subtrahend} = \\text{Minuend} - \\text{Difference}:",
          "\\text{Missing Number} = ${groupBinLaTeX(k1)}_2 - ${groupBinLaTeX(target)}_2",
          subRes['arrayLaTeX'] as String,
          ...(subRes['colStepsLaTeX'] as List<String>),
          "\\therefore \\; \\text{Missing Binary Number } (\\bullet\\bullet\\bullet\\bullet) = \\mathbf{${groupBinLaTeX(missingBin)}_2} \\quad (${missing10}_{10})",
        ];

        return BinaryAddSubResult(
          mode: 2,
          subMode: 1,
          finalAnswersLaTeX: {
            "Missing Subtrahend": "\\mathbf{${groupBinLaTeX(missingBin)}_2}",
            "Value in Base 10": "${missing10}_{10}",
            "Formula Used":
            "${groupBinLaTeX(k1)}_2 - ${groupBinLaTeX(target)}_2",
          },
          workingsLaTeX: [...lines, "", completedArrayLaTeX],
          steps: [
            BinaryAddSubStep(
              title:
              "Step 1: Subtract the Difference (${groupBinPlain(target)}₂) from the Top Number (${groupBinPlain(k1)}₂)",
              description:
              "When the bottom number in a subtraction (M − x = D) is missing, subtract D from M: x = ${groupBinPlain(k1)}₂ − ${groupBinPlain(target)}₂ = ${groupBinPlain(missingBin)}₂.",
              mathLinesLaTeX: [...lines, completedArrayLaTeX],
            ),
          ],
          canvasData: BinaryAddSubCanvasData(
            headerLaTeX:
            "\\text{Missing Subtrahend (Ex 6.1 \\#21, \\#23): } ${groupBinLaTeX(k1)}_2 - \\mathbf{${groupBinLaTeX(missingBin)}_2} = ${groupBinLaTeX(target)}_2",
            subHeaderLaTeX:
            "\\text{Missing Subtrahend} = \\text{Top Number } (${groupBinLaTeX(k1)}_2) - \\text{Difference } (${groupBinLaTeX(target)}_2)",
            card1Title: "Top Number (M)",
            card1LaTeX: "${groupBinLaTeX(k1)}_2",
            card2Title: "Difference (D)",
            card2LaTeX: "${groupBinLaTeX(target)}_2",
            card3Title: "Missing Number",
            card3LaTeX: "\\mathbf{${groupBinLaTeX(missingBin)}_2}",
            middleBannerLaTeX: completedArrayLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Missing Binary Number} = \\mathbf{${groupBinLaTeX(missingBin)}_2}",
          ),
        );
      } else {
        // Sub-Mode 2C: Missing Minuend (•••• − S = D  =>  Missing = D + S) (Ex 6.1 #22, #24 & Rev Ex 6 #9, #10)
        final Map<String, dynamic> addRes =
        performDetailedBinaryAddition([target, k1]);
        final String missingBin = addRes['sumBin'] as String;
        final int missing10 = addRes['sum10'] as int;

        final String completedArrayLaTeX = buildVerticalArrayLaTeX(
          terms: [missingBin, k1],
          opSymbol: '-',
          resultBin: target,
          missingRowIndex: 0,
        );

        final List<String> lines = [
          "\\text{Given: } \\bullet\\bullet\\bullet\\bullet - ${groupBinLaTeX(k1)}_2 = ${groupBinLaTeX(target)}_2",
          "\\text{Rule: When the top number (Minuend) is missing in } x - S = D, \\text{ add the Difference and the Subtrahend } (x = D + S):",
          "\\text{Missing Top Number} = ${groupBinLaTeX(target)}_2 + ${groupBinLaTeX(k1)}_2",
          addRes['arrayLaTeX'] as String,
          ...(addRes['colStepsLaTeX'] as List<String>),
          "\\therefore \\; \\text{Missing Binary Number } (\\bullet\\bullet\\bullet\\bullet) = \\mathbf{${groupBinLaTeX(missingBin)}_2} \\quad (${missing10}_{10})",
        ];

        return BinaryAddSubResult(
          mode: 2,
          subMode: 2,
          finalAnswersLaTeX: {
            "Missing Top Number": "\\mathbf{${groupBinLaTeX(missingBin)}_2}",
            "Value in Base 10": "${missing10}_{10}",
            "Formula Used":
            "${groupBinLaTeX(target)}_2 + ${groupBinLaTeX(k1)}_2",
          },
          workingsLaTeX: [...lines, "", completedArrayLaTeX],
          steps: [
            BinaryAddSubStep(
              title:
              "Step 1: Add the Difference (${groupBinPlain(target)}₂) and Subtrahend (${groupBinPlain(k1)}₂)",
              description:
              "When the top number in a subtraction (x − S = D) is missing, add D + S: ${groupBinPlain(target)}₂ + ${groupBinPlain(k1)}₂ = ${groupBinPlain(missingBin)}₂.",
              mathLinesLaTeX: [...lines, completedArrayLaTeX],
            ),
          ],
          canvasData: BinaryAddSubCanvasData(
            headerLaTeX:
            "\\text{Missing Top Number (Ex 6.1 \\#22, \\#24 \\& Rev \\#9–10): } \\mathbf{${groupBinLaTeX(missingBin)}_2} - ${groupBinLaTeX(k1)}_2 = ${groupBinLaTeX(target)}_2",
            subHeaderLaTeX:
            "\\text{Missing Minuend} = \\text{Difference } (${groupBinLaTeX(target)}_2) + \\text{Subtrahend } (${groupBinLaTeX(k1)}_2)",
            card1Title: "Difference (D)",
            card1LaTeX: "${groupBinLaTeX(target)}_2",
            card2Title: "Subtrahend (S)",
            card2LaTeX: "${groupBinLaTeX(k1)}_2",
            card3Title: "Missing Top (D + S)",
            card3LaTeX: "\\mathbf{${groupBinLaTeX(missingBin)}_2}",
            middleBannerLaTeX: completedArrayLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Missing Top Binary Number} = \\mathbf{${groupBinLaTeX(missingBin)}_2}",
          ),
        );
      }
    } catch (e) {
      return BinaryAddSubResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary numbers.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: QUANTITATIVE REASONING SPLIT-BOX (#6–10) & COMBINED ADD/SUB (Ex 6.3 #1)
  // ===========================================================================
  static BinaryAddSubResult solveQuantitativeOrCombined({
    required int subMode, // 0: QR Split-Box (TopLeft + TopRight = Bottom), 1: Combined A + B − C (Ex 6.3 #1)
    required String in1Str,
    required String in2Str,
    required String in3Str,
  }) {
    try {
      if (subMode == 0) {
        // Quantitative Reasoning Sample 2 & Questions #6–10 (Pages 62–63):
        // Rule: Top-Left + Top-Right = Bottom! Leave the unknown cell blank or '?'
        final String s1 = in1Str.trim().replaceAll('?', '');
        final String s2 = in2Str.trim().replaceAll('?', '');
        final String s3 = in3Str.trim().replaceAll('?', '');

        final int emptyCount =
            (s1.isEmpty ? 1 : 0) + (s2.isEmpty ? 1 : 0) + (s3.isEmpty ? 1 : 0);
        if (emptyCount != 1) {
          throw const FormatException(
            "In Quantitative Reasoning Split-Box mode, enter the 2 known binary numbers and leave the 1 missing box blank (or type '?').",
          );
        }

        String topL = "";
        String topR = "";
        String bot = "";
        String missingPositionName = "";
        String solvedBin = "";
        Map<String, dynamic> opDetails = {};

        if (s3.isEmpty) {
          // Bottom is missing (#6: 1 110 and 111) -> Add TopLeft + TopRight
          topL = sanitizeBinary(s1, fieldName: 'Top-Left Box');
          topR = sanitizeBinary(s2, fieldName: 'Top-Right Box');
          opDetails = performDetailedBinaryAddition([topL, topR]);
          bot = opDetails['sumBin'] as String;
          solvedBin = bot;
          missingPositionName = "Bottom Box (Top-Left + Top-Right)";
        } else if (s2.isEmpty) {
          // Top-Right is missing (#7 & #9) -> Subtract Bottom − TopLeft
          topL = sanitizeBinary(s1, fieldName: 'Top-Left Box');
          bot = sanitizeBinary(s3, fieldName: 'Bottom Box');
          opDetails = performDetailedBinarySubtraction(bot, topL);
          topR = opDetails['diffBin'] as String;
          solvedBin = topR;
          missingPositionName = "Top-Right Box (Bottom − Top-Left)";
        } else {
          // Top-Left is missing (#8 & #10) -> Subtract Bottom − TopRight
          topR = sanitizeBinary(s2, fieldName: 'Top-Right Box');
          bot = sanitizeBinary(s3, fieldName: 'Bottom Box');
          opDetails = performDetailedBinarySubtraction(bot, topR);
          topL = opDetails['diffBin'] as String;
          solvedBin = topL;
          missingPositionName = "Top-Left Box (Bottom − Top-Right)";
        }

        // Build the textbook 3-cell Quantitative Reasoning Split-Box in LaTeX!
        final String qrBoxLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\quad \\mathbf{${groupBinLaTeX(topL)}_2} \\quad & \\quad \\mathbf{${groupBinLaTeX(topR)}_2} \\quad \\\\ \\hline "
            "\\multicolumn{2}{|c|}{\\mathbf{${groupBinLaTeX(bot)}_2}} \\\\ \\hline "
            "\\end{array}";

        final List<String> lines = [
          "\\text{\\textbf{Step 1: Discover the Quantitative Reasoning Sample Rule (Page 62 Bottom Right)}}",
          "\\text{In the textbook sample: Top-Left } (1\\,001_2 = 9_{10}) + \\text{Top-Right } (111_2 = 7_{10}) = \\text{Bottom } (10\\,000_2 = 16_{10}).",
          "\\text{Rule: } \\mathbf{\\text{Top-Left} + \\text{Top-Right} = \\text{Bottom}}",
          "",
          "\\text{\\textbf{Step 2: Solve for the Missing $missingPositionName}}",
          opDetails['arrayLaTeX'] as String,
          ...(opDetails['colStepsLaTeX'] as List<String>),
          "\\therefore \\; \\text{Missing Value } (?) = \\mathbf{${groupBinLaTeX(solvedBin)}_2}",
        ];

        return BinaryAddSubResult(
          mode: 3,
          subMode: 0,
          finalAnswersLaTeX: {
            "Top-Left Box": "${groupBinLaTeX(topL)}_2",
            "Top-Right Box": "${groupBinLaTeX(topR)}_2",
            "Bottom Box (Sum)": "${groupBinLaTeX(bot)}_2",
            "Missing Value (?)": "\\mathbf{${groupBinLaTeX(solvedBin)}_2}",
          },
          workingsLaTeX: lines,
          steps: [
            BinaryAddSubStep(
              title:
              "Step 1: Quantitative Reasoning Split-Box Rule (Top-Left + Top-Right = Bottom)",
              description:
              "From the textbook sample on Page 62 (1 001₂ + 111₂ = 10 000₂), the two top boxes add together to give the bottom box.",
              mathLinesLaTeX: lines.sublist(0, 3),
            ),
            BinaryAddSubStep(
              title: "Step 2: Calculate the Missing $missingPositionName",
              description:
              (opDetails['colStepsPlain'] as List<String>).join('\n'),
              mathLinesLaTeX: lines.sublist(4),
            ),
          ],
          canvasData: BinaryAddSubCanvasData(
            headerLaTeX:
            "\\text{Quantitative Reasoning Split-Box (Pages 62–63): } ${groupBinLaTeX(topL)}_2 + ${groupBinLaTeX(topR)}_2 = ${groupBinLaTeX(bot)}_2",
            subHeaderLaTeX:
            "\\text{Sample Rule: Top-Left} + \\text{Top-Right} = \\text{Bottom} \\quad | \\quad \\text{Missing } (?) = \\mathbf{${groupBinLaTeX(solvedBin)}_2}",
            card1Title: "Top-Left Box",
            card1LaTeX: "${groupBinLaTeX(topL)}_2",
            card2Title: "Top-Right Box",
            card2LaTeX: "${groupBinLaTeX(topR)}_2",
            card3Title: "Bottom Box (Sum)",
            card3LaTeX: "\\mathbf{${groupBinLaTeX(bot)}_2}",
            middleBannerLaTeX: opDetails['arrayLaTeX'] as String,
            bottomSummaryLaTeX:
            "\\text{Missing Box } (?) = \\mathbf{${groupBinLaTeX(solvedBin)}_2}",
          ),
        );
      } else {
        // Sub-Mode 3B: Combined Addition & Subtraction Chain A + B − C (Exercise 6.3 #1: 11 101 + 10 011 − 10 001)
        final String aBin = sanitizeBinary(in1Str, fieldName: '1st Binary Number');
        final String bBin = sanitizeBinary(in2Str, fieldName: '2nd Binary Number');
        final String cBin = sanitizeBinary(in3Str, fieldName: '3rd Binary Number');

        final Map<String, dynamic> stage1Add =
        performDetailedBinaryAddition([aBin, bBin]);
        final String sumAB = stage1Add['sumBin'] as String;

        final Map<String, dynamic> stage2Sub =
        performDetailedBinarySubtraction(sumAB, cBin);
        final String finalBin = stage2Sub['diffBin'] as String;
        final int final10 = stage2Sub['diff10'] as int;

        final List<String> lines = [
          "\\text{\\textbf{Stage 1: Add the First Two Binary Numbers }} \\left(${groupBinLaTeX(aBin)}_2 + ${groupBinLaTeX(bBin)}_2\\right)",
          stage1Add['arrayLaTeX'] as String,
          ...(stage1Add['colStepsLaTeX'] as List<String>),
          "",
          "\\text{\\textbf{Stage 2: Subtract the Third Binary Number }} \\left(${groupBinLaTeX(sumAB)}_2 - ${groupBinLaTeX(cBin)}_2\\right)",
          stage2Sub['arrayLaTeX'] as String,
          ...(stage2Sub['colStepsLaTeX'] as List<String>),
          "\\therefore \\; ${groupBinLaTeX(aBin)}_2 + ${groupBinLaTeX(bBin)}_2 - ${groupBinLaTeX(cBin)}_2 = \\mathbf{${groupBinLaTeX(finalBin)}_2} \\quad (${final10}_{10})",
        ];

        return BinaryAddSubResult(
          mode: 3,
          subMode: 1,
          finalAnswersLaTeX: {
            "Stage 1 Sum (A + B)": "${groupBinLaTeX(sumAB)}_2",
            "Final Answer (A + B − C)": "\\mathbf{${groupBinLaTeX(finalBin)}_2}",
            "Base 10 Check": "${final10}_{10}",
          },
          workingsLaTeX: lines,
          steps: [
            BinaryAddSubStep(
              title:
              "Step 1: Add ${groupBinPlain(aBin)}₂ + ${groupBinPlain(bBin)}₂ = ${groupBinPlain(sumAB)}₂",
              description:
              (stage1Add['colStepsPlain'] as List<String>).join('\n'),
              mathLinesLaTeX: lines.sublist(1, 3 + (stage1Add['colStepsLaTeX'] as List).length),
            ),
            BinaryAddSubStep(
              title:
              "Step 2: Subtract ${groupBinPlain(sumAB)}₂ − ${groupBinPlain(cBin)}₂ = ${groupBinPlain(finalBin)}₂",
              description:
              (stage2Sub['colStepsPlain'] as List<String>).join('\n'),
              mathLinesLaTeX: lines.sublist(4 + (stage1Add['colStepsLaTeX'] as List).length),
            ),
          ],
          canvasData: BinaryAddSubCanvasData(
            headerLaTeX:
            "\\text{Exercise 6.3 \\#1 Combined Operation: } ${groupBinLaTeX(aBin)}_2 + ${groupBinLaTeX(bBin)}_2 - ${groupBinLaTeX(cBin)}_2 = \\mathbf{${groupBinLaTeX(finalBin)}_2}",
            subHeaderLaTeX:
            "\\text{Stage 1 Sum} = ${groupBinLaTeX(sumAB)}_2 \\quad \\longrightarrow \\quad \\text{Stage 2 Difference} = \\mathbf{${groupBinLaTeX(finalBin)}_2}",
            card1Title: "Stage 1: A + B",
            card1LaTeX: "${groupBinLaTeX(sumAB)}_2",
            card2Title: "Subtract C",
            card2LaTeX: "-\\; ${groupBinLaTeX(cBin)}_2",
            card3Title: "Final Result",
            card3LaTeX: "\\mathbf{${groupBinLaTeX(finalBin)}_2}",
            middleBannerLaTeX: stage2Sub['arrayLaTeX'] as String,
            bottomSummaryLaTeX:
            "\\therefore \\; ${groupBinLaTeX(aBin)}_2 + ${groupBinLaTeX(bBin)}_2 - ${groupBinLaTeX(cBin)}_2 = \\mathbf{${groupBinLaTeX(finalBin)}_2}",
          ),
        );
      }
    } catch (e) {
      return BinaryAddSubResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please check your binary inputs.",
      );
    }
  }
}