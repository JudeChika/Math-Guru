// lib/features/junior_secondary/jss1/geometry/perimeter/triangle/triangle_perimeter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'triangle_perimeter_solver.dart';
import 'triangle_perimeter_models.dart';

class TrianglePerimeterScreen extends StatefulWidget {
  const TrianglePerimeterScreen({super.key});

  @override
  State<TrianglePerimeterScreen> createState() => _TrianglePerimeterScreenState();
}

class _TrianglePerimeterScreenState extends State<TrianglePerimeterScreen> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  GeometryResult? _result;

  void _onChanged(_) => setState(() {});

  void _solve() {
    FocusScope.of(context).unfocus();
    double? a = double.tryParse(_aController.text);
    double? b = double.tryParse(_bController.text);
    double? c = double.tryParse(_cController.text);
    double? p = double.tryParse(_pController.text);

    // FIX: Force UI refresh by clearing the previous result first
    setState(() {
      _result = null;
      if (a != null && b != null && c != null) {
        _result = TrianglePerimeterSolver.solveForPerimeter(a, b, c);
      } else if (p != null && b != null && c != null) {
        _result = TrianglePerimeterSolver.solveForSideA(p, b, c);
      } else if (p != null && a != null && c != null) {
        _result = TrianglePerimeterSolver.solveForSideB(p, a, c);
      } else if (p != null && a != null && b != null) {
        _result = TrianglePerimeterSolver.solveForSideC(p, a, b);
      }
    });
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    _pController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Locking logic: enable field ONLY IF fewer than 3 fields are filled OR if this field itself is already filled.
    int filledFields = [_aController.text, _bController.text, _cController.text, _pController.text]
        .where((s) => s.isNotEmpty).length;
    bool canFill = filledFields < 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter of a Triangle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // FIX: Stretches children horizontally
          children: [
            TextField(controller: _aController, onChanged: _onChanged, enabled: canFill || _aController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Side a")),
            const SizedBox(height: 16),
            TextField(controller: _bController, onChanged: _onChanged, enabled: canFill || _bController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Side b")),
            const SizedBox(height: 16),
            TextField(controller: _cController, onChanged: _onChanged, enabled: canFill || _cController.text.isNotEmpty, decoration: const InputDecoration(labelText: "Enter Side c")),
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
          child: Padding(padding: const EdgeInsets.all(24), child: Center(child: Math.tex(_result!.finalAnswerLaTeX, textStyle: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))),
        ),
        const SizedBox(height: 24),
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero, // FIX: Allows the card to fill horizontal width
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // FIX: Centers the math equations
              children: _result!.steps.map((s) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: Math.tex(s.workingLaTeX, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontFamily: 'Poppins')))).toList(),
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
              subtitle: Math.tex(e.value.workingLaTeX)
          ),
        )),
      ],
    );
  }
}