// lib/features/junior_secondary/jss1/geometry/perimeter/rectangle/rectangle_perimeter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'rectangle_perimeter_solver.dart';
import 'rectangle_perimeter_models.dart';

class RectanglePerimeterScreen extends StatefulWidget {
  const RectanglePerimeterScreen({super.key});

  @override
  State<RectanglePerimeterScreen> createState() => _RectanglePerimeterScreenState();
}

class _RectanglePerimeterScreenState extends State<RectanglePerimeterScreen> {
  final TextEditingController _lController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  GeometryResult? _result;

  // Mutual exclusion: lock fields based on user input
  void _onChanged(_) => setState(() {});

  void _solve() {
    FocusScope.of(context).unfocus();
    double? l = double.tryParse(_lController.text);
    double? b = double.tryParse(_bController.text);
    double? p = double.tryParse(_pController.text);

    setState(() {
      if (l != null && b != null) {
        _result = RectanglePerimeterSolver.solveForPerimeter(l, b);
      } else if (p != null && b != null) {
        _result = RectanglePerimeterSolver.solveForLength(p, b);
      } else if (p != null && l != null) {
        _result = RectanglePerimeterSolver.solveForBreadth(p, l);
      }
    });
  }

  @override
  void dispose() {
    _lController.dispose();
    _bController.dispose();
    _pController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // UI Logic for locking fields
    bool isLDisabled = _pController.text.isNotEmpty && _bController.text.isNotEmpty;
    bool isBDisabled = _pController.text.isNotEmpty && _lController.text.isNotEmpty;
    bool isPDisabled = _lController.text.isNotEmpty && _bController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter of a Rectangle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _lController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onChanged,
              enabled: !isLDisabled,
              decoration: const InputDecoration(labelText: "Enter Length (l)"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onChanged,
              enabled: !isBDisabled,
              decoration: const InputDecoration(labelText: "Enter Breadth (b)"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onChanged,
              enabled: !isPDisabled,
              decoration: const InputDecoration(labelText: "Enter Perimeter (P)"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _solve, child: const Text("Solve")),
            ),
            if (_result != null) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Math.tex(_result!.finalAnswerLaTeX, textStyle: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            ),
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
              children: _result!.steps.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Center(
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
            subtitle: Math.tex(e.value.workingLaTeX),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }
}