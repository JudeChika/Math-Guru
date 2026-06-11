import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'polygon_perimeter_solver.dart';
import 'polygon_perimeter_models.dart';

class PolygonPerimeterScreen extends StatefulWidget {
  const PolygonPerimeterScreen({super.key});

  @override
  State<PolygonPerimeterScreen> createState() => _PolygonPerimeterScreenState();
}

class _PolygonPerimeterScreenState extends State<PolygonPerimeterScreen> {
  // Initialize with 3 sides (a triangle is the simplest polygon)
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  GeometryResult? _result;

  void _addSide() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeSide(int index) {
    setState(() {
      if (_controllers.length > 3) {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      }
    });
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    List<double> sides = [];
    bool allValid = true;

    for (var controller in _controllers) {
      if (controller.text.trim().isEmpty) {
        allValid = false;
        break;
      }
      double? val = double.tryParse(controller.text.trim());
      if (val != null) {
        sides.add(val);
      } else {
        allValid = false;
        break;
      }
    }

    setState(() {
      _result = null; // Force refresh
      if (!allValid) {
        _result = GeometryResult(
            steps: [],
            finalAnswerLaTeX: "",
            valid: false,
            errorMessage: "Please enter a valid number for all visible sides."
        );
      } else {
        _result = PolygonPerimeterSolver.solveForPerimeter(sides);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter of a Polygon')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "A polygon can have many sides. Add or remove fields as needed to match your shape.",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            // Dynamic List of Fields
            ..._controllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Enter Length (l${index + 1})",
                        ),
                      ),
                    ),
                    if (_controllers.length > 3)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeSide(index),
                        tooltip: "Remove this side",
                      ),
                  ],
                ),
              );
            }),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addSide,
                icon: const Icon(Icons.add, color: Colors.deepPurple),
                label: const Text("Add another side", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ),
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
    if (!_result!.valid) {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_result!.errorMessage ?? "Error", style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _result!.steps.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // To prevent overflow for very large polygons
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