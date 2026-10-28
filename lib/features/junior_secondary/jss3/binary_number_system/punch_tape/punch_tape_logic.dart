import 'punch_tape_models.dart';

class PunchTapeLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 13–15: Example 7 [Tables 1.7a–d] & Exercise 1.4 #1–5)
  // ===========================================================================
  static const List<PunchTapePreset> textbookPresets = [
    PunchTapePreset(
      chipLabel: "Ex 7a (Tables 1.7a–b): Punch Tape for LAGOS",
      mode: 0,
      punchTapeStyle: 0,
      inputStr: 'LAGOS',
    ),
    PunchTapePreset(
      chipLabel: "Ex 7b (Tables 1.7c–d): Punch Tape for I AM A NIGERIAN",
      mode: 0,
      punchTapeStyle: 0,
      inputStr: 'I AM A NIGERIAN',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #2a: Punch Tape for I AM A SUPERSTAR",
      mode: 0,
      punchTapeStyle: 0,
      inputStr: 'I AM A SUPERSTAR',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #2b: Punch Tape for I HATE CORRUPTION",
      mode: 0,
      punchTapeStyle: 0,
      inputStr: 'I HATE CORRUPTION',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #2c: Punch Tape for MY MOTHER IS BEAUTIFUL",
      mode: 0,
      punchTapeStyle: 0,
      inputStr: 'MY MOTHER IS BEAUTIFUL',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #2d: Punch Tape for NIGERIA IS A GREAT NATION",
      mode: 0,
      punchTapeStyle: 0,
      inputStr: 'NIGERIA IS A GREAT NATION',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #2e: I LIKE MY MATHEMATICS TEACHER",
      mode: 0,
      punchTapeStyle: 0,
      inputStr: 'I LIKE MY MATHEMATICS TEACHER',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #2f: MATHEMATICS IS AN INTERESTING SUBJECT",
      mode: 0,
      punchTapeStyle: 0,
      inputStr: 'MATHEMATICS IS AN INTERESTING SUBJECT',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #1a: Write SOKOTO in Coded Form",
      mode: 1,
      inputStr: 'SOKOTO',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #1b: Write KEFFI in Coded Form",
      mode: 1,
      inputStr: 'KEFFI',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #1e: Write ABAKALIKI in Coded Form",
      mode: 1,
      inputStr: 'ABAKALIKI',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #1h: Write AEROPLANE in Coded Form",
      mode: 1,
      inputStr: 'AEROPLANE',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #3a (Table 1.8a): Decode Binary Statement",
      mode: 2,
      inputStr:
      '1:001 ; 10:111, 1:001, 1:100, 1:100 ; 10:000, 1, 10:011, 10:011, 10:011 ; 1:101, 11:001 ; 10:011, 10:011, 11, 101 ; 101, 11:000, 1, 1:101',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #3b (Table 1.8b): Decode Binary Statement",
      mode: 2,
      inputStr:
      '10:011, 10:101, 11, 11, 101, 10:011, 10:011 ; 1:001, 10:011 ; 1:101, 1:001, 1:110, 101',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #4a: Translate 9, 12, 9, 11, 5; 13, 1, 20, 8, 5...",
      mode: 3,
      inputStr: '9, 12, 9, 11, 5; 13, 1, 20, 8, 5, 13; 1; 20; 9, 3, 19',
    ),
    PunchTapePreset(
      chipLabel: "Ex 1.4 #4b: Translate 9; 1, 13; 1; 7, 15, 15, 4; 14, 9...",
      mode: 3,
      inputStr: '9; 1, 13; 1; 7, 15, 15, 4; 14, 9, 7, 18, 9, 1, 14',
    ),
  ];

  // ===========================================================================
  // CORE ALPHABET, BINARY & PUNCH-TAPE HELPERS
  // ===========================================================================
  static const List<int> placeWeights = [16, 8, 4, 2, 1];

  /// Converts an uppercase letter ('A'..'Z') into a complete PunchTapeRow.
  static PunchTapeRow buildLetterRow(String rawChar) {
    final String upper = rawChar.trim().toUpperCase();
    if (upper.isEmpty || upper == ' ') {
      return PunchTapeRow.wordSeparator();
    }
    final int codeUnit = upper.codeUnitAt(0);
    if (codeUnit < 65 || codeUnit > 90) {
      throw FormatException(
        "Invalid character '$rawChar'. Only English letters A to Z (and spaces between words) are supported.",
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
      groupedPlain = '$upperBits:$lower3Bits';
      groupedLaTeX = '$upperBits\\,$lower3Bits';
    }

    final String padded5 = rawBin.padLeft(5, '0');
    final List<int> fiveBits =
    padded5.split('').map((ch) => ch == '1' ? 1 : 0).toList();

    // Build textbook punch-hole visual string matching Table 1.7(b) & Table 1.7(d)
    // Columns: [16, 8 : 4, 2, 1]
    final String upHole16 = fiveBits[0] == 1 ? '●' : ' ';
    final String upHole8 = fiveBits[1] == 1 ? '●' : ' ';
    final String lowHole4 = fiveBits[2] == 1 ? '●' : ' ';
    final String lowHole2 = fiveBits[3] == 1 ? '●' : ' ';
    final String lowHole1 = fiveBits[4] == 1 ? '●' : ' ';
    final String punchPattern =
        '$upHole16 $upHole8 : $lowHole4 $lowHole2 $lowHole1';

    return PunchTapeRow(
      letter: upper,
      base10Position: pos10,
      rawBinary: rawBin,
      upperBits: upperBits,
      lower3Bits: lower3Bits,
      groupedBinaryPlain: groupedPlain,
      groupedBinaryLaTeX: groupedLaTeX,
      fiveTrackBits: fiveBits,
      textbookPunchPatternPlain: punchPattern,
      isWordSeparator: false,
    );
  }

  /// Generates the unabridged step-by-step Base 10 -> Base 2 proof for a single letter (1..26).
  static Map<String, String> buildSingleLetterProof(PunchTapeRow row) {
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

    final List<String> activeCols = [];
    for (int c = 0; c < 5; c++) {
      if (row.fiveTrackBits[c] == 1) {
        activeCols.add("${placeWeights[c]}");
      }
    }

    final String latexLine =
        "\\bullet \\; \\mathbf{\\text{${row.letter}} = ${n}_{\\text{ten}}}: \\quad ${divStepsLaTeX.join(', \\; ')} \\; (\\uparrow) \\implies \\mathbf{${row.groupedBinaryLaTeX}_{\\text{two}}} \\quad \\left(\\text{Punch hole(s) at } ${activeCols.join(' + ')} = $n\\right)";

    final String plainLine =
        "• ${row.letter} = ${n}₁₀:  ${divStepsPlain.join('  ➔  ')} (Read remainders upwards ↑ = ${row.groupedBinaryPlain}₂).\n"
        "  – Punch card/tape holes (●) at place-value column(s): ${activeCols.join(' + ')} = ${n}₁₀.";

    return {
      'latex': latexLine,
      'plain': plainLine,
    };
  }

  /// Builds the Horizontal Word-by-Word Letter-to-Base-10 Mapping Grid.
  static String buildHorizontalWordGridLaTeX(List<PunchTapeRow> wordRows) {
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

  /// Builds the exact Side-by-Side LaTeX Table showing BOTH:
  /// - Left: `Table 1.7(a)/(c) Coded form` (Binary digits with vertical dashed separator `:`)
  /// - Right: `Table 1.7(b)/(d) Punch card / tape` (Solid black holes `\bullet` in place of `1`s and blank spaces in place of `0`s!)
  static String buildSideBySideCodedAndPunchTapeLaTeX(
      List<PunchTapeRow> rows, {
        required int punchTapeStyle,
      }) {
    final StringBuffer buf = StringBuffer();
    buf.write("\\begin{array}{|c|c|r:r||c|c:c|c|c|} \\hline ");
    buf.write(
        "\\textbf{Letter} & \\textbf{Base 10} & \\mathbf{16,8} & \\mathbf{4,2,1} & "
            "\\mathbf{16} & \\mathbf{8} & \\mathbf{4} & \\mathbf{2} & \\mathbf{1} \\\\ \\hline ");

    for (final PunchTapeRow r in rows) {
      if (r.isWordSeparator) {
        buf.write(
            "\\text{(Space)} & - & - & - & - & - & - & - & - \\\\ \\hline ");
        continue;
      }

      final String up = r.upperBits.isEmpty ? "" : "\\mathbf{${r.upperBits}}";
      final String low = "\\mathbf{${r.lower3Bits}}";

      final List<String> holeCells = [];
      for (int c = 0; c < 5; c++) {
        if (r.fiveTrackBits[c] == 1) {
          holeCells.add("\\bullet");
        } else {
          holeCells.add(punchTapeStyle == 1 ? "\\circ" : "\\phantom{\\bullet}");
        }
      }

      buf.write(
          "\\mathbf{\\text{${r.letter}}} & ${r.base10Position} & $up & $low & "
              "${holeCells.join(' & ')} \\\\ \\hline ");
    }

    buf.write("\\end{array}");
    return buf.toString();
  }

  /// Parses an English word or sentence (up to 48 letters so Exercise 1.4 #2f fits completely!).
  static List<PunchTapeRow> parseMessageToRows(String rawText) {
    final String cleaned = rawText
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      throw const FormatException(
        "Please enter a word or sentence using English letters A to Z (e.g. LAGOS, I AM A NIGERIAN, or I HATE CORRUPTION).",
      );
    }

    final List<String> words = cleaned.split(' ');
    final List<PunchTapeRow> allRows = [];
    int totalLetters = 0;

    for (int w = 0; w < words.length; w++) {
      final String word = words[w];
      if (word.isEmpty) continue;
      if (w > 0 && allRows.isNotEmpty) {
        allRows.add(PunchTapeRow.wordSeparator());
      }
      for (int i = 0; i < word.length; i++) {
        totalLetters++;
        if (totalLetters > 48) {
          throw const FormatException(
            "Please enter a sentence of up to 48 letters so the coded table and punch tape remain clear.",
          );
        }
        allRows.add(buildLetterRow(word[i]));
      }
    }

    return allRows;
  }

  // ===========================================================================
  // MODES 0 & 1: PUNCH CARD / TAPE GENERATOR & CODED BINARY FORM SOLVER
  // Covers Example 7 (Tables 1.7a–d), Exercise 1.4 #1(a–h), #2(a–f) & #5(a–e)
  // ===========================================================================
  static PunchTapeResult solveEncodeAndPunchTape({
    required int mode, // 0: Punch Card / Tape (Ex 7 & Ex 1.4 #2), 1: Coded Form (Ex 1.4 #1 & #5)
    required String rawTextInput,
    required int punchTapeStyle,
  }) {
    try {
      final List<PunchTapeRow> rows = parseMessageToRows(rawTextInput);
      final List<PunchTapeRow> letterOnlyRows =
      rows.where((r) => !r.isWordSeparator).toList();
      final bool isMultiWord = rows.any((r) => r.isWordSeparator);
      final String cleanPhrase = rows
          .map((r) => r.isWordSeparator ? ' ' : r.letter)
          .join('');

      // Group into words for horizontal letter-to-Base-10 mapping grids
      final List<List<PunchTapeRow>> wordGroups = [];
      List<PunchTapeRow> currGroup = [];
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
      final Set<String> seen = {};
      final List<PunchTapeRow> uniqueLetters = [];
      for (final r in letterOnlyRows) {
        if (!seen.contains(r.letter)) {
          seen.add(r.letter);
          uniqueLetters.add(r);
        }
      }

      final List<String> workings = [];
      final List<PunchTapeStep> steps = [];

      // Step 1: Alphabetical Position in Base 10 (A = 1 to Z = 26)
      workings.add(
          "\\text{\\textbf{Step 1: Number Each Letter in Base 10 (Alphabet Position A = 1 to Z = 26)}}");
      for (final List<PunchTapeRow> wg in wordGroups) {
        workings.add(buildHorizontalWordGridLaTeX(wg));
      }

      final String posSummaryPlain = letterOnlyRows
          .map((r) => "${r.letter} = ${r.base10Position}₁₀")
          .join(', ');

      steps.add(PunchTapeStep(
        title:
        "Step 1: Number Each Letter of '$cleanPhrase' in Base 10 (Table 1.1 Rule)",
        description:
        "First, number each letter of the English alphabet sequentially in base 10 from A = 1₁₀, B = 2₁₀, C = 3₁₀, …, up to Z = 26₁₀:\n"
            "• Letter positions: $posSummaryPlain.",
        mathLaTeX: wordGroups.map(buildHorizontalWordGridLaTeX).join('\n'),
      ));

      // Step 2: Unabridged Base-10 to Base-2 Conversion for Every Unique Letter
      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 2: Convert Each Unique Letter's Base 10 Number to Binary (Base 2)}}");
      final List<String> uniqueProofsPlain = [];
      final List<String> uniqueProofsLaTeX = [];

      for (final PunchTapeRow uRow in uniqueLetters) {
        final Map<String, String> proof = buildSingleLetterProof(uRow);
        workings.add(proof['latex']!);
        uniqueProofsPlain.add(proof['plain']!);
        uniqueProofsLaTeX.add(proof['latex']!);
      }

      steps.add(PunchTapeStep(
        title:
        "Step 2: Convert Each Letter's Base 10 Position to Base 2 (Repeated Division by 2)",
        description:
        "Divide each unique letter's base 10 number repeatedly by 2 and read the remainders upwards (↑), or decompose into the 5 binary place values (16, 8, 4, 2, 1):\n\n"
            "${uniqueProofsPlain.join('\n\n')}",
        mathLaTeX: uniqueProofsLaTeX.join('\n'),
      ));

      // Step 3: Build Both Textbook Tables (Table 1.7a/c Coded Form & Table 1.7b/d Punch Card/Tape)
      final String combinedTableLaTeX = buildSideBySideCodedAndPunchTapeLaTeX(
        rows,
        punchTapeStyle: punchTapeStyle,
      );

      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 3: Write Coded Form (Table 1.7a/c) \\& Punch Card/Tape (Table 1.7b/d)}}");
      workings.add(
          "\\text{Rule (Page 13): Punch a hole } (\\bullet) \\text{ in place of each binary digit } \\mathbf{1}, \\text{ and leave blank for } \\mathbf{0}.");
      workings.add(combinedTableLaTeX);

      final List<String> rowByRowPunchGuide = [];
      for (final PunchTapeRow r in rows) {
        if (r.isWordSeparator) {
          rowByRowPunchGuide
              .add("• -------- [Horizontal dashed line separating words] --------");
          continue;
        }
        final List<String> holeCols = [];
        for (int c = 0; c < 5; c++) {
          if (r.fiveTrackBits[c] == 1) {
            holeCols.add("${placeWeights[c]}");
          }
        }
        rowByRowPunchGuide.add(
          "• ${r.letter} (${r.base10Position}₁₀)  ➔  Coded: ${r.groupedBinaryPlain.padLeft(6)}  ➔  Punch Tape: [ ${r.textbookPunchPatternPlain} ]  (hole at ${holeCols.join(', ')})",
        );
      }

      steps.add(PunchTapeStep(
        title:
        "Step 3: Construct the Coded Form (Table 1.7a/c) & Punch Card / Tape (Table 1.7b/d)",
        description:
        "As shown in Example 7 on Page 14 of the textbook:\n"
            "1. Coded Form (Left): Write each letter vertically with its binary code aligned on the right (a vertical dashed line ':' separates the 16, 8 columns from the 4, 2, 1 columns).\n"
            "2. Punch Card / Tape (Right): Replace every binary digit '1' with a punched hole (●) and leave every binary digit '0' blank (unpunched space)!\n"
            "${isMultiWord ? '3. Multi-Word Sentence: Draw a horizontal dashed line between words to mark word spaces.\n' : ''}\n"
            "${rowByRowPunchGuide.join('\n')}",
        mathLaTeX: combinedTableLaTeX,
      ));

      final int totalHoles = letterOnlyRows.fold(
        0,
            (sum, r) => sum + r.fiveTrackBits.where((b) => b == 1).length,
      );

      final String codeSeqPlain = rows
          .map((r) => r.isWordSeparator ? ';' : r.groupedBinaryPlain)
          .join(', ')
          .replaceAll(', ;, ', '  ;  ');

      return PunchTapeResult(
        mode: mode,
        finalAnswers: {
          isMultiWord ? "Message" : "Word": cleanPhrase,
          "Total Letters":
          "${letterOnlyRows.length} letters${isMultiWord ? ' (${wordGroups.length} words)' : ''}",
          "Total Punched Holes (●)": "$totalHoles holes (for 1s)",
          if (letterOnlyRows.length <= 10) "Coded Binary": codeSeqPlain,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: PunchTapeCanvasData(
          mode: mode,
          punchTapeStyle: punchTapeStyle,
          rows: rows,
          headerBadge:
          "Table 1.7 Coded Form & Punch Card/Tape for '$cleanPhrase'",
          subBadge:
          "Left: Table 1.7(a)/(c) Coded Form   |   Right: Table 1.7(b)/(d) Punch Card / Tape (● = 1, Blank = 0)",
          bottomSummaryBanner:
          "$cleanPhrase  —  ${letterOnlyRows.length} Letters, $totalHoles Punched Holes (●)",
        ),
      );
    } catch (e) {
      return PunchTapeResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid English word or sentence (A–Z).",
      );
    }
  }

  // ===========================================================================
  // MODE 2: DECODE CODED BINARY FORM / PUNCH TAPE BACK TO ENGLISH
  // Covers Exercise 1.4 #3a & #3b (Table 1.8 on Page 15)
  // ===========================================================================
  static PunchTapeResult solveDecodeBinaryTable1_8({
    required String rawBinaryCodesInput,
  }) {
    try {
      String s = rawBinaryCodesInput.trim();
      if (s.isEmpty) {
        throw const FormatException(
          "Please enter binary codes separated by commas (use ';' or '/' between words), e.g. 10:011, 10:101, 11, 11, 101, 10:011, 10:011 ; 1:001, 10:011 ; 1:101, 1:001, 1:110, 101.",
        );
      }

      // Normalize word separators (';', '/', '|') into '/'
      s = s.replaceAll(';', ' / ').replaceAll('|', ' / ');

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
        rawTokens.addAll(s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty));
      }

      if (rawTokens.isEmpty) {
        throw const FormatException("No binary codes found to decode.");
      }

      final List<PunchTapeRow> decodedRows = [];
      final List<String> workings = [
        "\\text{\\textbf{Step 1: Convert Each Binary Code in the Table to Base 10 (Powers of 2)}}",
      ];
      final List<String> step1Plain = [];
      final List<String> step1LaTeX = [];
      final StringBuffer rawDecodedBuf = StringBuffer();

      int count = 0;
      for (final String tok in rawTokens) {
        if (tok == '/') {
          if (decodedRows.isNotEmpty && !decodedRows.last.isWordSeparator) {
            decodedRows.add(PunchTapeRow.wordSeparator());
            rawDecodedBuf.write(' ');
          }
          continue;
        }

        // Strip textbook dashed separator ':' and internal spaces
        final String cleanBin = tok
            .replaceAll(':', '')
            .replaceAll(' ', '')
            .replaceAll('₂', '')
            .replaceAll('●', '1')
            .replaceAll('○', '0')
            .replaceAll('_', '0')
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
            "Binary code '$cleanBin₂' equals ${base10Val}₁₀, which is outside the alphabet range 1 to 26 (A = 1₁₀ to Z = 26₁₀)!",
          );
        }

        count++;
        if (count > 48) {
          throw const FormatException(
              "Please enter up to 48 binary letter codes at a time.");
        }

        final String ch = String.fromCharCode(64 + base10Val);
        final PunchTapeRow row = buildLetterRow(ch);
        decodedRows.add(row);
        rawDecodedBuf.write(ch);

        final int len = cleanBin.length;
        final List<String> powTerms = [];
        final List<String> evalTerms = [];
        for (int i = 0; i < len; i++) {
          final int b = cleanBin[i] == '1' ? 1 : 0;
          final int p = len - 1 - i;
          final int pVal = 1 << p;
          powTerms.add("($b \\times 2^$p)");
          evalTerms.add("${b * pVal}");
        }

        final String lineTex =
            "\\bullet \\; ${row.groupedBinaryLaTeX}_{\\text{two}} = ${powTerms.join(' + ')} = ${evalTerms.join(' + ')} = \\mathbf{${base10Val}_{\\text{ten}}} \\longrightarrow \\mathbf{\\text{$ch}}";
        workings.add(lineTex);
        step1LaTeX.add(lineTex);
        step1Plain.add(
          "• ${row.groupedBinaryPlain}₂ = ${evalTerms.join(' + ')} = ${base10Val}₁₀  ➔  Letter '$ch'",
        );
      }

      if (decodedRows.isEmpty) {
        throw const FormatException("Please enter at least one binary code.");
      }

      final String literalDecoded = rawDecodedBuf.toString().trim();
      // Helpful check for Table 1.8(a) where the textbook printed `10:011` (S) three times in `PASSS` for `PASS`!
      final bool isTable1_8aTypo = literalDecoded.contains('PASSS');
      final String intendedMessage =
      isTable1_8aTypo ? literalDecoded.replaceAll('PASSS', 'PASS') : literalDecoded;

      final String typoExplanation = isTable1_8aTypo
          ? "\n• Helpful Textbook Note (Page 15, Table 1.8a): In the 3rd word of Table 1.8(a), the textbook printed '10 : 011' (S = 19₁₀) three times in a row, which literally spells 'PASSS'. The intended English statement is 'I WILL PASS MY SSCE EXAM'!"
          : "";

      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 2: Combine Letters Across Word Dividers to Read the Statement}}");
      workings.add(
          "\\text{Decoded Statement} = \\mathbf{\\text{$intendedMessage}}"
              "${isTable1_8aTypo ? ' \\quad (\\text{Literal rows: } \\text{$literalDecoded})' : ''}");

      final List<PunchTapeStep> steps = [
        PunchTapeStep(
          title:
          "Step 1: Convert Each Binary Row in the Coded Form to Base 10 (Table 1.8 Method)",
          description:
          "Expand each binary number in powers of 2 (16, 8, 4, 2, 1) to find its base 10 position (1 to 26), then match it to its alphabet letter (A to Z):\n\n"
              "${step1Plain.join('\n')}",
          mathLaTeX: step1LaTeX.join('\n'),
        ),
        PunchTapeStep(
          title:
          "Step 2: Group Letters by Horizontal Dashed Lines to Form Words",
          description:
          "Each horizontal dashed line in the coded table marks the end of a word. Reading the decoded words in order gives:\n"
              "• Decoded Statement = '$intendedMessage'!$typoExplanation",
          mathLaTeX:
          "\\text{Statement} = \\boxed{\\mathbf{\\text{$intendedMessage}}}",
        ),
      ];

      final List<PunchTapeRow> letterOnly =
      decodedRows.where((r) => !r.isWordSeparator).toList();

      return PunchTapeResult(
        mode: 2,
        finalAnswers: {
          "Decoded Statement": intendedMessage,
          if (isTable1_8aTypo) "Literal Table 1.8a Rows": literalDecoded,
          "Total Letters Decoded": "${letterOnly.length} letters",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: PunchTapeCanvasData(
          mode: 2,
          punchTapeStyle: 0,
          rows: decodedRows,
          headerBadge: "Decoded Statement:  '$intendedMessage'",
          subBadge:
          "Left: Table 1.8 Coded Binary Form   |   Right: Corresponding 5-Track Punch Card / Tape",
          bottomSummaryBanner: "Decoded English Statement = $intendedMessage",
        ),
      );
    } catch (e) {
      return PunchTapeResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary codes between 1₂ (1) and 11010₂ (26).",
      );
    }
  }

  // ===========================================================================
  // MODE 3: TRANSLATE BASE-10 NUMBER-CODED MESSAGES INTO WORDS
  // Covers Exercise 1.4 #4a & #4b on Page 15!
  // ===========================================================================
  static PunchTapeResult solveTranslateBase10NumbersToWords({
    required String rawNumbersInput,
  }) {
    try {
      String s = rawNumbersInput.trim();
      if (s.isEmpty) {
        throw const FormatException(
          "Please enter Base 10 numbers (1 to 26) separated by commas, using semicolons ';' between words (e.g. 9, 12, 9, 11, 5; 13, 1, 20, 8, 5, 13, 1, 20, 9, 3, 19).",
        );
      }

      // Normalize word separators (';' or '/')
      s = s.replaceAll('/', ';');
      final List<String> wordChunks = s
          .split(';')
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty)
          .toList();

      if (wordChunks.isEmpty) {
        throw const FormatException("Please enter Base 10 numbers between 1 and 26.");
      }

      final List<PunchTapeRow> rows = [];
      final List<List<PunchTapeRow>> wordGroups = [];
      final List<String> decodedWordsLiteral = [];
      int totalLetters = 0;

      for (int w = 0; w < wordChunks.length; w++) {
        final List<String> numTokens = wordChunks[w]
            .split(RegExp(r'[,\s]+'))
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();

        if (numTokens.isEmpty) continue;
        if (rows.isNotEmpty) {
          rows.add(PunchTapeRow.wordSeparator());
        }

        final List<PunchTapeRow> wg = [];
        final StringBuffer wordBuf = StringBuffer();

        for (final String tok in numTokens) {
          final int? n = int.tryParse(tok);
          if (n == null || n < 1 || n > 26) {
            throw FormatException(
              "Invalid number '$tok'. Every number in a coded message must be a whole number from 1 (A) to 26 (Z).",
            );
          }
          totalLetters++;
          if (totalLetters > 48) {
            throw const FormatException("Please enter up to 48 numbers at a time.");
          }
          final String ch = String.fromCharCode(64 + n);
          final PunchTapeRow r = buildLetterRow(ch);
          rows.add(r);
          wg.add(r);
          wordBuf.write(ch);
        }

        wordGroups.add(wg);
        decodedWordsLiteral.add(wordBuf.toString());
      }

      final String literalSentence = decodedWordsLiteral.join(' ');

      // Check for the two famous textbook misprints in Exercise 1.4 #4a and #4b on Page 15!
      String intendedSentence = literalSentence;
      String textbookTypoNote = "";

      if (literalSentence == 'I LIKE MATHEM A T ICS') {
        intendedSentence = 'I LIKE MATHEMATICS';
        textbookTypoNote =
        "\n• Helpful Textbook Note (Exercise 1.4 #4a): Notice that the textbook printed semicolons (;) instead of commas (,) around 1 (A) and 20 (T) inside '13, 1, 20, 8, 5, 13; 1; 20; 9, 3, 19', which splits 'MATHEMATICS' into 'MATHEM A T ICS'. Joining those letters gives 'I LIKE MATHEMATICS'!";
      } else if (literalSentence == 'I AM A GOOD NIGRIAN') {
        intendedSentence = 'I AM A GOOD NIGERIAN';
        textbookTypoNote =
        "\n• Helpful Textbook Note (Exercise 1.4 #4b): Notice that in the last word ('14, 9, 7, 18, 9, 1, 14' = N-I-G-R-I-A-N), the textbook accidentally omitted '5' (E) between 7 (G) and 18 (R). Including 5 (E) gives the intended sentence: 'I AM A GOOD NIGERIAN'!";
      }

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Match Each Base 10 Number (1 to 26) to Its Alphabet Letter (A to Z)}}",
      ];
      final List<String> wordBreakdownsPlain = [];
      final List<String> wordBreakdownsLaTeX = [];

      for (int w = 0; w < wordGroups.length; w++) {
        final List<PunchTapeRow> wg = wordGroups[w];
        final String gridTex = buildHorizontalWordGridLaTeX(wg);
        workings.add(gridTex);
        wordBreakdownsLaTeX.add(gridTex);

        final String mappingStr = wg
            .map((r) => "${r.base10Position} → ${r.letter}")
            .join(',  ');
        wordBreakdownsPlain.add(
          "• Word ${w + 1}: [$mappingStr]  ➔  '${decodedWordsLiteral[w]}'",
        );
      }

      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 2: Combine the Decoded Words into the Complete Sentence}}");
      workings.add(
          "\\text{Translated Message} = \\mathbf{\\text{$intendedSentence}}"
              "${intendedSentence != literalSentence ? ' \\quad (\\text{Literal: } \\text{$literalSentence})' : ''}");
      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 3: Binary Coded Form \\& Punch Tape Representation}}");
      workings.add(buildSideBySideCodedAndPunchTapeLaTeX(
        rows,
        punchTapeStyle: 0,
      ));

      final List<PunchTapeStep> steps = [
        PunchTapeStep(
          title:
          "Step 1: Replace Each Base 10 Number (1–26) with Its Letter in Table 1.1 (A–Z)",
          description:
          "In Exercise 1.4 #4, commas (,) separate letters within the same word, and semicolons (;) separate words in a sentence. Using A = 1, B = 2, …, Z = 26:\n\n"
              "${wordBreakdownsPlain.join('\n')}",
          mathLaTeX: wordBreakdownsLaTeX.join('\n'),
        ),
        PunchTapeStep(
          title:
          "Step 2: Read the Translated English Message",
          description:
          "Putting the decoded words together in order gives:\n"
              "• Translated Message = '$intendedSentence'!$textbookTypoNote",
          mathLaTeX:
          "\\text{Translated Message} = \\boxed{\\mathbf{\\text{$intendedSentence}}}",
        ),
        PunchTapeStep(
          title:
          "Step 3: Corresponding Binary Coded Form & Computer Punch Tape",
          description:
          "For completeness, here is the binary coded form and 5-track punch card/tape for '$intendedSentence':",
          mathLaTeX: buildSideBySideCodedAndPunchTapeLaTeX(
            rows,
            punchTapeStyle: 0,
          ),
        ),
      ];

      return PunchTapeResult(
        mode: 3,
        finalAnswers: {
          "Translated Message": intendedSentence,
          if (intendedSentence != literalSentence)
            "Literal Numbers": literalSentence,
          "Total Letters": "$totalLetters letters",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: PunchTapeCanvasData(
          mode: 3,
          punchTapeStyle: 0,
          rows: rows,
          headerBadge: "Translated Message:  '$intendedSentence'",
          subBadge:
          "Left: Table 1.7 Coded Form   |   Right: Table 1.7 Punch Card / Tape",
          bottomSummaryBanner: "Translated Message = $intendedSentence",
        ),
      );
    } catch (e) {
      return PunchTapeResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter valid Base 10 numbers from 1 to 26 separated by commas and semicolons.",
      );
    }
  }
}