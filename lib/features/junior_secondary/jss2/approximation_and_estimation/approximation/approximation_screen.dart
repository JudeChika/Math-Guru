import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'approximation_logic.dart';
import 'approximation_models.dart';

class ApproximationScreen extends StatefulWidget {
  const ApproximationScreen({super.key});

  @override
  State<ApproximationScreen> createState() => _ApproximationScreenState();
}

class _ApproximationScreenState extends State<ApproximationScreen> {
  int _selectedMode = 0; // 0: d.p., 1: s.f., 2: Whole Number, 3: False Accuracy

  final _numberController = TextEditingController();
  final _paramController = TextEditingController(text: "2");

  ApproximationResult? _result;

  @override
  void dispose() {
    _numberController.dispose();
    _paramController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    setState(() => _result = null);

    if (_numberController.text.isEmpty) {
      _showError("Please enter a number to round.");
      return;
    }

    if ((_selectedMode == 0 || _selectedMode == 1) && _paramController.text.isEmpty) {
      _showError("Please enter the degree of accuracy.");
      return;
    }

    final res = ApproximationLogic.solve(
        _numberController.text,
        _selectedMode,
        _paramController.text
    );

    setState(() => _result = res);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildInputForms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedMode == 3)
          _buildHelperBanner("Real world numbers shouldn't be overly exact. Enter a highly detailed number (e.g. 162.83) and we will estimate it reasonably!")
        else if (_selectedMode == 2)
          _buildHelperBanner("We will round the number to the nearest whole integer, removing any decimals.")
        else
          _buildHelperBanner("Select your target accuracy to see the step-by-step extraction of Target and Decider digits!"),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _numberController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: "Number to Round",
                  hintText: "e.g. 19711170 or 124.25",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calculate, color: Colors.deepPurple),
                ),
                onSubmitted: (_) => _calculate(),
              ),
            ),

            // Only show accuracy parameter field for d.p. and s.f.
            if (_selectedMode == 0 || _selectedMode == 1) ...[
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _paramController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _selectedMode == 0 ? "Places (d.p.)" : "Figures (s.f.)",
                    hintText: "e.g. 2",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (_) => _calculate(),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildHelperBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text(
            _result!.errorMessage ?? "Error",
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                    _result!.finalAnswer,
                    style: const TextStyle(fontSize: 42, color: Colors.green, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text("Step-by-Step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.deepPurple,
              child: Text('${e.key+1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4)),
                if (e.value.mathLaTeX != null) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                        e.value.mathLaTeX!,
                        textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)
                    ),
                  )
                ]
              ],
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Approximation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedMode,
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("d.p.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("s.f.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Whole No.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  3: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("False Acc.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                },
                onValueChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMode = value;
                      _result = null;
                    });
                  }
                },
                thumbColor: Colors.deepPurple.shade100,
                backgroundColor: Colors.grey.shade200,
              ),
            ),

            const SizedBox(height: 24),
            _buildInputForms(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined, color: Colors.white),
              label: const Text("Round & Explain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            _buildResultView(theme),
          ],
        ),
      ),
    );
  }
}