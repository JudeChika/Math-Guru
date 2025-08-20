import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'binary_division_logic.dart';
import 'binary_division_models.dart';

enum DivisionMethod { longDivision, repeatedSubtraction }

class BinaryDivisionScreen extends StatefulWidget {
  const BinaryDivisionScreen({super.key});

  @override
  State<BinaryDivisionScreen> createState() => _BinaryDivisionScreenState();
}

class _BinaryDivisionScreenState extends State<BinaryDivisionScreen> {
  final TextEditingController _dividendController = TextEditingController();
  final TextEditingController _divisorController = TextEditingController();
  BinaryDivisionResult? _result;
  DivisionMethod _selectedMethod = DivisionMethod.longDivision;

  void _performDivision() {
    setState(() {
      String method = _selectedMethod == DivisionMethod.longDivision ? "long_division" : "repeated_subtraction";
      _result = BinaryDivisionLogic.divideBinaryNumbers(
        _dividendController.text,
        _divisorController.text,
        method,
      );
    });
  }

  void _onMethodChanged(DivisionMethod? method) {
    if (method == null) return;
    setState(() {
      _selectedMethod = method;
    });
    if (_result != null) {
      _performDivision();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Division'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter binary numbers for division:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),

            // Input fields
            TextField(
              controller: _dividendController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: const InputDecoration(
                labelText: "Dividend (Number to be divided)",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                hintText: "e.g. 10101",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
              ),
              onSubmitted: (_) => _performDivision(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _divisorController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: const InputDecoration(
                labelText: "Divisor (Number to divide by)",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                hintText: "e.g. 111",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
              ),
              onSubmitted: (_) => _performDivision(),
            ),
            const SizedBox(height: 16),

            // Method selection
            Text(
              "Division Method:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<DivisionMethod>(
                    title: const Text("Long Division", style: TextStyle(fontFamily: 'Poppins')),
                    value: DivisionMethod.longDivision,
                    groupValue: _selectedMethod,
                    onChanged: _onMethodChanged,
                    activeColor: Colors.deepPurple,
                  ),
                ),
                Expanded(
                  child: RadioListTile<DivisionMethod>(
                    title: const Text("Repeated Subtraction", style: TextStyle(fontFamily: 'Poppins')),
                    value: DivisionMethod.repeatedSubtraction,
                    groupValue: _selectedMethod,
                    onChanged: _onMethodChanged,
                    activeColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Divide button
            Center(
              child: ElevatedButton(
                onPressed: _performDivision,
                child: const Text("Divide", style: TextStyle(fontFamily: 'Poppins')),
              ),
            ),

            const SizedBox(height: 20),

            // Centralized main result display
            if (_result != null && _result!.valid)
              Center(
                child: Card(
                  color: Colors.deepPurple.shade50,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                            "${_result!.dividend}_2 \\div ${_result!.divisor}_2 = ${_result!.binaryQuotient}_2",
                            textStyle: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        if (_result!.binaryRemainder != "0")
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Math.tex(
                              "\\text{remainder } ${_result!.binaryRemainder}_2",
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: 'Poppins',
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            "= ${_result!.decimalQuotient}_{10}" +
                                (_result!.decimalRemainder != 0 ? " \\text{ remainder } ${_result!.decimalRemainder}_{10}" : ""),
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: 'Poppins',
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildResultCard(BinaryDivisionResult result, ThemeData theme) {
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
              "Binary Numbers: ${result.dividend} ÷ ${result.divisor}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),

            // Legend for binary division rules (only for long division)
            if (result.method == "long_division")
              _buildLegendCard(theme),
            const SizedBox(height: 12),

            // Working display
            Text(
              "Working:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),

            if (result.method == "long_division")
              _buildLongDivisionTable(result, theme)
            else
              _buildRepeatedSubtractionTable(result, theme),

            const SizedBox(height: 12),

            // Step-by-step explanation
            Text(
              "Step-by-step Solution:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
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
              "Binary Division Rules",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Math.tex("0 \\div 1 = 0"),
                Math.tex("1 \\div 1 = 1"),
                Math.tex("0 \\div 0 = \\text{undefined}"),
                Math.tex("1 \\div 0 = \\text{undefined}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLongDivisionTable(BinaryDivisionResult result, ThemeData theme) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              "Long Division Process",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Division layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quotient
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Math.tex(
                            result.binaryQuotient,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Divider line and divisor | dividend
                  Row(
                    children: [
                      Math.tex(
                        result.divisor,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      const Text(" | ", style: TextStyle(fontSize: 16)),
                      Math.tex(
                        result.dividend,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, color: Colors.black54),
                  const SizedBox(height: 8),
                  // Steps
                  for (int i = 0; i < result.longDivisionSteps.length; i++)
                    if (result.longDivisionSteps[i].quotientBit == "1")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 20),
                                Math.tex(
                                  result.longDivisionSteps[i].dividend,
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("-", style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Math.tex(
                                  result.longDivisionSteps[i].divisor,
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const Divider(thickness: 1, color: Colors.black26),
                            Row(
                              children: [
                                const SizedBox(width: 20),
                                Math.tex(
                                  result.longDivisionSteps[i].remainder,
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                  // Final remainder
                  if (result.binaryRemainder != "0")
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Text("Remainder: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Math.tex(
                            result.binaryRemainder,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatedSubtractionTable(BinaryDivisionResult result, ThemeData theme) {
    List<DataRow> rows = [];

    // Find max length for alignment
    List<String> allNumbers = [
      result.dividend,
      result.divisor,
      ...result.subtractionSteps.map((step) => step.minuend),
      ...result.subtractionSteps.map((step) => step.difference),
    ];
    int maxLength = allNumbers.map((s) => s.length).reduce((a, b) => a > b ? a : b);

    // Initial dividend row
    rows.add(DataRow(
      color: WidgetStateProperty.all(Colors.blue.shade50),
      cells: [
        const DataCell(
          SizedBox(
            width: 30,
            child: Center(child: Text("")),
          ),
        ),
        ...List.generate(maxLength, (index) {
          int dividendIndex = result.dividend.length - 1 - (maxLength - 1 - index);
          String digit = (dividendIndex >= 0 && dividendIndex < result.dividend.length)
              ? result.dividend[dividendIndex]
              : "";

          return DataCell(
            SizedBox(
              width: 40,
              child: Center(
                child: digit.isEmpty ? const SizedBox() : Math.tex(
                  digit,
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        }),
        DataCell(
          SizedBox(
            width: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                "(${result.dividend})_2",
                textStyle: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    ));

    // Subtraction steps
    for (int i = 0; i < result.subtractionSteps.length; i++) {
      BinarySubtractionStep step = result.subtractionSteps[i];

      // Subtrahend row
      rows.add(DataRow(
        color: WidgetStateProperty.all(Colors.orange.shade50),
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
          ...List.generate(maxLength, (index) {
            int subtrahendIndex = step.subtrahend.length - 1 - (maxLength - 1 - index);
            String digit = (subtrahendIndex >= 0 && subtrahendIndex < step.subtrahend.length)
                ? step.subtrahend[subtrahendIndex]
                : "";

            return DataCell(
              SizedBox(
                width: 40,
                child: Center(
                  child: digit.isEmpty ? const SizedBox() : Math.tex(
                    digit,
                    textStyle: const TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ),
              ),
            );
          }),
          DataCell(
            SizedBox(
              width: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  "(${step.subtrahend})_2",
                  textStyle: const TextStyle(fontSize: 10, color: Colors.orange),
                ),
              ),
            ),
          ),
        ],
      ));

      // Difference row
      rows.add(DataRow(
        color: WidgetStateProperty.all(Colors.green.shade50),
        cells: [
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
          ...List.generate(maxLength, (index) {
            int differenceIndex = step.difference.length - 1 - (maxLength - 1 - index);
            String digit = (differenceIndex >= 0 && differenceIndex < step.difference.length)
                ? step.difference[differenceIndex]
                : "";

            return DataCell(
              SizedBox(
                width: 40,
                child: Center(
                  child: digit.isEmpty ? const SizedBox() : Math.tex(
                    digit,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            );
          }),
          DataCell(
            SizedBox(
              width: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  "Step ${step.stepNumber}",
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ));

      // Add separator line except for the last step
      if (i < result.subtractionSteps.length - 1) {
        rows.add(DataRow(
          cells: List.generate(maxLength + 2, (index) => const DataCell(
            SizedBox(
              width: 40,
              child: Divider(thickness: 1),
            ),
          )),
        ));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        horizontalMargin: 8,
        headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
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
              width: 100,
              child: Text(
                "Step",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        rows: rows,
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
    _dividendController.dispose();
    _divisorController.dispose();
    super.dispose();
  }
}