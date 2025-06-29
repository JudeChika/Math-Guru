import 'binary_grouping_row.dart';
import 'binary_expanded_step.dart';

class BinaryCountingResult {
  final String binaryString;
  final List<BinaryGroupingRow> groupingTable;
  final String expandedNotation;
  final List<BinaryExpandedStep> steps;
  final bool valid;
  final String? error;

  BinaryCountingResult({
    required this.binaryString,
    required this.groupingTable,
    required this.expandedNotation,
    required this.steps,
    required this.valid,
    this.error,
  });
}

class BinaryCountingLogic {
  static final _groupNames = [
    "Units",
    "Twos",
    "Fours",
    "Eights",
    "Sixteens",
    "Thirty-Twos",
    "Sixty-Fours",
    "One-Twenty-Eights",
    "Two-Fifty-Six",
    "Five-Twelve",
    "Ten-Twenty-Four",
    // Extend further if needed...
  ];

  static List<String> parseBinaryInputs(String input) {
    final cleaned = input.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return [];
    return cleaned
        .split(' ')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  // Validate binary string: only 0s and 1s
  static bool isValidBinary(String s) => RegExp(r'^[01]+$').hasMatch(s);

  static BinaryCountingResult analyzeBinary(String binaryInputRaw) {
    final binaryInput = binaryInputRaw.trim();
    if (!isValidBinary(binaryInput)) {
      return BinaryCountingResult(
        binaryString: binaryInput,
        groupingTable: [],
        expandedNotation: '',
        steps: [
          BinaryExpandedStep(description: "Invalid input: '$binaryInput' is not a valid binary number. Enter only 0s and 1s."),
        ],
        valid: false,
        error: "Invalid binary input.",
      );
    }
    final digits = binaryInput.split('');
    final len = digits.length;
    final groupingTable = <BinaryGroupingRow>[];

    // Build table from leftmost to rightmost (most significant to least)
    for (int i = 0; i < len; i++) {
      final power = len - 1 - i;
      groupingTable.add(BinaryGroupingRow(
        groupName: (power < _groupNames.length)
            ? _groupNames[power]
            : "2^$power",
        powerRep: "2${_superscript(power)}",
        digit: digits[i],
      ));
    }

    // Expanded notation (mathematical, with only the terms)
    List<String> terms = [];
    for (int i = 0; i < len; i++) {
      final power = len - 1 - i;
      final digit = digits[i];
      terms.add("($digit×2${_superscript(power)})");
    }
    final expandedNotation = "${_formatBinaryBase2(binaryInput)} = ${terms.join(" + ")}";

    // Step-by-step: Each term, only as base two, no base ten shown
    List<BinaryExpandedStep> steps = [];
    for (int i = 0; i < len; i++) {
      final power = len - 1 - i;
      final digit = digits[i];
      steps.add(BinaryExpandedStep(
        description: "Step ${i + 1}: $digit × 2${_superscript(power)}",
      ));
    }

    return BinaryCountingResult(
      binaryString: binaryInput,
      groupingTable: groupingTable,
      expandedNotation: expandedNotation,
      steps: steps,
      valid: true,
    );
  }

  static String _powerSup(int n) {
    // Only works for 0-9
    const sups = [
      "\u2070", "\u00b9", "\u00b2", "\u00b3", "\u2074", "\u2075",
      "\u2076", "\u2077", "\u2078", "\u2079"
    ];
    if (n == 0) return sups[0];
    String s = "";
    for (final ch in n.toString().split('')) {
      s += sups[int.parse(ch)];
    }
    return s;
  }

  static String _superscript(int n) => _powerSup(n);

  /// Formats a string such as "11011" as "11011₂"
  static String _formatBinaryBase2(String binary) {
    return "$binary\u2082";
  }
}