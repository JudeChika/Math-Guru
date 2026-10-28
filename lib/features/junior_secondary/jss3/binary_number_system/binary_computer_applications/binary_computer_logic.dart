import 'binary_computer_models.dart';

class BinaryComputerLogic {
  // ===========================================================================
  // 14 TEXTBOOK PRESETS (Pages 12–14: Table 1.1, Examples 5–7 & Exercise 1.4)
  // ===========================================================================
  static const List<BinaryComputerPreset> textbookPresets = [
    BinaryComputerPreset(
      chipLabel: "Ex 5a (Table 1.2): Code LAGOS",
      mode: 0,
      inputStr: 'LAGOS',
    ),
    BinaryComputerPreset(
      chipLabel: "Ex 5b (Table 1.3): Code KADUNA",
      mode: 0,
      inputStr: 'KADUNA',
    ),
    BinaryComputerPreset(
      chipLabel: "Ex 5c (Table 1.4): Code BENIN",
      mode: 0,
      inputStr: 'BENIN',
    ),
    BinaryComputerPreset(
      chipLabel: "Ex 5d (Table 1.5): Code ENUGU",
      mode: 0,
      inputStr: 'ENUGU',
    ),
    BinaryComputerPreset(
      chipLabel: "Ex 6 (Table 1.6): I LIKE MATHEMATICS",
      mode: 0,
      inputStr: 'I LIKE MATHEMATICS',
    ),
    BinaryComputerPreset(
      chipLabel: "Ex 7a: Punch Tape for LAGOS",
      mode: 1,
      punchTapeStyle: 0,
      inputStr: 'LAGOS',
    ),
    BinaryComputerPreset(
      chipLabel: "Ex 7b: Punch Tape for I AM A NIGERIAN",
      mode: 1,
      punchTapeStyle: 0,
      inputStr: 'I AM A NIGERIAN',
    ),
    BinaryComputerPreset(
      chipLabel: "Ex 7a (5-Bit Track): LAGOS (● = 1, ○ = 0)",
      mode: 1,
      punchTapeStyle: 1,
      inputStr: 'LAGOS',
    ),
    BinaryComputerPreset(
      chipLabel: "Decode Binary: 1 100, 1, 111, 1 111, 10 011",
      mode: 2,
      inputStr: '1 100, 1, 111, 1 111, 10 011',
    ),
    BinaryComputerPreset(
      chipLabel: "Decode Binary: 10, 101, 1 110, 1 001, 1 110",
      mode: 2,
      inputStr: '10, 101, 1 110, 1 001, 1 110',
    ),
    BinaryComputerPreset(
      chipLabel: "Decode Sentence: 1001 / 1, 1101 / 1 / 1011, 1001, 11010",
      mode: 2,
      inputStr: '1001 / 1, 1101 / 1 / 1011, 1001, 11010',
    ),
    BinaryComputerPreset(
      chipLabel: "Table 1.1: Full A–Z Binary Coding System",
      mode: 3,
      inputStr: 'A-Z',
    ),
    BinaryComputerPreset(
      chipLabel: "Table 1.1 (4-Bit Letters): H to O (8₁₀ to 15₁₀)",
      mode: 3,
      inputStr: 'H-O',
    ),
    BinaryComputerPreset(
      chipLabel: "Table 1.1 (5-Bit Letters): P to Z (16₁₀ to 26₁₀)",
      mode: 3,
      inputStr: 'P-Z',
    ),
  ];

  // ===========================================================================
  // CORE ALPHABET & BINARY CONVERSION HELPERS
  // ===========================================================================
  static const List<int> placeWeights = [16, 8, 4, 2, 1];

  /// Converts any positive integer (1..26) to its binary string and builds a CodedLetterRow.
  static CodedLetterRow buildLetterRow(String rawChar) {
    final String upper = rawChar.trim().toUpperCase();
    if (upper.isEmpty || upper == ' ') {
      return CodedLetterRow.wordSeparator();
    }
    final int codeUnit = upper.codeUnitAt(0);
    if (codeUnit < 65 || codeUnit > 90) {
      throw FormatException(
        "Invalid character '$rawChar'. Only English alphabet letters A to Z (and spaces between words) are supported.",
      );
    }

    final int pos10 = codeUnit - 64; // A = 1, B = 2, ..., Z = 26
    final String rawBin = pos10.toRadixString(2);

    String upperBits = '';
    String lower3Bits = rawBin;
    String groupedPlain = rawBin;
    String groupedLaTeX = rawBin;

    if (rawBin.length > 3) {
      final int splitIdx = rawBin.length - 3;
      upperBits = rawBin.substring(0, splitIdx);
      lower3Bits = rawBin.substring(splitIdx);
      groupedPlain = '$upperBits $lower3Bits';
      groupedLaTeX = '$upperBits\\,$lower3Bits';
    }

    final String padded5 = rawBin.padLeft(5, '0');
    final List<int> fiveBits =
    padded5.split('').map((ch) => ch == '1' ? 1 : 0).toList();

    return CodedLetterRow(
      letter: upper,
      base10Position: pos10,
      rawBinary: rawBin,
      upperBits: upperBits,
      lower3Bits: lower3Bits,
      groupedBinaryPlain: groupedPlain,
      groupedBinaryLaTeX: groupedLaTeX,
      fiveTrackBits: fiveBits,
      isWordSeparator: false,
    );
  }

