class HinduSymbol {
  final int digit;
  final String label;
  final String assetPath;
  const HinduSymbol({
    required this.digit,
    required this.label,
    required this.assetPath,
  });
}

/// Early Hindu symbols for digits 0-9, descending order for legend/UI consistency.
const List<HinduSymbol> hinduSymbols = [
  HinduSymbol(digit: 0, label: "Dot", assetPath: "assets/images/zero.png"),
  HinduSymbol(digit: 1, label: "Dash", assetPath: "assets/images/one.png"),
  HinduSymbol(digit: 2, label: "Double Dash", assetPath: "assets/images/two.png"),
  HinduSymbol(digit: 3, label: "Triple Dash", assetPath: "assets/images/three.png"),
  HinduSymbol(digit: 4, label: "Minus or Plus", assetPath: "assets/images/four.png"),
  HinduSymbol(digit: 5, label: "Five", assetPath: "assets/images/five.png"),
  HinduSymbol(digit: 6, label: "Six", assetPath: "assets/images/six.png"),
  HinduSymbol(digit: 7, label: "Seven", assetPath: "assets/images/seven.png"),
  HinduSymbol(digit: 8, label: "Eight", assetPath: "assets/images/eight.png"),
  HinduSymbol(digit: 9, label: "Question Mark", assetPath: "assets/images/nine.png"),
];

/// Helper maps for quick lookups
final Map<int, HinduSymbol> digitToSymbol = {
  for (final s in hinduSymbols) s.digit: s,
};

final Map<String, int> assetPathToDigit = {
  for (final s in hinduSymbols) s.assetPath: s.digit,
};