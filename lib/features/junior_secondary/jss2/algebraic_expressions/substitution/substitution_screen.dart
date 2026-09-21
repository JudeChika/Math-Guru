import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'substitution_logic.dart';
import 'substitution_models.dart';

class SubstitutionScreen extends StatefulWidget {
  const SubstitutionScreen({super.key});

  @override
  State<SubstitutionScreen> createState() => _SubstitutionScreenState();
}

class _SubstitutionScreenState extends State<SubstitutionScreen> {
  final TextEditingController _exprController = TextEditingController();

  final List<TextEditingController> _varNameControllers = [TextEditingController(text: 'x')];
  final List<TextEditingController> _varValueControllers = [TextEditingController()];

  SubstitutionResult? _result;

  @override
  void dispose() {
    _exprController.dispose();
    for (var c in _varNameControllers) { c.dispose(); }
    for (var c in _varValueControllers) { c.dispose(); }
    super.dispose();
  }

  void _addVariable() {
    setState(() {
      _varNameControllers.add(TextEditingController());
      _varValueControllers.add(TextEditingController());
    });
  }

  void _removeVariable(int index) {
    setState(() {
      _varNameControllers[index].dispose();
      _varValueControllers[index].dispose();
      _varNameControllers.removeAt(index);
      _varValueControllers.removeAt(index);
    });
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    Map<String, String> variables = {};
    for (int i = 0; i < _varNameControllers.length; i++) {
      String name = _varNameControllers[i].text.trim();
      String val = _varValueControllers[i].text.trim();
      if (name.isNotEmpty && val.isNotEmpty) {
        variables[name] = val;
      }
    }

    setState(() {
      _result = SubstitutionLogic.solve(_exprController.text, variables);
    });
  }

  Widget _buildInputSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
          child: const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(child: Text("Enter your algebraic expression and define the values for your variables. Use brackets for complex division e.g., (3x)/(2y).", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _exprController,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: "Algebraic Expression",
            hintText: "e.g. 3x^2y - 2x + 5",
            prefixIcon: const Icon(Icons.functions, color: Colors.deepPurple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        const Text("Variables & Values:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
        const SizedBox(height: 12),

        ...List.generate(_varNameControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _varNameControllers[index],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "Variable",
                      hintText: "e.g. x",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("=", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _varValueControllers[index],
                    keyboardType: TextInputType.text, // Changed to text to allow fraction inputs like "1/2"
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "Value",
                      hintText: "e.g. -2 or 1/2",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (_varNameControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeVariable(index),
                  )
              ],
            ),
          );
        }),

        TextButton.icon(
          onPressed: _addVariable,
          icon: const Icon(Icons.add, color: Colors.deepPurple),
          label: const Text("Add Another Variable", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        )
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
                for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          i == 0 ? _result!.workingsLaTeX[i] : "= ${_result!.workingsLaTeX[i]}",
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
              child: const Icon(Icons.school, size: 20),
            ),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(e.value.mathLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                )
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
      appBar: AppBar(title: const Text('Substitution of Variables')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(theme),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _solve,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text("Substitute & Evaluate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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