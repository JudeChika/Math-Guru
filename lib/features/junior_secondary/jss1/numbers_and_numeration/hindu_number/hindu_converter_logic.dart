import 'hindu_symbols.dart';
import 'hindu_conversion_step.dart';

class HinduConverter {
  /// Converts an English number string to a list of symbol asset paths (Early Hindu), with steps.
  static (List<String>, List<HinduConversionStep>, bool) englishToHindu(String input) {
    final steps = <HinduConversionStep>[];
    final List<String> symbolAssets = [];
    final List<String> symbolLabels = [];
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      steps.add(HinduConversionStep(
        description: "Please enter a non-empty number.",
        resultSoFar: "",
      ));
      return ([], steps, false);
    }
    for (int i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (!RegExp(r'^\d$').hasMatch(char)) {
        steps.add(HinduConversionStep(
          description: "Invalid character '$char' found. Only digits 0-9 are allowed.",
          resultSoFar: symbolLabels.join(', '),
        ));
        return ([], steps, false);
      }
      final digit = int.parse(char);
      final symbol = digitToSymbol[digit]!;
      symbolAssets.add(symbol.assetPath);
      symbolLabels.add(symbol.label);
      steps.add(HinduConversionStep(
        description: "Digit '$char' maps to symbol '${symbol.label}'.",
        resultSoFar: symbolLabels.join(', '),
      ));
    }
    steps.add(HinduConversionStep(
      description: "Final Early Hindu numeral assembled from the symbols.",
      resultSoFar: symbolLabels.join(', '),
    ));
    return (symbolAssets, steps, true);
  }

  /// Converts a list of symbol asset paths (Early Hindu) to English number string with steps.
  static (String, List<HinduConversionStep>, bool) hinduToEnglish(List<String> selectedAssets) {
    final steps = <HinduConversionStep>[];
    final buffer = StringBuffer();
    final List<String> symbolLabels = [];

    if (selectedAssets.isEmpty) {
      steps.add(HinduConversionStep(
        description: "Please select at least one symbol.",
        resultSoFar: "",
      ));
      return ("", steps, false);
    }
    for (final asset in selectedAssets) {
      if (!assetPathToDigit.containsKey(asset)) {
        steps.add(HinduConversionStep(
          description: "Invalid symbol selected.",
          resultSoFar: buffer.toString(),
        ));
        return ("", steps, false);
      }
      final digit = assetPathToDigit[asset]!;
      buffer.write(digit.toString());
      symbolLabels.add(digitToSymbol[digit]!.label);
      steps.add(HinduConversionStep(
        description: "Symbol '${digitToSymbol[digit]!.label}' maps to digit '$digit'.",
        resultSoFar: symbolLabels.join(', '),
      ));
    }
    steps.add(HinduConversionStep(
      description: "Final English number: ${buffer.toString()}",
      resultSoFar: symbolLabels.join(', '),
    ));
    return (buffer.toString(), steps, true);
  }
}