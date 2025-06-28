import 'package:flutter/material.dart';
import 'lcm_logic.dart';
import 'lcm_table_row.dart';
import 'lcm_step_explanation.dart';

class LCMScreen extends StatefulWidget {
  const LCMScreen({super.key});

  @override
  State<LCMScreen> createState() => _LCMScreenState();
}

class _LCMScreenState extends State<LCMScreen> {
  final _inputController = TextEditingController();

  LCMCalculatorResult? _result;

  void _calculate() {
    setState(() {
      _result = LCMCalculatorLogic.calculateLCM(_inputController.text);
    });
  }

  Widget _lcmTable(List<LCMTableRow> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text("Divisor")),
          for (int i = 0; i < rows[0].numbers.length; i++)
            DataColumn(label: Text("N${i + 1}")),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              cells: [
                DataCell(Text(row.divisor == 1 ? "" : row.divisor.toString())),
                ...row.numbers
                    .map((n) => DataCell(Text(n.toString())))
                    ,
              ],
            ),
        ],
        headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
        dataRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columnSpacing: 18,
      ),
    );
  }

  Widget _stepsList(List<LCMStepExplanation> steps, bool valid) {
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
                style: const TextStyle(color: Colors.deepPurple)),
          ),
          title: Text(steps[idx].description,
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LCM Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter numbers separated by commas or spaces (e.g. 12, 15, 18 or 6 8 14):",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "e.g. 12, 15, 18",
                      ),
                      onSubmitted: (_) => _calculate(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _calculate,
                    child: const Text("Calculate LCM"),
                  )
                ],
              ),
              const SizedBox(height: 18),
              if (_result != null && _result!.valid)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Division Table:", style: theme.textTheme.bodyMedium),
                    _lcmTable(_result!.tableRows),
                    const SizedBox(height: 14),
                    Text("LCM Result:",
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      "${_result!.lcm}",
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              Text("Step-by-step solution:", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              if (_result != null)
                _stepsList(_result!.steps, _result!.valid),
            ],
          ),
        ),
      ),
    );
  }
}