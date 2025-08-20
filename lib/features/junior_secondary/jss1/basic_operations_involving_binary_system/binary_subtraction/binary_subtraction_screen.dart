import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'binary_subtraction_logic.dart';
import 'binary_subtraction_models.dart';

class BinarySubtractionScreen extends StatefulWidget {
  const BinarySubtractionScreen({super.key});

  @override
  State<BinarySubtractionScreen> createState() => _BinarySubtractionScreenState();
}

class _BinarySubtractionScreenState extends State<BinarySubtractionScreen> {
  final TextEditingController _minuendController = TextEditingController();
  final TextEditingController _subtrahendController = TextEditingController();
  BinarySubtractionResult? _result;

  void _performSubtraction() {
    setState(() {
      _result = BinarySubtractionLogic.subtractBinaryNumbers(
        _minuendController.text,
        _subtrahendController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Subtraction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter binary numbers to subtract:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),

            // Input fields
            TextField(
              controller: _minuendController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: const InputDecoration(
                labelText: "Minuend (First Number)",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                hintText: "e.g. 1101",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
              ),
              onSubmitted: (_) => _performSubtraction(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subtrahendController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: const InputDecoration(
                labelText: "Subtrahend (Second Number)",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                hintText: "e.g. 1010",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
              ),
              onSubmitted: (_) => _performSubtraction(),
            ),
            const SizedBox(height: 16),

            // Subtract button
            Center(
              child: ElevatedButton(
                onPressed: _performSubtraction,
                child: const Text("Subtract", style: TextStyle(fontFamily: 'Poppins')),
              ),
            ),

            const SizedBox(height: 20),

            // Centralized main result display
            if (_result != null && _result!.valid)
              Center(
                child: Column(
                      children: [
                        Text(
                          "Result",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            "${_result!.minuend}_2 - ${_result!.subtrahend}_2 = ${_result!.binaryDifference}_2",
                            textStyle: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            "= ${_result!.decimalDifference}_{10}",
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: 'Poppins',
                              color: Colors.deepPurple.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
              ),

            const SizedBox(height: 18),

            // Result card
            if (_result != null)
              _buildResultCard(_result!, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BinarySubtractionResult result, ThemeData theme) {
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

    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Binary Numbers: ${result.minuend} - ${result.subtrahend}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),

            // Legend for binary subtraction rules
            _buildLegendCard(theme),
            const SizedBox(height: 20),

            // Working display as table
            Text(
              "Working:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            _buildWorkingTable(result, theme),

            const SizedBox(height: 20),

            // Step-by-step explanation
            Text(
              "Step-by-step Solution:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            _buildStepsList(result.stepByStepLaTeX ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendCard(ThemeData theme) {
    return Card(
      color: Colors.purple.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rules For Subtracting Binary Numbers",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Math.tex("0 - 0 = 0"),
                const SizedBox(height: 8),
                Math.tex("1 - 0 = 1"),
                const SizedBox(height: 8),
                Math.tex("1 - 1 = 0"),
                const SizedBox(height: 8),
                Math.tex("0 - 1 = 1 \\text{ (with borrow)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingTable(BinarySubtractionResult result, ThemeData theme) {
    // Find max length for padding
    int maxLength = [result.minuend.length, result.subtrahend.length, result.binaryDifference.length]
        .reduce((a, b) => a > b ? a : b);

    String paddedMinuend = result.minuend.padLeft(maxLength, ' ');
    String paddedSubtrahend = result.subtrahend.padLeft(maxLength, ' ');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        horizontalMargin: 8,
        headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
        dataRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columns: [
          const DataColumn(label: SizedBox(width: 30, child: Text(""))), // Operator column
          ...List.generate(
            maxLength,
                (index) => DataColumn(
              label: SizedBox(
                width: 40,
                child: Text(
                  "Bit ${maxLength - index - 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const DataColumn(
            label: SizedBox(
              width: 80,
              child: Text(
                "Notation",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        rows: [
          // Minuend row
          DataRow(
            color: WidgetStateProperty.all(Colors.grey.shade50),
            cells: [
              DataCell(
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Math.tex(
                      "",
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              // Minuend digits
              ...paddedMinuend.split('').map(
                    (digit) => DataCell(
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Math.tex(
                        digit == ' ' ? "0" : digit,
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
              // Minuend notation
              DataCell(
                SizedBox(
                  width: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      "(${result.minuend})_2",
                      textStyle: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Subtrahend row
          DataRow(
            color: WidgetStateProperty.all(Colors.grey.shade50),
            cells: [
              DataCell(
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Math.tex(
                      "-",
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              // Subtrahend digits
              ...paddedSubtrahend.split('').map(
                    (digit) => DataCell(
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Math.tex(
                        digit == ' ' ? "0" : digit,
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
              // Subtrahend notation
              DataCell(
                SizedBox(
                  width: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      "(${result.subtrahend})_2",
                      textStyle: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Result row with different color
          DataRow(
            color: WidgetStateProperty.all(Colors.deepPurple.shade100),
            cells: [
              // Equals sign
              DataCell(
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Math.tex(
                      "=",
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              // Result digits
              ...result.binaryDifference.padLeft(maxLength, '0').split('').map(
                    (digit) => DataCell(
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Math.tex(
                        digit,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Result notation
              DataCell(
                SizedBox(
                  width: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      "= (${result.binaryDifference})_2",
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(List<String> steps) {
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
            child: Text(
                '${idx + 1}',
                style: const TextStyle(
                    color: Colors.deepPurple,
                    fontFamily: 'Poppins'
                )
            ),
          ),
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              steps[idx],
              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _minuendController.dispose();
    _subtrahendController.dispose();
    super.dispose();
  }
}