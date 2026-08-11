import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'factors_logic.dart';
import 'factors_models.dart';

class FactorsScreen extends StatefulWidget {
  const FactorsScreen({super.key});

  @override
  State<FactorsScreen> createState() => _FactorsScreenState();
}

class _FactorsScreenState extends State<FactorsScreen> {
  final _inputController = TextEditingController();

  List<int>? _rangeNumbers;
  List<SingleNumberFactorsResult>? _results;
  String? _errorMessage;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleInput() {
    FocusScope.of(context).unfocus();
    final text = _inputController.text;
    if (text.isEmpty) return;

    setState(() {
      _errorMessage = null;
      _rangeNumbers = null;
      _results = null;
    });

    final parsed = FactorsLogic.parseInput(text);

    if (parsed.error != null) {
      setState(() => _errorMessage = parsed.error);
      return;
    }

    if (parsed.isRange) {
      // Show the grid for ranges
      setState(() {
        _rangeNumbers = parsed.numbers;
      });
    } else {
      // Process multiple specific numbers
      setState(() {
        _results = parsed.numbers.map((n) => FactorsLogic.calculateForNumber(n)).toList();
      });
    }
  }

  void _calculateFromRange(int number) {
    setState(() {
      _results = [FactorsLogic.calculateForNumber(number)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Factors & Prime Factors'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter numbers separated by spaces/commas (e.g. 12, 24) or a range (e.g. 10-30):",
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
                        hintText: "e.g. 12, 24 or 10-30",
                      ),
                      onSubmitted: (_) => _handleInput(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _handleInput,
                    child: const Text("Generate"),
                  )
                ],
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

              if (_rangeNumbers != null) ...[
                const SizedBox(height: 24),
                Text("Select a number from your range:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  color: Colors.deepPurple.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: _rangeNumbers!.map((n) => ActionChip(
                          label: Text(n.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.deepPurple.shade200),
                          onPressed: () => _calculateFromRange(n),
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              ],

              if (_results != null) ...[
                const SizedBox(height: 32),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _results!.length,
                  separatorBuilder: (context, index) => const Divider(height: 60, thickness: 2, color: Colors.deepPurple),
                  itemBuilder: (context, index) {
                    final result = _results![index];
                    return _buildSingleResultView(theme, result);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleResultView(ThemeData theme, SingleNumberFactorsResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Analysis for Number: ${result.number}",
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),

        _buildInfoCard(theme, "First 10 Multiples", '${result.multiples.join(', ')} ...'),
        _buildInfoCard(theme, "All Factors", result.factors.join(', ')),
        _buildInfoCard(theme, "Prime Factors", result.distinctPrimes.isEmpty ? "None" : result.distinctPrimes.join(', ')),

        Card(
          elevation: 0.5,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
          child: ListTile(
            title: Text("Index Form", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  "${result.number} = ${result.indexFormLaTeX}",
                  textStyle: const TextStyle(fontSize: 22, color: Colors.black87),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: result.steps.length,
          itemBuilder: (context, idx) {
            final step = result.steps[idx];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  foregroundColor: Colors.deepPurple,
                  child: Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(step.description, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      step.workingLaTeX,
                      textStyle: const TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Helper widget to build the summary cards cleanly
  Widget _buildInfoCard(ThemeData theme, String title, String content) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: ListTile(
        title: Text(title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}