import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'binary_addition_logic.dart';
import 'binary_addition_models.dart';

class BinaryAdditionScreen extends StatefulWidget {
  const BinaryAdditionScreen({super.key});

  @override
  State<BinaryAdditionScreen> createState() => _BinaryAdditionScreenState();
}

class _BinaryAdditionScreenState extends State<BinaryAdditionScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  BinaryAdditionResult? _result;

  void _addInputField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeInputField(int index) {
    if (_controllers.length > 2) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  void _performAddition() {
    List<String> inputs = _controllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    setState(() {
      _result = BinaryAdditionLogic.addBinaryNumbers(inputs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Addition'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter binary numbers to add:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),

            // Dynamic input fields
            Column(
              children: [
                for (int i = 0; i < _controllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controllers[i],
                            style: const TextStyle(fontFamily: 'Poppins'),
                            decoration: InputDecoration(
                              labelText: "Binary Number ${i + 1}",
                              labelStyle: const TextStyle(fontFamily: 'Poppins'),
                              hintText: "e.g. 1011",
                              hintStyle: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            onSubmitted: (_) => _performAddition(),
                          ),
                        ),
                        if (_controllers.length > 2)
                          IconButton(
                            onPressed: () => _removeInputField(i),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                          ),
                      ],
                    ),
                  ),

                // Add more fields button
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _addInputField,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                          "Add More Numbers",
                          style: TextStyle(fontFamily: 'Poppins')
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _performAddition,
                      child: const Text("Add", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ],
                ),
              ],
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
                            "${_result!.binaryInputs.join(' + ')}_2 = ${_result!.binarySum}_2",
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
                            "= ${_result!.decimalSum}_{10}",
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

  Widget _buildResultCard(BinaryAdditionResult result, ThemeData theme) {
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
              "Binary Numbers: ${result.binaryInputs.join(', ')}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),

            // Legend for binary addition rules
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
            _buildStepsList(result.stepByStepLaTeX ?? []), // Use LaTeX instead of plain text
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
              "Rules For Adding Binary Numbers",
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
                Math.tex("0 + 0 = 0"),
                const SizedBox(height: 8),
                Math.tex("0 + 1 = 1"),
                const SizedBox(height: 8),
                Math.tex("1 + 0 = 1"),
                const SizedBox(height: 8),
                Math.tex("1 + 1 = 10_2"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingTable(BinaryAdditionResult result, ThemeData theme) {
    // Find max length for padding
    int maxLength = result.binarySum.length;
    List<String> paddedInputs = result.binaryInputs
        .map((input) => input.padLeft(maxLength, ' '))
        .toList();

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
          ), // Notation column
        ],
        rows: [
          // Input rows
          for (int i = 0; i < paddedInputs.length; i++)
            DataRow(
              color: WidgetStateProperty.all(Colors.grey.shade50),
              cells: [
                // Operator column
                DataCell(
                  SizedBox(
                    width: 30,
                    child: Center(
                      child: Math.tex(
                        i == 0 ? "" : "+",
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                // Binary digits
                ...paddedInputs[i].split('').map(
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
                // Notation column
                DataCell(
                  SizedBox(
                    width: 80,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        "(${result.binaryInputs[i]})_2",
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
              ...result.binarySum.split('').map(
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
                      "= (${result.binarySum})_2",
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}