import 'package:flutter/material.dart';
import 'binary_to_decimal_logic.dart';
import 'decimal_to_binary_logic.dart';

class BinaryConversionScreen extends StatefulWidget {
  const BinaryConversionScreen({super.key});

  @override
  State<BinaryConversionScreen> createState() => _BinaryConversionScreenState();
}

class _BinaryConversionScreenState extends State<BinaryConversionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Base 2 to 10
  final _binaryInputController = TextEditingController();
  List<BinaryToDecimalResult> _binaryResults = [];

  // Base 10 to 2
  final _decimalInputController = TextEditingController();
  List<DecimalToBinaryResult> _decimalResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --------- BASE 2 TO BASE 10 ---------
  void _convertBinaryToDecimal() {
    setState(() {
      _binaryResults = BinaryToDecimalLogic.parseBinaryInputs(_binaryInputController.text)
          .map(BinaryToDecimalLogic.convert)
          .toList();
    });
  }

  Widget _binaryToDecimalTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter binary numbers (e.g. 1101 1010 111):",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _binaryInputController,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: const InputDecoration(
                  hintText: "e.g. 1101 1010 111",
                  hintStyle: TextStyle(fontFamily: 'Poppins'),
                ),
                onSubmitted: (_) => _convertBinaryToDecimal(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _convertBinaryToDecimal,
                  child: const Text("Convert", style: TextStyle(fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final result in _binaryResults)
            _binaryToDecimalResultCard(result, theme),
        ],
      ),
    );
  }

  Widget _binaryToDecimalResultCard(BinaryToDecimalResult result, ThemeData theme) {
    if (!result.valid) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            result.error ?? 'Invalid input.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }

    // Expanded notation split for new line before '='
    final notationParts = result.expandedNotation.split('=');
    final notationMain = notationParts.length > 1 ? notationParts.sublist(0, notationParts.length - 1).join('=') : result.expandedNotation;
    final finalAnswer = notationParts.length > 1 ? '=${notationParts.last.trim()}' : '';

    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Binary: ${result.binaryInput}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Expanded Notation:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notationMain.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Poppins',
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                  if (finalAnswer.isNotEmpty)
                    Text(
                      finalAnswer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        color: Colors.deepPurple.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Step-by-step Solution:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            _stepsList(result.steps),
          ],
        ),
      ),
    );
  }

  // --------- BASE 10 TO BASE 2 ---------
  void _convertDecimalToBinary() {
    setState(() {
      final inputs = DecimalToBinaryLogic.parseDecimalInputs(_decimalInputController.text);
      _decimalResults = inputs
          .map((n) => DecimalToBinaryLogic.convert(n, fractionBits: 12))
          .toList();
    });
  }

  Widget _decimalToBinaryTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter base ten numbers (whole, decimal, or fraction, e.g. 13 0.375 3/8):",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _decimalInputController,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: const InputDecoration(
                  hintText: "e.g. 13 0.375 3/8",
                  hintStyle: TextStyle(fontFamily: 'Poppins'),
                ),
                onSubmitted: (_) => _convertDecimalToBinary(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _convertDecimalToBinary,
                  child: const Text("Convert", style: TextStyle(fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final result in _decimalResults)
            _decimalToBinaryResultCard(result, theme),
        ],
      ),
    );
  }

  Widget _decimalToBinaryResultCard(DecimalToBinaryResult result, ThemeData theme) {
    if (!result.valid) {
      return Card(
        color: Colors.red.shade50,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            result.error ?? 'Invalid input.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }

    // Expanded notation split for new line before '='
    final notationParts = result.expandedNotation.split('\n=');
    final notationMain = notationParts.first;
    final finalAnswer = notationParts.length > 1 ? notationParts[1] : '';

    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Base 10: ${result.originalInput}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            if (result.integerSteps.isNotEmpty)
              Text(
                "Integer Part Conversion Table:",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            if (result.integerSteps.isNotEmpty)
              _intTable(result.integerSteps, theme),
            const SizedBox(height: 8),
            if (result.fractionSteps.isNotEmpty)
              Text(
                "Fractional Part Conversion Table:",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            if (result.fractionSteps.isNotEmpty)
              _fracTable(result.fractionSteps, theme),
            const SizedBox(height: 8),
            Text(
              "Expanded Notation:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notationMain.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Poppins',
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                  if (finalAnswer.isNotEmpty)
                    Text(
                      finalAnswer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        color: Colors.deepPurple.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Step-by-step Solution:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            _stepsList(result.stepByStep),
          ],
        ),
      ),
    );
  }

  Widget _intTable(List<BinaryDivisionStep> steps, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Step')),
          DataColumn(label: Text('Value')),
          DataColumn(label: Text('Operation')),
          DataColumn(label: Text('Quotient')),
          DataColumn(label: Text('Remainder')),
        ],
        rows: [
          for (final s in steps)
            DataRow(
              cells: [
                DataCell(Text('${s.step}', style: const TextStyle(fontFamily: 'Poppins'))),
                DataCell(Text(s.value, style: const TextStyle(fontFamily: 'Poppins'))),
                DataCell(Text(s.operation, style: const TextStyle(fontFamily: 'Poppins'))),
                DataCell(Text(s.quotientOrIntPart, style: const TextStyle(fontFamily: 'Poppins'))),
                DataCell(Text(s.remainderOrFraction, style: const TextStyle(fontFamily: 'Poppins'))),
              ],
            ),
        ],
        headingRowColor: MaterialStateProperty.all(Colors.purple.shade50),
        dataRowColor: MaterialStateProperty.all(Colors.grey.shade50),
      ),
    );
  }

  Widget _fracTable(List<BinaryDivisionStep> steps, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Step')),
          DataColumn(label: Text('Value')),
          DataColumn(label: Text('Operation')),
          DataColumn(label: Text('Int Part')),
          DataColumn(label: Text('Frac Remainder')),
        ],
        rows: [
          for (final s in steps)
            DataRow(
              cells: [
                DataCell(Text('${s.step}', style: const TextStyle(fontFamily: 'Poppins'))),
                DataCell(Text(s.value, style: const TextStyle(fontFamily: 'Poppins'))),
                DataCell(Text(s.operation, style: const TextStyle(fontFamily: 'Poppins'))),
                DataCell(Text(s.quotientOrIntPart, style: const TextStyle(fontFamily: 'Poppins'))),
                DataCell(Text(s.remainderOrFraction, style: const TextStyle(fontFamily: 'Poppins'))),
              ],
            ),
        ],
        headingRowColor: MaterialStateProperty.all(Colors.purple.shade50),
        dataRowColor: MaterialStateProperty.all(Colors.grey.shade50),
      ),
    );
  }

  Widget _stepsList(List<String> steps) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, idx) => Card(
        color: Colors.deepPurple.shade50,
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: Text('${idx + 1}',
                style: const TextStyle(
                    color: Colors.deepPurple, fontFamily: 'Poppins')),
          ),
          title: Text(
            steps[idx],
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontFamily: 'Poppins'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _binaryInputController.dispose();
    _decimalInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Conversion'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text("Base 2 → Base 10", style: TextStyle(fontFamily: 'Poppins')),
            ),
            Tab(
              child: Text("Base 10 → Base 2", style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _binaryToDecimalTab(context),
          _decimalToBinaryTab(context),
        ],
      ),
    );
  }
}