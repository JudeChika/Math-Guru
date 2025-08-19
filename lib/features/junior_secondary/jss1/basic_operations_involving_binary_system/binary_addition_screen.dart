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
                            "${_result!.binaryInputs.join(' + ')}_2 = ${_result!.binarySum}_2",
                            textStyle: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Math.tex(
                          "= ${_result!.decimalSum}_{10}",
                          textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Poppins',
                            color: Colors.deepPurple.shade700,
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

            // Working display as table
            Text(
              "Working:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            _buildWorkingTable(result, theme),

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
            _buildStepsList(result.stepByStepExplanation), // Use plain text instead of LaTeX
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
    String paddedResult = result.binarySum.padLeft(maxLength, ' ');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          columnSpacing: 8,
          horizontalMargin: 12,
          headingRowHeight: 0, // Hide header
          dataRowMinHeight: 32,
          dataRowMaxHeight: 32,
          columns: List.generate(
            maxLength + 2, // +2 for operator and notation columns
                (index) => DataColumn(
              label: Container(width: 0), // Empty headers
            ),
          ),
          rows: [
            // Input rows
            for (int i = 0; i < paddedInputs.length; i++)
              DataRow(
                cells: [
                  // Operator column
                  DataCell(
                    Text(
                      i == 0 ? '' : '+',
                      style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Binary digits
                  ...paddedInputs[i].split('').map(
                        (digit) => DataCell(
                      Text(
                        digit,
                        style: const TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Notation column
                  DataCell(
                    Text(
                      '(${result.binaryInputs[i]}₂)',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

            // Separator row
            DataRow(
              cells: List.generate(
                maxLength + 2,
                    (index) => DataCell(
                  Container(
                    height: 1,
                    color: index == 0 || index == maxLength + 1
                        ? Colors.transparent
                        : Colors.black,
                  ),
                ),
              ),
            ),

            // Result row
            DataRow(
              cells: [
                // Equals sign
                const DataCell(
                  Text(
                    '=',
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Result digits
                ...paddedResult.split('').map(
                      (digit) => DataCell(
                    Text(
                      digit,
                      style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                // Result notation
                DataCell(
                  Text(
                    '= ${result.binarySum}₂',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
          title: Text(
            steps[idx],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'Poppins',
              fontSize: 12,
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