  /// Generates the unabridged step-by-step Base 10 -> Base 2 proof for a single letter (1..26),
  /// showing BOTH repeated division by 2 AND powers-of-2 place value decomposition!
  static Map<String, String> buildSingleLetterConversionProof(
      CodedLetterRow row) {
    final int n = row.base10Position;
    final List<String> divStepsLaTeX = [];
    final List<String> divStepsPlain = [];

    int curr = n;
    while (curr > 0) {
      final int q = curr ~/ 2;
      final int r = curr % 2;
      divStepsLaTeX.add("$curr \\div 2 = $q \\text{ r } \\mathbf{$r}");
      divStepsPlain.add("$curr ÷ 2 = $q r $r");
      curr = q;
    }

    // Also build powers-of-2 expansion from the highest active bit down to 2^0
    final List<String> activePowerTermsLaTeX = [];
    final List<String> evaluatedPowerTerms = [];
    final int bitLen = row.rawBinary.length;
    for (int i = 0; i < bitLen; i++) {
      final int bit = row.rawBinary[i] == '1' ? 1 : 0;
      final int p = bitLen - 1 - i;
      final int pVal = 1 << p;
      activePowerTermsLaTeX.add("($bit \\times 2^$p)");
      evaluatedPowerTerms.add("${bit * pVal}");
    }

    final String latexLine1 =
        "\\bullet \\; \\mathbf{\\text{${row.letter}} = ${n}_{\\text{ten}}}: \\quad ${divStepsLaTeX.join(', \\; ')} \\; (\\uparrow) \\implies \\mathbf{${row.groupedBinaryLaTeX}_{\\text{two}}}";
    final String latexLine2 =
        "\\quad \\text{Check by powers of 2: } $n = ${evaluatedPowerTerms.join(' + ')} = ${activePowerTermsLaTeX.join(' + ')} = \\mathbf{${row.groupedBinaryLaTeX}_{\\text{two}}}";

    final String plainSummary =
        "• ${row.letter} = ${n}₁₀:\n"
        "  – By repeated division by 2: ${divStepsPlain.join('  ➔  ')} (Read remainders upwards ↑ = ${row.groupedBinaryPlain}₂).\n"
        "  – Check by powers of 2: ${evaluatedPowerTerms.join(' + ')} = ${row.groupedBinaryPlain}₂.";

    return {
      'latex1': latexLine1,
      'latex2': latexLine2,
      'plain': plainSummary,
    };
  }

  /// Builds the Horizontal Letter-to-Base-10 Mapping Grid shown in Example 5c (BENIN) & 5d (ENUGU).
  static String buildHorizontalWordMappingLaTeX(List<CodedLetterRow> wordRows) {
    final String colSpec = List.filled(wordRows.length + 1, 'c').join('|');
    final String lettersRow =
    wordRows.map((r) => "\\mathbf{\\text{${r.letter}}}").join(' & ');
    final String base10Row =
    wordRows.map((r) => "${r.base10Position}").join(' & ');

    return "\\begin{array}{|$colSpec|} \\hline "
        "\\text{Letter} & $lettersRow \\\\ \\hline "
        "\\text{Base 10} & $base10Row \\\\ \\hline "
        "\\end{array}";
  }

  /// Builds the exact Vertical Textbook Coded Table (Tables 1.2–1.6 style) with the
  /// vertical dashed 3-bit separator line and horizontal dashed lines between words!
  static String buildVerticalCodedTableLaTeX(
      List<CodedLetterRow> rows, {
        bool includeBase10Column = true,
      }) {
    final StringBuffer buf = StringBuffer();
    if (includeBase10Column) {
      buf.write("\\begin{array}{c c | r : r} ");
      buf.write(
          "\\textbf{Letter} & \\textbf{Base 10} & \\textbf{16, 8} & \\textbf{4, 2, 1} \\\\ \\hline ");
    } else {
      buf.write("\\begin{array}{c | r : r} ");
      buf.write(
          "\\textbf{Letter} & \\textbf{16, 8} & \\textbf{4, 2, 1} \\\\ \\hline ");
    }

    for (int i = 0; i < rows.length; i++) {
      final CodedLetterRow r = rows[i];
      if (r.isWordSeparator) {
        buf.write("\\hline ");
        continue;
      }
      final String up = r.upperBits.isEmpty ? "" : "\\mathbf{${r.upperBits}}";
      final String low = "\\mathbf{${r.lower3Bits}}";
      if (includeBase10Column) {
        buf.write(
            "\\mathbf{\\text{${r.letter}}} & ${r.base10Position} & $up & $low \\\\ ");
      } else {
        buf.write("\\mathbf{\\text{${r.letter}}} & $up & $low \\\\ ");
      }
    }
    buf.write("\\end{array}");
    return buf.toString();
  }

