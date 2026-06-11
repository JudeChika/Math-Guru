import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'circle_perimeter_solver.dart';
import 'circle_perimeter_models.dart';

class CirclePerimeterScreen extends StatefulWidget {
  const CirclePerimeterScreen({super.key});

  @override
  State<CirclePerimeterScreen> createState() => _CirclePerimeterScreenState();
}

class _CirclePerimeterScreenState extends State<CirclePerimeterScreen> {
  final TextEditingController _rController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  GeometryResult? _result;

  void _onChanged(_) => setState(() {});

  void _solve() {
    FocusScope.of(context).unfocus();
    double? r = double.tryParse(_rController.text);
    double? c = double.tryParse(_cController.text);

    setState(() {
      _result = null; // Force UI refresh
      if (r != null) {
        _result = CirclePerimeterSolver.solveForCircumference(r);
      } else if (c != null) {
        _result = CirclePerimeterSolver.solveForRadius(c);
      }
    });
  }

  @override
  void dispose() {
    _rController.dispose();
    _cController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mutual exclusion locking logic
    bool isRDisabled = _cController.text.isNotEmpty;
    bool isCDisabled = _rController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter (Circumference) of a Circle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _rController,
                onChanged: _onChanged,
                enabled: !isRDisabled,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Enter Radius (r)")
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _cController,
                onChanged: _onChanged,
                enabled: !isCDisabled,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Enter Circumference (C)")
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _solve, child: const Text("Solve")),
            if (_result != null) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                  child: Math.tex(
                      _result!.finalAnswerLaTeX,
                      textStyle: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
                  )
              )
          ),
        ),
        const SizedBox(height: 24),
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _result!.steps.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(s.workingLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontFamily: 'Poppins')),
                ),
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text('${e.key+1}')),
            title: Text(e.value.explanation, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Math.tex(e.value.workingLaTeX),
              ),
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }
}