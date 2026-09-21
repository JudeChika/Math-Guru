import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'directed_algebra_logic.dart';
import 'directed_algebra_models.dart';

class DirectedAlgebraScreen extends StatefulWidget {
  const DirectedAlgebraScreen({super.key});

  @override
  State<DirectedAlgebraScreen> createState() => _DirectedAlgebraScreenState();
}

class _DirectedAlgebraScreenState extends State<DirectedAlgebraScreen> {
  final TextEditingController _term1Controller = TextEditingController();
  final TextEditingController _term2Controller = TextEditingController();

  bool _isMultiply = true;
  DirectedAlgebraResult? _result;

  @override
  void dispose() {
    _term1Controller.dispose();
    _term2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    if (_term1Controller.text.trim().isEmpty || _term2Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both algebraic terms.')));
      return;
    }

    setState(() {
      if (_isMultiply) {
        _result = DirectedAlgebraLogic.multiply(_term1Controller.text, _term2Controller.text);
      } else {
        _result = DirectedAlgebraLogic.divide(_term1Controller.text, _term2Controller.text);
      }
    });
  }

  Widget _buildInputSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
          child: const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(child: Text("Enter your algebraic terms. Include signs (e.g., -5, 2y, -33x^2) and select Multiply or Divide.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: _term1Controller,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Term 1",
                  hintText: "e.g. -33x^2",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<bool>(
                  value: _isMultiply,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                  alignment: Alignment.center,
                  items: const [
                    DropdownMenuItem(value: true, child: Text("×", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                    DropdownMenuItem(value: false, child: Text("÷", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                  ],
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        _isMultiply = value;
                        _result = null;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: TextField(
                controller: _term2Controller,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Term 2",
                  hintText: "e.g. -3x",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _calculate(),
              ),
            ),
          ],
        ),
      ],
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
        const Text("Final Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Math.tex(
                    _result!.finalAnswerLaTeX,
                    textStyle: const TextStyle(fontSize: 42, color: Colors.green, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _result!.workings.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          (i == 0 || _result!.workings[i].contains('\\frac') && i == 1)
                              ? _result!.workings[i]
                              : "= ${_result!.workings[i]}",
                          textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple)
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
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
              child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                if (e.value.mathLaTeX != null) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(e.value.mathLaTeX!, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
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
      appBar: AppBar(title: const Text('Directed Algebraic Terms')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(theme),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.functions, color: Colors.white),
              label: const Text("Simplify Expression", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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