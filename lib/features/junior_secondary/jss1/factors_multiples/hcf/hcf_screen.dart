import 'package:flutter/material.dart';
import 'hcf_logic.dart';
import 'hcf_prime_factorization_row.dart';
import 'hcf_solution_step.dart';

class HCFScreen extends StatefulWidget {
  const HCFScreen({super.key});

  @override
  State<HCFScreen> createState() => _HCFScreenState();
}

class _HCFScreenState extends State<HCFScreen> {
  final _inputController = TextEditingController();
  HCFCalculatorResult? _result;

  void _calculate() {
    setState(() {
      _result = HCFCalculatorLogic.calculateHCF(_inputController.text);
    });
  }

  Widget _factorizationTable(List<HCFPrimeFactorizationRow> rows, List<int> commonFactors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${row.number} = ",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Wrap(
                  children: [
                    for (int i = 0; i < row.factors.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: Text(
                          "${row.factors[i]}${i < row.factors.length - 1 ? " × " : ""}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: commonFactors.contains(row.factors[i])
                                ? Colors.green.shade800
                                : Colors.black87,
                            fontWeight: commonFactors.contains(row.factors[i])
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _stepsList(List<HCFSolutionStep> steps, bool valid) {
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
          subtitle: steps[idx].detail != null
              ? Text(
            steps[idx].detail!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.purple.shade800,
              fontWeight: FontWeight.w600,
            ),
          )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HCF Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter numbers separated by commas or spaces (e.g. 24, 36, 60):",
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
                        hintText: "e.g. 24, 36, 60",
                      ),
                      onSubmitted: (_) => _calculate(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _calculate,
                    child: const Text("Calculate HCF"),
                  )
                ],
              ),
              const SizedBox(height: 18),
              if (_result != null && _result!.valid)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Prime Factorization:", style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    _factorizationTable(_result!.factorizationRows, _result!.commonFactors),
                    const SizedBox(height: 14),
                    Text("HCF Result:",
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      "${_result!.hcf}",
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