  /// Builds the LaTeX representation of a 5-Track Computer Punch Tape (Example 7a & 7b)
  static String buildPunchTapeTableLaTeX(
      List<CodedLetterRow> rows, {
        required int punchTapeStyle,
      }) {
    final StringBuffer buf = StringBuffer();
    buf.write("\\begin{array}{|c|c||c|c|c|c|c|} \\hline ");
    buf.write(
        "\\textbf{Letter} & \\textbf{Base 10} & \\mathbf{16}\\;(2^4) & \\mathbf{8}\\;(2^3) & \\mathbf{4}\\;(2^2) & \\mathbf{2}\\;(2^1) & \\mathbf{1}\\;(2^0) \\\\ \\hline ");

    for (final CodedLetterRow r in rows) {
      if (r.isWordSeparator) {
        buf.write(
            "\\text{(Space)} & - & - & - & - & - & - \\\\ \\hline ");
        continue;
      }

      final int bitLen = r.rawBinary.length;
      final List<String> trackCells = [];
      for (int col = 0; col < 5; col++) {
        final int bitPower = 4 - col; // 4, 3, 2, 1, 0
        final int bitVal = r.fiveTrackBits[col];
        if (bitVal == 1) {
          trackCells.add("\\bullet");
        } else {
          if (punchTapeStyle == 1) {
            trackCells.add("\\circ");
          } else {
            // In textbook style (Example 7), leading zeros above bitLen are left blank, while internal 0s are unpunched spaces
            trackCells.add(bitPower < bitLen ? "\\cdot" : "\\phantom{\\bullet}");
          }
        }
      }

      buf.write(
          "\\mathbf{\\text{${r.letter}}} & ${r.base10Position} & ${trackCells.join(' & ')} \\\\ \\hline ");
    }

    buf.write("\\end{array}");
    return buf.toString();
  }

  /// Parses an English word or sentence into a list of CodedLetterRow items (with word separators)
  static List<CodedLetterRow> parseTextToCodedRows(String rawText) {
    final String cleaned = rawText
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      throw const FormatException(
        "Please enter a word or sentence using English letters A to Z (e.g. LAGOS, KADUNA, BENIN, ENUGU, or I LIKE MATHEMATICS).",
      );
    }

    final List<String> words = cleaned.split(' ');
    final List<CodedLetterRow> allRows = [];
    int totalLetters = 0;

    for (int w = 0; w < words.length; w++) {
      final String word = words[w];
      if (word.isEmpty) continue;
      if (w > 0 && allRows.isNotEmpty) {
        allRows.add(CodedLetterRow.wordSeparator());
      }
      for (int i = 0; i < word.length; i++) {
        totalLetters++;
        if (totalLetters > 32) {
          throw const FormatException(
            "Please enter a word or sentence of up to 32 letters so the coded table and punch tape remain clear.",
          );
        }
        allRows.add(buildLetterRow(word[i]));
      }
    }

