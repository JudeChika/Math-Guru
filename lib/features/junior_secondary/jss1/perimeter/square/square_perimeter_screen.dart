// lib/features/junior_secondary/jss1/geometry/perimeter/square/square_perimeter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'square_perimeter_solver.dart';
import 'square_perimeter_models.dart';

class SquarePerimeterScreen extends StatefulWidget {
  const SquarePerimeterScreen({super.key});

  @override
  State<SquarePerimeterScreen> createState() => _SquarePerimeterScreenState();
}

class _SquarePerimeterScreenState extends State<SquarePerimeterScreen> {
  final TextEditingController _sideController = TextEditingController();
  final TextEditingController _perimeterController = TextEditingController();
  GeometryResult? _result;

  void _onSideChanged(String value) {
    if (value.isNotEmpty && _perimeterController.text.isNotEmpty) {
      _perimeterController.clear();
    }
  }

  void _onPerimeterChanged(String value) {
    if (value.isNotEmpty && _sideController.text.isNotEmpty) {
      _sideController.clear();
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    if (_sideController.text.trim().isNotEmpty) {
      setState(() => _result = SquarePerimeterSolver.solveForPerimeter(_sideController.text.trim()));
    } else if (_perimeterController.text.trim().isNotEmpty) {
      setState(() => _result = SquarePerimeterSolver.solveForSide(_perimeterController.text.trim()));
    }
  }

  @override
  void dispose() {
    _sideController.dispose();
    _perimeterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter of a Square')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _sideController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onSideChanged,
              decoration: const InputDecoration(labelText: "Enter Length (l)", hintText: "e.g. 5"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _perimeterController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onPerimeterChanged,
              decoration: const InputDecoration(labelText: "Enter Perimeter (P)", hintText: "e.g. 20"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _solve, child: const Text("Solve")),
            ),
            const SizedBox(height: 24),
            if (_result != null && _result!.valid) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Math.tex(_result!.finalAnswerLaTeX, textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins')),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: _result!.steps.map((s) => Center(child: Padding(padding: const EdgeInsets.all(4), child: Math.tex(s.workingLaTeX, textStyle: TextStyle(fontSize: 18, color: Colors.deepPurple.shade900))))).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((entry) {
          int idx = entry.key;
          var step = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${idx + 1}')),
              title: Text(step.explanation, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              subtitle: Math.tex(step.workingLaTeX),
            ),
          );
        }),
      ],
    );
  }
}