import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'parallelogram_perimeter_solver.dart';
import 'parallelogram_perimeter_models.dart';

class ParallelogramPerimeterScreen extends StatefulWidget {
  const ParallelogramPerimeterScreen({super.key});

  @override
  State<ParallelogramPerimeterScreen> createState() => _ParallelogramPerimeterScreenState();
}

class _ParallelogramPerimeterScreenState extends State<ParallelogramPerimeterScreen> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  GeometryResult? _result;

  void _onChanged(_) => setState(() {});

  void _solve() {
    FocusScope.of(context).unfocus();
    double? a = double.tryParse(_aController.text);
    double? b = double.tryParse(_bController.text);
    double? p = double.tryParse(_pController.text);

    setState(() {
      _result = null; // Force refresh
      if (a != null && b != null) {
        _result = ParallelogramPerimeterSolver.solveForPerimeter(a, b);
      } else if (p != null && b != null) {
        _result = ParallelogramPerimeterSolver.solveForSideA(p, b);
      } else if (p != null && a != null) {
        _result = ParallelogramPerimeterSolver.solveForSideB(p, a);
      }
    });
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _pController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Locking logic: enable field ONLY IF fewer than 2 fields are filled OR if this field itself is already filled.
    int filledFields = [
      _aController.text,
      _bController.text,
      _pController.text
    ].where((s) => s.isNotEmpty).length;

    bool canFill = filledFields < 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter of a Parallelogram')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _aController, onChanged: _onChanged, enabled: canFill || _aController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Adjacent Side (a)")),
            const SizedBox(height: 16),
            TextField(controller: _bController, onChanged: _onChanged, enabled: canFill || _bController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Adjacent Side (b)")),
            const SizedBox(height: 16),
            TextField(controller: _pController, onChanged: _onChanged, enabled: canFill || _pController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Perimeter (P)")),
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
              child: Center(child: Math.tex(_result!.finalAnswerLaTeX, textStyle: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))
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
              child: Math.tex(e.value.workingLaTeX),
            ),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }
}