    return allRows;
  }

  // ===========================================================================
  // MODE 0: WORD & SENTENCE TO CODED BINARY FORM (Examples 5 & 6 — Tables 1.2–1.6)
  // ===========================================================================
  static BinaryComputerResult solveWordOrSentenceToBinary({
    required String rawTextInput,
    bool includeFullTable1_1 = false,
  }) {
    try {
      final List<CodedLetterRow> rows = parseTextToCodedRows(rawTextInput);
      final List<CodedLetterRow> letterOnlyRows =
      rows.where((r) => !r.isWordSeparator).toList();
      final bool isMultiWord = rows.any((r) => r.isWordSeparator);

      final String cleanPhrase = rows
          .map((r) => r.isWordSeparator ? ' ' : r.letter)
          .join('');

      // Split into words for horizontal tables (Example 5c & 5d style)
      final List<List<CodedLetterRow>> wordGroups = [];
      List<CodedLetterRow> currGroup = [];
      for (final r in rows) {
        if (r.isWordSeparator) {
          if (currGroup.isNotEmpty) {
            wordGroups.add(currGroup);
            currGroup = [];
          }
        } else {
          currGroup.add(r);
        }
      }
      if (currGroup.isNotEmpty) wordGroups.add(currGroup);

      // Unique letters in order of appearance for unabridged Base-10 to Base-2 proofs
      final Set<String> seenLetters = {};
      final List<CodedLetterRow> uniqueLetters = [];
      for (final r in letterOnlyRows) {
        if (!seenLetters.contains(r.letter)) {
          seenLetters.add(r.letter);
          uniqueLetters.add(r);
        }
      }

      final List<String> workings = [];
      final List<BinaryComputerStep> steps = [];

      // Step 1: Alphabetical Base-10 Position Lookup (A=1 to Z=26)
      workings.add(
          "\\text{\\textbf{Step 1: Number Each Letter in Base 10 (Alphabet Position A = 1 to Z = 26)}}");
      for (final List<CodedLetterRow> wg in wordGroups) {
        workings.add(buildHorizontalWordMappingLaTeX(wg));
      }

      final String letterMapSummaryPlain = letterOnlyRows
          .map((r) => "${r.letter} = ${r.base10Position}₁₀")
          .join(', ');

      // Check if word is KADUNA to include the helpful textbook misprint note for Table 1.3!
      final bool hasLetterU = seenLetters.contains('U');
      final String kadunaTypoNote = cleanPhrase.contains('KADUNA')
          ? "\n• Helpful Textbook Note (Page 12, Table 1.3): In Table 1.3 for KADUNA, the textbook accidentally printed '11' instead of '21' next to U in the Base 10 column, even though it correctly wrote 10 101₂ (= 21₁₀) in the binary column! Remember that U is the 21st letter of the alphabet (U = 21₁₀ = 10 101₂)."
          : (hasLetterU
          ? "\n• Note: U is the 21st letter of the alphabet (U = 21₁₀ = 10 101₂)."
          : "");

      steps.add(BinaryComputerStep(
        title:
        "Step 1: Find Each Letter's Alphabetical Position in Base 10 (Table 1.1 Rule)",
        description:
        "To translate '$cleanPhrase' into computer coded form, first number the 26 letters of the English alphabet sequentially in base 10 from A = 1, B = 2, C = 3, …, up to Z = 26:\n"
            "• Letter positions: $letterMapSummaryPlain.$kadunaTypoNote",
        mathLaTeX: wordGroups.map(buildHorizontalWordMappingLaTeX).join('\n'),
      ));

      // Step 2: Unabridged Base 10 -> Base 2 Conversion for Every Unique Letter
      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 2: Convert Each Letter's Base 10 Number to Binary (Base 2)}}");
      final List<String> uniqueProofsPlain = [];
      final List<String> uniqueProofsLaTeX = [];

      for (final CodedLetterRow uRow in uniqueLetters) {
        final Map<String, String> proof = buildSingleLetterConversionProof(uRow);
        workings.add(proof['latex1']!);
        workings.add(proof['latex2']!);
        uniqueProofsPlain.add(proof['plain']!);
        uniqueProofsLaTeX.add("${proof['latex1']!}\n${proof['latex2']!}");
      }

      steps.add(BinaryComputerStep(
        title:
        "Step 2: Convert Each Letter's Base 10 Position to Base 2 (Repeated Division by 2)",
        description:
        "Divide each letter's base 10 position repeatedly by 2 and read the remainders upwards (↑), or decompose into powers of 2 (16, 8, 4, 2, 1):\n\n"
            "${uniqueProofsPlain.join('\n\n')}",
        mathLaTeX: uniqueProofsLaTeX.join('\n'),
      ));

      // Step 3: Complete Vertical Coded Table (Tables 1.2–1.6 Style)
      final String verticalTableLaTeX = buildVerticalCodedTableLaTeX(
        rows,
        includeBase10Column: !isMultiWord || rows.length <= 16,
      );

      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 3: Write }} \\text{'$cleanPhrase'} \\text{\\textbf{ Vertically in Coded Binary Form (${isMultiWord ? 'Table 1.6' : 'Tables 1.2–1.5'} Format)}}");
      workings.add(verticalTableLaTeX);

      steps.add(BinaryComputerStep(
        title:
        "Step 3: Arrange Vertically in Textbook Coded Form (${isMultiWord ? 'Table 1.6 Sentence Style' : 'Tables 1.2–1.5 Word Style'})",
        description:
        "• Write each letter vertically line-by-line with its binary code aligned on the right.\n"
            "• Just like Tables 1.2 to 1.6 in the textbook, a vertical dashed line separates the 3 rightmost bits (4, 2, 1) from the leading bits (16, 8)."
            "${isMultiWord ? '\n• Because this is a multi-word sentence, horizontal divider lines are placed between words to represent spaces!' : ''}",
        mathLaTeX: verticalTableLaTeX,
      ));

      if (includeFullTable1_1) {
        workings.add("");
        workings.add("\\text{\\textbf{Reference: Complete Table 1.1 (A = 1 to Z = 26)}}");
        workings.add(_buildFullTable1_1LaTeX());
      }

      final String codeSequencePlain = rows
          .map((r) => r.isWordSeparator ? '/' : '${r.groupedBinaryPlain}₂')
          .join(', ')
          .replaceAll(', /, ', '  /  ');

      return BinaryComputerResult(
        mode: 0,
        finalAnswers: {
          isMultiWord ? "Input Sentence" : "Input Word": cleanPhrase,
          "Total Letters Coded": "${letterOnlyRows.length} letters",
          "Coded Binary Sequence": codeSequencePlain,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryComputerCanvasData(
          mode: 0,
          punchTapeStyle: 0,
          rows: rows,
          headerBadge:
          "Coded Form of '$cleanPhrase'  (${letterOnlyRows.length} Letters)",
          subBadge:
          "Left: Textbook Coded Table (Tables 1.2–1.6)   |   Right: 5-Track Computer Punch Tape (Example 7)",
          bottomSummaryBanner: "$cleanPhrase  ➔  $codeSequencePlain",
        ),
      );
    } catch (e) {
      return BinaryComputerResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid English word or sentence (A–Z).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: COMPUTER PUNCH TAPE GENERATOR (Example 7a & 7b)
  // ===========================================================================
  static BinaryComputerResult solvePunchTapeGenerator({
    required String rawTextInput,
    required int punchTapeStyle, // 0: Punched Holes Only for 1s, 1: Full 5-Bit Track (● = 1, ○ = 0)
  }) {
    try {
      final List<CodedLetterRow> rows = parseTextToCodedRows(rawTextInput);
      final List<CodedLetterRow> letterOnlyRows =
      rows.where((r) => !r.isWordSeparator).toList();
      final bool isMultiWord = rows.any((r) => r.isWordSeparator);
      final String cleanPhrase = rows
          .map((r) => r.isWordSeparator ? ' ' : r.letter)
          .join('');

      final Set<String> seenLetters = {};
      final List<CodedLetterRow> uniqueLetters = [];
      for (final r in letterOnlyRows) {
        if (!seenLetters.contains(r.letter)) {
          seenLetters.add(r.letter);
          uniqueLetters.add(r);
        }
      }

      final List<String> workings = [];
      final List<BinaryComputerStep> steps = [];

      // Step 1: Convert Each Letter to Base 10 and Base 2
      workings.add(
          "\\text{\\textbf{Step 1: Find Base 10 and Base 2 Code for Each Letter in '$cleanPhrase'}}");
      final List<String> uniqueProofsPlain = [];
      final List<String> uniqueProofsLaTeX = [];

      for (final CodedLetterRow uRow in uniqueLetters) {
        final Map<String, String> proof = buildSingleLetterConversionProof(uRow);
        workings.add(proof['latex1']!);
        uniqueProofsPlain.add(proof['plain']!);
        uniqueProofsLaTeX.add(proof['latex1']!);
      }

      steps.add(BinaryComputerStep(
        title:
        "Step 1: Convert Each Letter in '$cleanPhrase' to Its Binary Code (Table 1.1)",
        description:
        "Before punching a computer tape or card, find each letter's alphabetical position (1 to 26) and convert it to binary:\n\n"
            "${uniqueProofsPlain.join('\n\n')}",
        mathLaTeX: uniqueProofsLaTeX.join('\n'),
      ));

      // Step 2: Explain How Punch Tapes Work (Page 13 Rule) & Show Row-by-Row Hole Positions
      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 2: Punch Holes in Place of Binary 1s on the 5-Track Tape (Example 7)}}");
      workings.add(
          "\\text{Rule (Page 13): Punch a hole } (\\bullet) \\text{ for every binary digit } \\mathbf{1}, \\text{ and leave unpunched for } \\mathbf{0}.");

      final List<String> rowPunchDescriptions = [];
      for (final CodedLetterRow r in rows) {
        if (r.isWordSeparator) {
          rowPunchDescriptions.add("• [Word Space]: Leave a blank separator row between words.");
          continue;
        }
        final List<String> punchedCols = [];
        for (int c = 0; c < 5; c++) {
          if (r.fiveTrackBits[c] == 1) {
            punchedCols.add("${placeWeights[c]}");
          }
        }
        rowPunchDescriptions.add(
          "• ${r.letter} = ${r.base10Position}₁₀ = ${r.groupedBinaryPlain}₂  ➔  Punch hole(s) at column(s) [${punchedCols.join(' + ')}] (since ${punchedCols.join(' + ')} = ${r.base10Position}).",
        );
      }

      final String punchTableLaTeX = buildPunchTapeTableLaTeX(
        rows,
        punchTapeStyle: punchTapeStyle,
      );
      workings.add(punchTableLaTeX);

      steps.add(BinaryComputerStep(
        title:
        "Step 2: Punch Holes (●) for Binary '1's Across the 5 Place-Value Tracks (16, 8, 4, 2, 1)",
        description:
        "• Textbook Rule (Page 13): 'To get messages on punch cards or tapes, holes are punched in place of binary numbers in the coded words or statements line by line.'\n"
            "• Every binary '1' is represented by a punched hole (●), and every binary '0' is left unpunched:\n\n"
            "${rowPunchDescriptions.join('\n')}",
        mathLaTeX: punchTableLaTeX,
      ));

      final int totalHolesPunched = letterOnlyRows.fold(
        0,
            (sum, r) => sum + r.fiveTrackBits.where((b) => b == 1).length,
      );

      return BinaryComputerResult(
        mode: 1,
        finalAnswers: {
          "Message on Tape": cleanPhrase,
          "Tape Rows (Letters)":
          "${letterOnlyRows.length} letter rows${isMultiWord ? ' + word spaces' : ''}",
          "Total Holes Punched (1s)": "$totalHolesPunched holes (●)",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryComputerCanvasData(
          mode: 1,
          punchTapeStyle: punchTapeStyle,
          rows: rows,
          headerBadge: "Computer Punch Tape for '$cleanPhrase' (Example 7)",
          subBadge:
          "Tracks: 16 (2⁴) | 8 (2³) : 4 (2²) | 2 (2¹) | 1 (2⁰)   —   ● = Punched Hole (1)",
          bottomSummaryBanner:
          "Total Punched Holes (●) = $totalHolesPunched across ${letterOnlyRows.length} letters",
        ),
      );
    } catch (e) {
      return BinaryComputerResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter a valid word or sentence for the punch tape.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: DECODE BINARY CODE / PUNCH TAPE BACK TO ENGLISH
  // ===========================================================================
  static BinaryComputerResult solveDecodeBinaryToEnglish({
    required String rawBinaryCodesInput,
  }) {
    try {
      String s = rawBinaryCodesInput.trim();
      if (s.isEmpty) {
        throw const FormatException(
          "Please enter binary codes separated by commas (e.g. 1100, 1, 111, 1111, 10011). Use '/' between words.",
        );
      }

      // Normalize word separators ('/', ';', '|') into a distinct token
      s = s.replaceAll('|', ' / ').replaceAll(';', ' / ');

      // Split into tokens: if commas are present, split by comma or '/'; otherwise split by whitespace
      final List<String> rawTokens = [];
      if (s.contains(',')) {
        final List<String> slashParts = s.split('/');
        for (int w = 0; w < slashParts.length; w++) {
          if (w > 0) rawTokens.add('/');
          final List<String> commaParts = slashParts[w]
              .split(',')
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .toList();
          rawTokens.addAll(commaParts);
        }
      } else {
        rawTokens.addAll(
          s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty),
        );
      }

      if (rawTokens.isEmpty) {
        throw const FormatException("No binary codes found to decode.");
      }

      final List<CodedLetterRow> decodedRows = [];
      final List<String> workings = [
        "\\text{\\textbf{Step 1: Convert Each Binary Code to Base 10 by Expanding in Powers of 2}}",
      ];
      final List<String> step1LinesPlain = [];
      final List<String> step1LinesLaTeX = [];
      final StringBuffer decodedMessageBuf = StringBuffer();

      int letterCounter = 0;
      for (final String tok in rawTokens) {
        if (tok == '/') {
          if (decodedRows.isNotEmpty && !decodedRows.last.isWordSeparator) {
            decodedRows.add(CodedLetterRow.wordSeparator());
            decodedMessageBuf.write(' ');
          }
          continue;
        }

        // Strip internal grouping spaces (e.g. "1 100" -> "1100", "10:011" -> "10011") and subscripts
        final String cleanBin = tok
            .replaceAll(':', '')
            .replaceAll(' ', '')
            .replaceAll('₂', '')
            .replaceAll(RegExp(r'(_|\s)*(two|2)$', caseSensitive: false), '')
            .replaceAll('●', '1')
            .replaceAll('○', '0')
            .replaceAll('.', '0')
            .trim();

        if (cleanBin.isEmpty) continue;
        if (!RegExp(r'^[01]+$').hasMatch(cleanBin)) {
          throw FormatException(
            "Invalid binary code '$tok'. Each code must contain only binary digits 0 and 1 (or ● and ○).",
          );
        }

        final int base10Val = int.parse(cleanBin, radix: 2);
        if (base10Val < 1 || base10Val > 26) {
          throw FormatException(
            "Binary code '$cleanBin₂' equals ${base10Val}₁₀, which is outside the alphabet range 1 to 26 (A = 1₁₀ to Z = 26₁₀ = 11 010₂)!",
          );
        }

        letterCounter++;
        if (letterCounter > 32) {
          throw const FormatException("Please enter up to 32 binary codes at a time.");
        }

        final String ch = String.fromCharCode(64 + base10Val);
        final CodedLetterRow row = buildLetterRow(ch);
        decodedRows.add(row);
        decodedMessageBuf.write(ch);

        // Build full power-of-2 expansion for this binary code
        final int len = cleanBin.length;
        final List<String> powerTermsLaTeX = [];
        final List<String> evalTermsLaTeX = [];
        for (int i = 0; i < len; i++) {
          final int b = cleanBin[i] == '1' ? 1 : 0;
          final int p = len - 1 - i;
          final int pVal = 1 << p;
          powerTermsLaTeX.add("($b \\times 2^$p)");
          evalTermsLaTeX.add("${b * pVal}");
        }

        final String lineLatex =
            "\\bullet \\; ${row.groupedBinaryLaTeX}_{\\text{two}} = ${powerTermsLaTeX.join(' + ')} = ${evalTermsLaTeX.join(' + ')} = \\mathbf{${base10Val}_{\\text{ten}}} \\longrightarrow \\mathbf{\\text{$ch}}";
        workings.add(lineLatex);
        step1LinesLaTeX.add(lineLatex);
        step1LinesPlain.add(
          "• ${row.groupedBinaryPlain}₂ = ${evalTermsLaTeX.join(' + ')} = ${base10Val}₁₀  ➔  Letter '$ch'",
        );
      }

      if (decodedRows.isEmpty) {
        throw const FormatException("Please enter at least one valid binary code.");
      }

      final String decodedMessage = decodedMessageBuf.toString().trim();
      final List<CodedLetterRow> letterOnlyRows =
      decodedRows.where((r) => !r.isWordSeparator).toList();

      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 2: Match Each Base 10 Number to Table 1.1 and Combine Letters}}");
      workings.add(buildVerticalCodedTableLaTeX(decodedRows));
      workings.add(
          "\\therefore \\; \\text{Decoded English Message} = \\mathbf{\\text{$decodedMessage}}");

      final List<BinaryComputerStep> steps = [
        BinaryComputerStep(
          title:
          "Step 1: Convert Each Binary Code to Base 10 Using Powers of 2",
          description:
          "Expand each binary number in powers of 2 (16, 8, 4, 2, 1) to find its value in base 10, then match that number (1 to 26) to its letter in Table 1.1:\n\n"
              "${step1LinesPlain.join('\n')}",
          mathLaTeX: step1LinesLaTeX.join('\n'),
        ),
        BinaryComputerStep(
          title:
          "Step 2: Combine the Decoded Letters in Order",
          description:
          "Reading the decoded letters in order from first to last gives the hidden message:\n"
              "• Decoded Message = '$decodedMessage'!",
          mathLaTeX:
          "\\text{Decoded Message} = \\boxed{\\mathbf{\\text{$decodedMessage}}}",
        ),
      ];

      return BinaryComputerResult(
        mode: 2,
        finalAnswers: {
          "Decoded Message": decodedMessage,
          "Base 10 Numbers": letterOnlyRows
              .map((r) => "${r.base10Position}₁₀ (${r.letter})")
              .join(', '),
          "Total Letters Decoded": "${letterOnlyRows.length} letters",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryComputerCanvasData(
          mode: 2,
          punchTapeStyle: 0,
          rows: decodedRows,
          headerBadge: "Decoded Binary Message:  '$decodedMessage'",
          subBadge:
          "Each binary code is converted to Base 10 (1–26) and matched to Letters A–Z",
          bottomSummaryBanner: "Decoded Result = $decodedMessage",
        ),
      );
    } catch (e) {
      return BinaryComputerResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary codes between 1₂ (1) and 11010₂ (26).",
      );
    }
  }

  // ===========================================================================
  // MODE 3: INTERACTIVE TABLE 1.1 EXPLORER (A–Z LOOKUP & 5-BIT PLACE-VALUE GRID)
  // ===========================================================================
  static String _buildFullTable1_1LaTeX() {
    // Renders Table 1.1 in two side-by-side 13-row columns (A–M and N–Z) so it fits cleanly!
    final StringBuffer buf = StringBuffer();
    buf.write("\\begin{array}{|c|c|r||c|c|r|} \\hline ");
    buf.write(
        "\\textbf{Letter} & \\textbf{Base 10} & \\textbf{Base 2} & \\textbf{Letter} & \\textbf{Base 10} & \\textbf{Base 2} \\\\ \\hline ");
    for (int i = 0; i < 13; i++) {
      final CodedLetterRow left =
      buildLetterRow(String.fromCharCode(65 + i)); // A..M
      final CodedLetterRow right =
      buildLetterRow(String.fromCharCode(65 + 13 + i)); // N..Z
      buf.write(
          "\\mathbf{\\text{${left.letter}}} & ${left.base10Position} & \\mathbf{${left.groupedBinaryLaTeX}} & "
              "\\mathbf{\\text{${right.letter}}} & ${right.base10Position} & \\mathbf{${right.groupedBinaryLaTeX}} \\\\ \\hline ");
    }
    buf.write("\\end{array}");
    return buf.toString();
  }

  static BinaryComputerResult solveTable1_1Explorer({
    required String filterInputStr,
  }) {
    try {
      final String clean = filterInputStr.trim().toUpperCase();
      List<CodedLetterRow> selectedRows = [];
      String rangeLabel = "Full Alphabet A to Z (1₁₀ to 26₁₀)";

      if (clean.isEmpty || clean == 'A-Z' || clean == 'ALL') {
        selectedRows = List.generate(
          26,
              (i) => buildLetterRow(String.fromCharCode(65 + i)),
        );
      } else if (RegExp(r'^[A-Z]\s*-\s*[A-Z]$').hasMatch(clean)) {
        final List<String> parts =
        clean.split('-').map((s) => s.trim()).toList();
        final int startCode = parts[0].codeUnitAt(0);
        final int endCode = parts[1].codeUnitAt(0);
        final int lo = startCode <= endCode ? startCode : endCode;
        final int hi = startCode <= endCode ? endCode : startCode;
        for (int c = lo; c <= hi; c++) {
          selectedRows.add(buildLetterRow(String.fromCharCode(c)));
        }
        rangeLabel =
        "Letters ${String.fromCharCode(lo)} to ${String.fromCharCode(hi)} (${lo - 64}₁₀ to ${hi - 64}₁₀)";
      } else {
        selectedRows = parseTextToCodedRows(clean)
            .where((r) => !r.isWordSeparator)
            .toList();
        rangeLabel = "Selected Letters: ${selectedRows.map((r) => r.letter).join(', ')}";
      }

      final List<String> workings = [
        "\\text{\\textbf{Table 1.1: The 26-Letter Alphabet Binary Coding System (Page 12)}}",
        "\\text{Why at most 5 binary digits are needed: } 2^4 = 16 \\text{ and } 2^5 - 1 = 31 \\ge 26.",
        "\\bullet \\text{ Letters A to G } (1_{\\text{ten}} \\text{ to } 7_{\\text{ten}}): \\text{ 1 to 3 binary digits } (1_{\\text{two}} \\text{ to } 111_{\\text{two}}).",
        "\\bullet \\text{ Letters H to O } (8_{\\text{ten}} \\text{ to } 15_{\\text{ten}}): \\text{ 4 binary digits } (1\\,000_{\\text{two}} \\text{ to } 1\\,111_{\\text{two}}).",
        "\\bullet \\text{ Letters P to Z } (16_{\\text{ten}} \\text{ to } 26_{\\text{ten}}): \\text{ 5 binary digits } (10\\,000_{\\text{two}} \\text{ to } 11\\,010_{\\text{two}}).",
        "",
        _buildFullTable1_1LaTeX(),
      ];

      final List<BinaryComputerStep> steps = [
        BinaryComputerStep(
          title:
          "Step 1: Structure of Table 1.1 (Why 26 Letters Need Up to 5 Binary Digits)",
          description:
          "• In Table 1.1 on page 12, the 26 letters of the alphabet are numbered from A = 1₁₀ to Z = 26₁₀.\n"
              "• Letters A to G (1 to 7) use 1 to 3 bits (columns 4, 2, 1).\n"
              "• Letters H to O (8 to 15) reach the 8s column (2³ = 8), so they require 4 bits (1 000₂ to 1 111₂).\n"
              "• Letters P to Z (16 to 26) reach the 16s column (2⁴ = 16), so they require 5 bits (10 000₂ to 11 010₂).",
          mathLaTeX: _buildFullTable1_1LaTeX(),
        ),
        BinaryComputerStep(
          title: "Step 2: 5-Bit Place-Value Breakdown ($rangeLabel)",
          description:
          "Every letter from A to Z can be written as a sum of a subset of the five binary place weights [16, 8, 4, 2, 1]:",
          mathLaTeX: buildPunchTapeTableLaTeX(
            selectedRows,
            punchTapeStyle: 1,
          ),
        ),
      ];

      return BinaryComputerResult(
        mode: 3,
        finalAnswers: {
          "Displayed Range": rangeLabel,
          "First Letter in Range":
          "${selectedRows.first.letter} = ${selectedRows.first.base10Position}₁₀ = ${selectedRows.first.groupedBinaryPlain}₂",
          "Last Letter in Range":
          "${selectedRows.last.letter} = ${selectedRows.last.base10Position}₁₀ = ${selectedRows.last.groupedBinaryPlain}₂",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryComputerCanvasData(
          mode: 3,
          punchTapeStyle: 1,
          rows: selectedRows,
          headerBadge: "Table 1.1 Explorer:  $rangeLabel",
          subBadge:
          "A = 1₁₀ (1₂)   |   H = 8₁₀ (1 000₂)   |   P = 16₁₀ (10 000₂)   |   Z = 26₁₀ (11 010₂)",
          bottomSummaryBanner:
          "Showing ${selectedRows.length} letter(s) on the Coded Table & 5-Track Punch Tape",
        ),
      );
    } catch (e) {
      return BinaryComputerResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter a valid letter range (e.g. A-Z, A-G, H-O, P-Z) or word.",
      );
    }
  }
}