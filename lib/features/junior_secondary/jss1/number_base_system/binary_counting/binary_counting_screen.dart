import 'package:flutter/material.dart';
import 'binary_counting_logic.dart';
import 'binary_grouping_row.dart';
import 'binary_expanded_step.dart';

class BinaryCountingScreen extends StatefulWidget {
  const BinaryCountingScreen({super.key});

  @override
  State<BinaryCountingScreen> createState() => _BinaryCountingScreenState();
}

class _BinaryCountingScreenState extends State<BinaryCountingScreen> {
  final _inputController = TextEditingController();
  List<BinaryCountingResult> _results = [];

  void _analyze() {
    setState(() {
      final binaries = BinaryCountingLogic.parseBinaryInputs(_inputController.text);
      _results = binaries
          .map((b) => BinaryCountingLogic.analyzeBinary(b))
          .toList();
    });
  }

  Widget _groupingTable(List<BinaryGroupingRow> rows, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Grouping')),
          DataColumn(label: Text('Power')),
          DataColumn(label: Text('Digit')),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              cells: [
                DataCell(Text(
                  row.groupName,
                  style: const TextStyle(fontFamily: 'Poppins'),
                )),
                DataCell(Text(
                  row.powerRep,
                  style: const TextStyle(fontFamily: 'Poppins'),
                )),
                DataCell(Text(
                  row.digit,
                  style: const TextStyle(fontFamily: 'Poppins'),
                )),
              ],
            ),
        ],
        headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
        dataRowColor: WidgetStateProperty.all(Colors.grey.shade50),
      ),
    );
  }

  Widget _stepsList(List<BinaryExpandedStep> steps, bool valid) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, idx) => Card(
        color: valid
            ? Theme.of(context).cardColor.withOpacity(0.97)
            : Colors.red.shade50,
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade50,
            child: Text('${idx + 1}',
                style: const TextStyle(color: Colors.deepPurple, fontFamily: 'Poppins')),
          ),
          title: Text(
            steps[idx].description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Poppins'),
          ),
        ),
      ),
    );
  }

  Widget _analysisResult(BinaryCountingResult result, ThemeData theme) {
    if (!result.valid) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            result.error ?? 'Invalid input.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red, fontFamily: 'Poppins'),
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
              "Binary: ${result.binaryString}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            Text("Grouping Table:",
                style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins')),
            _groupingTable(result.groupingTable, theme),
            const SizedBox(height: 20),
            Text("Expanded Notation:",
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                result.expandedNotation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Poppins',
                  color: Colors.deepPurple.shade800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Step-by-step Solution:",
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            _stepsList(result.steps, result.valid),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counting in Binary'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter one or more binary numbers (e.g. 11011 101 1001):",
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      decoration: const InputDecoration(
                        hintText: "e.g. 11011 101 1001",
                        hintStyle: TextStyle(fontFamily: 'Poppins'),
                      ),
                      onSubmitted: (_) => _analyze(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _analyze,
                    child: const Text("Analyze", style: TextStyle(fontFamily: 'Poppins')),
                  )
                ],
              ),
              const SizedBox(height: 18),
              for (final result in _results) _analysisResult(result, theme),
            ],
          ),
        ),
      ),
    );
  }
}