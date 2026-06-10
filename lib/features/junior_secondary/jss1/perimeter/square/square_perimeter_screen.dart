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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter of a Square')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _sideController, onChanged: _onSideChanged, decoration: const InputDecoration(labelText: "Enter Length (l)")),
            TextField(controller: _perimeterController, onChanged: _onPerimeterChanged, decoration: const InputDecoration(labelText: "Enter Perimeter (P)")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _solve, child: const Text("Solve")),
            if (_result != null && _result!.valid) ...[
              const SizedBox(height: 20),
              // Final Answer
              Card(color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(20), child: Center(child: Math.tex(_result!.finalAnswerLaTeX, textStyle: TextStyle(fontSize: 28, color: Colors.green.shade800, fontWeight: FontWeight.bold))))),
              // Workings
              const SizedBox(height: 20),
              Text("Workings:", style: theme.textTheme.titleMedium),
              _buildWorkingsCard(_result!.steps, theme),
              // Breakdown
              const SizedBox(height: 20),
              _buildStepsList(_result!.steps, theme),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingsCard(List<GeometrySolutionStep> steps, ThemeData theme) {
    return Card(
      color: Colors.deepPurple.shade50,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: steps.map((s) => Center(child: Padding(padding: const EdgeInsets.all(4), child: Math.tex(s.workingLaTeX, textStyle: TextStyle(fontSize: 18, color: Colors.deepPurple.shade900))))).toList(),
        ),
      ),
    );
  }

  Widget _buildStepsList(List<GeometrySolutionStep> steps, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, i) => ListTile(leading: CircleAvatar(child: Text('${i+1}')), title: Text(steps[i].explanation), subtitle: Math.tex(steps[i].workingLaTeX)),
    );
  }
}