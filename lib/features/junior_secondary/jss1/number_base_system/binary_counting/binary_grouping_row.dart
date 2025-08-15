class BinaryGroupingRow {
  final String groupName;
  final String powerRep; // e.g., "2⁴"
  final String digit;
  final String? powerRepLaTeX; // e.g., "2^{4}"

  BinaryGroupingRow({
    required this.groupName,
    required this.powerRep,
    required this.digit,
    this.powerRepLaTeX,
  });
}